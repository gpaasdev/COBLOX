# Roblox Open Cloud & Engine API Master Manual
**Project**: COBLOX Multiverse Sanctum (LGBOS v11.0)  
**Status**: Production & Live Released  
**Target Environment**: Next.js Server Actions (`web/src/app/actions/opencloud.ts`), CLI Execution Runner (`scripts/opencloud_runner.js`), & Roblox Engine (Luau)

---

## 1. Overview & Architecture

Roblox Open Cloud provides secure, server-authoritative HTTPS REST APIs allowing external web applications, administrative panels, CI/CD automation pipelines, and live-ops services to communicate directly with Roblox Universes and active game instances.

In COBLOX, all web dashboard administrative actions pass through server-side Next.js Server Actions located at:
`[opencloud.ts](file:///Users/mac/.gemini/antigravity-ide/scratch/COBLOX/web/src/app/actions/opencloud.ts)`

### Security Model & Production Constraints
- **Zero-Trust Validation**: Every request validates `ROBLOX_UNIVERSE_ID` and `ROBLOX_OPEN_CLOUD_API_KEY` before dispatching HTTP calls.
- **No Mock Data / No Fallbacks**: On network or permission failure, functions raise explicit errors containing the exact status code and raw response message from Roblox servers.
- **Header Standard**: All Open Cloud API calls attach the secret header:
  `x-api-key: <ROBLOX_OPEN_CLOUD_API_KEY>`

---

## 2. Environment Configuration

The following credentials are required in `web/.env.local` or host system environment:

| Environment Variable | Example Value | Description |
| :--- | :--- | :--- |
| `ROBLOX_OPEN_CLOUD_API_KEY` | `/N/G1bhX3kW+qyM...` | Granular API Key generated from Roblox Creator Dashboard |
| `ROBLOX_UNIVERSE_ID` | `10545905192` | Target Universe ID for COBLOX |
| `ROBLOX_PLACE_ID` | `105075159736246` | Target Place ID for COBLOX Sanctum |
| `ROBLOX_USER_ID` | `11329819428` | Developer / Owner User ID (`hycoblox`) |

---

## 3. OpenAPI 3.0.4 & AIP Design Patterns Compliance

### 3.1 OpenAPI Specification Structure
- **Specification Standard**: OpenAPI `3.0.4` (`https://create.roblox.com/docs/cloud/openapi.json`)
- **Server URL**: `https://apis.roblox.com`
- **Roblox Extensions**:
  - `x-roblox-stability`: `STABLE`, `EXPERIMENTAL`, `DEPRECATED`
  - `x-roblox-rate-limits`: `perApiKeyOwner`, `perOauth2Authorization` (e.g. 600 requests/minute)
  - `x-roblox-scopes`: Granular permission scopes per endpoint (e.g. `universe.datastore:read`, `asset:write`)
  - `x-roblox-engine-usability`: `apiKeyWithHttpService: false` (Enforces API key usage by external web servers/Next.js actions rather than raw client-side Luau `HttpService`).

### 3.2 Google AIP Design Patterns
- **AIP-122 Resource Naming**: Hierarchical URN paths (`universes/{universeId}/places/{placeId}`, `universes/{universeId}/user-restrictions/{userId}`).
- **AIP-131 Standard Methods**: `Get`, `List`, `Create`, `Update`, `Delete`.
- **AIP-132 Custom Methods**: Verb-suffixed custom endpoints (`:restart-servers`, `:luau-execution`).
- **AIP-151 Long-Running Operations (LRO)**:
  - Asynchronous endpoints return an `Operation` object: `{ "path": "operations/assets/12345", "done": false }`.
  - Clients poll `GET https://apis.roblox.com/cloud/v2/{path}` until `done: true` to obtain the final `assetId` or `error`.

---

## 4. Automated Place Publishing & Asset Management APIs

### 4.1 Automated Place Publishing (`publishPlaceFile`)
- **Endpoint**: `POST https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType={versionType}`
- **Header**: `x-api-key: <KEY>`, `Content-Type: application/octet-stream`
- **CLI Command**: `node scripts/opencloud_runner.js build-and-publish-place [placeId] [versionType]`
- **Workflow**:
  1. Compiles Luau codebase to binary `.rbxl` using `rojo build -o test.rbxl`.
  2. Reads compiled binary buffer (`test.rbxl`).
  3. Sends HTTP POST request to Open Cloud Place Publishing API.
  4. Returns `200 OK` with JSON response: `{ "versionNumber": 102 }`.

### 4.2 Open Cloud Assets API v1 (`uploadAsset` & `pollLongRunningOperation`)
- **Endpoint**: `POST https://apis.roblox.com/assets/v1/assets`
- **Header**: `x-api-key: <KEY>`
- **Payload Format**: Multipart Form-Data (`request` metadata JSON + `fileContent` binary blob).
- **Supported Types**: `Decal`, `Audio`, `Model`, `Mesh`, `Plugin`.

---

## 5. Detailed Action-by-Action Reference (All 34 Production Server Actions)

### 5.1 Public & User Info APIs

#### 1. `getRobloxUserInfo(userId: string)`
- **Endpoint**: `GET https://users.roblox.com/v1/users/{userId}`
- **Keterangan Ringkas**: Mengambil profil publik pengguna Roblox berdasarkan `userId` (username, displayName, tanggal pembuatan akun, status ban).
- **Penggunaan**: Header profil pemain di Web Admin Dashboard saat mencari data inventaris atau transaksi.

#### 2. `getGroupRoles(groupId: string)`
- **Endpoint**: `GET https://groups.roblox.com/v1/groups/{groupId}/roles`
- **Keterangan Ringkas**: Mengambil daftar seluruh role/pangkat yang ada di dalam Roblox Group tertentu.
- **Penggunaan**: Menyinkronkan tingkat otorisasi admin web dengan struktur divisi/grup Roblox.

#### 3. `getUserGroupRank(groupId: string, userId: string)`
- **Endpoint**: `GET https://groups.roblox.com/v1/users/{userId}/groups/roles`
- **Keterangan Ringkas**: Memeriksa apakah seorang pemain terdaftar dalam grup Roblox dan mengembalikan nama role serta nilai numeric rank (0 - 255).
- **Penggunaan**: Verifikasi hak akses khusus (misalnya Moderator atau Developer) sebelum mengizinkan perintah sensitif.

---

### 5.2 Standard DataStores API (Cloud v1)
Primary Datastore Name: `COBLOX_DataStore_LGBOS_v11`

#### 4. `listDatastores(prefix?: string, limit?: number, cursor?: string)`
- **Endpoint**: `GET https://apis.roblox.com/datastores/v1/universes/{universeId}/standard-datastores`
- **Keterangan Ringkas**: Mengambil daftar nama semua DataStore yang terdaftar di dalam Universe Roblox.
- **Penggunaan**: Audit internal untuk memantau struktur penyimpanan data yang aktif di dalam game.

#### 5. `getDatastoreEntries(query: string = "")`
- **Endpoint**: `GET https://apis.roblox.com/datastores/v1/universes/{universeId}/standard-datastores/datastore/entries`
- **Keterangan Ringkas**: Mencari dan membaca isi key DataStore pemain. Mengambil profil spesifik jika `query` terisi, atau 20 key teratas beserta status wallet jika kosong.
- **Penggunaan**: Dashboard manajemen akun pemain untuk melihat Gems, Coins, Aura Energy, dan Chrono Sparks.

#### 6. `getDatastoreEntry(entryKey: string, datastoreName?: string, scope?: string)`
- **Endpoint**: `GET .../standard-datastores/datastore/entries/entry`
- **Keterangan Ringkas**: Mengambil data mentah (JSON) dari key DataStore tertentu pada scope tertentu (default `"global"`).
- **Penggunaan**: Inspeksi mendalam (*deep-dive JSON*) data pemain untuk keperluan debugging.

#### 7. `setDatastoreEntry(entryKey: string, data: any, datastoreName?: string, scope?: string)`
- **Endpoint**: `POST .../standard-datastores/datastore/entries/entry`
- **Keterangan Ringkas**: Menyimpan atau mengganti objek data JSON secara langsung pada key DataStore target.
- **Penggunaan**: Restorasi data cadangan atau overwrite state pemain oleh admin.

#### 8. `updatePlayerData(id: string, updates: { gems?: number; coins?: number; auraEnergy?: number; chronoSparks?: number })`
- **Endpoint**: `POST .../standard-datastores/datastore/entries/entry`
- **Keterangan Ringkas**: Mengubah saldo spesifik (Gems, Coins, Aura Energy, Chrono Sparks) milik pemain secara terisolasi tanpa merusak struktur inventaris lainnya.
- **Penggunaan**: Aksi tombol `Save Changes` di UI Dashboard Admin saat melakukan kompensasi atau penyesuaian saldo pemain.

#### 9. `deleteDatastoreEntry(entryKey: string, datastoreName?: string, scope?: string)`
- **Endpoint**: `DELETE .../standard-datastores/datastore/entries/entry`
- **Keterangan Ringkas**: Menghapus key dari DataStore secara permanen.
- **Penggunaan**: Penghapusan data akun uji coba (*test account reset*).

#### 10. `getEntryVersions(entryKey: string, datastoreName?: string, scope?: string, limit?: number, cursor?: string)`
- **Endpoint**: `GET .../standard-datastores/datastore/entries/entry/versions`
- **Keterangan Ringkas**: Mengambil riwayat versi (*version history*) dari suatu key DataStore.
- **Penggunaan**: Audit perubahan data pemain untuk mendeteksi tindakan duplikasi item atau exploit.

#### 11. `getEntryVersion(entryKey: string, versionId: string, datastoreName?: string, scope?: string)`
- **Endpoint**: `GET .../standard-datastores/datastore/entries/entry/versions/version`
- **Keterangan Ringkas**: Mengambil isi snapshot data pada versi `versionId` spesifik di masa lalu.
- **Penggunaan**: Fitur *Rollback Data* pemain jika terjadi insiden kebocoran data atau corrupt save.

---

### 5.3 Ordered DataStores API (Cloud v1)

#### 12. `getOrderedDataStoreEntries(datastoreName: string, scope?: string, orderBy?: "Asc"|"Desc", limit?: number, cursor?: string, max?: number, min?: number)`
- **Endpoint**: `GET https://apis.roblox.com/ordered-datastores/v1/universes/{universeId}/orderedDataStores/{name}/scopes/{scope}/entries`
- **Keterangan Ringkas**: Mengambil daftar nilai terurut (*sorted numerical values*) dari Ordered DataStore.
- **Penggunaan**: Menampilkan Papan Peringkat Global (*Global Leaderboard*) Gems, Rebirth, atau Level di Web Portal.

#### 13. `setOrderedDataStoreEntry(datastoreName: string, entryKey: string, value: number, scope?: string)`
- **Endpoint**: `POST .../orderedDataStores/{name}/scopes/{scope}/entries/{entryKey}`
- **Keterangan Ringkas**: Memperbarui atau menambahkan skor numerik pemain ke dalam Ordered DataStore.
- **Penggunaan**: Pembaruan manual skor leaderboard dari luar game.

#### 14. `deleteOrderedDataStoreEntry(datastoreName: string, entryKey: string, scope?: string)`
- **Endpoint**: `DELETE .../orderedDataStores/{name}/scopes/{scope}/entries/{entryKey}`
- **Keterangan Ringkas**: Menghapus entri pemain dari Ordered DataStore leaderboard.
- **Penggunaan**: Pembersihan akun cheater/exploiter dari papan peringkat global.

---

### 5.4 MemoryStores API (Cloud v1)

#### 15. `readMemoryStoreQueue(queueName: string, count?: number)`
- **Endpoint**: `GET https://apis.roblox.com/memory-store/v1/universes/{universeId}/queues/{queueName}/items`
- **Keterangan Ringkas**: Membaca dan mengeluarkan (*pop*) sejumlah item dari MemoryStore Queue.
- **Penggunaan**: Memantau antrean matchmaking atau antrean tugas pemprosesan antar-server game.

#### 16. `addMemoryStoreQueueItem(queueName: string, item: any, expirationSeconds?: number, priority?: number)`
- **Endpoint**: `POST https://apis.roblox.com/memory-store/v1/universes/{universeId}/queues/{queueName}/items`
- **Keterangan Ringkas**: Menambahkan item baru ke dalam MemoryStore Queue dengan waktu kadaluarsa (TTL) dan prioritas.
- **Penggunaan**: Mengirimkan sinyal tugas cepat yang membutuhkan eksekusi urut (*FIFO*).

#### 17. `discardMemoryStoreQueueItem(queueName: string, id: string)`
- **Endpoint**: `DELETE .../queues/{queueName}/items/{id}`
- **Keterangan Ringkas**: Menghapus item tertentu dari MemoryStore Queue berdasarkan ID item.
- **Penggunaan**: Membatalkan pesanan atau antrean yang mengalami timeout.

#### 18. `getMemoryStoreSortedMapItem(mapName: string, key: string)`
- **Endpoint**: `GET https://apis.roblox.com/memory-store/v1/universes/{universeId}/sorted-maps/{mapName}/items/{key}`
- **Keterangan Ringkas**: Mengambil nilai dari MemoryStore Sorted Map berdasarkan key.
- **Penggunaan**: Inspeksi status server aktif atau data transaksi sementara.

#### 19. `setMemoryStoreSortedMapItem(mapName: string, key: string, value: any, ttlSeconds?: number)`
- **Endpoint**: `POST .../sorted-maps/{mapName}/items/{key}`
- **Keterangan Ringkas**: Menyimpan nilai pasangan key-value pada MemoryStore Sorted Map dengan TTL tertentu.
- **Penggunaan**: Menyimpan flag status maintenance sementara antar server.

#### 20. `deleteMemoryStoreSortedMapItem(mapName: string, key: string)`
- **Endpoint**: `DELETE .../sorted-maps/{mapName}/items/{key}`
- **Keterangan Ringkas**: Menghapus key dari MemoryStore Sorted Map.
- **Penggunaan**: Menghapus status lock sementara.

---

### 5.5 Messaging API (Cloud v1)

#### 21. `sendLiveOpsMessage(topic: string, message: string | object)`
- **Endpoint**: `POST https://apis.roblox.com/messaging/v1/universes/{universeId}/topics/{topic}`
- **Keterangan Ringkas**: Mempublikasikan pesan sinyal real-time ke seluruh server Roblox yang sedang aktif mendengarkan topik tersebut.
- **Penggunaan**: Fitur Broadcast Pengumuman LiveOps, Notifikasi Event Global, atau Pengumuman Maintenance Server.

---

### 5.6 Moderation & User Restrictions (Cloud v2)

#### 22. `updateUserRestriction(userId: string, active: boolean, durationSeconds?: number, displayReason?: string, privateReason?: string)`
- **Endpoint**: `PATCH https://apis.roblox.com/cloud/v2/universes/{universeId}/user-restrictions/{userId}`
- **Keterangan Ringkas**: Menerapkan sanksi ban/restriction (aktifkan/nonaktifkan) pada pemain agar tidak bisa masuk ke dalam game, lengkap dengan durasi dan alasan.
- **Penggunaan**: Fitur Ban/Unban Pemain dari Dashboard Mod.

#### 23. `getUserRestriction(userId: string)`
- **Endpoint**: `GET https://apis.roblox.com/cloud/v2/universes/{universeId}/user-restrictions/{userId}`
- **Keterangan Ringkas**: Memeriksa status hukuman/ban aktif seorang pengguna di Universe COBLOX.
- **Penggunaan**: Pengecekan status ban sebelum memproses permohonan banding (*appeal*).

#### 24. `listUserRestrictions(pageSize?: number, pageToken?: string)`
- **Endpoint**: `GET https://apis.roblox.com/cloud/v2/universes/{universeId}/user-restrictions`
- **Keterangan Ringkas**: Mengambil daftar seluruh pemain yang sedang menjalani hukuman/ban di Universe ini.
- **Penggunaan**: Halaman Audit Moderasi pada Dashboard Admin.

---

### 5.7 Live Server Operations & Remote Execution (Cloud v2)

#### 25. `restartPlaceServers(targetPlaceId?: string)`
- **Endpoint**: `POST https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/instances/restart-servers`
- **Keterangan Ringkas**: Menginisiasi restart beruntah untuk semua server game yang sedang aktif di Place target.
- **Penggunaan**: Menerapkan update script Roblox tanpa perlu mematikan game secara manual dari Studio.

#### 26. `sendUserPushNotification(userId: string, title: string, content: string)`
- **Endpoint**: `POST https://apis.roblox.com/cloud/v2/universes/{universeId}/user-notifications`
- **Keterangan Ringkas**: Mengirimkan notifikasi push Roblox secara langsung ke aplikasi mobile/desktop pemain.
- **Penggunaan**: Pengingat klaim hadiah harian atau notifikasi event spesial.

#### 27. `executeRemoteLuau(targetPlaceId: string | undefined, luauScript: string)`
- **Endpoint**: `POST https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/luau-execution`
- **Keterangan Ringkas**: Mengirimkan skrip Luau kustom untuk dieksekusi secara otomatis di server Roblox aktif.
- **Penggunaan**: Diagnostik server live atau perbaikan bug darurat (*hotfix*).

#### 28. `getLuauExecutionTaskStatus(targetPlaceId: string | undefined, taskId: string)`
- **Endpoint**: `GET https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/luau-execution/tasks/{taskId}`
- **Keterangan Ringkas**: Memeriksa status dan hasil keluaran (*output/logs*) dari tugas eksekusi Luau remote.
- **Penggunaan**: Memantau apakah script hotfix telah sukses dijalankan.

---

### 5.8 Matchmaking, Universe, & Place Management (Cloud v2)

#### 29. `updatePlayerMatchmakingAttribute(userId: string, skillRating: number, preferredRegion?: string)`
- **Endpoint**: `PATCH https://apis.roblox.com/cloud/v2/universes/{universeId}/matchmaking/players/{userId}`
- **Keterangan Ringkas**: Memperbarui atribut MMR (*Matchmaking Rating*) dan preferensi wilayah server pemain.
- **Penggunaan**: Pengaturan peringkat kompetitif dari web admin.

#### 30. `getUniverseDetails()`
- **Endpoint**: `GET https://apis.roblox.com/cloud/v2/universes/{universeId}`
- **Keterangan Ringkas**: Mengambil metadata Universe (nama, deskripsi, status publikasi, pengatur kekayaan).
- **Penggunaan**: Informasi ringkasan pada Dashboard Utama Web.

#### 31. `getPlaceDetails(targetPlaceId?: string)`
- **Endpoint**: `GET https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}`
- **Keterangan Ringkas**: Mengambil rincian spesifik Place (Max Players, Server Fill Rate).
- **Penggunaan**: Monitoring kapasitas dan performa Place.

#### 32. `publishPlaceFile(targetPlaceId: string | undefined, versionType: "Saved"|"Published", fileContentBase64: string)`
- **Endpoint**: `POST https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions`
- **Keterangan Ringkas**: Mengunggah file biner tempat (`.rbxl`) dalam format Base64 untuk mempublikasikan versi baru Place secara programmatic.
- **Penggunaan**: Pipeline otomatisasi CI/CD dari GitHub Actions ke Roblox Live Universe.

#### 33. `pollLongRunningOperation(operationPath: string, maxAttempts?: number, intervalMs?: number)`
- **Endpoint**: `GET https://apis.roblox.com/cloud/v2/{path}`
- **Keterangan Ringkas**: Memantau status operasi asynchronous berdurasi panjang (AIP-151 LRO) hingga mengembalikan status `done: true`.
- **Penggunaan**: Polling status proses pengolahan file aset atau eksekusi Luau task.

#### 34. `uploadAsset(assetType: string, displayName: string, description: string, fileContentBase64: string, targetUserId?: string)`
- **Endpoint**: `POST https://apis.roblox.com/assets/v1/assets`
- **Keterangan Ringkas**: Mengunggah aset baru (Decal, Audio, Plugin, Mesh) ke Roblox via Open Cloud Assets API.
- **Penggunaan**: Otomatisasi pengunggahan gambar badge, ikon resep, atau audio efek dari web admin.

---

## 6. Analisis Mendalam: Roblox Engine API Reference (`https://create.roblox.com/docs/id-id/reference/engine`)

### 6.1 Struktur Utama Engine API
1. **Classes (654+ Kelas)**:
   - Objek berbasis OOP yang membentuk hierarki DOM Roblox (`Instance`).
   - Layanan Utama di COBLOX: `DataStoreService`, `MemoryStoreService`, `MessagingService`, `Players`, `HttpService`, `ReplicatedStorage`, `ServerScriptService`.
2. **Data Types (47+ Tipe Data Khusus)**:
   - `Vector3`, `CFrame`, `UDim2`, `Color3`, `Region3`, `RaycastParams`.
3. **Enums (546+ Enumerasi)**:
   - `Enum.Material`, `Enum.KeyCode`, `Enum.RaycastFilterType`, `Enum.ProductPurchaseDecision`.
4. **Globals & Libraries**:
   - `task.spawn`, `task.wait`, `task.defer`, `pcall`, `typeof`, `require`, `script`.

---

## 7. Roblox Studio MCP (Model Context Protocol)

Roblox Studio mendukung **Built-in Model Context Protocol (MCP) Server**, memungkinkan AI coding assistant terhubung secara real-time ke sesi Studio aktif:
- **Eksplorasi DataModel**: Membaca tree instance tempat secara langsung.
- **Manajemen Skrip**: Membaca, membuat, dan memodifikasi ModuleScript/ServerScript.
- **Manipulasi Objek**: Menambah, merubah properti (`Position`, `Size`, `Color`), atau menghapus Instance di Workspace.
- **Otomatisasi Testing**: Memulai/menghentikan playtest dan mensimulasikan input.
