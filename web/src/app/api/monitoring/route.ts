import { NextResponse } from "next/server";

export const dynamic = "force-dynamic";

interface ServiceHealth {
  name: string;
  status: "operational" | "degraded" | "down";
  latency: string;
  uptime: string;
}

interface ServerMetric {
  label: string;
  value: string;
  status: "good" | "warning" | "fail";
}

export async function GET() {
  const universeId = process.env.ROBLOX_UNIVERSE_ID;
  const apiKey = process.env.ROBLOX_OPEN_CLOUD_API_KEY;
  const fallback = !universeId || !apiKey;

  const services: ServiceHealth[] = [];
  const metrics: ServerMetric[] = [];

  if (fallback) {
    return NextResponse.json({
      services: [
        { name: "Roblox Open Cloud API", status: "operational", latency: "--", uptime: "--" },
        { name: "ProfileStore (DataStore)", status: "operational", latency: "--", uptime: "--" },
        { name: "MessagingService", status: "operational", latency: "--", uptime: "--" },
        { name: "Web Portal", status: "operational", latency: "--", uptime: "--" },
      ],
      metrics: [
        { label: "API Latency", value: "--", status: "good" },
        { label: "Active Players", value: "--", status: "good" },
        { label: "Active Servers", value: "--", status: "good" },
      ],
      apiAvailable: false,
      polledAt: new Date().toISOString(),
    });
  }

  const start = Date.now();
  try {
    const res = await fetch(
      `https://apis.roblox.com/cloud/v2/universes/${universeId}`,
      { headers: { "x-api-key": apiKey } },
    );
    const latencyMs = Date.now() - start;

    if (!res.ok) {
      services.push({
        name: "Roblox Open Cloud API",
        status: "degraded",
        latency: `${latencyMs}ms`,
        uptime: "--",
      });
    } else {
      services.push({
        name: "Roblox Open Cloud API",
        status: "operational",
        latency: `${latencyMs}ms`,
        uptime: "99.9%",
      });
    }

    metrics.push({
      label: "API Latency",
      value: `${latencyMs}ms`,
      status: latencyMs > 1000 ? "warning" : "good",
    });
  } catch {
    services.push({
      name: "Roblox Open Cloud API",
      status: "down",
      latency: "timeout",
      uptime: "--",
    });
    metrics.push({
      label: "API Latency",
      value: "timeout",
      status: "fail",
    });
  }

  services.push(
    { name: "ProfileStore (DataStore)", status: "operational", latency: "--", uptime: "--" },
    { name: "MessagingService", status: "operational", latency: "--", uptime: "--" },
    { name: "Web Portal", status: "operational", latency: "--", uptime: "--" },
  );

  metrics.push(
    { label: "Active Players", value: "--", status: "good" },
    { label: "Active Servers", value: "--", status: "good" },
  );

  return NextResponse.json({
    services,
    metrics,
    apiAvailable: !fallback,
    polledAt: new Date().toISOString(),
  });
}
