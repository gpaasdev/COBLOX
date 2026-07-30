import { NextRequest, NextResponse } from "next/server";

function getCredentials() {
  const universeId = process.env.ROBLOX_UNIVERSE_ID;
  const apiKey = process.env.ROBLOX_OPEN_CLOUD_API_KEY;

  if (!universeId || !apiKey) {
    throw new Error("Missing Roblox Open Cloud credentials");
  }

  return { universeId, apiKey };
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = request.nextUrl;
    const datastoreName = searchParams.get("datastoreName");
    const entryKey = searchParams.get("key");
    const scope = searchParams.get("scope") ?? "global";

    if (!datastoreName || !entryKey) {
      return NextResponse.json(
        { error: "datastoreName and key query parameters are required" },
        { status: 400 },
      );
    }

    const { universeId, apiKey } = getCredentials();

    const url = `https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry?datastoreName=${encodeURIComponent(datastoreName)}&scope=${encodeURIComponent(scope)}&entryKey=${encodeURIComponent(entryKey)}`;

    const res = await fetch(url, {
      headers: { "x-api-key": apiKey.trim() },
    });

    if (!res.ok) {
      if (res.status === 404) {
        return NextResponse.json(
          { error: "Entry not found", datastoreName, entryKey },
          { status: 404 },
        );
      }
      const errText = await res.text();
      return NextResponse.json(
        { error: "DataStore API error", status: res.status, details: errText },
        { status: res.status },
      );
    }

    const data = await res.json();
    return NextResponse.json({ datastoreName, entryKey, data });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to read DataStore entry", details: String(error) },
      { status: 500 },
    );
  }
}
