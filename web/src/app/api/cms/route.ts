import { NextRequest, NextResponse } from "next/server";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export async function GET() {
  try {
    const posts = await prisma.blogPost.findMany({
      orderBy: { updatedAt: "desc" },
    });
    return NextResponse.json({ posts });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to fetch posts", details: String(error) },
      { status: 500 },
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { title, slug, content, excerpt, category, published, authorName, tags } = body as {
      title?: string;
      slug?: string;
      content?: string;
      excerpt?: string;
      category?: string;
      published?: boolean;
      authorName?: string;
      tags?: string;
    };

    if (!title || !slug) {
      return NextResponse.json(
        { error: "Title and slug are required" },
        { status: 400 },
      );
    }

    const existing = await prisma.blogPost.findUnique({ where: { slug } });
    if (existing) {
      return NextResponse.json(
        { error: "A post with this slug already exists" },
        { status: 409 },
      );
    }

    const post = await prisma.blogPost.create({
      data: {
        title,
        slug,
        content: content ?? "",
        excerpt: excerpt ?? "",
        category: category ?? "announcement",
        published: published ?? false,
        authorName: authorName ?? "Admin",
        tags: tags ?? "",
      },
    });

    return NextResponse.json({ post }, { status: 201 });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to create post", details: String(error) },
      { status: 500 },
    );
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const body = await request.json();
    const { id, title, slug, content, excerpt, category, published, authorName, tags } = body as {
      id?: string;
      title?: string;
      slug?: string;
      content?: string;
      excerpt?: string;
      category?: string;
      published?: boolean;
      authorName?: string;
      tags?: string;
    };

    if (!id) {
      return NextResponse.json({ error: "ID is required for update" }, { status: 400 });
    }

    const existing = await prisma.blogPost.findUnique({ where: { id } });
    if (!existing) {
      return NextResponse.json({ error: "Post not found" }, { status: 404 });
    }

    const post = await prisma.blogPost.update({
      where: { id },
      data: {
        ...(title !== undefined ? { title } : {}),
        ...(slug !== undefined ? { slug } : {}),
        ...(content !== undefined ? { content } : {}),
        ...(excerpt !== undefined ? { excerpt } : {}),
        ...(category !== undefined ? { category } : {}),
        ...(published !== undefined ? { published } : {}),
        ...(authorName !== undefined ? { authorName } : {}),
        ...(tags !== undefined ? { tags } : {}),
      },
    });

    return NextResponse.json({ post });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to update post", details: String(error) },
      { status: 500 },
    );
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = request.nextUrl;
    const id = searchParams.get("id");

    if (!id) {
      return NextResponse.json({ error: "ID query parameter is required" }, { status: 400 });
    }

    const existing = await prisma.blogPost.findUnique({ where: { id } });
    if (!existing) {
      return NextResponse.json({ error: "Post not found" }, { status: 404 });
    }

    await prisma.blogPost.delete({ where: { id } });

    return NextResponse.json({ success: true, message: "Post deleted" });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to delete post", details: String(error) },
      { status: 500 },
    );
  }
}
