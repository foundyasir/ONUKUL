// [ADD] stats
window.fetchStats = async function () {
  return jsonFetch('api.php?action=stats');
};
// donors & admin can call these
window.donateMoney = async function (amount) {
  return jsonFetch('api.php?action=donations', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ mode:'money', amount: Number(amount) })
  });
};
window.donateItem = async function ({ item_name, unit, quantity }) {
  return jsonFetch('api.php?action=donations', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ mode:'item', item_name, unit, quantity: Number(quantity) })
  });
};

// [ADD lines 1–22] Robust JSON fetch
async function jsonFetch(url, opts) {
  const res = await fetch(url, opts);
  const text = await res.text();
  let data;
  try { data = text ? JSON.parse(text) : {}; }
  catch (e) {
    // Strip HTML tags from PHP error pages so the toast is readable
    const plain = text.replace(/<[^>]+>/g, '').trim();
    throw new Error(plain || 'Server returned non-JSON');
  }
  if (!res.ok || data?.error) {
    throw new Error(data?.error || 'Request failed');
  }
  return data;
}

// app.js (globals; non-module)
window.getSession = async function () {
  return jsonFetch('api.php?action=session');
};

window.login = async function (nid, password) {
  return jsonFetch('api.php?action=login', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ nid, password })
  });
};


window.logout = async function () {
  await jsonFetch('api.php?action=logout', { method:'POST' });

};

window.addUser = async function (payload) {
  return jsonFetch('api.php?action=users', {
  method:'POST', headers:{'Content-Type':'application/json'},
  body: JSON.stringify(payload)
});
};
window.fetchUsers = async function () {
  const r = await fetch('api.php?action=users');
  const d = await r.json(); if (!r.ok) throw new Error(d.error||'Users failed'); return d;
};

window.fetchInventory = async function () {
  const r = await fetch('api.php?action=inventory');
  const d = await r.json(); if (!r.ok) throw new Error(d.error||'Inventory failed'); return d;
};

window.addInventory = async function (item_name, unit, quantity) {
  const r = await fetch('api.php?action=inventory', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ item_name, unit, quantity })
  });
  const d = await r.json(); if (!r.ok) throw new Error(d.error||'Add inventory failed'); return d;
};

window.fetchPackages = async function () {
  const r = await fetch('api.php?action=packages');
  const d = await r.json(); if (!r.ok) throw new Error(d.error||'Packages failed'); return d;
};

window.createPackage = async function (name, description, items) {
  const r = await fetch('api.php?action=packages', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ name, description, items })
  });
  const d = await r.json(); if (!r.ok) throw new Error(d.error||'Create package failed'); return d;
};

window.fetchAidRequests = async function () {
  const r = await fetch('api.php?action=aidRequests');
  const d = await r.json(); if (!r.ok) throw new Error(d.error||'Aid requests failed'); return d;
};

// accepts either {mode:'package', package_id, quantity, reason}
// or {mode:'item', item_name, unit, quantity, reason}
window.createAidRequest = async function (payload) {
  const url = 'api.php?action=aidRequests';
  const headers = { 'Content-Type': 'application/json' };

  // Try with op:'create' (most backends expect this)
  try {
    return await jsonFetch(url, {
      method: 'POST', headers,
      body: JSON.stringify(Object.assign({ op: 'create' }, payload))
    });
  } catch (e) {
    // If your PHP says "Invalid action", try other common variants, then no-op
    if (/invalid action/i.test(e.message || '')) {
      try {
        // some codebases use op:'request'
        return await jsonFetch(url, {
          method: 'POST', headers,
          body: JSON.stringify(Object.assign({ op: 'request' }, payload))
        });
      } catch (e2) {
        // final fallback: send without any "op"
        return await jsonFetch(url, {
          method: 'POST', headers,
          body: JSON.stringify(payload)
        });
      }
    }
    throw e;
  }
};




window.getLocations = async function(){
  return jsonFetch('api.php?action=locations');
};
window.setMyLocation = async function({lat=null,lng=null,district=null}={}){
  return jsonFetch('api.php?action=locations', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ lat, lng, district })
  });
};

window.approveAidRequest = async function (request_id) {
  const r = await fetch('api.php?action=aidRequests', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ op:'approve', request_id })
  });
  const d = await r.json(); if (!r.ok) throw new Error(d.error||'Approve failed'); return d;
};

window.rejectAidRequest = async function (request_id) {
  const r = await fetch('api.php?action=aidRequests', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ op:'reject', request_id })
  });
  const d = await r.json(); if (!r.ok) throw new Error(d.error||'Reject failed'); return d;
};

window.fetchDonations = async function () {
  const r = await fetch('api.php?action=donations');
  const d = await r.json(); if (!r.ok) throw new Error(d.error||'Donations failed'); return d;
};

// [REPLACE] donation helpers
window.donateMoney = async function (amount) {
  return jsonFetch('api.php?action=donations', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ mode:'money', amount: Number(amount) })
  });
};
window.donateItem = async function ({ item_name, unit, quantity }) {
  return jsonFetch('api.php?action=donations', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ mode:'item', item_name, unit, quantity: Number(quantity) })
  });
};
// Stories API
window.fetchStories = async function(){
  return jsonFetch('api.php?action=stories');
};
window.createStory = async function(formData){
  const res = await fetch('api.php?action=stories', { method:'POST', body: formData });
  const d = await res.json(); if(!res.ok || d?.error) throw new Error(d?.error||'Failed'); return d;
};
window.deleteStory = async function(id){
  return jsonFetch('api.php?action=stories', {
    method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ op:'delete', id })
  });
};

