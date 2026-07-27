import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';

const ROBLOX_WEBHOOK_SECRET = process.env.ROBLOX_WEBHOOK_SECRET;

// In-memory cache for live streaming discoveries to /lore page.
// Starts empty — populated exclusively by real in-game webhook events.
export const liveDiscoveriesCache: Array<{
  id: string;
  type: string;
  playerName: string;
  timestamp: string;
}> = [];

function verifySignature(rawBody: string, signatureHeader: string | null): boolean {
  if (!ROBLOX_WEBHOOK_SECRET) {
    console.error('[Webhook] ROBLOX_WEBHOOK_SECRET is not configured.');
    return false;
  }
  if (!signatureHeader) {
    return false;
  }
  // Roblox sends HMAC-SHA256 signature as hex in the roblox-signature header
  const expected = crypto
    .createHmac('sha256', ROBLOX_WEBHOOK_SECRET)
    .update(rawBody, 'utf8')
    .digest('hex');
  try {
    return crypto.timingSafeEqual(
      Buffer.from(signatureHeader, 'hex'),
      Buffer.from(expected, 'hex')
    );
  } catch {
    return false;
  }
}

export async function POST(req: NextRequest) {
  try {
    const rawBody = await req.text();
    const signatureHeader = req.headers.get('roblox-signature');

    if (!verifySignature(rawBody, signatureHeader)) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const payload = JSON.parse(rawBody);

    if (payload.eventType === 'FIRST_DISCOVERY') {
      liveDiscoveriesCache.unshift({
        id: payload.discoveryId,
        type: payload.discoveryType,
        playerName: payload.playerName,
        timestamp: new Date().toISOString(),
      });
      if (liveDiscoveriesCache.length > 50) liveDiscoveriesCache.pop();

      return NextResponse.json({
        success: true,
        message: `Recorded First Discovery of ${payload.discoveryId} by ${payload.playerName}`,
      }, { status: 200 });
    }

    return NextResponse.json({ success: true, message: 'Webhook received' }, { status: 200 });
  } catch (error) {
    console.error('[Webhook] Processing error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

export async function GET() {
  return NextResponse.json({ discoveries: liveDiscoveriesCache }, { status: 200 });
}
