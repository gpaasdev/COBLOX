import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';

const ROBLOX_WEBHOOK_SECRET = process.env.ROBLOX_WEBHOOK_SECRET || 'fallback-secret-for-dev';

// In-memory cache for live streaming discoveries to /lore page
export const liveDiscoveriesCache: Array<{
  id: string;
  type: string;
  playerName: string;
  timestamp: string;
}> = [
  {
    id: "FerriumAlloy",
    type: "Material",
    playerName: "PlayerXYZ",
    timestamp: new Date().toISOString(),
  },
  {
    id: "AetherCrystalNode",
    type: "Resource",
    playerName: "Vance_Architect",
    timestamp: new Date().toISOString(),
  }
];

export async function POST(req: NextRequest) {
  try {
    const rawBody = await req.text();
    const signatureHeader = req.headers.get('roblox-signature') || req.headers.get('x-coblox-secret');

    // Simple dev fallback check for local server-to-server testing
    if (signatureHeader !== ROBLOX_WEBHOOK_SECRET && !req.headers.get('roblox-signature')) {
      return NextResponse.json({ error: 'Missing or invalid authentication header' }, { status: 401 });
    }

    const payload = JSON.parse(rawBody);
    console.log(`[Webhook] Received Roblox Event:`, payload);

    if (payload.eventType === "FIRST_DISCOVERY") {
      liveDiscoveriesCache.unshift({
        id: payload.discoveryId,
        type: payload.discoveryType,
        playerName: payload.playerName,
        timestamp: new Date().toISOString(),
      });
      if (liveDiscoveriesCache.length > 50) liveDiscoveriesCache.pop();

      return NextResponse.json({
        success: true,
        message: `Recorded First Discovery of ${payload.discoveryId} by ${payload.playerName}`
      }, { status: 200 });
    }

    return NextResponse.json({ success: true, message: 'Webhook received' }, { status: 200 });
  } catch (error) {
    console.error('Webhook processing error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

export async function GET() {
  return NextResponse.json({
    discoveries: liveDiscoveriesCache
  }, { status: 200 });
}
