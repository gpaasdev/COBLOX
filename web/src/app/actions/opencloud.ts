"use server";

import { revalidatePath } from "next/cache";

const UNIVERSE_ID = process.env.ROBLOX_UNIVERSE_ID;
const API_KEY = process.env.ROBLOX_OPEN_CLOUD_API_KEY;
const DATASTORE_NAME = "COBLOX_DataStore_LGBOS_v11";

async function getRobloxUserInfo(userId: string) {
  try {
    const res = await fetch(`https://users.roblox.com/v1/users/${userId}`);
    if (res.ok) {
      const data = await res.json();
      return {
        username: data.name || `User_${userId}`,
        displayName: data.displayName || data.name || `User_${userId}`
      };
    }
  } catch (e) {
    console.error("Failed to fetch Roblox user info:", e);
  }
  return { username: `User_${userId}`, displayName: `User_${userId}` };
}

export async function getDatastoreEntries(query: string = "") {
  if (!UNIVERSE_ID || !API_KEY) {
    throw new Error("ROBLOX_UNIVERSE_ID or ROBLOX_OPEN_CLOUD_API_KEY is missing in environment variables.");
  }

  if (query && query.trim() !== "") {
    try {
      const profileKey = `COBLOX_LGBOS_v11_${query}`;
      const res = await fetch(`https://apis.roblox.com/datastores/v1/universes/${UNIVERSE_ID}/standard-datastores/datastore/entries/entry?datastoreName=${DATASTORE_NAME}&entryKey=${profileKey}`, {
        headers: { "x-api-key": API_KEY }
      });
      if (res.ok) {
        const rawData = await res.json();
        const playerData = rawData.Data || {};
        const wallet = playerData.Wallet || {};
        const userInfo = await getRobloxUserInfo(query);
        
        return [{
          id: query,
          username: userInfo.username,
          displayName: userInfo.displayName,
          avatarUrl: `https://tr.rbxcdn.com/30DAY-AvatarHeadshot-${query}-Png/150/150/AvatarHeadshot/Png`,
          gems: wallet.Gems || 0,
          coins: wallet.Coins || 0,
          auraEnergy: wallet.AuraEnergy || 0,
          chronoSparks: wallet.ChronoSparks || 0,
          status: "Active",
          rawData: rawData
        }];
      }
      return [];
    } catch (e) {
      console.error(e);
      return [];
    }
  }

  const listRes = await fetch(`https://apis.roblox.com/datastores/v1/universes/${UNIVERSE_ID}/standard-datastores/datastore/entries?datastoreName=${DATASTORE_NAME}&limit=10`, {
    headers: { "x-api-key": API_KEY }
  });
  
  if (!listRes.ok) {
    throw new Error("Failed to fetch DataStore keys from Roblox Open Cloud.");
  }

  const listData = await listRes.json();
  const keys = listData.keys || [];

  const results = [];
  for (const keyObj of keys) {
    const entryRes = await fetch(`https://apis.roblox.com/datastores/v1/universes/${UNIVERSE_ID}/standard-datastores/datastore/entries/entry?datastoreName=${DATASTORE_NAME}&entryKey=${keyObj.key}`, {
      headers: { "x-api-key": API_KEY }
    });
    if (entryRes.ok) {
      const rawData = await entryRes.json();
      const playerData = rawData.Data || {};
      const wallet = playerData.Wallet || {};
      
      const userId = keyObj.key.replace("COBLOX_LGBOS_v11_", "");
      const userInfo = await getRobloxUserInfo(userId);

      results.push({
        id: userId,
        username: userInfo.username,
        displayName: userInfo.displayName,
        avatarUrl: `https://tr.rbxcdn.com/30DAY-AvatarHeadshot-${userId}-Png/150/150/AvatarHeadshot/Png`,
        gems: wallet.Gems || 0,
        coins: wallet.Coins || 0,
        auraEnergy: wallet.AuraEnergy || 0,
        chronoSparks: wallet.ChronoSparks || 0,
        status: "Active",
        rawData: rawData
      });
    }
  }

  return results;
}

export async function updatePlayerData(id: string, updates: { gems?: number; coins?: number; auraEnergy?: number; chronoSparks?: number }) {
  if (!UNIVERSE_ID || !API_KEY) {
    throw new Error("ROBLOX_UNIVERSE_ID or ROBLOX_OPEN_CLOUD_API_KEY is missing in environment variables.");
  }

  const profileKey = `COBLOX_LGBOS_v11_${id}`;
  const entryRes = await fetch(`https://apis.roblox.com/datastores/v1/universes/${UNIVERSE_ID}/standard-datastores/datastore/entries/entry?datastoreName=${DATASTORE_NAME}&entryKey=${profileKey}`, {
    headers: { "x-api-key": API_KEY }
  });

  if (!entryRes.ok) throw new Error("Failed to fetch current player data before update.");
  const currentData = await entryRes.json();

  if (currentData.Data && currentData.Data.Wallet) {
    if (updates.gems !== undefined) currentData.Data.Wallet.Gems = updates.gems;
    if (updates.coins !== undefined) currentData.Data.Wallet.Coins = updates.coins;
    if (updates.auraEnergy !== undefined) currentData.Data.Wallet.AuraEnergy = updates.auraEnergy;
    if (updates.chronoSparks !== undefined) currentData.Data.Wallet.ChronoSparks = updates.chronoSparks;
  }

  const updateRes = await fetch(`https://apis.roblox.com/datastores/v1/universes/${UNIVERSE_ID}/standard-datastores/datastore/entries/entry?datastoreName=${DATASTORE_NAME}&entryKey=${profileKey}`, {
    method: "POST",
    headers: {
      "x-api-key": API_KEY,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(currentData)
  });

  if (!updateRes.ok) {
    const errText = await updateRes.text();
    throw new Error(`Failed to update DataStore: ${errText}`);
  }

  revalidatePath("/dashboard/datastore");
  return { success: true };
}

export async function sendLiveOpsMessage(topic: string, message: string) {
  if (!UNIVERSE_ID || !API_KEY) {
    throw new Error("ROBLOX_UNIVERSE_ID or ROBLOX_API_KEY is missing in environment variables.");
  }

  const res = await fetch(`https://apis.roblox.com/messaging/v1/universes/${UNIVERSE_ID}/topics/${topic}`, {
    method: "POST",
    headers: {
      "x-api-key": API_KEY,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ message: message })
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`Failed to send LiveOps message: ${errText}`);
  }

  return { success: true };
}
