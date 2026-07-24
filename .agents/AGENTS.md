# Antigravity Agent Engineering Standards & Operating Methodology

## 1. Operating Workflow
All non-trivial feature developments and architectural modifications must follow this strict cycle:
1. **Understand Codebase & Map Dependencies**: Use structural analysis, trace imports, and verify schemas before making changes.
2. **Plan & Obtain User Feedback**: Create an implementation plan (`implementation_plan.md`) with explicit verification steps and risk analysis.
3. **Execute & Test**: Write clean, strongly typed code (`--!strict` in Luau / TypeScript / Python).
4. **Empirical Verification**: Run automated build commands (e.g. `rojo build -o test.rbxl`), linters (`selene`), and test suites before declaring success.

## 2. Code Quality & Performance Guidelines
- **Zero-Trust Security**: Always validate client inputs server-side. Enforce physical distance checks ($\le 15$ studs), balance checks, and ownership verification.
- **Strict Resource Budgeting**: Maintain total memory under $< 2.5\text{ GB}$ RAM (Low-End Mobile Target). Use `ObjectPool` for transient visual effects, particle instances, and temporary UI nodes. Max 20 active particles per emitter.
- **Config-Driven Architecture**: Decouple logic from data. Store items, recipes, drop rates, and balance constants in dedicated configuration files (`Config` tables).

## 3. UI/UX & Juiciness Standards
- **Anti-AI-Slop**: Avoid generic, plain-looking UI. Implement vibrant curated color palettes, custom typography, and dynamic micro-animations.
- **Tactile Feedback**: Every interactive button or element must react to user input (elastic spring tweening, subtle camera shake, sound chimes, haptic feedback).
- **Clean Responsive Layouts**: Keep viewports clutter-free with collapsible drawers, maximum container boundaries (`MaxWidth`), and spatial 3D interactions.

## 4. Security & Network Protocols
- **Zero-Trust Payloads**: Never trust the client. Every `RemoteEvent` and `RemoteFunction` payload must be validated at runtime (e.g. strict `typeof()` checks) before processing, because Luau type hints do not guarantee runtime safety.
- **Graceful Pcall Wrapping**: All external/volatile API calls (`DataStoreService`, `MemoryStoreService`, `MessagingService`, `HttpService`) must be wrapped in `pcall` or `xpcall`.
- **Memory Lifecycle (Janitor/Maid)**: Avoid memory leaks by ensuring all instance connections (`:Connect`) are disconnected when the session/object is destroyed.
- **Strict Typing**: Use `--!strict` headers for all scripts and avoid globals.
