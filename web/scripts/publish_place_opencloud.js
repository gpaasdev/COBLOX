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
const PLACE_ID = env.ROBLOX_PLACE_ID;
const RBXL_PATH = path.join(__dirname, '../../COBLOX_v11_Final.rbxl');

console.log("=========================================");
console.log("Roblox Open Cloud Direct Place Publisher");
console.log("Universe ID:", UNIVERSE_ID);
console.log("Place ID:", PLACE_ID);
console.log("Place File:", RBXL_PATH);
console.log("=========================================");

async function publishPlace() {
  if (!fs.existsSync(RBXL_PATH)) {
    console.error("❌ Place file COBLOX_v11_Final.rbxl does not exist!");
    return;
  }

  const fileData = fs.readFileSync(RBXL_PATH);
  console.log(`File size: ${(fileData.length / 1024 / 1024).toFixed(2)} MB`);

  const url = `https://apis.roblox.com/universes/v1/${UNIVERSE_ID}/places/${PLACE_ID}/versions?versionType=Published`;

  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        'x-api-key': API_KEY,
        'Content-Type': 'application/octet-stream'
      },
      body: fileData
    });

    console.log(`[Publish API] Status: ${res.status} ${res.statusText}`);
    const responseText = await res.text();
    console.log("[Publish API] Response:", responseText);

    if (res.ok) {
      console.log("🎉 SUCCESS! Place file published directly to Roblox Cloud via Open Cloud API!");
    }
  } catch (e) {
    console.error("❌ Exception during publish:", e.message);
  }
}

publishPlace();
