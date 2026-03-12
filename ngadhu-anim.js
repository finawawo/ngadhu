/* NGADHU Microanimation Engine v2.0 */
(function(){
'use strict';

/* ─── CSS injection ─────────────────────────────────────── */
var S=document.createElement('style');
S.textContent=`
/* ── Scroll-reveal base ─────────── */
.rev{opacity:0;transition:opacity .6s cubic-bezier(.22,1,.36,1),transform .6s cubic-bezier(.22,1,.36,1)}
.rev-up   {transform:translateY(32px)}
.rev-left {transform:translateX(-32px)}
.rev-right{transform:translateX(32px)}
.rev-scale{transform:scale(.93)}
.rev-fade {transform:none}
.in{opacity:1!important;transform:none!important}

/* ── Stagger delay helpers ─────── */
.d1{transition-delay:.07s}.d2{transition-delay:.14s}.d3{transition-delay:.21s}
.d4{transition-delay:.28s}.d5{transition-delay:.35s}.d6{transition-delay:.42s}

/* ── Navbar scroll ──────────────── */
.navbar{transition:background .3s,box-shadow .3s,transform .3s}
.nav-scrolled{background:rgba(13,17,23,.98)!important;box-shadow:0 2px 24px rgba(0,0,0,.4)!important}
.nav-up{transform:translateY(-100%)}

/* ── Scroll progress bar ─────────  */
#ng-prog{position:fixed;top:0;left:0;width:0;height:2px;z-index:9999;pointer-events:none;
  background:linear-gradient(90deg,#C0392B,#D4A843);transition:width .12s linear}

/* ── Page-enter ─────────────────── */
@keyframes pg-in{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:none}}
.page-enter{animation:pg-in .45s ease both}

/* ── Float ──────────────────────── */
@keyframes float-y{0%,100%{transform:translateY(0)}50%{transform:translateY(-7px)}}
.anim-float{animation:float-y 3.2s ease-in-out infinite}

/* ── Pulse ring ─────────────────── */
@keyframes pulse-ring{0%{box-shadow:0 0 0 0 rgba(192,57,43,.45)}
  70%{box-shadow:0 0 0 10px rgba(192,57,43,0)}100%{box-shadow:0 0 0 0 rgba(192,57,43,0)}}
.anim-pulse{animation:pulse-ring 2.2s ease-in-out infinite}

/* ── Shimmer text ────────────────── */
@keyframes shimmer-move{0%{background-position:-200% center}100%{background-position:200% center}}
.anim-shimmer{background:linear-gradient(90deg,#E74C3C 0%,#D4A843 40%,#fff 50%,#D4A843 60%,#E74C3C 100%);
  background-size:250% auto;-webkit-background-clip:text;-webkit-text-fill-color:transparent;
  background-clip:text;animation:shimmer-move 4s linear infinite}

/* ── Spin slow ───────────────────── */
@keyframes spin-slow{to{transform:rotate(360deg)}}
.anim-spin{animation:spin-slow 18s linear infinite}

/* ── Counter digit drop ──────────── */
@keyframes dig-in{from{opacity:0;transform:translateY(-10px)}to{opacity:1;transform:none}}
.digit-in{animation:dig-in .4s ease both}

/* ── Card hover glow ─────────────── */
.card-glow{transition:box-shadow .3s,border-color .3s,transform .3s}
.card-glow:hover{box-shadow:0 8px 32px rgba(192,57,43,.18);border-color:rgba(192,57,43,.35)!important;transform:translateY(-4px)}

/* ── Button ripple ───────────────── */
@keyframes ripple{to{transform:scale(4);opacity:0}}
.ripple-effect{position:relative;overflow:hidden}
.ripple-effect .rp-wave{position:absolute;border-radius:50%;
  background:rgba(255,255,255,.25);transform:scale(0);
  animation:ripple .55s ease-out;pointer-events:none}

/* ── Magnetic hover ──────────────── */
.ng-magnetic{transition:transform .3s cubic-bezier(.34,1.56,.64,1)}

/* ── Underline link ──────────────── */
.link-ul{position:relative}
.link-ul::after{content:'';position:absolute;bottom:-1px;left:0;width:0;height:1.5px;
  background:#E74C3C;transition:width .28s ease;border-radius:1px}
.link-ul:hover::after{width:100%}

/* ── Progress bar ────────────────── */
.pb-fill{transition:width 1.1s cubic-bezier(.4,0,.2,1)}

/* ── Tag bounce-in ───────────────── */
@keyframes tag-in{from{opacity:0;transform:scale(.7)}to{opacity:1;transform:scale(1)}}
.tag-anim{animation:tag-in .35s cubic-bezier(.34,1.56,.64,1) both}

/* ── Skeleton shimmer ────────────── */
@keyframes sk{0%{background-position:200% 0}100%{background-position:-200% 0}}
.skeleton{background:linear-gradient(90deg,rgba(255,255,255,.04) 25%,rgba(255,255,255,.09) 50%,rgba(255,255,255,.04) 75%);
  background-size:200% 100%;animation:sk 1.5s ease infinite;border-radius:6px}

/* ── Typewriter cursor ───────────── */
.tw-cursor::after{content:'|';animation:blink .7s step-end infinite;color:#E74C3C}
@keyframes blink{50%{opacity:0}}

/* ── Hero stats count up ─────────── */
@keyframes num-up{from{opacity:0;transform:translateY(20px) scale(.9)}to{opacity:1;transform:none}}
.num-anim{animation:num-up .5s cubic-bezier(.22,1,.36,1) both}

/* ── Nav link hover ──────────────── */
.nav-links a{transition:color .2s,background .2s}
.nav-links a::after{content:'';display:block;height:2px;width:0;background:#E74C3C;
  border-radius:1px;transition:width .25s ease;margin-top:-2px}
.nav-links a:hover::after,.nav-links a.active::after{width:100%}
`;
document.head.appendChild(S);

/* ─── Scroll progress ───────────────────────────────────── */
var prog=document.createElement('div');prog.id='ng-prog';document.body.prepend(prog);
window.addEventListener('scroll',function(){
  var st=window.scrollY,dh=document.documentElement.scrollHeight-window.innerHeight;
  prog.style.width=(dh>0?st/dh*100:0)+'%';
},{passive:true});

/* ─── Navbar scroll behavior ────────────────────────────── */
var nav=document.querySelector('.navbar');
var lastY=0;
if(nav){
  window.addEventListener('scroll',function(){
    var y=window.scrollY;
    if(y>60) nav.classList.add('nav-scrolled'); else nav.classList.remove('nav-scrolled','nav-up');
    if(y>200){
      if(y>lastY+6) nav.classList.add('nav-up'); else if(y<lastY-6) nav.classList.remove('nav-up');
    }
    lastY=y;
  },{passive:true});
}

/* ─── Intersection observer reveal ─────────────────────── */
var io=new IntersectionObserver(function(entries){
  entries.forEach(function(e){
    if(e.isIntersecting){
      var el=e.target;
      var d=parseInt(el.dataset.d||0);
      setTimeout(function(){el.classList.add('in');},d);
      io.unobserve(el);
    }
  });
},{threshold:.12,rootMargin:'0px 0px -30px 0px'});

function observe(){
  document.querySelectorAll('.rev,.rev-up,.rev-left,.rev-right,.rev-scale,.rev-fade').forEach(function(el,i){
    if(!el.dataset.d) el.dataset.d=Math.min(i%8*70,420);
    io.observe(el);
  });
}

/* ─── Counter animation ─────────────────────────────────── */
function countUp(el){
  var raw=el.dataset.target||el.textContent;
  var suffix=el.dataset.suffix||'';
  var prefix=el.dataset.prefix||'';
  var target=parseFloat(raw.replace(/[^0-9.]/g,''))||0;
  var dec=(String(target).split('.')[1]||'').length;
  var dur=1600,start=null;
  function step(ts){
    if(!start)start=ts;
    var p=Math.min((ts-start)/dur,1);
    var e=1-Math.pow(1-p,3);
    var v=target*e;
    el.textContent=prefix+(dec?v.toFixed(dec):Math.floor(v).toLocaleString('id'))+suffix;
    if(p<1)requestAnimationFrame(step);
  }
  requestAnimationFrame(step);
}
var cio=new IntersectionObserver(function(entries){
  entries.forEach(function(e){
    if(e.isIntersecting){countUp(e.target);cio.unobserve(e.target);}
  });
},{threshold:.5});
function observeCounters(){
  document.querySelectorAll('[data-counter]').forEach(function(el){cio.observe(el);});
}

/* ─── Ripple on click ───────────────────────────────────── */
function addRipple(el){
  el.classList.add('ripple-effect');
  el.addEventListener('click',function(e){
    var r=el.getBoundingClientRect();
    var d=Math.max(el.clientWidth,el.clientHeight);
    var sp=document.createElement('span');
    sp.className='rp-wave';
    sp.style.cssText='width:'+d+'px;height:'+d+'px;left:'+(e.clientX-r.left-d/2)+'px;top:'+(e.clientY-r.top-d/2)+'px';
    el.appendChild(sp);
    setTimeout(function(){sp.remove();},600);
  });
}
function initRipple(){
  document.querySelectorAll('.btn-ripple,.btn-submit,.btn-apply-filter,.dl-btn,.cat-tab,.topic-btn,.filter-chip').forEach(addRipple);
}

/* ─── Magnetic buttons ──────────────────────────────────── */
function initMagnetic(){
  document.querySelectorAll('.ng-magnetic,.btn-login').forEach(function(el){
    el.addEventListener('mousemove',function(e){
      var r=el.getBoundingClientRect();
      var dx=(e.clientX-r.left-r.width/2)*.22;
      var dy=(e.clientY-r.top-r.height/2)*.22;
      el.style.transform='translate('+dx+'px,'+dy+'px)';
    });
    el.addEventListener('mouseleave',function(){
      el.style.transition='transform .45s cubic-bezier(.34,1.56,.64,1)';
      el.style.transform='';
      setTimeout(function(){el.style.transition='';},450);
    });
  });
}

/* ─── Tilt cards ────────────────────────────────────────── */
function initTilt(){
  document.querySelectorAll('.ng-tilt').forEach(function(card){
    card.addEventListener('mousemove',function(e){
      var r=card.getBoundingClientRect();
      var rx=((e.clientY-r.top)/r.height-.5)*10;
      var ry=((e.clientX-r.left)/r.width-.5)*-10;
      card.style.transform='perspective(700px) rotateX('+rx+'deg) rotateY('+ry+'deg) translateY(-3px)';
    });
    card.addEventListener('mouseleave',function(){
      card.style.transition='transform .4s ease';
      card.style.transform='';
      setTimeout(function(){card.style.transition='';},400);
    });
  });
}

/* ─── Stagger grid children ─────────────────────────────── */
function initStagger(){
  document.querySelectorAll('[data-stagger]').forEach(function(parent){
    Array.from(parent.children).forEach(function(child,i){
      child.classList.add('rev-up','rev');
      child.dataset.d=i*75;
      io.observe(child);
    });
  });
}

/* ─── Typewriter ────────────────────────────────────────── */
function typewrite(el,text,speed){
  speed=speed||55;el.textContent='';el.classList.add('tw-cursor');
  var i=0;
  var t=setInterval(function(){
    el.textContent+=text[i++];
    if(i>=text.length){clearInterval(t);el.classList.remove('tw-cursor');}
  },speed);
}
function initTypewriter(){
  var twio=new IntersectionObserver(function(entries){
    entries.forEach(function(e){
      if(e.isIntersecting){
        typewrite(e.target,e.target.dataset.tw,parseInt(e.target.dataset.twspeed)||55);
        twio.unobserve(e.target);
      }
    });
  });
  document.querySelectorAll('[data-tw]').forEach(function(el){twio.observe(el);});
}

/* ─── Smooth anchor scroll ──────────────────────────────── */
function initAnchor(){
  document.querySelectorAll('a[href^="#"]').forEach(function(a){
    a.addEventListener('click',function(e){
      var t=document.querySelector(a.getAttribute('href'));
      if(t){e.preventDefault();t.scrollIntoView({behavior:'smooth',block:'start'});}
    });
  });
}

/* ─── Page enter animation ──────────────────────────────── */
function initPageEnter(){
  var main=document.querySelector('main,.page-wrap,.content,.main-layout');
  if(main) main.classList.add('page-enter');
}

/* ─── Stat bar fill animation ───────────────────────────── */
function initStatBars(){
  var sbio=new IntersectionObserver(function(entries){
    entries.forEach(function(e){
      if(e.isIntersecting){
        var fill=e.target.querySelector('.pb-fill,.progress-fill');
        if(fill){
          var w=fill.dataset.w||fill.style.width||'0%';
          fill.style.width='0%';
          setTimeout(function(){fill.style.width=w;},150);
        }
        sbio.unobserve(e.target);
      }
    });
  },{threshold:.4});
  document.querySelectorAll('.progress-bar,.ng-progress').forEach(function(el){sbio.observe(el);});
}

/* ─── Card spotlight hover ──────────────────────────────── */
function initSpotlight(){
  document.querySelectorAll('.spotlight').forEach(function(el){
    el.addEventListener('mousemove',function(e){
      var r=el.getBoundingClientRect();
      el.style.background='radial-gradient(280px circle at '+(e.clientX-r.left)+'px '+(e.clientY-r.top)+'px,rgba(192,57,43,.1) 0%,transparent 70%)';
    });
    el.addEventListener('mouseleave',function(){el.style.background='';});
  });
}

/* ─── Tag stagger ───────────────────────────────────────── */
function initTagAnim(){
  document.querySelectorAll('.card-tags .tag,.header-tags .tag').forEach(function(t,i){
    t.classList.add('tag-anim');
    t.style.animationDelay=(i*60)+'ms';
  });
}

/* ─── Run all ───────────────────────────────────────────── */
function run(){
  observe();
  observeCounters();
  initRipple();
  initMagnetic();
  initTilt();
  initStagger();
  initTypewriter();
  initAnchor();
  initPageEnter();
  initStatBars();
  initSpotlight();
  initTagAnim();
}
if(document.readyState==='loading'){document.addEventListener('DOMContentLoaded',run);}else{run();}

/* ─── Expose ─────────────────────────────────────────────── */
window.NG={countUp:countUp,typewrite:typewrite};
})();
