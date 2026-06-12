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

> **Q&A — Product Overview**
> 
> **Q1: What is the app's bundle identifier and display name?**
> A: Bundle ID = `com.pocketing.app`. Display name = **"Pocketing"**.
> 
> **Q2: iPhone-only or Universal (iPad)?**
> A: iPhone-optimized, iPad-compatible (no separate iPad layout).
> 
> **Q3: Supported orientations?**
> A: Portrait only.

---

## 2. Design System: Neobrutalism
The UI must feel raw, bold, and highly tactile. Avoid soft gradients and blur effects.
* **Colors:** Pure Black (`#000000`), Pure White (`#FFFFFF`), Bright Yellow (`#FFD700`), Hot Pink (`#FF69B4`), Electric Blue (`#0000FF`), and Mint Green (`#98FB98` for correct states), Blood Red (`#FF0000` for incorrect states).
* **Borders:** Thick, pure black borders on all interactive elements (`lineWidth: 3`).
* **Shadows:** Hard, unblurred offset shadows. (`.shadow(color: .black, radius: 0, x: 4, y: 4)`).
* **Typography:** System font, highly bolded. Uppercase for headers and buttons.
* **Animations:** Snappy spring animations (`.spring(response: 0.3, dampingFraction: 0.7)`).

> **Q&A — Design System**
> 
> **Q4: Screen background color?**
> A: Pure White (`#FFFFFF`) for main backgrounds. Bright Yellow (`#FFD700`) as accent background for the Home screen header area.
> 
> **Q5: Concrete font sizes for each typographic level?**
> A: Title/Header = 28pt `.bold`, Body/Primer = 16pt `.medium`, Caption/Label = 12pt `.semibold`. Buttons = 18pt `.bold` `.uppercased()`.
> 
> **Q6: Corner radius — sharp or slightly rounded?**
> A: Neobrutalism convention: `cornerRadius: 0` (sharp corners) on all bordered elements.
> 
> **Q7: Per-course accent colors for the Course Selector buttons?**
> A: Yes. Assign a deterministic accent from the palette per course: Concurrency → Hot Pink, Data Structures → Electric Blue, Operating Systems → Bright Yellow. "Mix All" → Pure White with black border.

---

## 3. Data Architecture & State

### 3.1 The Seed File (`content.json`)
The app ships with a hardcoded JSON file. On first launch, the app parses this JSON and injects it into SwiftData.

**`binaryChoice` example:**
```json
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
```

> **Q&A — Data Architecture**
> 
> **Q8: How many seed cards and across which courses?**
> A: Minimum **20 cards** across **3 courses**: Concurrency, Data Structures, Operating Systems. At least 2 of each challenge type per course (minimum 6 `binaryChoice`, 6 `spotTheBug`, 6 `fillBlank`, plus 2 extras).
> 
> **Q9: JSON structure for `spotTheBug` challengeData?**
> A:
> ```json
> {
>   "codeLines": ["func swap(a: Int, b: Int) {", "  var temp = a", "  a = temp", "  b = a", "}"],
>   "bugLineIndex": 2,
>   "feedback": "Line 3 should assign 'b' to 'temp' before overwriting 'a'."
> }
> ```
> Fields: `codeLines: [String]`, `bugLineIndex: Int` (0-indexed), `feedback: String`.
> 
> **Q10: JSON structure for `fillBlank` challengeData?**
> A:
> ```json
> {
>   "snippet": "let queue = DispatchQueue(label: \"bg\", attributes: ___)",
>   "options": [".concurrent", ".serial", ".background"],
>   "correctIndex": 0,
>   "feedback": "The '.concurrent' attribute allows multiple tasks to run simultaneously."
> }
> ```
> Fields: `snippet: String` (containing `___`), `options: [String]` (exactly 3), `correctIndex: Int`, `feedback: String`.
> 
> **Q11: Store `challengeData` as `Data` blob or as a relationship?**
> A: Store as `Data` (JSON-encoded blob) as specified. Decode into typed Swift structs (`BinaryChallengeData`, `SpotTheBugChallengeData`, `FillBlankChallengeData`) on access via a computed property.
> 
> **Q12: How to differentiate "unseen" cards from "incorrect-reset" cards (both have bucket==0)?**
> A: Add a `timesAnswered: Int` (default `0`) field to `CardModel`. Unseen = `bucket == 0 && timesAnswered == 0`. Increment `timesAnswered` on every answer.

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
* `timesAnswered`: Int (Default `0`) — **Added per Q12**

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
* **Always:** `timesAnswered += 1` — **Added per Q12**

> **Q&A — SRS Engine**
> 
> **Q13: Does bucket increment beyond 4?**
> A: Yes, the bucket integer is unbounded. The interval formula caps at +30 days for any bucket ≥ 4.
> 
> **Q14: Bucket 0 initial `nextReviewDate`?**
> A: `Date.now` — cards are immediately due on first launch.

### 4.2 Dynamic Priority Queue (Endless Swipe Engine)
The ViewModel should feed the UI an infinite array of cards by querying SwiftData in this exact priority:
1. **The Medicine (Due):** Cards where `nextReviewDate <= Date.now`.
2. **The New Stuff (Unseen):** Cards where `bucket == 0` AND `timesAnswered == 0`.
3. **The Treadmill (Mastered):** Randomly selected cards where `bucket >= 2` (Fallback to keep the swipe endless).

> **Q&A — Queue**
> 
> **Q15: How many "Treadmill" cards to fetch per batch?**
> A: Fetch up to **5** random mastered cards at a time. Reshuffle when exhausted.
> 
> **Q16: Active card buffer size?**
> A: Maintain a buffer of **10** cards in the ViewModel. Refill from SwiftData when fewer than **3** remain in the buffer.

---

## 5. User Interface & Core Flows

### 5.1 Screen 1: Course Selector (Home)
* A bold, grid-based layout of available courses.
* Each course is a massive button with a Neobrutalist design.
* Includes a "Mix All" button for chaotic, cross-discipline review.

> **Q&A — Home Screen**
> 
> **Q17: Grid layout — columns?**
> A: 2-column `LazyVGrid` with `GridItem(.flexible())` spacing 16pt.
> 
> **Q18: "Mix All" button placement?**
> A: Full-width button **above** the course grid, visually distinct (white background, black border, hot pink text).

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

> **Q&A — Arena**
> 
> **Q19: Swipe direction?**
> A: Vertical (upward) via `y` offset animation as specified. No drag gesture — purely button-driven ("NEXT").
> 
> **Q20: Session summary / stats screen?**
> A: Not in MVP. Out of scope.
> 
> **Q21: Navigation mechanism?**
> A: `NavigationStack` with `navigationDestination`. Home pushes to Arena with a `course: String?` parameter (`nil` = Mix All).
> 
> **Q22: Visual deck depth in ZStack?**
> A: Render the top **3** cards. Cards below the top get `scaleEffect(1 - 0.05 * depth)` and `offset(y: CGFloat(depth) * 8)` for a stacked appearance. Only top card (`depth == 0`) receives user interaction.

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
