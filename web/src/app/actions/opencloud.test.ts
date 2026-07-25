import assert from "node:assert";
import {
  getRobloxUserInfo,
  getGroupRoles,
  getUserGroupRank,
  listDatastores,
  getDatastoreEntries,
  getDatastoreEntry,
  setDatastoreEntry,
  updatePlayerData,
  deleteDatastoreEntry,
  getEntryVersions,
  getEntryVersion,
  getOrderedDataStoreEntries,
  setOrderedDataStoreEntry,
  deleteOrderedDataStoreEntry,
  readMemoryStoreQueue,
  addMemoryStoreQueueItem,
  discardMemoryStoreQueueItem,
  getMemoryStoreSortedMapItem,
  setMemoryStoreSortedMapItem,
  deleteMemoryStoreSortedMapItem,
  sendLiveOpsMessage,
  updateUserRestriction,
  getUserRestriction,
  listUserRestrictions,
  restartPlaceServers,
  sendUserPushNotification,
  executeRemoteLuau,
  getLuauExecutionTaskStatus,
  updatePlayerMatchmakingAttribute,
  getUniverseDetails,
  getPlaceDetails,
  publishPlaceFile,
  pollLongRunningOperation,
  uploadAsset
} from "./opencloud";

export function verifyOpenCloudActionsExports() {
  assert.strictEqual(typeof getRobloxUserInfo, "function");
  assert.strictEqual(typeof getGroupRoles, "function");
  assert.strictEqual(typeof getUserGroupRank, "function");
  assert.strictEqual(typeof listDatastores, "function");
  assert.strictEqual(typeof getDatastoreEntries, "function");
  assert.strictEqual(typeof getDatastoreEntry, "function");
  assert.strictEqual(typeof setDatastoreEntry, "function");
  assert.strictEqual(typeof updatePlayerData, "function");
  assert.strictEqual(typeof deleteDatastoreEntry, "function");
  assert.strictEqual(typeof getEntryVersions, "function");
  assert.strictEqual(typeof getEntryVersion, "function");
  assert.strictEqual(typeof getOrderedDataStoreEntries, "function");
  assert.strictEqual(typeof setOrderedDataStoreEntry, "function");
  assert.strictEqual(typeof deleteOrderedDataStoreEntry, "function");
  assert.strictEqual(typeof readMemoryStoreQueue, "function");
  assert.strictEqual(typeof addMemoryStoreQueueItem, "function");
  assert.strictEqual(typeof discardMemoryStoreQueueItem, "function");
  assert.strictEqual(typeof getMemoryStoreSortedMapItem, "function");
  assert.strictEqual(typeof setMemoryStoreSortedMapItem, "function");
  assert.strictEqual(typeof deleteMemoryStoreSortedMapItem, "function");
  assert.strictEqual(typeof sendLiveOpsMessage, "function");
  assert.strictEqual(typeof updateUserRestriction, "function");
  assert.strictEqual(typeof getUserRestriction, "function");
  assert.strictEqual(typeof listUserRestrictions, "function");
  assert.strictEqual(typeof restartPlaceServers, "function");
  assert.strictEqual(typeof sendUserPushNotification, "function");
  assert.strictEqual(typeof executeRemoteLuau, "function");
  assert.strictEqual(typeof getLuauExecutionTaskStatus, "function");
  assert.strictEqual(typeof updatePlayerMatchmakingAttribute, "function");
  assert.strictEqual(typeof getUniverseDetails, "function");
  assert.strictEqual(typeof getPlaceDetails, "function");
  assert.strictEqual(typeof publishPlaceFile, "function");
  assert.strictEqual(typeof pollLongRunningOperation, "function");
  assert.strictEqual(typeof uploadAsset, "function");
}

verifyOpenCloudActionsExports();
