require('dotenv').config({ path: '.env.local' });
const UNIVERSE_ID = process.env.ROBLOX_UNIVERSE_ID;
const API_KEY = process.env.ROBLOX_OPEN_CLOUD_API_KEY;
const DATASTORE_NAME = "COBLOX_DataStore_LGBOS_v11";

async function test() {
  console.log(`Universe ID: ${UNIVERSE_ID}`);
  console.log(`API Key Length: ${API_KEY ? API_KEY.length : 0}`);
  
  const url = `https://apis.roblox.com/datastores/v1/universes/${UNIVERSE_ID}/standard-datastores/datastore/entries?datastoreName=${DATASTORE_NAME}&limit=10`;
  console.log(`Fetching: ${url}`);
  
  const res = await fetch(url, {
    headers: { "x-api-key": API_KEY }
  });
  
  if (!res.ok) {
    console.error("FAILED:", res.status, await res.text());
  } else {
    console.log("SUCCESS:", await res.json());
  }
}
test();
