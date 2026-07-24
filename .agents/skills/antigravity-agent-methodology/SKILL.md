---
name: antigravity-agent-methodology
description: >-
  General software development methodology and agent execution standard:
  planning-first workflow, zero-trust security, strict performance budgeting,
  codebase mapping, and empirical verification. Use for any general coding task,
  refactoring, or feature implementation.
---

# Antigravity Agent Methodology & Execution Standards

## Overview
This skill defines the universal operating framework for the AI coding agent across all software engineering projects (Game Dev, Web Applications, Backend Services, and System Infrastructure).

## 4 Core Pillars of Engineering Excellence

### 1. Planning & Intent Alignment
- **Investigate Before Editing**: Never modify files blindly. Inspect line definitions, parent schemas, and invocation sites.
- **Architectural Implementation Plan**: Create `implementation_plan.md` for major changes, specifying proposed diffs, risk factors, and verification steps.

### 2. Zero-Trust & Defensive Architecture
- **Server-Authoritative Enforcement**: Treat all client data as untrusted. Validate physics boundaries, distances, balances, and permissions on the server.
- **Graceful Fallbacks**: Design systems to fail safely (e.g. procedural primitive fallbacks when 3D models or network assets are unavailable).

### 3. Resource & Memory Budgeting
- **Strict RAM Constraints**: Allocate objects wisely (<6GB total RAM target).
- **Object Recycling**: Implement object pooling for high-frequency allocations (particles, projectiles, UI nodes).

### 4. Empirical Verification & Quality Gates
- **Never Claim Success Without Evidence**: Run tests, linters, and build scripts.
- **Clean Log Synthesis**: Inspect logs silently, identify root causes, and present clear solutions to the user.

## Workflow Checklist
- [ ] Codebase mapped & dependencies checked
- [ ] Implementation plan created & reviewed
- [ ] Code written with strict types & zero anti-patterns
- [ ] Automated build & static linters passed cleanly
- [ ] Walkthrough report generated with empirical proof
