# Project Requirements Document (PRD): Neobrutalist CS Micro-Learning App

## 🤖 Instructions for the Developer (LLM)
You are an expert iOS Developer specializing in SwiftUI, SwiftData, and MVVM architecture. Your task is to build a 100% offline, bite-sized learning app based on this PRD. 
* Write clean, modular, production-ready Swift code.
* Do not suggest backend integrations (Firebase, Supabase, etc.). The app is strictly offline.
* Follow the Neobrutalist aesthetic strictly (thick borders, offset shadows, stark colors).
* Build iteratively. Ask the user which Phase they want to tackle first, and output complete files for that phase.

---

## 1. Product Overview
A hyper-fast, offline-first iOS app designed for a 4th-year Computer Science student to learn niche CS topics in micro-sessions (60-180 seconds). The core loop relies on "Micro-Scenarios" (Read -> Apply) rather than passive flashcards.

* **Target OS:** iOS 17+
* **Framework:** SwiftUI
* **Local Database:** SwiftData
* **Architecture:** MVVM (Model-View-ViewModel)

---

## 2. Design System: Neobrutalism
The UI must feel raw, bold, and highly tactile. Avoid soft gradients and blur effects.
* **Colors:** Pure Black (`#000000`), Pure White (`#FFFFFF`), Bright Yellow (`#FFD700`), Hot Pink (`#FF69B4`), Electric Blue (`#0000FF`), and Mint Green (`#98FB98` for correct states), Blood Red (`#FF0000` for incorrect states).
* **Borders:** Thick, pure black borders on all interactive elements (`lineWidth: 3`).
* **Shadows:** Hard, unblurred offset shadows. (`.shadow(color: .black, radius: 0, x: 4, y: 4)`).
* **Typography:** System font, highly bolded. Uppercase for headers and buttons.
* **Animations:** Snappy spring animations (`.spring(response: 0.3, dampingFraction: 0.7)`).

---

## 3. Data Architecture & State

### 3.1 The Seed File (`content.json`)
The app ships with a hardcoded JSON file. On first launch, the app parses this JSON and injects it into SwiftData.

```json
[
  {
    "id": "UUID-STRING-HERE",
    "course": "Concurrency",
    "topic": "Deadlocks",
    "primer": "A deadlock occurs when two threads hold locks the other needs, causing both to freeze indefinitely.",
    "challengeType": "binaryChoice",
    "challengeData": {
      "scenario": "Thread A locks X, waits for Y. Thread B locks Y, waits for X. What happens?",
      "options": ["Deadlock", "Race Condition"],
      "correctIndex": 0,
      "feedback": "Correct. Neither thread can proceed, freezing the app."
    }
  }
]
```

### 3.2 The SwiftData Model (`CardModel`)
Convert the JSON into a SwiftData `@Model` to track Spaced Repetition System (SRS) metrics.

* `id`: String (UUID)
* `course`: String
* `topic`: String
* `primer`: String
* `challengeType`: String (Enum: `binaryChoice`, `spotTheBug`, `fillBlank`)
* `challengeData`: Data (JSON encoded representation of the specific challenge)
* `bucket`: Int (Default `0`)
* `nextReviewDate`: Date (Default `Date.now`)

---

## 4. Spaced Repetition System (SRS) Engine
The app uses a "Lazy Leitner" algorithm. 

### 4.1 Update Logic (`processAnswer`)
When the user completes a challenge:
* **If Correct:** `bucket += 1`. Set `nextReviewDate` based on the new bucket.
  * Bucket 1 = +1 day
  * Bucket 2 = +3 days
  * Bucket 3 = +7 days
  * Bucket 4+ = +30 days
* **If Incorrect:** `bucket = 0`. Set `nextReviewDate` to `Date.now` (Due immediately/next session).

### 4.2 Dynamic Priority Queue (Endless Swipe Engine)
The ViewModel should feed the UI an infinite array of cards by querying SwiftData in this exact priority:
1. **The Medicine (Due):** Cards where `nextReviewDate <= Date.now`.
2. **The New Stuff (Unseen):** Cards where `bucket == 0` AND have never been answered.
3. **The Treadmill (Mastered):** Randomly selected cards where `bucket >= 2` (Fallback to keep the swipe endless).

---

## 5. User Interface & Core Flows

### 5.1 Screen 1: Course Selector (Home)
* A bold, grid-based layout of available courses.
* Each course is a massive button with a Neobrutalist design.
* Includes a "Mix All" button for chaotic, cross-discipline review.

### 5.2 Screen 2: The Swipe Arena (The Core Loop)
* A `ZStack` containing a deck of `CardView` components.
* Only the top card is interactive.
* **Progressive Disclosure:** 
  * Initially shows only the `course`, `topic`, and `primer` text.
  * A giant "APPLY" button sits at the bottom.
  * Tapping "APPLY" uses `.withAnimation` to expand the card downward, revealing the `ChallengeView` (hiding the "APPLY" button, keeping the primer visible).
* **Auto-Swipe:** 
  * Once the user answers the challenge, visually indicate correctness (Green/Red background flash on the choice) and show the `feedback` string.
  * Add a "NEXT" button.
  * Tapping "NEXT" triggers an animation moving the card's `y` offset off-screen (e.g., `-1000`) and removes it from the active array, revealing the next card.

### 5.3 Challenge Views (Interactive Components)
Based on `challengeType`, render one of the following inside the expanded card:
* **Binary Choice (`binaryChoice`):** Two massive vertical buttons.
* **Spot the Bug (`spotTheBug`):** A stylized block of code where each line is a tappable row.
* **Fill the Blank (`fillBlank`):** A code snippet with a `___` gap, and 3 pill buttons at the bottom to slot in the answer.

---

## 6. Implementation Phases (For the LLM)

* **Phase 1: Foundation.** Setup the Xcode project, define the `Codable` structs, create the `content.json` file, and build the initial Data Seeder.
* **Phase 2: SwiftData & SRS.** Setup the `@Model`, the `SwiftData` container, and the `CardManager` logic (Queue and Bucket updates).
* **Phase 3: Neobrutalist UI Primitives.** Create reusable SwiftUI view modifiers for the Neobrutalist borders, shadows, and buttons.
* **Phase 4: The Card Component.** Build the `CardView` with the progressive disclosure (downward expand) animation and integrate the interactive challenge components.
* **Phase 5: The Arena & Flow.** Build the `ZStack` endless swipe logic, connect it to the `CardManager` queue, and build the Home Screen course selector.
