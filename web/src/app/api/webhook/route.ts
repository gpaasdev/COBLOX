import { NextRequest, NextResponse } from "next/server";

export async function POST(request: NextRequest) {
  const webhookUrl = process.env.DISCORD_WEBHOOK_URL;
  if (!webhookUrl) {
    return NextResponse.json({ error: "Webhook not configured" }, { status: 500 });
  }

  let body;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "Invalid JSON" }, { status: 400 });
  }

  const { event, message, data } = body;
  const color = event === "deploy" ? 3066993 : event === "error" ? 15158332 : 3447003;

  const embed = {
    title: `COBLOX ${event || "Event"}`,
    description: message || "No message",
    color,
    fields: data ? Object.entries(data).map(([k, v]) => ({ name: k, value: String(v), inline: true })) : [],
    timestamp: new Date().toISOString(),
  };

  try {
    const res = await fetch(webhookUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ embeds: [embed] }),
    });
    if (!res.ok) {
      return NextResponse.json({ error: "Webhook send failed" }, { status: 502 });
    }
    return NextResponse.json({ success: true });
  } catch (err) {
    return NextResponse.json({ error: String(err) }, { status: 500 });
  }
}
