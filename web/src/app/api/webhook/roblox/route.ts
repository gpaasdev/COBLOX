import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';

// The secret configured in the Roblox Creator Dashboard
const ROBLOX_WEBHOOK_SECRET = process.env.ROBLOX_WEBHOOK_SECRET || 'fallback-secret-for-dev';

export async function POST(req: NextRequest) {
  try {
    const rawBody = await req.text();
    const signatureHeader = req.headers.get('roblox-signature');

    if (!signatureHeader) {
      return NextResponse.json({ error: 'Missing roblox-signature header' }, { status: 401 });
    }

    const signatureParts = signatureHeader.split(',');
    let timestamp = '';
    let signature = '';

    for (const part of signatureParts) {
      if (part.startsWith('t=')) timestamp = part.slice(2);
      if (part.startsWith('v1=')) signature = part.slice(3);
    }

    if (!timestamp || !signature) {
      return NextResponse.json({ error: 'Invalid signature format' }, { status: 401 });
    }

    const signedPayload = `${timestamp}.${rawBody}`;
    const expectedSignature = crypto
      .createHmac('sha256', ROBLOX_WEBHOOK_SECRET)
      .update(signedPayload)
      .digest('base64');

    if (expectedSignature !== signature) {
      console.warn('Webhook signature verification failed');
      return NextResponse.json({ error: 'Invalid signature' }, { status: 401 });
    }

    const payload = JSON.parse(rawBody);
    console.log(`[Webhook] Received Roblox Subscription Event:`, payload);

    return NextResponse.json({ success: true, message: 'Webhook received' }, { status: 200 });
  } catch (error) {
    console.error('Webhook processing error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
