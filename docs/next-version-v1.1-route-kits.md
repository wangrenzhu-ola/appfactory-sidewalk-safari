# Sidewalk Safari v1.1 — Route Kits + Walk Recap

Date: 2026-07-09
Status: planned-and-implemented-in-this-branch

## Product thesis

v1.0 proves the core loop: choose a quest, complete clue tiles, save a Find Moment, and keep a local Safari Log. v1.1 should reduce the parent’s setup time before leaving home and make the walk feel worth replaying afterward.

## Target user pain

- Parents need a quest matched to the walk they are already taking, not just a generic starter list.
- Starter quests are useful, but the parent needs a safe way to copy one into an editable custom quest.
- After a walk, the Safari Log should summarize what happened in kid-friendly language instead of only listing counts.

## Scope

### P0 — Route Kits

Add quick-planning route kits for common short walks:

- School Walk
- Bus Stop
- Park Gate
- Errand Loop

Each route kit provides a route hint and three editable clue prompts. Creating from a kit makes a normal custom `SidewalkQuest`, saved locally and fully editable.

### P0 — Copy Quest

Add a copy action for starter or saved quests. The copied quest becomes a custom quest with waiting clue tiles so a parent can tune it for today’s sidewalk.

### P0 — Walk Recap

Show a local walk recap in Quest Run and Safari Log:

- completed clues
- skipped clues
- saved Find Moments
- replay count
- a next-step suggestion

### Non-goals

- No map, GPS, community cache, upload, child tracking, backend account, or AI clue generation.
- No StoreKit purchase path beyond the existing premium unavailable preview.
- No new dependency.

## Acceptance

- Route Kit cards are visible from Quest Picker and create a persisted custom quest.
- Copy Quest is reachable from a quest card and produces a custom editable copy.
- Walk Recap is visible for a quest with progress or Find Moments.
- Unit tests cover route-kit creation, quest copy reset behavior, and recap counts.
- Xcode tests pass; simulator install/launch evidence is refreshed.
