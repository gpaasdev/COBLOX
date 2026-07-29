"use client";
import { useState } from "react";
import { Plus, Edit, Eye, Trash2, FileText, Megaphone, Newspaper } from "lucide-react";

const initialPosts = [
  { id: 1, title: "Phase 1 Hardening Complete — Launch Ready!", type: "announcement", status: "published", date: "2026-07-29" },
  { id: 2, title: "Fairytale Realm Assets Uploaded", type: "announcement", status: "published", date: "2026-07-28" },
  { id: 3, title: "Launch Readiness & Hardening (v195)", type: "changelog", status: "published", date: "2026-07-29" },
  { id: 4, title: "Localization Completion (v194)", type: "changelog", status: "published", date: "2026-07-29" },
  { id: 5, title: "Economy Security & Badge Creation (v190-193)", type: "changelog", status: "published", date: "2026-07-29" },
];

export default function CMSPage() {
  const [posts, setPosts] = useState(initialPosts);
  const [filter, setFilter] = useState("all");

  const filtered = filter === "all" ? posts : posts.filter((p) => p.type === filter);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Content Management</h1>
          <p className="text-slate-500">Manage changelog, announcements, and knowledge base articles.</p>
        </div>
        <button className="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 transition-colors">
          <Plus className="h-4 w-4" />
          New Post
        </button>
      </div>

      <div className="flex gap-2 mb-2">
        {["all", "changelog", "announcement", "blog"].map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${
              filter === f ? "bg-blue-100 text-blue-700" : "text-slate-500 hover:bg-slate-100"
            }`}
          >
            {f.charAt(0).toUpperCase() + f.slice(1)}
          </button>
        ))}
      </div>

      <div className="rounded-xl border border-slate-200 bg-white shadow-sm overflow-hidden">
        <table className="w-full text-left text-sm">
          <thead className="bg-slate-50 text-slate-500">
            <tr>
              <th className="px-6 py-4 font-medium">Title</th>
              <th className="px-6 py-4 font-medium">Type</th>
              <th className="px-6 py-4 font-medium">Status</th>
              <th className="px-6 py-4 font-medium">Date</th>
              <th className="px-6 py-4 font-medium text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {filtered.map((post) => (
              <tr key={post.id} className="hover:bg-slate-50 transition-colors">
                <td className="px-6 py-4">
                  <div className="flex items-center gap-3">
                    {post.type === "announcement" ? (
                      <Megaphone className="h-4 w-4 text-amber-500" />
                    ) : (
                      <Newspaper className="h-4 w-4 text-blue-500" />
                    )}
                    <span className="font-medium text-slate-800">{post.title}</span>
                  </div>
                </td>
                <td className="px-6 py-4">
                  <span className="inline-flex items-center rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-semibold text-slate-700">
                    {post.type}
                  </span>
                </td>
                <td className="px-6 py-4">
                  <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${
                    post.status === "published" ? "bg-emerald-100 text-emerald-700" : "bg-amber-100 text-amber-700"
                  }`}>
                    {post.status}
                  </span>
                </td>
                <td className="px-6 py-4 text-slate-500">{post.date}</td>
                <td className="px-6 py-4 text-right">
                  <div className="flex items-center justify-end gap-1">
                    <button className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors" title="Edit">
                      <Edit className="h-4 w-4" />
                    </button>
                    <button className="p-2 text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 rounded-md transition-colors" title="Preview">
                      <Eye className="h-4 w-4" />
                    </button>
                    <button className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors" title="Delete">
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
