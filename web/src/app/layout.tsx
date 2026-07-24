import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import { Analytics } from "@vercel/analytics/react";
import { SpeedInsights } from "@vercel/speed-insights/next";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

// Modern Web SEO Configuration
export const metadata: Metadata = {
  title: {
    default: "COBLOX | Multiverse Alchemy Sanctum",
    template: "%s | COBLOX",
  },
  description:
    "Pengalaman Hybrid Pet Tycoon & Social Action Alkimia terdepan di Roblox 2026. Susun Bejana Aura, racik elemen magis, dan tetaskan Spirit Companion legendaris.",
  openGraph: {
    title: "COBLOX | Multiverse Alchemy Sanctum",
    description: "Pengalaman Hybrid Pet Tycoon & Social Action Alkimia terdepan di Roblox 2026.",
    url: "https://gpaasdev.github.io/COBLOX/", // Replace with actual production URL when Vercel is linked
    siteName: "COBLOX",
    images: [
      {
        url: "https://raw.githubusercontent.com/gpaasdev/COBLOX/main/.github/assets/game_thumbnail_16x9.png",
        width: 1920,
        height: 1080,
        alt: "COBLOX Official Key Art",
      },
    ],
    locale: "id_ID",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "COBLOX | Multiverse Alchemy Sanctum",
    description: "Pengalaman Hybrid Pet Tycoon & Social Action Alkimia terdepan di Roblox 2026.",
    images: ["https://raw.githubusercontent.com/gpaasdev/COBLOX/main/.github/assets/game_thumbnail_16x9.png"],
  },
};

// JSON-LD for AEO / GEO (ModernWebSEO / next-seo principle)
const jsonLd = {
  "@context": "https://schema.org",
  "@type": "VideoGame",
  name: "COBLOX: Multiverse Alchemy Sanctum",
  description:
    "Hybrid Pet Tycoon & Social Action Alkimia di Roblox. Susun Bejana Aura otomatis, racik elemen magis, dan tetaskan Spirit Companion.",
  gamePlatform: ["Roblox", "PC", "Mobile", "Console"],
  operatingSystem: "Windows, macOS, iOS, Android, Xbox, PlayStation",
  genre: ["Tycoon", "Action", "RPG", "Social"],
  publisher: {
    "@type": "Organization",
    name: "COBLOX Studio",
  },
  url: "https://www.roblox.com/join/qkced",
  image: "https://raw.githubusercontent.com/gpaasdev/COBLOX/main/.github/assets/game_thumbnail_16x9.png",
};

import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="id"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body className="min-h-full flex flex-col bg-slate-950 text-slate-50">
        <Header />
        <main className="flex-grow flex flex-col">
          {children}
        </main>
        <Footer />
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
