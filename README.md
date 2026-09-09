# FitOS

An iOS-first adaptive strength-training platform that answers one question exceptionally well:

> **What should I train today, based on what I actually did?**

Instead of assuming the user followed a fixed Push/Pull/Legs calendar, FitOS maintains a rolling training state across muscle stimulus, training debt, recovery, goals, available time, and later nutrition/body trends. It then builds the next session around the user's real history.

## Product wedge

- Fast workout logging
- Compound-exercise stimulus split across primary and secondary muscles
- Rolling 7-day training debt per muscle
- Recovery gating
- Dynamic **Train Today** workout generation
- Progressive overload and later deload logic
- Body weight / circumference trends
- Apple Health integration
- AI explanations on top of deterministic calculations
- MCP/API layer so users can connect the AI assistant of their choice

## Architecture principle

**Math first, LLM second.**

The training engine calculates volume, effective stimulus, recovery, deficits, and priorities deterministically. AI interprets that structured state, explains recommendations, and handles natural language. It does not invent the underlying numbers.

## Repository status

The first implementation slice is a Swift package containing the deterministic Training State Engine and workout generator. This makes the core logic unit-testable before the SwiftUI shell is built.

```bash
swift test
```

## Initial milestones

1. Training State Engine ✅
2. Adaptive workout generation ✅ foundation
3. Exercise catalog + muscle mappings
4. SwiftUI workout logger
5. Local persistence (SwiftData)
6. Supabase sync/auth
7. Body metrics + Apple Health
8. AI coaching layer
9. MCP/API
10. TestFlight beta

See `docs/ARCHITECTURE.md` and `docs/MVP.md`.
