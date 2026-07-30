import { NextRequest, NextResponse } from "next/server";

export async function POST(request: NextRequest) {
  try {
    const { script } = await request.json();
    const apiKey = process.env.ROBLOX_OPEN_CLOUD_API_KEY;
    const universeId = process.env.ROBLOX_UNIVERSE_ID;

    if (!apiKey || !universeId) {
      return NextResponse.json(
        { error: "Missing Open Cloud credentials" },
        { status: 500 },
      );
    }

    if (!script || typeof script !== "string") {
      return NextResponse.json(
        { error: "Script body string parameter is required" },
        { status: 400 },
      );
    }

    const url = `https://apis.roblox.com/luau-execution/v1/universes/${universeId}/tasks`;

    const res = await fetch(url, {
      method: "POST",
      headers: {
        "x-api-key": apiKey.trim(),
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ script }),
    });

    if (!res.ok) {
      const errText = await res.text();
      return NextResponse.json(
        { error: "Luau Execution API error", status: res.status, details: errText },
        { status: res.status },
      );
    }

    const data = await res.json();
    return NextResponse.json({ success: true, task: data });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to execute Luau script", details: String(error) },
      { status: 500 },
    );
  }
}
