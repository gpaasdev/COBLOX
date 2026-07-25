#!/usr/bin/env node

/**
 * COBLOX Open Cloud API Command Line Execution Runner
 * Execute any Roblox Open Cloud API v1/v2 action directly from shell.
 * 
 * Usage:
 *   node scripts/opencloud_runner.js <action> [...args]
 * 
 * Examples:
 *   node scripts/opencloud_runner.js user-info 11329819428
 *   node scripts/opencloud_runner.js universe-info
 *   node scripts/opencloud_runner.js place-info
 *   node scripts/opencloud_runner.js datastores-list
 *   node scripts/opencloud_runner.js datastore-read 11329819428
 *   node scripts/opencloud_runner.js user-restriction 11329819428
 *   node scripts/opencloud_runner.js broadcast COBLOX_Broadcast "Hello Sanctum"
 *   node scripts/opencloud_runner.js restart-servers
 *   node scripts/opencloud_runner.js build-and-publish-place
 *   node scripts/opencloud_runner.js upload-asset <filePath> <assetType> <displayName> [description]
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// 1. Resolve environment credentials
let apiKey = process.env.ROBLOX_OPEN_CLOUD_API_KEY;
let universeId = process.env.ROBLOX_UNIVERSE_ID;
let placeId = process.env.ROBLOX_PLACE_ID;
let userId = process.env.ROBLOX_USER_ID;

const envPaths = [
  path.join(__dirname, '../web/.env.local'),
  path.join(__dirname, '../.env')
];

for (const envPath of envPaths) {
  if ((!apiKey || !universeId) && fs.existsSync(envPath)) {
    const envContent = fs.readFileSync(envPath, 'utf8');
    envContent.split('\n').forEach(line => {
      const match = line.match(/^([A-Z0-9_]+)=["']?([^"'\r\n]+)["']?/);
      if (match) {
        if (!process.env[match[1]]) process.env[match[1]] = match[2];
      }
    });
    apiKey = apiKey || process.env.ROBLOX_OPEN_CLOUD_API_KEY;
    universeId = universeId || process.env.ROBLOX_UNIVERSE_ID;
    placeId = placeId || process.env.ROBLOX_PLACE_ID;
    userId = userId || process.env.ROBLOX_USER_ID;
  }
}

const action = process.argv[2];
const arg1 = process.argv[3];
const arg2 = process.argv[4];
const arg3 = process.argv[5];
const arg4 = process.argv[6];

if (!action) {
  console.log("Roblox Open Cloud Runner ready.");
  console.log("Universe ID:", universeId);
  console.log("Place ID:", placeId);
  console.log("API Key present:", Boolean(apiKey));
  process.exit(0);
}

async function pollLRO(operationPath, maxAttempts = 10, intervalMs = 1500) {
  const headers = { "x-api-key": apiKey };
  const normalizedPath = operationPath.startsWith("/") ? operationPath.slice(1) : operationPath;
  const url = normalizedPath.startsWith("http") ? normalizedPath : `https://apis.roblox.com/cloud/v2/${normalizedPath}`;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    console.log(`Polling LRO operation (${attempt}/${maxAttempts})...`);
    const res = await fetch(url, { headers });
    if (!res.ok) {
      throw new Error(`LRO Poll Error (${res.status}): ${await res.text()}`);
    }
    const data = await res.json();
    if (data.done) {
      return data;
    }
    await new Promise(r => setTimeout(r, intervalMs));
  }
  throw new Error("LRO operation timed out.");
}

async function run() {
  const headers = { "x-api-key": apiKey, "Content-Type": "application/json" };

  try {
    switch (action) {
      case "user-info": {
        const targetUser = arg1 || userId;
        const res = await fetch(`https://users.roblox.com/v1/users/${targetUser}`);
        console.log(await res.json());
        break;
      }
      case "universe-info": {
        const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}`, { headers });
        console.log(await res.json());
        break;
      }
      case "place-info": {
        const targetPlace = arg1 || placeId;
        const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}/places/${targetPlace}`, { headers });
        console.log(await res.json());
        break;
      }
      case "datastores-list": {
        const res = await fetch(`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores?limit=20`, { headers });
        console.log(await res.json());
        break;
      }
      case "datastore-read": {
        const targetKey = arg1 ? (arg1.startsWith("COBLOX_") ? arg1 : `COBLOX_LGBOS_v11_${arg1}`) : `COBLOX_LGBOS_v11_${userId}`;
        const res = await fetch(`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry?datastoreName=COBLOX_DataStore_LGBOS_v11&entryKey=${targetKey}`, { headers });
        console.log(await res.json());
        break;
      }
      case "user-restriction": {
        const targetUser = arg1 || userId;
        const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}/user-restrictions/${targetUser}`, { headers });
        console.log(await res.json());
        break;
      }
      case "broadcast": {
        const topic = arg1 || "COBLOX_Broadcast";
        const msg = arg2 || "LiveOps Announcement";
        const res = await fetch(`https://apis.roblox.com/messaging/v1/universes/${universeId}/topics/${encodeURIComponent(topic)}`, {
          method: "POST",
          headers,
          body: JSON.stringify({ message: msg })
        });
        console.log("Broadcast status:", res.status, await res.text());
        break;
      }
      case "restart-servers": {
        const targetPlace = arg1 || placeId;
        const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}/places/${targetPlace}/instances/restart-servers`, {
          method: "POST",
          headers
        });
        console.log("Restart status:", res.status, await res.text());
        break;
      }
      case "build-and-publish-place": {
        const targetPlace = arg1 || placeId;
        const versionType = arg2 || "Saved"; // "Saved" or "Published"
        console.log("Step 1: Compiling Rojo Place binary 'test.rbxl'...");
        execSync('rojo build -o test.rbxl', { cwd: path.join(__dirname, '..'), stdio: 'inherit' });

        const placeFilePath = path.join(__dirname, '../test.rbxl');
        console.log(`Step 2: Reading compiled place binary from '${placeFilePath}'...`);
        const binaryBuffer = fs.readFileSync(placeFilePath);
        console.log(`Binary size: ${binaryBuffer.length} bytes.`);

        console.log(`Step 3: Publishing to Roblox Open Cloud (Universe ${universeId}, Place ${targetPlace}, Type: ${versionType})...`);
        const pubRes = await fetch(`https://apis.roblox.com/universes/v1/${universeId}/places/${targetPlace}/versions?versionType=${versionType}`, {
          method: "POST",
          headers: {
            "x-api-key": apiKey,
            "Content-Type": "application/octet-stream"
          },
          body: binaryBuffer
        });

        console.log("Publish Status:", pubRes.status, pubRes.statusText);
        const pubData = await pubRes.json();
        console.log("Publish Result Payload:", pubData);
        break;
      }
      case "upload-asset": {
        const filePath = arg1;
        const assetType = arg2 || "Model";
        const displayName = arg3 || "COBLOX_Asset";
        const description = arg4 || displayName;

        if (!filePath || !fs.existsSync(filePath)) {
          throw new Error("INVALID_ARGUMENT: Valid file path is required for asset upload.");
        }

        console.log(`Uploading asset '${displayName}' (${assetType}) from '${filePath}'...`);
        const fileBuf = fs.readFileSync(filePath);

        const metadataJson = JSON.stringify({
          assetType,
          displayName,
          description,
          creationContext: {
            creator: {
              userId: String(userId)
            }
          }
        });

        const formData = new FormData();
        formData.append("request", metadataJson);
        const blob = new Blob([fileBuf]);
        formData.append("fileContent", blob, path.basename(filePath));

        const res = await fetch("https://apis.roblox.com/assets/v1/assets", {
          method: "POST",
          headers: { "x-api-key": apiKey },
          body: formData
        });

        console.log("Upload HTTP Status:", res.status, res.statusText);
        const initialRes = await res.json();
        console.log("Initial Response:", initialRes);

        if (initialRes.path && !initialRes.done) {
          const finalRes = await pollLRO(initialRes.path);
          console.log("LRO Polling Final Result:", finalRes);
        }
        break;
      }
      default:
        console.error(`Unknown action: ${action}`);
        process.exit(1);
    }
  } catch (err) {
    console.error("Execution error:", err.message);
  }
}

run();
