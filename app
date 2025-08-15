<!doctype html>
<html lang="nb">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
  <meta name="theme-color" content="#0b64f0" />
  <title>14-dagers rotasjon – mobil FIX</title>
  <style>
    :root { --fg:#0b0b0b; --bg:#f7f7f8; --muted:#6b7280; --card:#ffffff; --line:#e5e7eb; --accent:#2563eb; --pad: clamp(12px, 3.5vw, 20px); }
    @media (prefers-color-scheme: dark) { :root { --fg:#e8e8ea; --bg:#0b0b0f; --muted:#9aa0a6; --card:#121218; --line:#2a2a2f; --accent:#60a5fa; } }
    * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
    html, body { height: 100%; }
    body { margin:0; font:16px/1.45 system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial; color:var(--fg); background: radial-gradient(80rem 80rem at 10% -20%, #3b82f620, transparent 60%), var(--bg); min-height:100dvh; }
    .wrap { max-width:860px; margin:0 auto; padding:var(--pad); }
    .card { background:var(--card); border:1px solid var(--line); border-radius:16px; padding:clamp(14px,3vw,24px); box-shadow:0 10px 25px rgba(0,0,0,.06); }
    h1 { margin:4px 0 8px; font-size: clamp(1.2rem,1.1rem + 1.4vw,1.9rem); }
    p.lead { margin:0 0 12px; color:var(--muted); }
    .grid{ display:grid; gap:12px; grid-template-columns:1fr; } @media(min-width:760px){ .grid.two{ grid-template-columns:1fr 1fr; } } @media(min-width:900px){ .grid.three{ grid-template-columns:1fr 1fr 1fr; } }
    label{ font-weight:600; display:block; margin:8px 0 6px; }
    input[type="datetime-local"], input[type="number"]{ width:100%; padding:14px 12px; border:1px solid var(--line); border-radius:12px; background:transparent; color:var(--fg); font-size:16px; }
    input:focus{ outline:2px solid color-mix(in oklab, var(--accent) 55%, transparent); outline-offset:2px; }
    .switch{ display:flex; align-items:center; gap:10px; margin-top:4px; }
    .hint{ color:var(--muted); font-size:.9rem; }
    .big{ font-size: clamp(1.8rem,1.4rem + 4vw,3rem); font-weight:800; letter-spacing:-.5px; margin:.4rem 0 .2rem; }
    .sub{ color:var(--muted); margin-bottom:.8rem; }
    .bar{ height:20px; width:100%; background:linear-gradient(0deg,#0000,#0000), #e5e7eb; border-radius:999px; position:relative; overflow:hidden; border:1px solid var(--line); }
    .bar>.fill{ position:absolute; inset:0 auto 0 0; width:0%; background:linear-gradient(90deg, var(--accent), #22c55e); transition: width .25s ease; }
    .kv{ display:grid; grid-template-columns:1fr; gap:10px; margin-top:12px; } @media(min-width:760px){ .kv{ grid-template-columns:1fr 1fr; } }
    .kv div{ border:1px dashed var(--line); border-radius:12px; padding:12px; }
    .kv b{ display:block; font-size:1.05rem; }
    .muted{ color:var(--muted); }
    .section{ margin-top:16px; border-top:1px solid var(--line); padding-top:14px; }
    .mono{ font-variant-numeric: tabular-nums; }
    .btns{ position:sticky; bottom:0; display:flex; gap:10px; flex-wrap:nowrap; margin-top:14px; padding-top:10px; background:linear-gradient(180deg,#0000, color-mix(in oklab, var(--card) 95%, transparent)); }
    button,.ghost{ border:1px solid var(--line); background:var(--card); color:var(--fg); padding:14px 14px; border-radius:12px; cursor:pointer; font-weight:600; flex:1 1 auto; touch-action:manipulation; }
    button.primary{ background:var(--accent); color:#fff; border-color:transparent; } .ghost{text-decoration:none; text-align:center;}
    .toggle{ width:100%; margin-top:6px; }
    button:active{ transform:translateY(1px); }
    .panel{ display:none; margin-top:10px; padding:12px; border:1px solid var(--line); border-radius:12px; background:linear-gradient(180deg,#0000,#0001); }
    .panel.show{ display:block; }
    .foot{ margin:16px 0 2px; color:var(--muted); font-size:.9rem; }
    .ok{ color:#16a34a; font-weight:700; }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <h1>14-dagers rotasjon</h1>
      <p class="lead">Mobil FIX. Hvis denne teksten viser <span id="jsok" class="ok">✅ JS kjører</span>, fungerer skriptet.</p>

      <div class="grid two" role="group">
        <div>
          <label for="start">Start av rotasjonen</label>
          <input id="start" type="datetime-local" />
          <div class="hint">Tolkes som lokal tid. Lagres lokalt.</div>
        </div>
        <div>
          <label for="useNow" class="switch">
            <input id="useNow" type="checkbox" checked />
            Bruk nåtid (live)
          </label>
          <input id="when" type="datetime-local" aria-label="Valgt tidspunkt" disabled />
          <div class="hint">Fjern haken for å simulere en annen dato/tid.</div>
        </div>
      </div>

      <div aria-live="polite" aria-atomic="true">
        <div class="big" id="percentDoneBig">– % gjennomført</div>
        <div class="sub"><span id="statusText" class="muted">Velg starttidspunkt.</span></div>
      </div>

      <div class="bar" role="progressbar" aria-label="Prosent gjennomført" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
        <div class="fill" id="barFill"></div>
      </div>

      <div class="kv">
        <div><b id="timeLeft">–</b><span class="muted">Tid igjen</span></div>
        <div><b id="timeGone">–</b><span class="muted">Tid som har gått</span></div>
      </div>

      <div class="kv">
        <div><b id="currentEnd">–</b><span class="muted">Gjeldende slutt (14 d eller 14 d + forlengelse)</span></div>
        <div><b id="percentLeftSmall">–</b><span class="muted">Prosent igjen</span></div>
      </div>

      <div class="section">
        <button class="primary toggle" id="toggleExt">Legg til forlengelse</button>
        <div class="panel" id="extPanel" aria-live="polite">
          <div class="grid three">
            <div>
              <label for="newEndInput">Ny slutt (dato og tid)</label>
              <input id="newEndInput" type="datetime-local" />
              <div class="hint">Hvis tomt/for tidlig: fortsatt 14 dager.</div>
            </div>
            <div>
              <label for="rateDay">Lønn 07:00–19:00 (kr/time)</label>
              <input id="rateDay" type="number" inputmode="decimal" min="0" step="1" placeholder="f.eks. 350" />
            </div>
            <div>
              <label for="rateNight">Lønn utenfor 07:00–19:00 (kr/time)</label>
              <input id="rateNight" type="number" inputmode="decimal" min="0" step="1" placeholder="f.eks. 450" />
            </div>
          </div>

          <div class="kv">
            <div><b id="ordinaryEnd">–</b><span class="muted">Ordinær slutt (14 dager)</span></div>
            <div><b id="extInfo">–</b><span class="muted">Forlengelse (varighet)</span></div>
          </div>

          <div class="kv">
            <div><b id="ovtSplit">–</b><span class="muted">Timer i 07–19 / utenfor</span></div>
            <div>
              <b id="earningsNowLabel" class="mono">–</b>
              <span class="muted">Opptjent så langt</span>
              <div class="bar" role="progressbar" aria-label="Opptjent så langt" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
                <div class="fill" id="earningsFill"></div>
              </div>
            </div>
          </div>

          <div class="kv">
            <div><b id="ovtWindow">–</b><span class="muted">Overtidsperiode</span></div>
            <div><b id="earningsTotal" class="mono">–</b><span class="muted">Estimert total lønn (hele forlengelsen)</span></div>
          </div>
        </div>
      </div>

      <div class="btns">
        <button class="primary" id="save">Lagre</button>
        <button id="reset">Nullstill</button>
        <a class="ghost" href="#" id="shareLink">Del lenke</a>
      </div>

      <div class="foot">Fremdrift = <code>(nå − start) / (slutt − start) × 100</code>.</div>
    </div>
  </div>

  <script>
    // Elements
    const startEl = document.getElementById('start');
    const useNowEl = document.getElementById('useNow');
    const whenEl = document.getElementById('when');
    const percentDoneBigEl = document.getElementById('percentDoneBig');
    const percentLeftSmallEl = document.getElementById('percentLeftSmall');
    const statusTextEl = document.getElementById('statusText');
    const barFillEl = document.getElementById('barFill');
    const timeLeftEl = document.getElementById('timeLeft');
    const timeGoneEl = document.getElementById('timeGone');
    const currentEndEl = document.getElementById('currentEnd');
    const toggleExtBtn = document.getElementById('toggleExt');
    const extPanel = document.getElementById('extPanel');
    const newEndInputEl = document.getElementById('newEndInput');
    const rateDayEl = document.getElementById('rateDay');
    const rateNightEl = document.getElementById('rateNight');
    const ordinaryEndEl = document.getElementById('ordinaryEnd');
    const extInfoEl = document.getElementById('extInfo');
    const ovtSplitEl = document.getElementById('ovtSplit');
    const ovtWindowEl = document.getElementById('ovtWindow');
    const earningsTotalEl = document.getElementById('earningsTotal');
    const earningsFillEl = document.getElementById('earningsFill');
    const earningsNowLabelEl = document.getElementById('earningsNowLabel');
    document.getElementById('jsok').textContent = '✅ JS kjører';

    // Const/format
    const TOTAL_MS_14 = 14 * 24 * 60 * 60 * 1000;
    const NOK = new Intl.NumberFormat('nb-NO', { style: 'currency', currency: 'NOK', maximumFractionDigits: 0 });
    const NFpct = new Intl.NumberFormat('nb-NO', { minimumFractionDigits: 1, maximumFractionDigits: 1 });
    function fmtPct(v){ return NFpct.format(v) + " %"; }
    function fmtDT(d){ if(!d || isNaN(d)) return "–"; return new Intl.DateTimeFormat('nb-NO',{weekday:'short', day:'2-digit', month:'short', year:'numeric', hour:'2-digit', minute:'2-digit'}).format(d); }
    function fmtDur(ms){ if(ms < 0) ms = 0; const s = Math.floor(ms/1000), d=Math.floor(s/86400), h=Math.floor((s%86400)/3600), m=Math.floor((s%3600)/60); const parts=[]; if(d) parts.push(d+" d"); parts.push(h+" t"); parts.push(m+" min"); return parts.join(" "); }
    // Robust parser: aksepterer med/uten sekunder og millisek.
    function parseLocalDateTime(value){
      if(!value) return new Date(NaN);
      // YYYY-MM-DDTHH:MM[:SS[.sss]]
      const m = value.match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{3}))?)?$/);
      if(!m) return new Date(value); // fallback
      const Y=+m[1], Mo=+m[2]-1, D=+m[3], H=+m[4], Mi=+m[5], S=+(m[6]||0), MS=+(m[7]||0);
      return new Date(Y, Mo, D, H, Mi, S, MS);
    }
    function toLocalDatetimeValue(d){ if(!d || isNaN(d)) return ""; const pad=n=>String(n).padStart(2,"0"); return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`; }
    function getNow(){ return useNowEl.checked ? new Date() : parseLocalDateTime(whenEl.value); }

    // 07–19 helpers
    function startOfDay(d){ const x=new Date(d); x.setHours(0,0,0,0); return x; }
    function addDays(d,n){ const x=new Date(d); x.setDate(x.getDate()+n); return x; }
    function overlapMs(a,b,c,d){ const s=Math.max(a.getTime(),c.getTime()); const e=Math.min(b.getTime(),d.getTime()); return Math.max(0,e-s); }
    function dayWindowMs(periodStart, periodEnd){ if(!(periodStart instanceof Date) || !(periodEnd instanceof Date)) return 0; let inside=0, cursor=startOfDay(periodStart); while(cursor<periodEnd){ const y=new Date(cursor); const day07=new Date(y.getFullYear(),y.getMonth(),y.getDate(),7,0,0,0); const day19=new Date(y.getFullYear(),y.getMonth(),y.getDate(),19,0,0,0); inside += overlapMs(periodStart,periodEnd,day07,day19); cursor = addDays(cursor,1);} return inside; }

    // Storage
    function loadFromStorage(){ try{ const s=localStorage.getItem('rot14_start'); if(s) startEl.value=s; const use=localStorage.getItem('rot14_useNow'); if(use!==null) useNowEl.checked = use==='1'; const w=localStorage.getItem('rot14_when'); if(w) whenEl.value=w; const ext = JSON.parse(localStorage.getItem('rot14_ext3')||'{}'); if(ext.open){ extPanel.classList.add('show'); toggleExtBtn.textContent='Skjul forlengelse'; } if(ext.newEnd) newEndInputEl.value = ext.newEnd; if(ext.rateDay!=null) rateDayEl.value = ext.rateDay; if(ext.rateNight!=null) rateNightEl.value = ext.rateNight; }catch{} }
    function saveToStorage(){ try{ if(startEl.value) localStorage.setItem('rot14_start', startEl.value); localStorage.setItem('rot14_useNow', useNowEl.checked ? '1':'0'); if(whenEl.value) localStorage.setItem('rot14_when', whenEl.value); const ext = { open: extPanel.classList.contains('show'), newEnd: newEndInputEl.value || null, rateDay: rateDayEl.value ? Number(rateDayEl.value) : null, rateNight: rateNightEl.value ? Number(rateNightEl.value) : null }; localStorage.setItem('rot14_ext3', JSON.stringify(ext)); }catch{} }
    function loadFromURL(){ const p=new URLSearchParams(location.search); const s=p.get('start'); const t=p.get('t'); const ne=p.get('ext'); const open=p.get('open'); if(s){ const d=new Date(s); startEl.value = isNaN(d)? s : toLocalDatetimeValue(d); } if(t){ const d=new Date(t); if(!isNaN(d)){ whenEl.value=toLocalDatetimeValue(d); useNowEl.checked=false; whenEl.disabled=false; } } if(ne){ const d=new Date(ne); if(!isNaN(d)){ newEndInputEl.value=toLocalDatetimeValue(d); } } if(open==='1'){ extPanel.classList.add('show'); toggleExtBtn.textContent='Skjul forlengelse'; } }

    function currentEnds(start){ const ordinaryEnd = new Date(start.getTime() + TOTAL_MS_14); const newEndVal = parseLocalDateTime(newEndInputEl.value); const extValid = extPanel.classList.contains('show') && newEndInputEl.value && !isNaN(newEndVal) && newEndVal > ordinaryEnd; const endUsed = extValid ? newEndVal : ordinaryEnd; return { ordinaryEnd, endUsed, extValid, newEndVal }; }

    function update(){
      const start = parseLocalDateTime(startEl.value);
      const now = getNow();
      const validStart = startEl.value && !isNaN(start);

      if(!validStart){
        percentDoneBigEl.textContent="– % gjennomført"; percentLeftSmallEl.textContent="–"; statusTextEl.textContent="Velg starttidspunkt.";
        barFillEl.style.width="0%"; barFillEl.parentElement.setAttribute('aria-valuenow','0');
        timeLeftEl.textContent="–"; timeGoneEl.textContent="–"; currentEndEl.textContent="–";
        ordinaryEndEl.textContent="–"; extInfoEl.textContent="–"; ovtSplitEl.textContent="–"; ovtWindowEl.textContent="–";
        earningsTotalEl.textContent="–"; earningsNowLabelEl.textContent="–"; earningsFillEl.style.width="0%"; earningsFillEl.parentElement.setAttribute('aria-valuenow','0'); return;
      }

      const { ordinaryEnd, endUsed, extValid, newEndVal } = currentEnds(start);

      const totalMs = endUsed - start;
      const elapsed = now - start;
      const pctDone = Math.max(0, Math.min(100, 100 * (elapsed / totalMs)));
      const remaining = Math.max(0, endUsed - now);

      percentDoneBigEl.textContent = fmtPct(pctDone) + " gjennomført";
      percentLeftSmallEl.textContent = fmtPct(100 - pctDone);
      barFillEl.style.width = pctDone + "%"; barFillEl.parentElement.setAttribute('aria-valuenow', String(Math.round(pctDone)));
      timeLeftEl.textContent = fmtDur(remaining); timeGoneEl.textContent = fmtDur(Math.max(0, elapsed));
      currentEndEl.textContent = fmtDT(endUsed);

      let status=""; if(elapsed < 0){ status = `Starter ${fmtDT(start)} – ${fmtDur(-elapsed)} til start.`; } else if(now >= endUsed){ status = `Ferdig (${fmtDT(endUsed)}).`; } else { status = `Gjeldende slutt: ${fmtDT(endUsed)} (${fmtDur(remaining)} igjen).`; } statusTextEl.textContent = status;

      ordinaryEndEl.textContent = fmtDT(ordinaryEnd);

      if(!extValid){
        extInfoEl.textContent = "Ingen forlengelse"; ovtSplitEl.textContent = "–"; ovtWindowEl.textContent = "–";
        earningsTotalEl.textContent = "–"; earningsNowLabelEl.textContent = "–"; earningsFillEl.style.width="0%"; earningsFillEl.parentElement.setAttribute('aria-valuenow','0'); return;
      }

      const otStart = ordinaryEnd; const otEnd = newEndVal; const extMs = otEnd - otStart;
      const dayMs = dayWindowMs(otStart, otEnd); const nightMs = Math.max(0, extMs - dayMs);
      const dayHours = dayMs / 3_600_000; const nightHours = nightMs / 3_600_000;
      const rateDay = Number(rateDayEl.value || 0); const rateNight = Number(rateNightEl.value || 0);
      const earningsTotal = dayHours * rateDay + nightHours * rateNight;

      const nowClampedEnd = now < otStart ? otStart : (now > otEnd ? otEnd : now);
      const liveDayMs = dayWindowMs(otStart, nowClampedEnd);
      const liveNightMs = Math.max(0, (nowClampedEnd - otStart) - liveDayMs);
      const earningsLive = (liveDayMs/3_600_000) * rateDay + (liveNightMs/3_600_000) * rateNight;

      extInfoEl.textContent = fmtDur(extMs);
      ovtSplitEl.textContent = `${dayHours.toFixed(2)} t (07–19) / ${nightHours.toFixed(2)} t (utenfor)`;
      ovtWindowEl.textContent = `${fmtDT(otStart)} → ${fmtDT(otEnd)} (${fmtDur(extMs)})`;
      earningsTotalEl.textContent = isFinite(earningsTotal) ? NOK.format(earningsTotal) : "–";

      const pctEarned = (earningsTotal > 0 && isFinite(earningsLive)) ? Math.max(0, Math.min(100, 100 * (earningsLive / earningsTotal))) : 0;
      earningsNowLabelEl.textContent = `${NOK.format(isFinite(earningsLive) ? earningsLive : 0)} (${fmtPct(pctEarned)})`;
      earningsFillEl.style.width = pctEarned + "%"; earningsFillEl.parentElement.setAttribute('aria-valuenow', String(Math.round(pctEarned)));
    }

    // Events: lytt både på input og change for bedre mobilstøtte
    ['input','change'].forEach(ev => {
      startEl.addEventListener(ev, ()=>{ saveToStorage(); update(); });
      whenEl.addEventListener(ev, ()=>{ saveToStorage(); update(); });
      newEndInputEl.addEventListener(ev, ()=>{ saveToStorage(); update(); });
      rateDayEl.addEventListener(ev, ()=>{ saveToStorage(); update(); });
      rateNightEl.addEventListener(ev, ()=>{ saveToStorage(); update(); });
    });
    useNowEl.addEventListener('change', ()=>{ whenEl.disabled = useNowEl.checked; saveToStorage(); update(); });

    document.addEventListener('visibilitychange', ()=>{ if(document.visibilityState==='visible') update(); });

    const saveBtn = document.getElementById('save'), resetBtn = document.getElementById('reset'), shareLink = document.getElementById('shareLink');
    saveBtn.addEventListener('click', ()=>{ saveToStorage(); saveBtn.textContent="Lagret ✓"; setTimeout(()=> saveBtn.textContent="Lagre", 1200); });
    resetBtn.addEventListener('click', ()=>{ localStorage.clear(); location.reload(); });

    shareLink.addEventListener('click', async (e)=>{
      e.preventDefault();
      const params=new URLSearchParams();
      const d=parseLocalDateTime(startEl.value); if(!isNaN(d)) params.set('start', new Date(d).toISOString());
      if(!useNowEl.checked && whenEl.value){ const t=parseLocalDateTime(whenEl.value); if(!isNaN(t)) params.set('t', new Date(t).toISOString()); }
      if(extPanel.classList.contains('show')) params.set('open','1');
      if(newEndInputEl.value){ const ne=parseLocalDateTime(newEndInputEl.value); if(!isNaN(ne)) params.set('ext', new Date(ne).toISOString()); }
      const url = location.origin + location.pathname + (params.toString()?("?"+params.toString()):"");
      try{ await navigator.clipboard.writeText(url); shareLink.textContent="Kopiert ✓"; setTimeout(()=> shareLink.textContent="Del lenke", 1200); } catch{ prompt("Kopier lenken:", url); }
    });

    toggleExtBtn.addEventListener('click', ()=>{
      extPanel.classList.toggle('show');
      toggleExtBtn.textContent = extPanel.classList.contains('show') ? 'Skjul forlengelse' : 'Legg til forlengelse';
      saveToStorage(); update();
      if(extPanel.classList.contains('show')) extPanel.scrollIntoView({behavior:'smooth', block:'start'});
    });

    // Init
    function loadFromURL(){ const p=new URLSearchParams(location.search); const s=p.get('start'); const t=p.get('t'); const ne=p.get('ext'); const open=p.get('open'); if(s){ const d=new Date(s); startEl.value = isNaN(d)? s : toLocalDatetimeValue(d); } if(t){ const d=new Date(t); if(!isNaN(d)){ whenEl.value=toLocalDatetimeValue(d); useNowEl.checked=false; whenEl.disabled=false; } } if(ne){ const d=new Date(ne); if(!isNaN(d)){ newEndInputEl.value=toLocalDatetimeValue(d); } } if(open==='1'){ extPanel.classList.add('show'); toggleExtBtn.textContent='Skjul forlengelse'; } }
    function init(){ loadFromURL(); try{ const s=localStorage.getItem('rot14_start'); if(s) startEl.value=s; const use=localStorage.getItem('rot14_useNow'); if(use!==null) useNowEl.checked = use==='1'; const w=localStorage.getItem('rot14_when'); if(w) whenEl.value=w; const ext = JSON.parse(localStorage.getItem('rot14_ext3')||'{}'); if(ext.open){ extPanel.classList.add('show'); toggleExtBtn.textContent='Skjul forlengelse'; } if(ext.newEnd) newEndInputEl.value = ext.newEnd; if(ext.rateDay!=null) rateDayEl.value = ext.rateDay; if(ext.rateNight!=null) rateNightEl.value = ext.rateNight; }catch{}; whenEl.disabled = useNowEl.checked; update(); }
    init();
    setInterval(update, 1000);
  </script>
</body>
</html>
