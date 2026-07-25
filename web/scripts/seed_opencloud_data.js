const fs = require('fs');
const path = require('path');

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
const DATASTORE_NAME = "COBLOX_DataStore_LGBOS_v11";

console.log("=========================================");
console.log("COBLOX Open Cloud DataStore Synchronizer");
console.log("Universe ID:", UNIVERSE_ID);
console.log("Target DataStore:", DATASTORE_NAME);
console.log("=========================================");

const configData = {
  Version: "v11.0",
  LastSyncedUTC: new Date().toISOString(),
  Monetization: {
    VIPPassId: 1923436403,
    SuperLuckPassId: 1924362417,
    Plus50SlotsPassId: 1924818406,
    AutoHatchPassId: 1925292405,
    GemsSmallPackId: 3611126819,
    GemsLargePackId: 3611126995,
    CoinsSmallPackId: 3611126655,
    CoinsLargePackId: 3611126895
  },
  AvatarCatalogCount: 10,
  Status: "Active"
};

async function syncGlobalConfig() {
  const entryKey = "COBLOX_GlobalConfig_v11";
  const url = `https://apis.roblox.com/datastores/v1/universes/${UNIVERSE_ID}/standard-datastores/datastore/entries/entry?datastoreName=${DATASTORE_NAME}&entryKey=${entryKey}`;

  try {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "x-api-key": API_KEY,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(configData)
    });

    console.log(`[GlobalConfig Sync] Status: ${res.status} ${res.statusText}`);
    if (res.ok) {
      console.log("[GlobalConfig Sync] ✅ SUCCESS! Open Cloud DataStore Entry Synced!");
    } else {
      console.log("[GlobalConfig Sync] ⚠️ Error Response:", await res.text());
    }
  } catch (e) {
    console.error("[GlobalConfig Sync] Exception:", e.message);
  }
}

syncGlobalConfig();
