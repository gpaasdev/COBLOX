import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const code = searchParams.get("code");
  const state = searchParams.get("state");
  const error = searchParams.get("error");

  if (error) {
    console.error("[OAuth2 Redirect] Error received:", error);
    return NextResponse.redirect(
      new URL(`/?oauth_error=${encodeURIComponent(error)}`, request.url)
    );
  }

  if (!code) {
    return NextResponse.json(
      { error: "Missing authorization code" },
      { status: 400 }
    );
  }

  // Exchange authorization code for access token
  try {
    const tokenResponse = await fetch(
      "https://apis.roblox.com/oauth/v1/token",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({
          grant_type: "authorization_code",
          code,
          client_id: process.env.ROBLOX_OAUTH_CLIENT_ID || "",
          client_secret: process.env.ROBLOX_OAUTH_CLIENT_SECRET || "",
        }),
      }
    );

    if (!tokenResponse.ok) {
      const errorData = await tokenResponse.text();
      console.error("[OAuth2] Token exchange failed:", errorData);
      return NextResponse.redirect(
        new URL("/?oauth_error=token_exchange_failed", request.url)
      );
    }

    const tokenData = await tokenResponse.json();
    const accessToken = tokenData.access_token;
    const refreshToken = tokenData.refresh_token;

    console.log(
      `[OAuth2] Token received for ${state || "unknown user"}`
    );

    // Store token in database or return to client
    // For now, redirect to dashboard with success indicator
    return NextResponse.redirect(
      new URL(
        `/dashboard?oauth=success&state=${encodeURIComponent(state || "")}`,
        request.url
      )
    );
  } catch (err) {
    console.error("[OAuth2] Token exchange error:", err);
    return NextResponse.redirect(
      new URL("/?oauth_error=server_error", request.url)
    );
  }
}
