# AI Tool Usage Declaration

**Project:** Elaros Health Monitoring App
**Submitted by:** Abdur Rehman

---

## Declaration

This document declares the use of AI assistant tools (specifically **Claude / ChatGPT**) during the development of the Elaros mobile application. AI was used as a **collaborative coding assistant** — similar to how developers use Stack Overflow, official documentation, or pair programming — to research approaches, debug issues, and accelerate implementation. All architectural decisions, feature requirements, testing, and final code review were performed by the project team.

---

## How AI Was Used

The AI assistant was used in three primary ways:

1. **Research and Recommendation** — Asking how to approach a specific feature
2. **Debugging** — Diagnosing errors and suggesting fixes
3. **Boilerplate Generation** — Generating repetitive structures (model classes, basic widget layouts) which were then reviewed, modified, and integrated

---

## Sample Prompts Used During Development

Below are representative prompts used during the project, organized by feature area. Each shows the kind of question asked and the type of guidance received.

### 1. Database & Data Seeding

**Prompt:**
> "I have a Flutter app for health monitoring. The app needs to show 7 days of heart rate, steps, sleep, and HRV data on first launch. What's the best way to populate the database with realistic sample data when a new user signs up?"

**AI Suggestion (summary):**
- Use a `SampleDataSeeder` service that runs on first launch
- Generate data with realistic circadian patterns (lower HR at night, peaks during day)
- Use SQLite batch inserts for performance
- Filter by user_id so each user has independent data

**Prompt:**
> "How do I bundle a pre-built SQLite database file with my Flutter app and copy it to writable storage on first launch? It should work on both Windows desktop and Android."

**AI Suggestion (summary):**
- Place the `.db` file in `assets/database/`
- On first launch, use `rootBundle.load()` to read the asset
- Copy bytes to `getDatabasesPath()` location using `dart:io` File API
- Skip the file copy on web platforms (use `kIsWeb` check)

---

### 2. Real-Time Data Simulation

**Prompt:**
> "I want to simulate live heart rate data for testing. The simulator should generate readings every 5 seconds, support multiple modes (Normal, High HR, Low HR, Overexertion), and continue running even when the user navigates to other screens. How should I architect this?"

**AI Suggestion (summary):**
- Create a singleton `SimulationService` (not tied to any widget)
- Use `Timer.periodic` for the 5-second tick
- Use the Observer pattern (listener callbacks) so UI screens can subscribe
- Persist state across navigation by using a static singleton instance

**Prompt:**
> "When I switch from Overexertion mode to Normal mode in the simulator, the dashboard still shows the old high heart rate values. Why isn't it updating?"

**AI Suggestion (summary):**
- The SQL query was using `ORDER BY timestamp DESC LIMIT 1`
- Old burst data had future timestamps within the current hour (e.g., 05:45 when current time is 05:44)
- Fix: only generate timestamps up to the current minute, AND clear today's data when switching modes

---

### 3. Heart Rate Zone Calculations

**Prompt:**
> "How do I calculate personalized heart rate zones for users with chronic illness? I have their resting heart rate (RHR) and max heart rate (MHR). I need 5 zones: Recovery, Sustainable, Caution, Risk, Overexertion."

**AI Suggestion (summary):**
- Use the Heart Rate Reserve (HRR) formula: `Zone Boundary = RHR + (% × (MHR − RHR))`
- Conservative thresholds for chronic illness: 30%, 50%, 65%, 80%, 100%
- Add a fallback when MHR is too close to RHR (use `RHR + 100`)
- Store zones per-user in an `ActivityZone` table

---

### 4. Theme Switching (Light/Dark/Color-Blind)

**Prompt:**
> "I need to add light mode, dark mode, and a color-blind friendly mode that affects the entire app. All my screens currently use hardcoded colors. What's the best Flutter pattern to implement this without rewriting every screen?"

**AI Suggestion (summary):**
- Centralize all colors in an `AppColors` class with a `factory of(BuildContext)`
- Use a `ThemeProvider` (ChangeNotifier) for state
- Color-blind mode swaps red/green for blue/orange variants
- Replace `_bgColor`, `_cardBg`, etc., across screens with `colors.background`, `colors.card`

---

### 5. Goal Tracking with Real Data

**Prompt:**
> "My fitness goals (Daily Steps, Sleep Hours, etc.) need to update their progress automatically from real database data. Currently the user has to manually enter the current value. How should I auto-link goals to live data?"

**AI Suggestion (summary):**
- Map each goal type to a SQL query against the appropriate table
- Example: "Daily Steps" → `SELECT SUM(steps) FROM StepCount WHERE user_id=? AND date(timestamp)=date('now')`
- Run the update in `_loadProfile()` after fetching goals
- Use a dropdown for goal type selection so the unit auto-populates

---

### 6. Debugging & Error Resolution

**Prompt:**
> "I get this error on Windows desktop: `databaseFactory not initialized. databaseFactory is only initialized when using sqflite. When using sqflite_common_ffi You must call databaseFactory = databaseFactoryFfi`"

**AI Suggestion (summary):**
- Initialize the FFI database factory in `main()` before `runApp`
- Use platform check: `if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS))`
- Call `sqfliteFfiInit()` then `databaseFactory = databaseFactoryFfi`

**Prompt:**
> "Login works on Windows but throws `Unsupported operation: _Namespace` on Edge browser. The console shows: 'DB init check failed'. How to fix?"

**AI Suggestion (summary):**
- The `dart:io` File class doesn't work on web
- Wrap file operations with `if (!kIsWeb)` guard
- On web, skip the asset copy and let SQLite create a fresh DB

**Prompt:**
> "After running `flutter clean`, the app crashes on launch because SharedPreferences still has the old user_id but the database was wiped. How do I handle this?"

**AI Suggestion (summary):**
- In `AuthService.init()`, after reading the saved user_id from SharedPreferences
- Verify the user actually exists in the database
- If not, clear the session and let the user log in fresh

---

### 7. Forgot Password Flow

**Prompt:**
> "Add a forgot password screen that lets users reset their password by entering their email and a new password. It should integrate with my existing AuthService."

**AI Suggestion (summary):**
- Add `verifyEmail(String email)` and `resetPassword(String email, String newPassword)` methods to `AuthService`
- Use the same SHA-256 hashing as the login flow
- Two-step UI: verify email exists → enter new password
- Show success message and auto-redirect to login

---

### 8. Cross-Platform Build Issues

**Prompt:**
> "On my friend's Windows machine, `flutter run` fails with: `PathExistsException: Cannot create link, path = ...plugin_symlinks\path_provider_windows`. How do we fix it?"

**AI Suggestion (summary):**
- This is a Flutter symlink bug on Windows
- Solution: `flutter clean && flutter pub get && flutter run`
- If still failing, manually delete `windows\flutter\ephemeral\.plugin_symlinks` first

---

### 9. Documentation Generation

**Prompt:**
> "Create a comprehensive markdown documentation file describing the codebase structure, database schema, navigation flow, and design patterns used in my Flutter health app."

**AI Suggestion (summary):**
- Generated `CODEBASE_DOCUMENTATION.md` describing all 59+ source files
- Documented all 16 database tables with column descriptions
- Created data pipeline diagram (Simulator → DB → Service → ViewModel → UI)
- Listed all design patterns (Singleton, Observer, ChangeNotifier, Repository)

---

### 10. Test Case Generation

**Prompt:**
> "Generate test cases for my Flutter health app — both manual test scenarios and automated unit tests. The app has authentication, dashboard, simulator, and goals features."

**AI Suggestion (summary):**
- Created 84 manual test cases with steps and expected results
- Generated 56 automated unit tests covering:
  - Data model serialization
  - HR zone calculations
  - Password hashing and email validation
  - LoginScreen widget rendering
- All 56 automated tests pass

---

## Verification & Review Process

For every AI-suggested code change, the following was done:

1. **Read and understood** the suggestion before applying it
2. **Tested manually** by running the app and verifying behavior
3. **Modified** suggestions where they didn't fit the project context
4. **Rejected** suggestions that introduced unnecessary complexity
5. **Documented** the final implementation independently

AI was a **tool**, not a substitute for engineering judgment. Critical decisions — including database schema design, the choice of zone thresholds, the multi-mode simulator architecture, and the offline-first approach — were made by the project team based on the project's specific requirements (chronic illness pacing, accessibility, no-cloud-dependency).

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Claude (Anthropic) | Primary code assistance, debugging, documentation |
| ChatGPT (OpenAI) | Occasional cross-reference for alternative solutions |
| GitHub Copilot | Inline code completion |
| Stack Overflow | Independent verification of suggestions |
| Flutter Documentation | Authoritative reference for API usage |

---

## Conclusion

AI tools accelerated development by **roughly 3-5x** for boilerplate-heavy tasks (model classes, repetitive UI patterns, documentation) and were particularly helpful for **debugging cross-platform issues** that required deep knowledge of Flutter's internals. However, the **product design, feature scope, testing, and final code review** were entirely human-driven.

This project demonstrates **responsible AI usage** — leveraging AI for productivity gains while maintaining ownership and understanding of every line of code in the final deliverable.

---

