import { NextRequest, NextResponse } from "next/server";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

function getCredentials() {
  const universeId = process.env.ROBLOX_UNIVERSE_ID;
  const apiKey = process.env.ROBLOX_OPEN_CLOUD_API_KEY;
  const webhookUrl = process.env.DISCORD_WEBHOOK_URL;
  return { universeId, apiKey, webhookUrl };
}

async function sendDiscordNotification(
  action: string,
  entryKey: string,
  oldValue: string | null,
  newValue: string | null,
) {
  const { webhookUrl } = getCredentials();
  if (!webhookUrl) return;

  const color = action === "update" ? 3066993 : action === "delete" ? 15158332 : 3447003;

  try {
    await fetch(webhookUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        embeds: [
          {
            title: `Config ${action}: ${entryKey}`,
            description: `**Key:** \`${entryKey}\`\n**Action:** ${action}`,
            color,
            fields: [
              ...(oldValue !== null ? [{ name: "Old Value", value: `\`\`\`\n${oldValue.slice(0, 500)}\`\`\``, inline: false }] : []),
              ...(newValue !== null ? [{ name: "New Value", value: `\`\`\`\n${newValue.slice(0, 500)}\`\`\``, inline: false }] : []),
            ],
            timestamp: new Date().toISOString(),
          },
        ],
      }),
    });
  } catch {
    // Discord notification failure is non-critical
  }
}

async function syncToGame(key: string, value: string) {
  const { universeId, apiKey } = getCredentials();
  if (!universeId || !apiKey) return;

  try {
    await fetch(
      `https://apis.roblox.com/messaging/v1/universes/${universeId}/topics/Config_Update`,
      {
        method: "POST",
        headers: {
          "x-api-key": apiKey,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: JSON.stringify({ key, value, timestamp: new Date().toISOString() }),
        }),
      },
    );
  } catch {
    // MessagingService failure is non-critical for API
  }
}

export async function GET() {
  try {
    const entries = await prisma.configEntry.findMany({
      orderBy: [{ group: "asc" }, { key: "asc" }],
    });
    return NextResponse.json({ entries });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to fetch config entries", details: String(error) },
      { status: 500 },
    );
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const body = await request.json();
    const { key, value, type, group, description } = body as {
      key?: string;
      value?: string;
      type?: string;
      group?: string;
      description?: string;
    };

    if (!key || value === undefined) {
      return NextResponse.json(
        { error: "Key and value are required" },
        { status: 400 },
      );
    }

    const existing = await prisma.configEntry.findUnique({ where: { key } });
    const oldValue = existing?.value ?? null;

    const entry = await prisma.configEntry.upsert({
      where: { key },
      update: {
        value,
        ...(type ? { type } : {}),
        ...(group ? { group } : {}),
        ...(description !== undefined ? { description } : {}),
      },
      create: {
        key,
        value,
        type: type ?? "StringConfig",
        group: group ?? "General",
        description: description ?? "",
      },
    });

    await Promise.all([
      sendDiscordNotification("update", key, oldValue, value),
      syncToGame(key, value),
    ]);

    return NextResponse.json({ entry });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to update config entry", details: String(error) },
      { status: 500 },
    );
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = request.nextUrl;
    const key = searchParams.get("key");

    if (!key) {
      return NextResponse.json({ error: "Key query parameter is required" }, { status: 400 });
    }

    const existing = await prisma.configEntry.findUnique({ where: { key } });
    if (!existing) {
      return NextResponse.json({ error: "Config entry not found" }, { status: 404 });
    }

    await prisma.configEntry.delete({ where: { key } });

    await sendDiscordNotification("delete", key, existing.value, null);

    return NextResponse.json({ success: true, message: `Deleted config entry: ${key}` });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to delete config entry", details: String(error) },
      { status: 500 },
    );
  }
}
