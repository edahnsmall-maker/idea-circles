// Saves rows to Supabase through its REST API. No library needed.
// The anon/publishable key only has permission to INSERT (see schema.sql).
(function () {
  var cfg = window.IC_CONFIG || {};

  function configured() {
    return /^(https:\/\/.+|http:\/\/(127\.0\.0\.1|localhost)(:\d+)?)/.test(cfg.supabaseUrl || '') &&
      !!cfg.supabaseAnonKey && cfg.supabaseAnonKey.indexOf('PASTE_') !== 0;
  }

  async function insert(table, rows) {
    if (!configured()) throw new Error('not-configured');
    var res = await fetch(cfg.supabaseUrl.replace(/\/$/, '') + '/rest/v1/' + table, {
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

  function looksLikeEmail(s) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s);
  }

  window.IC = { configured: configured, insert: insert, looksLikeEmail: looksLikeEmail };
})();
