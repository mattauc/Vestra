# Vestra — Project Guide for Claude

## What this app is
Vestra is an iOS portfolio tracking app for everyday investors. Users can track multiple investment types — property, ETFs, and crypto — through a swipeable "page" metaphor. The goal is a full-featured, production-quality app shipped on the App Store.

## Goals and working style
- **Learning tool first.** The user wants to understand the code, not just receive a finished product. Explain your reasoning. Prefer small, focused changes over large rewrites.
- **Production quality.** Everything built here should be App Store ready: secure, tested, and well-structured.
- **Security matters.** Authentication, Firestore rules, and data handling should be production-grade. Flag any security concerns proactively.
- **No unnecessary changes.** Don't refactor, rename, or clean up code that isn't directly related to the task at hand.
- **Never edit a file unless the user explicitly names it in their request.** If a fix requires touching a file the user didn't mention, ask first.

---

## Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Architecture | MVVM |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Reactivity | Combine |
| Platform | iOS |
| Language | Swift |

---

## Architecture

### App entry (`VestraApp.swift`)
`VestraAppModel` is a root `@MainActor ObservableObject` that creates and owns the three top-level managers. They are injected into the view hierarchy as `@EnvironmentObject`.

```
VestraAppModel
├── AuthManager       — Firebase session + user profile
├── UserManager       — subscribes to AuthManager, exposes profile data to views
└── PageStore         — owns all PortfolioPages, persists to Firestore
```

### Navigation flow
```
VestraInterface  (auth gate)
├── LoginView / RegistrationView   (unauthenticated)
└── DashboardView                  (authenticated)
    ├── Tab 0: Home (profile + net worth summary)
    ├── Tab 1: PageStoreView (swipeable card stack)
    └── Tab 2: SettingsView (stub)
```

`PageStoreView` uses a `NavigationStack` with a `NavigationPath`. Tapping a card pushes the detail view (e.g. `PropertyPageView`) onto the stack.

---

## Data models

### `PortfolioPage` (enum)
The central model. An enum with associated values — this is the unified type stored in `PageStore` and persisted to Firestore.

```swift
enum PortfolioPage: Identifiable, Codable, Equatable, Hashable {
    case property(PropertyPage)
    case etf(ETFPage)
    case crypto(CryptoPage)
}
```

### `PagePayload` (protocol)
All page types conform to this. Provides `id: UUID`, `title: String`, `activeInvestment: Bool`.

### Page types
| Type | Status | Model detail |
|---|---|---|
| `PropertyPage` | Most complete | Has `Loan`, `Expenses`, `Valuation`, `PropertyType`, `SuburbDetails` (stub) |
| `ETFPage` | Stub | Only `id`, `title`, `activeInvestment` |
| `CryptoPage` | Stub | Only `id`, `title`, `activeInvestment` |

### `UserProfile`
Stored in Firestore at `users/{uid}`. Fields: `id`, `fullname`, `email`, `networth` (Int), `salary` (Double).

---

## Firestore structure

```
users/
  {uid}                        ← UserProfile document
    pages/
      {pageId}                 ← PortfolioPage document (encoded as PortfolioPage enum)
```

Pages are read/written in bulk by `PageStore`. Each persist call diffs against Firestore: deletes removed pages, upserts remaining ones.

---

## ViewModels

### `AuthManager`
- Owns `FirebaseAuth.User?` session and `UserProfile?`
- `signIn`, `createUser`, `signOut`, `deleteAccount` (stub), `fetchUser`
- Other managers subscribe to `$userSession` and `$currentUser` via Combine

### `UserManager`
- Mirrors `AuthManager.currentUser` via a Combine sink
- Exposes computed properties: `userName`, `userNetworth`, `userSalary`
- `updateSalary()` is a stub

### `PageStore`
- Source of truth for `[PortfolioPage]`
- Reloads from Firestore when `authManager.$userSession` changes
- `createPage`, `addPage`, `updatePage`, `deletePage` — all call `persistPages()` async

### `PropertyPageManager`
- Scoped to a single `PropertyPage` by `pageId`
- Reads initial state from `PageStore`, owns local mutations
- Call `pageStore.updatePage(.property(manager.currentPage))` to persist

---

## Patterns to follow

- **ViewModels**: `@MainActor final class`, conform to `ObservableObject`, use `@Published private(set)` for state
- **Cross-manager reactivity**: Combine `sink` into `cancellables`
- **Previews**: Use `#Preview` macro with `@Previewable @State`; provide real manager instances, not mocks
- **Form validation**: Conform the View to `AuthenticationFormProtocl` (note: existing typo in codebase — do not fix unless asked) and implement `formIsValid: Bool`
- **Currency**: Default to AUD (`Locale.current.currency?.identifier ?? "AUD"`)
- **Thread safety**: All UI state updates go through `@MainActor`

---

## Current state of the app (what's done vs. stub)

### Done
- Firebase Auth: sign in, sign up, sign out
- Firestore persistence for pages (create, read, update, delete)
- `PortfolioPage` enum + `PagePayload` protocol
- Swipeable card stack UI (`PageStoreView` + `PageView` with drag gesture)
- `PropertyPage` model with `Loan`, `Expenses`, `Valuation`
- `PropertyPageView` with editable title, persists on submit
- `PropertyPageManager` for local page mutations
- Navigation: card tap → detail view via `NavigationPath`
- Page creation flow (`PageCreation` sheet → `PageTypeTab`)

### Stubs / in progress
- `ETFPage`, `CryptoPage` — models exist, views are placeholders
- `SettingsView` — empty
- `Dashboard` model — empty
- `SuburbDetails` — empty struct
- `UserManager.updateSalary()` — not implemented
- `AuthManager.deleteAccount()` — not implemented
- `PropertyPageView` close button currently **deletes** the page (likely temporary)

---

## Security considerations (production checklist)
- Firestore security rules must be locked down per-user before App Store submission
- `deleteAccount()` must be implemented before shipping
- Error handling currently uses `print("DEBUG: ...")` — replace with proper error propagation before production
- Passwords are handled by Firebase Auth SDK (never stored locally) — maintain this
- No sensitive data should be logged in production builds
