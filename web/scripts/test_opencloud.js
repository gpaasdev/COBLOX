const fs = require('fs');
const path = require('path');

// Read .env.local manually
const envPath = path.join(__dirname, '../.env.local');
const envText = fs.readFileSync(envPath, 'utf8');
const env = {};
envText.split('\n').forEach(line => {
  const [k, ...v] = line.split('=');
  if (k && v.length) {
    env[k.trim()] = v.join('=').trim().replace(/^"|"$/g, '');
  }
});

const API_KEY = env.ROBLOX_OPEN_CLOUD_API_KEY;
const UNIVERSE_ID = env.ROBLOX_UNIVERSE_ID;

console.log("Testing Roblox Open Cloud API Connection...");
console.log("Universe ID:", UNIVERSE_ID);

async function testDataStore() {
  const url = `https://apis.roblox.com/datastores/v1/universes/${UNIVERSE_ID}/standard-datastores/datastore/entries?datastoreName=COBLOX_DataStore_LGBOS_v11&limit=5`;
  try {
    const res = await fetch(url, { headers: { 'x-api-key': API_KEY } });
    console.log(`[DataStores API] Status: ${res.status} ${res.statusText}`);
    if (res.ok) {
      const data = await res.json();
      console.log("[DataStores API] Keys found:", data.keys ? data.keys.length : 0);
    } else {
      console.log("[DataStores API] Error body:", await res.text());
    }
  } catch (e) {
    console.error("[DataStores API] Exception:", e.message);
  }
}

async function testMessaging() {
  const url = `https://apis.roblox.com/messaging/v1/universes/${UNIVERSE_ID}/topics/LiveOps`;
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        'x-api-key': API_KEY,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ message: "Open Cloud API Verification Check" })
    });
    console.log(`[MessagingService API] Status: ${res.status} ${res.statusText}`);
    if (!res.ok) {
      console.log("[MessagingService API] Error body:", await res.text());
    }
  } catch (e) {
    console.error("[MessagingService API] Exception:", e.message);
  }
}

async function testUserRestrictions() {
  const url = `https://apis.roblox.com/cloud/v2/universes/${UNIVERSE_ID}/user-restrictions/11329819428`;
  try {
    const res = await fetch(url, { headers: { 'x-api-key': API_KEY } });
    console.log(`[UserRestrictions API] Status: ${res.status} ${res.statusText}`);
    if (!res.ok) {
      console.log("[UserRestrictions API] Error body:", await res.text());
    }
  } catch (e) {
    console.error("[UserRestrictions API] Exception:", e.message);
  }
}

async function run() {
  await testDataStore();
  await testMessaging();
  await testUserRestrictions();
}

run();
