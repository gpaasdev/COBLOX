import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  try {
    const apiKey = process.env.ROBLOX_OPEN_CLOUD_API_KEY;
    const universeId = process.env.ROBLOX_UNIVERSE_ID;

    if (!apiKey || !universeId) {
      return NextResponse.json(
        { error: "Missing Open Cloud credentials" },
        { status: 500 },
      );
    }

    const universeUrl = `https://apis.roblox.com/cloud/v2/universes/${universeId}`;

    const res = await fetch(universeUrl, {
      headers: { "x-api-key": apiKey.trim() },
    });

    if (!res.ok) {
      return NextResponse.json(
        { error: "Universe metadata query failed", status: res.status },
        { status: res.status },
      );
    }

    const universeData = await res.json();
    return NextResponse.json({
      success: true,
      universe: universeData,
      metrics: {
        timestamp: new Date().toISOString(),
        status: "Active",
      },
    });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to fetch live analytics", details: String(error) },
      { status: 500 },
    );
  }
}
