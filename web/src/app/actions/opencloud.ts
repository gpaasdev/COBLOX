"use server";

import { revalidatePath } from "next/cache";

/**
 * Roblox Open Cloud API Server Actions - Production Grade
 * COBLOX Multiverse Sanctum (LGBOS v11.0)
 * 
 * Strict Zero-Trust Security: No mock data, no fallback fallbacks.
 * Direct REST API Integration with Roblox Open Cloud v1 & v2.
 */

function getCredentials() {
  const universeId = process.env.ROBLOX_UNIVERSE_ID;
  const apiKey = process.env.ROBLOX_OPEN_CLOUD_API_KEY;
  const placeId = process.env.ROBLOX_PLACE_ID;

  if (!universeId || !apiKey) {
    throw new Error("CRITICAL_CONFIG_ERROR: ROBLOX_UNIVERSE_ID or ROBLOX_OPEN_CLOUD_API_KEY is missing in environment variables.");
  }
  return { universeId, apiKey, placeId };
}

const DEFAULT_DATASTORE_NAME = "COBLOX_DataStore_LGBOS_v11";

// ==========================================
// 1. PUBLIC & USER INFO APIs
// ==========================================

export async function getRobloxUserInfo(userId: string) {
  if (!userId || userId.trim() === "") {
    throw new Error("INVALID_ARGUMENT: userId is required.");
  }

  const res = await fetch(`https://users.roblox.com/v1/users/${userId}`, {
    headers: { "Accept": "application/json" }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`ROBLOX_USER_API_ERROR (${res.status}): ${errText}`);
  }

  const data = await res.json();
  return {
    id: String(data.id),
    username: data.name,
    displayName: data.displayName,
    created: data.created,
    isBanned: data.isBanned || false,
    externalAppDisplayName: data.externalAppDisplayName || null
  };
}

export async function getGroupRoles(groupId: string) {
  if (!groupId || groupId.trim() === "") {
    throw new Error("INVALID_ARGUMENT: groupId is required.");
  }

  const res = await fetch(`https://groups.roblox.com/v1/groups/${groupId}/roles`);
  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`ROBLOX_GROUPS_API_ERROR (${res.status}): ${errText}`);
  }

  const data = await res.json();
  return data;
}

export async function getUserGroupRank(groupId: string, userId: string) {
  if (!groupId || !userId) {
    throw new Error("INVALID_ARGUMENT: groupId and userId are required.");
  }

  const res = await fetch(`https://groups.roblox.com/v1/users/${userId}/groups/roles`);
  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`ROBLOX_USER_ROLES_API_ERROR (${res.status}): ${errText}`);
  }

  const data = await res.json();
  const groupMembership = (data.data || []).find((g: any) => String(g.group.id) === String(groupId));
  
  if (!groupMembership) {
    return { isMember: false, role: null, rank: 0 };
  }

  return {
    isMember: true,
    role: groupMembership.role.name,
    rank: groupMembership.role.rank
  };
}

// ==========================================
// 2. STANDARD DATASTORES API (Cloud v1)
// ==========================================

export async function listDatastores(prefix: string = "", limit: number = 10, cursor: string = "") {
  const { universeId, apiKey } = getCredentials();
  
  let url = `https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores?limit=${limit}`;
  if (prefix) url += `&prefix=${encodeURIComponent(prefix)}`;
  if (cursor) url += `&cursor=${encodeURIComponent(cursor)}`;

  const res = await fetch(url, {
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`DATASTORE_LIST_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

export async function getDatastoreEntries(query: string = "") {
  const { universeId, apiKey } = getCredentials();

  if (query && query.trim() !== "") {
    const profileKey = query.startsWith("COBLOX_") ? query : `COBLOX_LGBOS_v11_${query}`;
    const res = await fetch(`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry?datastoreName=${DEFAULT_DATASTORE_NAME}&entryKey=${profileKey}`, {
      headers: { "x-api-key": apiKey }
    });

    if (!res.ok) {
      if (res.status === 404) return [];
      const errText = await res.text();
      throw new Error(`DATASTORE_ENTRY_ERROR (${res.status}): ${errText}`);
    }

    const rawData = await res.json();
    const playerData = rawData.Data || {};
    const wallet = playerData.Wallet || {};
    
    const rawUserId = query.replace("COBLOX_LGBOS_v11_", "");
    let userInfo = { username: `User_${rawUserId}`, displayName: `User_${rawUserId}` };
    try {
      if (/^\d+$/.test(rawUserId)) {
        userInfo = await getRobloxUserInfo(rawUserId);
      }
    } catch {
      // Fallback display if Roblox user API fails
    }

    return [{
      id: rawUserId,
      username: userInfo.username,
      displayName: userInfo.displayName,
      avatarUrl: `https://tr.rbxcdn.com/30DAY-AvatarHeadshot-${rawUserId}-Png/150/150/AvatarHeadshot/Png`,
      gems: wallet.Gems || 0,
      coins: wallet.Coins || 0,
      auraEnergy: wallet.AuraEnergy || 0,
      chronoSparks: wallet.ChronoSparks || 0,
      status: "Active",
      rawData: rawData
    }];
  }

  const listRes = await fetch(`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries?datastoreName=${DEFAULT_DATASTORE_NAME}&limit=20`, {
    headers: { "x-api-key": apiKey }
  });

  if (!listRes.ok) {
    const errText = await listRes.text();
    throw new Error(`DATASTORE_KEYS_ERROR (${listRes.status}): ${errText}`);
  }

  const listData = await listRes.json();
  const keys = listData.keys || [];

  const results = [];
  for (const keyObj of keys) {
    const entryRes = await fetch(`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry?datastoreName=${DEFAULT_DATASTORE_NAME}&entryKey=${keyObj.key}`, {
      headers: { "x-api-key": apiKey }
    });

    if (entryRes.ok) {
      const rawData = await entryRes.json();
      const playerData = rawData.Data || {};
      const wallet = playerData.Wallet || {};
      
      const rawUserId = keyObj.key.replace("COBLOX_LGBOS_v11_", "");
      let userInfo = { username: keyObj.key, displayName: keyObj.key };
      try {
        if (/^\d+$/.test(rawUserId)) {
          userInfo = await getRobloxUserInfo(rawUserId);
        }
      } catch {
        // Keep key fallback display
      }

      results.push({
        id: rawUserId,
        username: userInfo.username,
        displayName: userInfo.displayName,
        avatarUrl: /^\d+$/.test(rawUserId) ? `https://tr.rbxcdn.com/30DAY-AvatarHeadshot-${rawUserId}-Png/150/150/AvatarHeadshot/Png` : "",
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

export async function getDatastoreEntry(entryKey: string, datastoreName: string = DEFAULT_DATASTORE_NAME, scope: string = "global") {
  const { universeId, apiKey } = getCredentials();
  
  const res = await fetch(`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry?datastoreName=${encodeURIComponent(datastoreName)}&scope=${encodeURIComponent(scope)}&entryKey=${encodeURIComponent(entryKey)}`, {
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`GET_DATASTORE_ENTRY_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

export async function setDatastoreEntry(entryKey: string, data: any, datastoreName: string = DEFAULT_DATASTORE_NAME, scope: string = "global") {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry?datastoreName=${encodeURIComponent(datastoreName)}&scope=${encodeURIComponent(scope)}&entryKey=${encodeURIComponent(entryKey)}`, {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(data)
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`SET_DATASTORE_ENTRY_ERROR (${res.status}): ${errText}`);
  }

  revalidatePath("/dashboard/datastore");
  return { success: true, message: `Successfully updated entry '${entryKey}' in DataStore '${datastoreName}'` };
}

export async function updatePlayerData(id: string, updates: { gems?: number; coins?: number; auraEnergy?: number; chronoSparks?: number }) {
  const { universeId, apiKey } = getCredentials();

  const profileKey = id.startsWith("COBLOX_") ? id : `COBLOX_LGBOS_v11_${id}`;
  const entryRes = await fetch(`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry?datastoreName=${DEFAULT_DATASTORE_NAME}&entryKey=${profileKey}`, {
    headers: { "x-api-key": apiKey }
  });

  if (!entryRes.ok) {
    const errText = await entryRes.text();
    throw new Error(`FETCH_PLAYER_DATA_BEFORE_UPDATE_ERROR (${entryRes.status}): ${errText}`);
  }

  const currentData = await entryRes.json();
  const isOnline = currentData.MetaData && currentData.MetaData.ActiveSession;

  if (isOnline) {
    // Player is currently online. We cannot mutate DataStore directly because of ProfileStore Session Lock.
    // Delegate to MessagingService so the active server can handle it.
    await sendLiveOpsMessage("Web_DataUpdate", { 
      userId: id.replace("COBLOX_LGBOS_v11_", ""), 
      updates 
    });
    return { success: true, message: `Player is online. Update dispatched via MessagingService for ${id}` };
  }

  if (currentData.Data && currentData.Data.Wallet) {
    if (updates.gems !== undefined) currentData.Data.Wallet.Gems = updates.gems;
    if (updates.coins !== undefined) currentData.Data.Wallet.Coins = updates.coins;
    if (updates.auraEnergy !== undefined) currentData.Data.Wallet.AuraEnergy = updates.auraEnergy;
    if (updates.chronoSparks !== undefined) currentData.Data.Wallet.ChronoSparks = updates.chronoSparks;
  } else {
    throw new Error("INVALID_DATASTORE_STRUCTURE: Profile does not contain a valid Data.Wallet table.");
  }

  const updateRes = await fetch(`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry?datastoreName=${DEFAULT_DATASTORE_NAME}&entryKey=${profileKey}`, {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(currentData)
  });

  if (!updateRes.ok) {
    const errText = await updateRes.text();
    throw new Error(`UPDATE_PLAYER_DATA_ERROR (${updateRes.status}): ${errText}`);
  }

  revalidatePath("/dashboard/datastore");
  return { success: true, message: `Updated player stats offline for ${id}` };
}

export async function deleteDatastoreEntry(entryKey: string, datastoreName: string = DEFAULT_DATASTORE_NAME, scope: string = "global") {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry?datastoreName=${encodeURIComponent(datastoreName)}&scope=${encodeURIComponent(scope)}&entryKey=${encodeURIComponent(entryKey)}`, {
    method: "DELETE",
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`DELETE_DATASTORE_ENTRY_ERROR (${res.status}): ${errText}`);
  }

  revalidatePath("/dashboard/datastore");
  return { success: true, message: `Deleted key '${entryKey}' from DataStore '${datastoreName}'` };
}

export async function getEntryVersions(entryKey: string, datastoreName: string = DEFAULT_DATASTORE_NAME, scope: string = "global", limit: number = 10, cursor: string = "") {
  const { universeId, apiKey } = getCredentials();

  let url = `https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry/versions?datastoreName=${encodeURIComponent(datastoreName)}&scope=${encodeURIComponent(scope)}&entryKey=${encodeURIComponent(entryKey)}&limit=${limit}`;
  if (cursor) url += `&cursor=${encodeURIComponent(cursor)}`;

  const res = await fetch(url, {
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`GET_ENTRY_VERSIONS_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

export async function getEntryVersion(entryKey: string, versionId: string, datastoreName: string = DEFAULT_DATASTORE_NAME, scope: string = "global") {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry/versions/version?datastoreName=${encodeURIComponent(datastoreName)}&scope=${encodeURIComponent(scope)}&entryKey=${encodeURIComponent(entryKey)}&versionId=${encodeURIComponent(versionId)}`, {
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`GET_ENTRY_VERSION_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

// ==========================================
// 3. ORDERED DATASTORES API (Cloud v1)
// ==========================================

export async function getOrderedDataStoreEntries(datastoreName: string, scope: string = "global", orderBy: "Asc" | "Desc" = "Desc", limit: number = 10, cursor: string = "", max?: number, min?: number) {
  const { universeId, apiKey } = getCredentials();

  let url = `https://apis.roblox.com/ordered-datastores/v1/universes/${universeId}/orderedDataStores/${encodeURIComponent(datastoreName)}/scopes/${encodeURIComponent(scope)}/entries?max_page_size=${limit}&order_by=${orderBy}`;
  if (cursor) url += `&page_token=${encodeURIComponent(cursor)}`;
  if (max !== undefined) url += `&filter=value<=${max}`;
  if (min !== undefined) url += `&filter=value>=${min}`;

  const res = await fetch(url, {
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`GET_ORDERED_DATASTORE_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

export async function setOrderedDataStoreEntry(datastoreName: string, entryKey: string, value: number, scope: string = "global") {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/ordered-datastores/v1/universes/${universeId}/orderedDataStores/${encodeURIComponent(datastoreName)}/scopes/${encodeURIComponent(scope)}/entries/${encodeURIComponent(entryKey)}`, {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ value })
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`SET_ORDERED_DATASTORE_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

export async function deleteOrderedDataStoreEntry(datastoreName: string, entryKey: string, scope: string = "global") {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/ordered-datastores/v1/universes/${universeId}/orderedDataStores/${encodeURIComponent(datastoreName)}/scopes/${encodeURIComponent(scope)}/entries/${encodeURIComponent(entryKey)}`, {
    method: "DELETE",
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`DELETE_ORDERED_DATASTORE_ERROR (${res.status}): ${errText}`);
  }

  return { success: true };
}

// ==========================================
// 4. MEMORYSTORES API (Cloud v1)
// ==========================================

export async function readMemoryStoreQueue(queueName: string, count: number = 10) {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/memory-store/v1/universes/${universeId}/queues/${encodeURIComponent(queueName)}/items?count=${count}`, {
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`READ_MEMORYSTORE_QUEUE_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

export async function addMemoryStoreQueueItem(queueName: string, item: any, expirationSeconds: number = 3600, priority: number = 0) {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/memory-store/v1/universes/${universeId}/queues/${encodeURIComponent(queueName)}/items`, {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      item: item,
      ttl: `${expirationSeconds}s`,
      priority: priority
    })
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`ADD_MEMORYSTORE_QUEUE_ITEM_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

export async function discardMemoryStoreQueueItem(queueName: string, id: string) {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/memory-store/v1/universes/${universeId}/queues/${encodeURIComponent(queueName)}/items/${encodeURIComponent(id)}`, {
    method: "DELETE",
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`DISCARD_MEMORYSTORE_QUEUE_ITEM_ERROR (${res.status}): ${errText}`);
  }

  return { success: true };
}

export async function getMemoryStoreSortedMapItem(mapName: string, key: string) {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/memory-store/v1/universes/${universeId}/sorted-maps/${encodeURIComponent(mapName)}/items/${encodeURIComponent(key)}`, {
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`GET_MEMORYSTORE_MAP_ITEM_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

export async function setMemoryStoreSortedMapItem(mapName: string, key: string, value: any, ttlSeconds: number = 3600) {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/memory-store/v1/universes/${universeId}/sorted-maps/${encodeURIComponent(mapName)}/items/${encodeURIComponent(key)}`, {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      value: value,
      ttl: `${ttlSeconds}s`
    })
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`SET_MEMORYSTORE_MAP_ITEM_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

export async function deleteMemoryStoreSortedMapItem(mapName: string, key: string) {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/memory-store/v1/universes/${universeId}/sorted-maps/${encodeURIComponent(mapName)}/items/${encodeURIComponent(key)}`, {
    method: "DELETE",
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`DELETE_MEMORYSTORE_MAP_ITEM_ERROR (${res.status}): ${errText}`);
  }

  return { success: true };
}

// ==========================================
// 5. MESSAGING API (Cloud v1)
// ==========================================

export async function sendLiveOpsMessage(topic: string, message: string | object) {
  const { universeId, apiKey } = getCredentials();

  if (!topic || topic.trim() === "") {
    throw new Error("INVALID_ARGUMENT: Messaging topic is required.");
  }

  const payloadString = typeof message === "string" ? message : JSON.stringify(message);

  const res = await fetch(`https://apis.roblox.com/messaging/v1/universes/${universeId}/topics/${encodeURIComponent(topic)}`, {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ message: payloadString })
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`SEND_LIVEOPS_MESSAGE_ERROR (${res.status}): ${errText}`);
  }

  return { success: true, topic, message: payloadString };
}

// ==========================================
// 6. USER RESTRICTIONS & MODERATION (Cloud v2)
// ==========================================

export async function updateUserRestriction(userId: string, active: boolean, durationSeconds?: number, displayReason?: string, privateReason?: string) {
  const { universeId, apiKey } = getCredentials();

  if (!userId || userId.trim() === "") {
    throw new Error("INVALID_ARGUMENT: userId is required.");
  }

  const body: any = {
    gameJoinRestriction: {
      active: active
    }
  };

  if (active) {
    if (durationSeconds) {
      body.gameJoinRestriction.duration = `${durationSeconds}s`;
    }
    if (displayReason) {
      body.gameJoinRestriction.displayReason = displayReason;
    }
    if (privateReason) {
      body.gameJoinRestriction.privateReason = privateReason;
    }
  }

  const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}/user-restrictions/${userId}`, {
    method: "PATCH",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body)
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`USER_RESTRICTIONS_API_ERROR (${res.status}): ${errText}`);
  }

  return { success: true, userId, active };
}

export async function getUserRestriction(userId: string) {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}/user-restrictions/${userId}`, {
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`GET_USER_RESTRICTION_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

export async function listUserRestrictions(pageSize: number = 10, pageToken: string = "") {
  const { universeId, apiKey } = getCredentials();

  let url = `https://apis.roblox.com/cloud/v2/universes/${universeId}/user-restrictions?maxPageSize=${pageSize}`;
  if (pageToken) url += `&pageToken=${encodeURIComponent(pageToken)}`;

  const res = await fetch(url, {
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`LIST_USER_RESTRICTIONS_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

// ==========================================
// 7. SERVER OPERATIONS & REMOTE EXECUTION (Cloud v2)
// ==========================================

export async function restartPlaceServers(targetPlaceId?: string) {
  const { universeId, apiKey, placeId: envPlaceId } = getCredentials();
  const placeId = targetPlaceId || envPlaceId;

  if (!placeId) {
    throw new Error("INVALID_ARGUMENT: placeId is required either as an argument or in ROBLOX_PLACE_ID.");
  }

  const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}/places/${placeId}/instances/restart-servers`, {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`RESTART_PLACE_SERVERS_ERROR (${res.status}): ${errText}`);
  }

  return { success: true, message: `Successfully initiated server restart for Place ${placeId}` };
}

export async function sendUserPushNotification(userId: string, title: string, content: string) {
  const { universeId, apiKey } = getCredentials();

  if (!userId || !title || !content) {
    throw new Error("INVALID_ARGUMENT: userId, title, and content are required.");
  }

  const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}/user-notifications`, {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      targetUser: `users/${userId}`,
      payload: {
        messageId: `msg_${Date.now()}`,
        title: title,
        content: content
      }
    })
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`SEND_USER_PUSH_NOTIFICATION_ERROR (${res.status}): ${errText}`);
  }

  return { success: true, userId, title };
}

export async function executeRemoteLuau(targetPlaceId: string | undefined, luauScript: string) {
  const { universeId, apiKey, placeId: envPlaceId } = getCredentials();
  const placeId = targetPlaceId || envPlaceId;

  if (!placeId || !luauScript) {
    throw new Error("INVALID_ARGUMENT: placeId and luauScript are required.");
  }

  const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}/places/${placeId}/luau-execution`, {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ script: luauScript })
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`EXECUTE_REMOTE_LUAU_ERROR (${res.status}): ${errText}`);
  }

  return { success: true, result: await res.json() };
}

export async function getLuauExecutionTaskStatus(targetPlaceId: string | undefined, taskId: string) {
  const { universeId, apiKey, placeId: envPlaceId } = getCredentials();
  const placeId = targetPlaceId || envPlaceId;

  if (!placeId || !taskId) {
    throw new Error("INVALID_ARGUMENT: placeId and taskId are required.");
  }

  const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}/places/${placeId}/luau-execution/tasks/${taskId}`, {
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`GET_LUAU_TASK_STATUS_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

// ==========================================
// 8. MATCHMAKING & USER ATTRIBUTES (Cloud v2)
// ==========================================

export async function updatePlayerMatchmakingAttribute(userId: string, skillRating: number, preferredRegion: string = "Global") {
  const { universeId, apiKey } = getCredentials();

  if (!userId) {
    throw new Error("INVALID_ARGUMENT: userId is required.");
  }

  const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}/matchmaking/players/${userId}`, {
    method: "PATCH",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      attributes: {
        skillRating: skillRating,
        preferredRegion: preferredRegion
      }
    })
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`MATCHMAKING_API_ERROR (${res.status}): ${errText}`);
  }

  return { success: true, message: `Updated Matchmaking MMR to ${skillRating} for User ${userId}` };
}

// ==========================================
// 9. UNIVERSE & PLACE MANAGEMENT (Cloud v2)
// ==========================================

export async function getUniverseDetails() {
  const { universeId, apiKey } = getCredentials();

  const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}`, {
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`GET_UNIVERSE_DETAILS_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

export async function getPlaceDetails(targetPlaceId?: string) {
  const { universeId, apiKey, placeId: envPlaceId } = getCredentials();
  const placeId = targetPlaceId || envPlaceId;

  if (!placeId) {
    throw new Error("INVALID_ARGUMENT: placeId is required.");
  }

  const res = await fetch(`https://apis.roblox.com/cloud/v2/universes/${universeId}/places/${placeId}`, {
    headers: { "x-api-key": apiKey }
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`GET_PLACE_DETAILS_ERROR (${res.status}): ${errText}`);
  }

  return await res.json();
}

export async function publishPlaceFile(targetPlaceId: string | undefined, versionType: "Saved" | "Published", fileContentBase64: string) {
  const { universeId, apiKey, placeId: envPlaceId } = getCredentials();
  const placeId = targetPlaceId || envPlaceId;

  if (!placeId || !fileContentBase64) {
    throw new Error("INVALID_ARGUMENT: placeId and fileContentBase64 are required.");
  }

  const binaryBuffer = Buffer.from(fileContentBase64, "base64");

  const res = await fetch(`https://apis.roblox.com/universes/v1/${universeId}/places/${placeId}/versions?versionType=${versionType}`, {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/octet-stream"
    },
    body: binaryBuffer
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`PUBLISH_PLACE_FILE_ERROR (${res.status}): ${errText}`);
  }

  const data = await res.json();
  return { success: true, versionNumber: data.versionNumber, placeId };
}

// ==========================================
// 10. OPEN CLOUD ASSETS API (v1) & LRO POLLING
// ==========================================

export async function pollLongRunningOperation(operationPath: string, maxAttempts: number = 10, intervalMs: number = 1000) {
  const { apiKey } = getCredentials();

  const normalizedPath = operationPath.startsWith("/") ? operationPath.slice(1) : operationPath;
  const url = normalizedPath.startsWith("http") ? normalizedPath : `https://apis.roblox.com/cloud/v2/${normalizedPath}`;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const res = await fetch(url, {
      headers: { "x-api-key": apiKey }
    });

    if (!res.ok) {
      const errText = await res.text();
      throw new Error(`POLL_OPERATION_ERROR (${res.status}): ${errText}`);
    }

    const data = await res.json();
    if (data.done) {
      return data;
    }

    await new Promise(r => setTimeout(r, intervalMs));
  }

  throw new Error(`POLL_OPERATION_TIMEOUT: Operation '${operationPath}' did not complete within ${maxAttempts * intervalMs}ms`);
}

export async function uploadAsset(
  assetType: "Model" | "Decal" | "Audio" | "Mesh" | "Plugin",
  displayName: string,
  description: string,
  fileContentBase64: string,
  targetUserId?: string
) {
  const { apiKey } = getCredentials();
  const userId = targetUserId || process.env.ROBLOX_USER_ID;

  if (!displayName || !fileContentBase64) {
    throw new Error("INVALID_ARGUMENT: displayName and fileContentBase64 are required.");
  }

  const metadataJson = JSON.stringify({
    assetType,
    displayName,
    description: description || displayName,
    creationContext: {
      creator: {
        userId: userId ? String(userId) : undefined
      }
    }
  });

  const formData = new FormData();
  formData.append("request", metadataJson);
  
  const binaryBuffer = Buffer.from(fileContentBase64, "base64");
  const blob = new Blob([binaryBuffer]);
  formData.append("fileContent", blob, `asset.${assetType.toLowerCase()}`);

  const res = await fetch("https://apis.roblox.com/assets/v1/assets", {
    method: "POST",
    headers: {
      "x-api-key": apiKey
    },
    body: formData
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`UPLOAD_ASSET_ERROR (${res.status}): ${errText}`);
  }

  const initialResponse = await res.json();

  if (initialResponse.done) {
    return initialResponse;
  }

  if (initialResponse.path) {
    return await pollLongRunningOperation(initialResponse.path);
  }

  return initialResponse;
}
