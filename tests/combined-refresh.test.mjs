import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

test('open card refreshes every 30 seconds and stops after closing',async()=>{
  const element=()=>({children:[],style:{},append(e){this.children.push(e);},replaceChildren(){this.children=[];},setAttribute(){},remove(){},querySelector(){return null;}});
  const document={readyState:'loading',body:element(),createElement:element,querySelector(){return null;},addEventListener(){}};
  const window={requestAnimationFrame(){},innerWidth:800,innerHeight:800};
  let tick,interval,requests=0;
  const context=vm.createContext({document,window,localStorage:{getItem(){return null;}},AbortSignal,Intl,Date,Number,Math,
    setInterval(fn,ms){tick=fn;interval=ms;return 1;},clearInterval(){tick=null;},
    fetch:async()=>{requests++;return {ok:true,json:async()=>({deepseek:{ok:true,totalBalance:20-requests,currency:'CNY'},subscription:{available:false,windows:[]}})};}});
  vm.runInContext(fs.readFileSync(new URL('../desktop/ui/account-view.js',import.meta.url),'utf8'),context);
  const flush=()=>new Promise(resolve=>setImmediate(resolve));
  window.WhaleAccountView.toggleBubble(document);await flush();
  assert.equal(requests,1);assert.equal(interval,30000);
  tick();await flush();assert.equal(requests,2);
  window.WhaleAccountView.close();assert.equal(tick,null);
  await window.WhaleAccountView.refresh();assert.equal(requests,2);
});
