"use client";

import { useEffect, useState, useCallback } from "react";
import { FileText, Save, Loader2, Plus, XCircle, CheckCircle } from "lucide-react";

interface Post {
  id: string;
  title: string;
  content: string;
  category: string;
  published: boolean;
  authorName: string;
  createdAt: string;
  updatedAt: string;
  slug: string;
  excerpt: string;
  tags: string;
}

export default function CMSPage() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [editingPost, setEditingPost] = useState<Post | null>(null);
  const [editTitle, setEditTitle] = useState("");
  const [editContent, setEditContent] = useState("");
  const [editCategory, setEditCategory] = useState("announcement");
  const [editPublished, setEditPublished] = useState(true);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [filter, setFilter] = useState("all");
  const [showNewForm, setShowNewForm] = useState(false);

  const fetchPosts = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch("/api/cms");
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setPosts(data.posts ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load posts");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchPosts();
  }, [fetchPosts]);

  const startEditing = (post: Post) => {
    setEditingPost(post);
    setEditTitle(post.title);
    setEditContent(post.content);
    setEditCategory(post.category);
    setEditPublished(post.published);
    setShowNewForm(false);
  };

  const startNewPost = () => {
    setEditingPost(null);
    setEditTitle("");
    setEditContent("");
    setEditCategory("announcement");
    setEditPublished(false);
    setShowNewForm(true);
  };

  const cancelEdit = () => {
    setEditingPost(null);
    setEditTitle("");
    setEditContent("");
    setEditCategory("announcement");
    setEditPublished(true);
    setShowNewForm(false);
  };

  const savePost = async () => {
    if (!editTitle.trim()) return;
    setSaving(true);
    setError(null);
    setSaved(false);

    try {
      const body = {
        title: editTitle,
        content: editContent,
        category: editCategory,
        published: editPublished,
        slug: editingPost?.slug ?? editTitle.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, ""),
        excerpt: editContent.slice(0, 200),
        authorName: "Admin",
      };

      const res = await fetch("/api/cms", {
        method: editingPost ? "PATCH" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ...body, id: editingPost?.id }),
      });

      if (!res.ok) {
        const errData = await res.json().catch(() => ({}));
        throw new Error(errData.error ?? "Save failed");
      }

      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
      cancelEdit();
      await fetchPosts();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to save post");
    } finally {
      setSaving(false);
    }
  };

  const deletePost = async (post: Post) => {
    if (!confirm(`Delete "${post.title}"?`)) return;
    try {
      const res = await fetch(`/api/cms?id=${encodeURIComponent(post.id)}`, { method: "DELETE" });
      if (!res.ok) throw new Error("Delete failed");
      await fetchPosts();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to delete post");
    }
  };

  const filteredPosts = filter === "all"
    ? posts
    : posts.filter((p) => p.category === filter);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <Loader2 className="h-8 w-8 animate-spin text-slate-400" />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Content Management</h1>
          <p className="text-slate-500">Manage announcements and knowledge base articles.</p>
        </div>
        <button
          onClick={startNewPost}
          className="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-blue-700"
        >
          <Plus className="h-4 w-4" />
          New Post
        </button>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          <XCircle className="h-4 w-4 shrink-0" />
          {error}
          <button onClick={() => setError(null)} className="ml-auto text-red-500 hover:text-red-700">Dismiss</button>
        </div>
      )}

      <div className="flex flex-wrap gap-2">
        {["all", "announcement", "changelog", "blog", "guide"].map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`rounded-lg px-3 py-1.5 text-sm font-medium transition-colors ${
              filter === f ? "bg-slate-900 text-white" : "bg-slate-100 text-slate-600 hover:bg-slate-200"
            }`}
          >
            {f.charAt(0).toUpperCase() + f.slice(1)}
          </button>
        ))}
      </div>

      {(showNewForm || editingPost) && (
        <div className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 className="mb-4 text-lg font-semibold text-slate-900">
            {editingPost ? "Edit Post" : "New Post"}
          </h2>
          <div className="flex flex-col gap-4">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="flex flex-col gap-1.5">
                <label htmlFor="editTitle" className="text-sm font-medium text-slate-700">Title</label>
                <input
                  id="editTitle"
                  type="text"
                  value={editTitle}
                  onChange={(e) => setEditTitle(e.target.value)}
                  className="rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                  placeholder="Post title"
                />
              </div>
              <div className="flex flex-col gap-1.5">
                <label htmlFor="editCategory" className="text-sm font-medium text-slate-700">Category</label>
                <select
                  id="editCategory"
                  value={editCategory}
                  onChange={(e) => setEditCategory(e.target.value)}
                  className="rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                >
                  <option value="announcement">Announcement</option>
                  <option value="changelog">Changelog</option>
                  <option value="blog">Blog</option>
                  <option value="guide">Guide</option>
                </select>
              </div>
            </div>

            <div className="flex flex-col gap-1.5">
              <label htmlFor="editContent" className="text-sm font-medium text-slate-700">Content</label>
              <textarea
                id="editContent"
                value={editContent}
                onChange={(e) => setEditContent(e.target.value)}
                rows={16}
                className="rounded-lg border border-slate-200 px-3 py-2 font-mono text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                placeholder="Markdown content..."
              />
            </div>

            <div className="flex items-center gap-2">
              <input
                id="editPublished"
                type="checkbox"
                checked={editPublished}
                onChange={(e) => setEditPublished(e.target.checked)}
                className="h-4 w-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500"
              />
              <label htmlFor="editPublished" className="text-sm text-slate-700">Published</label>
            </div>

            <div className="flex items-center justify-end gap-3">
              {saved && (
                <span className="flex items-center gap-1 text-sm text-emerald-600">
                  <CheckCircle className="h-4 w-4" />
                  Saved
                </span>
              )}
              <button onClick={cancelEdit} className="rounded-lg px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100">
                Cancel
              </button>
              <button
                onClick={savePost}
                disabled={saving || !editTitle.trim()}
                className="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-blue-700 disabled:opacity-50"
              >
                {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
                {editingPost ? "Update Post" : "Create Post"}
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
        {filteredPosts.length === 0 ? (
          <div className="p-8 text-center text-sm text-slate-400">
            No content found. Create your first post.
          </div>
        ) : (
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-slate-500">
              <tr>
                <th className="px-6 py-4 font-medium">Title</th>
                <th className="px-6 py-4 font-medium">Category</th>
                <th className="px-6 py-4 font-medium">Status</th>
                <th className="px-6 py-4 font-medium">Updated</th>
                <th className="px-6 py-4 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredPosts.map((post) => (
                <tr key={post.id} className="transition-colors hover:bg-slate-50">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <FileText className="h-4 w-4 text-slate-400" />
                      <span className="font-medium text-slate-800">{post.title}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="inline-flex items-center rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-medium text-slate-700">
                      {post.category}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
                      post.published ? "bg-emerald-100 text-emerald-700" : "bg-amber-100 text-amber-700"
                    }`}>
                      {post.published ? "Published" : "Draft"}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-slate-500">
                    {new Date(post.updatedAt).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        onClick={() => startEditing(post)}
                        className="rounded-md p-2 text-slate-400 transition-colors hover:bg-blue-50 hover:text-blue-600"
                      >
                        <FileText className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => deletePost(post)}
                        className="rounded-md p-2 text-slate-400 transition-colors hover:bg-red-50 hover:text-red-600"
                      >
                        <XCircle className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
