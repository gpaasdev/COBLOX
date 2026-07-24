"use server";

import { revalidatePath } from "next/cache";

// Mock database for demonstration (until real Open Cloud is wired up)
let MOCK_DATASTORE = [
  { id: "1", username: "PlayerOne", rank: "Alchemist", gems: 1500, status: "Active" },
  { id: "2", username: "NoobMaster", rank: "Novice", gems: 50, status: "Active" },
  { id: "3", username: "ToxicSpammer", rank: "Novice", gems: 0, status: "Banned" },
];

export async function getDatastoreEntries(query: string = "") {
  // Simulate network delay
  await new Promise((resolve) => setTimeout(resolve, 500));
  
  if (!query) return MOCK_DATASTORE;
  return MOCK_DATASTORE.filter((entry) => 
    entry.username.toLowerCase().includes(query.toLowerCase())
  );
}

export async function updatePlayerGems(id: string, newAmount: number) {
  await new Promise((resolve) => setTimeout(resolve, 600));
  
  const entry = MOCK_DATASTORE.find((e) => e.id === id);
  if (entry) {
    entry.gems = newAmount;
  }
  
  revalidatePath("/dashboard/datastore");
  return { success: true };
}

export async function sendLiveOpsMessage(topic: string, message: string) {
  await new Promise((resolve) => setTimeout(resolve, 800));
  console.log(`[Open Cloud] Broadcast to ${topic}: ${message}`);
  return { success: true, delivered: 1542 };
}
