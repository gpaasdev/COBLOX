import { notFound } from "next/navigation";

interface RobloxUser {
  id: number;
  name: string;
  displayName: string;
  description: string;
  created: string;
  isBanned: boolean;
  hasVerifiedBadge: boolean;
}

async function getRobloxUser(userId: string): Promise<RobloxUser | null> {
  try {
    const res = await fetch(
      `https://users.roblox.com/v1/users/${userId}`,
      { next: { revalidate: 300 } },
    );
    if (!res.ok) return null;
    const data = await res.json();
    return {
      id: data.id,
      name: data.name,
      displayName: data.displayName,
      description: data.description ?? "",
      created: data.created,
      isBanned: data.isBanned ?? false,
      hasVerifiedBadge: data.hasVerifiedBadge ?? false,
    } satisfies RobloxUser;
  } catch {
    return null;
  }
}

function thumbnailUrl(userId: string, size = 420): string {
  return `https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=${userId}&size=${size}x${size}&format=Png`;
}

export default async function ProfilePage({
  params,
}: {
  params: Promise<{ userId: string }>;
}) {
  const { userId } = await params;
  if (!/^\d+$/.test(userId)) notFound();

  const [user, thumbnailRes] = await Promise.all([
    getRobloxUser(userId),
    fetch(thumbnailUrl(userId), { next: { revalidate: 300 } }),
  ]);

  if (!user) notFound();

  const thumbData = thumbnailRes.ok
    ? (await thumbnailRes.json()).data?.[0]
    : null;
  const thumbUrl: string | null = thumbData?.imageUrl ?? null;

  return (
    <main className="mx-auto min-h-screen max-w-4xl px-4 py-12">
      <div className="rounded-2xl border border-gray-800 bg-gray-900/60 p-8 backdrop-blur">
        <div className="flex flex-col items-center gap-6 sm:flex-row sm:items-start">
          {thumbUrl && (
            <img
              src={thumbUrl}
              alt={`${user.displayName} avatar`}
              className="size-32 rounded-full border-2 border-amber-500 object-cover sm:size-40"
            />
          )}
          <div className="flex-1 text-center sm:text-left">
            <div className="flex items-center justify-center gap-2 sm:justify-start">
              <h1 className="text-3xl font-bold text-white">
                {user.displayName}
              </h1>
              {user.hasVerifiedBadge && (
                <span className="rounded bg-blue-600 px-1.5 py-0.5 text-xs font-bold text-white">
                  VERIFIED
                </span>
              )}
            </div>
            <p className="mt-1 text-lg text-gray-400">@{user.name}</p>
            {user.description && (
              <p className="mt-4 max-w-lg text-gray-300">
                {user.description}
              </p>
            )}
            <div className="mt-6 grid grid-cols-2 gap-4 text-sm sm:flex sm:gap-6">
              <div>
                <span className="block text-gray-500">User ID</span>
                <span className="font-mono text-amber-400">{user.id}</span>
              </div>
              <div>
                <span className="block text-gray-500">Joined</span>
                <span className="text-gray-200">
                  {new Date(user.created).toLocaleDateString()}
                </span>
              </div>
              <div>
                <span className="block text-gray-500">Status</span>
                <span
                  className={
                    user.isBanned ? "text-red-400" : "text-green-400"
                  }
                >
                  {user.isBanned ? "Banned" : "Active"}
                </span>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8 grid gap-4 sm:grid-cols-3">
          <div className="rounded-xl border border-gray-700 bg-gray-800/50 p-4 text-center">
            <div className="text-2xl font-bold text-amber-400">—</div>
            <div className="mt-1 text-xs text-gray-500">Rank</div>
          </div>
          <div className="rounded-xl border border-gray-700 bg-gray-800/50 p-4 text-center">
            <div className="text-2xl font-bold text-amber-400">—</div>
            <div className="mt-1 text-xs text-gray-500">Spirits</div>
          </div>
          <div className="rounded-xl border border-gray-700 bg-gray-800/50 p-4 text-center">
            <div className="text-2xl font-bold text-amber-400">—</div>
            <div className="mt-1 text-xs text-gray-500">Reactions</div>
          </div>
        </div>
      </div>
    </main>
  );
}
