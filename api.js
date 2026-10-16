// Talks to Supabase through its REST API. No library needed.
// The public key can only ADD rows, and READ the public idea list
// (idea text and counts, never names or emails). See the schema files.
(function () {
  var cfg = window.IC_CONFIG || {};

  function configured() {
    return /^(https:\/\/.+|http:\/\/(127\.0\.0\.1|localhost)(:\d+)?)/.test(cfg.supabaseUrl || '') &&
      !!cfg.supabaseAnonKey && cfg.supabaseAnonKey.indexOf('PASTE_') !== 0;
  }

  function base() { return cfg.supabaseUrl.replace(/\/$/, '') + '/rest/v1/'; }

  async function insert(table, rows) {
    if (!configured()) throw new Error('not-configured');
    var res = await fetch(base() + table, {
      method: 'POST',
      headers: {
        apikey: cfg.supabaseAnonKey,
        'Content-Type': 'application/json',
        Prefer: 'return=minimal'
      },
      body: JSON.stringify(rows)
    });
    if (!res.ok) {
      var detail = '';
      try { detail = await res.text(); } catch (e) {}
      throw new Error('save-failed ' + res.status + ' ' + detail);
    }
  }

  async function select(pathAndQuery) {
    if (!configured()) throw new Error('not-configured');
    var res = await fetch(base() + pathAndQuery, { headers: { apikey: cfg.supabaseAnonKey } });
    if (!res.ok) throw new Error('load-failed ' + res.status);
    return res.json();
  }

  function looksLikeEmail(s) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s);
  }

  // Small per-device memory: your name/email, and which ideas you liked or joined.
  // Browser storage can be unavailable (private mode), so every access is guarded.
  function remember(key, value) {
    try { localStorage.setItem('ic_' + key, JSON.stringify(value)); } catch (e) {}
  }
  function recall(key, fallback) {
    try { var v = localStorage.getItem('ic_' + key); return v ? JSON.parse(v) : fallback; } catch (e) { return fallback; }
  }

  window.IC = { configured: configured, insert: insert, select: select, looksLikeEmail: looksLikeEmail,
    remember: remember, recall: recall };
})();
