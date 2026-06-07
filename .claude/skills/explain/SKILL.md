---
name: explain
description: Explains the current file in learning-friendly terms — what it does, why it's structured that way, and how it fits the Vestra architecture.
---

The user is learning iOS development and using Claude as a teaching tool. They are building Vestra, a SwiftUI investing app using MVVM, Firebase Auth, and Firestore.

When invoked, read the file the user is asking about (or the most recently discussed file if none is specified). Then explain it across three sections:

**What this file does**
Plain English. No jargon unless you define it. What problem does this file solve? What would break if it didn't exist?

**Why it's structured this way**
Explain the architectural decisions. Why is this a `final class` vs a `struct`? Why `@MainActor`? Why `@EnvironmentObject` vs `@ObservedObject`? Why Combine here? Connect the pattern to the MVVM architecture and to Vestra specifically — not just generic iOS theory.

**How it connects to the rest of the app**
Trace the relationships. What creates this? What does this feed into? Where does data come from and where does it go? Reference specific files and types by name (e.g. `PageStore`, `AuthManager`, `PortfolioPage`).

Keep the tone conversational and direct. Use short paragraphs. If there's something worth flagging as a learning moment — a subtle Swift behaviour, a common mistake this pattern avoids, or something in the code that's temporary/incomplete — call it out briefly at the end under a **Worth noting** heading.
