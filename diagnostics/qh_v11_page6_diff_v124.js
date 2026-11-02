/* QH-1.2.24: read-only V11/Ultra Pro2 PAGE6 baseline and diff.
   G1/G2/G3 offsets 3,7,11 are merely the row-4 encoded RPM values.
   A changed group is NOT independent proof of the real engine limiter. */
const qhP6Fmt='QH-V11-PAGE6-DIFF-V1',qhP6Prefix='qhV11Page6DiffV1:';
let qhP6ManualBusy=false,qhP6Error='';
function qhP6Bytes(value){
 const x=value instanceof Uint8Array?Array.from(value):value;
 if(!Array.isArray(x)||x.length<43||x.length>256||
    !x.every(n=>Number.isInteger(n)&&n>=0&&n<=255))
   throw Error('PAGE6 V11 không đủ 43 byte hợp lệ.');
 return x.slice();
}
function qhP6Ctx(){
 const a=api(),h=a?.handshake;
 if(!state.ecuConnected||state.ecuPhase!=='live'||a?.profile?.key!=='MODERN_V11')
   throw Error('Cần ECU V11/Ultra Pro2 đang LIVE.');
 if(!h||!String(h.ident||'').trim()||!Number.isFinite(Number(h.ecuId)))
   throw Error('Thiếu định danh ECU từ handshake 0x5A.');
 const bank=Number(state.activeMap);
 if(!Number.isInteger(bank)||bank<1||bank>4)throw Error('MAP No. không hợp lệ.');
 const device=identity();
 return {a,h,bank,device,key:qhP6Prefix+device+':MAP'+bank};
}
function qhP6Load(ctx){
 let json;
 try{json=localStorage.getItem(ctx.key)}catch(e){throw Error('Không đọc được PAGE6 đã lưu: '+e.message);}
 if(!json)return null;
 let saved;
 try{saved=JSON.parse(json)}catch(_e){throw Error('Dữ liệu PAGE6 đã lưu hỏng JSON.');}
 if(saved?.format!==qhP6Fmt||saved.device!==ctx.device||saved.bank!==ctx.bank)
   throw Error('PAGE6 đã lưu không đúng ECU/MAP.');
 qhP6Bytes(saved.baseline);
 if(saved.lastSeen)qhP6Bytes(saved.lastSeen);
 if(saved.lastComparison){qhP6Bytes(saved.lastComparison.before);qhP6Bytes(saved.lastComparison.after);}
 return saved;
}
function qhP6Save(ctx,rec){
 const value=JSON.stringify(rec);
 try{
   localStorage.setItem(ctx.key,value);
   if(localStorage.getItem(ctx.key)!==value)throw Error('đọc lại bộ nhớ không khớp');
 }catch(e){throw Error('Lưu PAGE6 thất bại: '+e.message);}
}
function qhP6Rpm(byte){return Math.round(byte*64/50)*50;}
function qhP6Diff(a,b){
 a=qhP6Bytes(a);b=qhP6Bytes(b);
 const equalLength=a.length===b.length,changes=[];
 for(let i=0;i<Math.max(a.length,b.length);i++)
   if(a[i]!==b[i])changes.push({offset:i,before:a[i]??null,after:b[i]??null});
 const offs=[3,7,11];
 const candidateGroup=equalLength&&changes.length===1&&offs.includes(changes[0].offset)
   ?offs.indexOf(changes[0].offset)+1:null;
 return {equalLength,changes,candidateGroup,physicalLimiterVerified:false};
}
function qhP6Blank(ctx,bytes){
 const raw=qhP6Bytes(bytes);
 return {format:qhP6Fmt,device:ctx.device,bank:ctx.bank,baseline:raw,
   baselineAt:Date.now(),lastSeen:raw.slice(),lastComparison:null,
   physicalLimiterVerified:false};
}
function qhP6Remember(ctx,record,a,b,source){
 record.lastSeen=qhP6Bytes(b);
 record.lastComparison={source,at:Date.now(),before:qhP6Bytes(a),after:qhP6Bytes(b)};
 record.physicalLimiterVerified=false;
 qhP6Save(ctx,record);
}
function qhP6RecordRead(snapshot,bank,session){
 try{
   const ctx=qhP6Ctx();
   if(ctx.bank!==Number(bank)||ctx.h!==session)throw Error('ECU/MAP thay đổi trong khi đọc.');
   const fresh=qhP6Bytes(snapshot?.raw);
   let rec=qhP6Load(ctx);
   if(!rec){rec=qhP6Blank(ctx,fresh);qhP6Save(ctx,rec);}
   else qhP6Remember(ctx,rec,rec.baseline,fresh,'AUTO READ - SO MOC');
   qhP6Error='';qhP6Render();
 }catch(e){qhP6Error='LƯU PAGE6: '+String(e?.message||e);qhP6Render();}
}
function qhP6RecordWrite(before,after,bank,session){
 try{
   const ctx=qhP6Ctx();
   if(ctx.bank!==Number(bank)||ctx.h!==session)throw Error('ECU/MAP đổi trong lúc ghi.');
   const a=qhP6Bytes(before),b=qhP6Bytes(after);
   let rec=qhP6Load(ctx);
   if(!rec)rec=qhP6Blank(ctx,a);
   qhP6Remember(ctx,rec,a,b,'AUTO WRITE - READBACK');
   qhP6Error='';qhP6Render();
 }catch(e){qhP6Error='SO SÁNH SAU GHI: '+String(e?.message||e);qhP6Render();}
}
function qhP6Render(){
 const status=el('qhV11P6Status'),rows=el('qhV11P6GroupRows'),out=el('qhV11P6Diff');
 if(!status||!rows||!out)return;
 let ctx,rec;
 try{ctx=qhP6Ctx();rec=qhP6Load(ctx);}
 catch(e){
   status.textContent=qhP6Error||String(e?.message||e);
   rows.innerHTML='<tr><td colspan="4">Không có ECU V11 LIVE</td></tr>';
   out.textContent='Chưa có dữ liệu để so sánh.';
   return;
 }
 if(!rec){
   status.textContent=qhP6Error||'Chưa lưu PAGE6. Bấm ĐỌC IDLE TỪ ECU hoặc LƯU MỐC PAGE6.';
   rows.innerHTML='<tr><td colspan="4">Chưa có mốc cho ECU/MAP này</td></tr>';
   out.textContent='Chỉ đọc PAGE6, không ghi giới hạn tua.';
   return;
 }
 const original=rec.baseline,current=rec.lastSeen||original,pair=rec.lastComparison;
 const difference=pair?qhP6Diff(pair.before,pair.after):null;
 let msg='Đã lưu mốc MAP '+ctx.bank+' lúc '+new Date(rec.baselineAt).toLocaleString('vi-VN')+'.';
 if(difference){
   if(!difference.equalLength)msg+=' Độ dài PAGE6 khác nhau: không thể kết luận.';
   else if(!difference.changes.length)msg+=' PAGE6 không thay đổi.';
   else if(difference.candidateGroup){
     const d=difference.changes[0];
     msg+=' ỨNG VIÊN G'+difference.candidateGroup+' (byte '+d.offset+'): raw '+d.before+' → '+d.after+
       ', giá trị RPM trên bảng '+qhP6Rpm(d.before)+' → '+qhP6Rpm(d.after)+
       '. CHƯA xác minh tác dụng giới hạn tua thực tế.';
   }else msg+=' Có '+difference.changes.length+' byte thay đổi; không thể kết luận một nhóm.';
 }
 status.textContent=(qhP6Error?qhP6Error+' | ':'')+msg;
 const changed=(difference?.changes||[]).map(c=>c.offset);
 rows.innerHTML=[1,2,3].map(g=>{
   const off=(g-1)*4+3,old=original[off],cur=current[off];
   return '<tr><td>G'+g+'</td><td>'+off+'</td><td>'+
     qhP6Rpm(old)+' (raw '+old+')</td><td style="color:'+
     (changed.includes(off)?'#ffd49a':'#eafff0')+'">'+qhP6Rpm(cur)+' (raw '+cur+')</td></tr>';
 }).join('');
 out.textContent=!pair?'Chưa có lần so sánh thứ hai.':
   'Nguồn: '+pair.source+' | BYTE THAY ĐỔI: '+
   (difference.changes.length?difference.changes.map(d=>{
     const kind=d.offset<12?'G'+(Math.floor(d.offset/4)+1)+' row '+(d.offset%4):
       (d.offset<21?'AUTOSHIFT':(d.offset<43?'ECT MOTOR':'REPLY TAIL'));
     return d.offset+' ['+kind+'] '+d.before+'→'+d.after;
   }).join('; '):'không có')+
   '\nĐây chỉ là chẩn đoán byte; Backfire V11 chưa được mở ghi giới hạn tua.';
}
async function qhP6ManualRead(makeBaseline){
 if(qhP6ManualBusy||busy)return;
 qhP6ManualBusy=true;
 try{
   const ctx=qhP6Ctx(),existing=qhP6Load(ctx);
   if(makeBaseline&&existing){
     if(typeof window.blinkConfirm!=='function')throw Error('Thiếu xác nhận để thay mốc.');
     const ok=await window.blinkConfirm('THAY MỐC PAGE6',
       'Mốc PAGE6 MAP '+ctx.bank+' sẽ bị thay. Chỉ xác nhận khi đã lưu bản gốc.',
       'LƯU MỐC MỚI','HỦY');
     if(!ok)return;
   }
   await transaction(async()=>{
     const now=qhP6Ctx();
     if(now.h!==ctx.h||now.device!==ctx.device||now.bank!==ctx.bank)
       throw Error('ECU/MAP đổi trước khi đọc PAGE6.');
     const sample=await ctx.a.readMaxSpeedFromIdle(ctx.bank,false);
     const after=qhP6Ctx();
     if(after.h!==ctx.h||after.device!==ctx.device||after.bank!==ctx.bank)
       throw Error('ECU/MAP đổi khi đọc PAGE6.');
     const bytes=qhP6Bytes(sample?.raw);
     if(makeBaseline)qhP6Save(ctx,qhP6Blank(ctx,bytes));
     else{
       let rec=qhP6Load(ctx);
       if(!rec){rec=qhP6Blank(ctx,bytes);qhP6Save(ctx,rec);}
       else qhP6Remember(ctx,rec,rec.baseline,bytes,'MANUAL READ - SO MOC');
     }
     qhP6Error='';
     fmtStatus('unknown','PAGE6 V11 đã đọc/so sánh; Blackfire tự động vẫn khóa.');
   });
 }catch(e){qhP6Error='CHẨN ĐOÁN PAGE6: '+String(e?.message||e);}
 finally{qhP6ManualBusy=false;qhP6Render();}
}
function qhP6Export(){
 try{
   const ctx=qhP6Ctx(),rec=qhP6Load(ctx);
   if(!rec)throw Error('Chưa có dữ liệu PAGE6.');
   const pair=rec.lastComparison;
   const report={...rec,comparison:pair?qhP6Diff(pair.before,pair.after):null,
     note:'A changed G1/G2/G3 byte is not proof of physical engine limiter.'};
   const blob=new Blob([JSON.stringify(report,null,2)],{type:'application/json'});
   const url=URL.createObjectURL(blob),link=document.createElement('a');
   link.href=url;link.download='QH_V11_PAGE6_DIFF_MAP'+ctx.bank+'.json';
   document.body.appendChild(link);link.click();link.remove();
   setTimeout(()=>URL.revokeObjectURL(url),1600);
 }catch(e){qhP6Error='XUẤT PAGE6: '+String(e?.message||e);qhP6Render();}
}
el('qhV11P6Capture')?.addEventListener('click',()=>void qhP6ManualRead(true));
el('qhV11P6Compare')?.addEventListener('click',()=>void qhP6ManualRead(false));
el('qhV11P6Export')?.addEventListener('click',qhP6Export);
el('qhBfOpen')?.addEventListener('click',qhP6Render);
window.QHV11Page6Diag={recordRead:qhP6RecordRead,recordWrite:qhP6RecordWrite,
 compare:qhP6Diff,render:qhP6Render};
