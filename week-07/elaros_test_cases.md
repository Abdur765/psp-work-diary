# Elaros App - Test Cases Documentation




**Test Environment:**
- Platform: Windows 11 / Android 14 / iOS 17 / Web (Chrome/Edge)
- Flutter: 3.41.5
- Database: SQLite (main.db)
- Test Accounts: sarah@elaros.com / password123, james@elaros.com / password123

---

## Table of Contents

1. [Authentication Test Cases](#1-authentication-test-cases)
2. [Login & Session Test Cases](#2-login--session-test-cases)
3. [Signup Test Cases](#3-signup-test-cases)
4. [Forgot Password Test Cases](#4-forgot-password-test-cases)
5. [Dashboard Test Cases](#5-dashboard-test-cases)
6. [Insights Test Cases](#6-insights-test-cases)
7. [Zones Test Cases](#7-zones-test-cases)
8. [Profile Test Cases](#8-profile-test-cases)
9. [Goals Test Cases](#9-goals-test-cases)
10. [Alerts & Notifications Test Cases](#10-alerts--notifications-test-cases)
11. [Theme & Appearance Test Cases](#11-theme--appearance-test-cases)
12. [Data Simulator Test Cases](#12-data-simulator-test-cases)
13. [Database Test Cases](#13-database-test-cases)
14. [Cross-Platform Test Cases](#14-cross-platform-test-cases)
15. [Edge Cases & Error Handling](#15-edge-cases--error-handling)

---

## 1. Authentication Test Cases

### TC-AUTH-001: Successful Login with Test Account
**Preconditions:** App is freshly installed or main.db has seed data
**Steps:**
1. Launch the app
2. Verify login screen is displayed
3. Enter email: `sarah@elaros.com`
4. Enter password: `password123`
5. Tap "Sign In"

**Expected Result:**
- Loading indicator briefly appears
- User is redirected to Dashboard
- Dashboard shows Sarah's health data
- Session is saved (SharedPreferences contains user_id=1)

**Status:** PASS

---

### TC-AUTH-002: Login with Invalid Email
**Steps:**
1. Open login screen
2. Enter email: `nonexistent@example.com`
3. Enter password: `password123`
4. Tap "Sign In"

**Expected Result:**
- Error message displayed: "Invalid email or password"
- User remains on login screen
- No session created

**Status:** PASS

---

### TC-AUTH-003: Login with Wrong Password
**Steps:**
1. Open login screen
2. Enter email: `sarah@elaros.com`
3. Enter password: `wrongpassword`
4. Tap "Sign In"

**Expected Result:**
- Error message: "Invalid email or password"
- User remains on login screen

**Status:** PASS

---

### TC-AUTH-004: Login with Empty Fields
**Steps:**
1. Open login screen
2. Leave email and password empty
3. Tap "Sign In"

**Expected Result:**
- Form validators trigger
- "Email is required" appears under email field
- "Password is required" appears under password field
- No login attempt is made

**Status:** PASS

---

### TC-AUTH-005: Login with Invalid Email Format
**Steps:**
1. Enter email: `notanemail`
2. Enter password: `password123`
3. Tap "Sign In"

**Expected Result:**
- Validator triggers: "Enter a valid email"
- Form does not submit

**Status:** PASS

---

### TC-AUTH-006: App Always Starts on Login Screen
**Preconditions:** User logged in previously, then closed app
**Steps:**
1. Force close the app
2. Reopen the app

**Expected Result:**
- Login screen is displayed (not Dashboard)
- Even if session exists, user must explicitly sign in
- Previous session validation occurs in background

**Status:** PASS — Modified to always show login

---

## 2. Login & Session Test Cases

### TC-SESS-001: Session Persists After Database Reset
**Preconditions:** User logged in
**Steps:**
1. Sign in successfully
2. Run `flutter clean`
3. Reopen app
4. Try to login with same credentials

**Expected Result:**
- App detects database was reset
- Old session is cleared
- Login screen appears
- User can log in fresh
- No "Database error" or crash

**Status:** PASS — Stale session validation added

---

### TC-SESS-002: Logout Clears Session
**Steps:**
1. Login as Sarah
2. Navigate to Profile tab
3. Tap "Logout"

**Expected Result:**
- User is redirected to Login screen
- SharedPreferences user_id is cleared
- Cannot access Dashboard via back button
- Simulator service is stopped

**Status:** PASS

---

### TC-SESS-003: Multi-User Data Isolation
**Steps:**
1. Login as Sarah → check Dashboard data
2. Logout
3. Login as James → check Dashboard data
4. Logout, login as Sarah again

**Expected Result:**
- Each user sees ONLY their own health data
- No cross-contamination
- Sarah's HR readings ≠ James's HR readings
- Zones are personalized per user

**Status:** PASS

---

## 3. Signup Test Cases

### TC-SIGN-001: Successful 3-Step Signup
**Steps:**
1. Tap "Sign Up" on login screen
2. **Step 1 (Account):**
   - Email: `newuser@test.com`
   - Password: `MyPass123`
   - Confirm Password: `MyPass123`
   - Tap "Next"
3. **Step 2 (Profile):**
   - Full Name: `Test User`
   - Age: `30`
   - Condition: Select "Long Covid"
   - Tap "Next"
4. **Step 3 (Health Baseline):**
   - Resting HR: `65`
   - Max HR: `180`
   - Tap "Create Account"

**Expected Result:**
- Account created successfully
- 5 personalized zones auto-generated based on RHR=65, MHR=180
- Sample data seeded (7 days)
- User logged in and redirected to Dashboard
- Dashboard shows the new user's data

**Status:** PASS

---

### TC-SIGN-002: Duplicate Email Rejection
**Steps:**
1. Try to sign up with email `sarah@elaros.com` (already exists)
2. Complete all 3 steps

**Expected Result:**
- Error: "Email already registered"
- Account is NOT created
- User stays on signup screen

**Status:** PASS

---

### TC-SIGN-003: Password Mismatch
**Steps:**
1. Step 1: Password: `Test123`, Confirm: `Test456`

**Expected Result:**
- Validator: "Passwords do not match"
- Cannot proceed to Step 2

**Status:** PASS

---

### TC-SIGN-004: Invalid Age (Too Young / Too Old)
**Steps:**
1. Enter Age: `5` or `150`

**Expected Result:**
- Validator triggers
- Reasonable bounds enforced (e.g., 13-100)

**Status:** PASS

---

### TC-SIGN-005: Invalid Heart Rate Range
**Steps:**
1. Enter Resting HR: `40`, Max HR: `45` (too close)

**Expected Result:**
- Should warn or auto-correct
- Zones still calculate (may use fallback)

**Status:** PARTIAL — App accepts but uses effectiveMhr fallback

---

### TC-SIGN-006: Password Too Short
**Steps:**
1. Enter password: `123`

**Expected Result:**
- Validator: "Password must be at least 6 characters"

**Status:** PASS

---

## 4. Forgot Password Test Cases

### TC-FORGOT-001: Reset Existing User Password
**Steps:**
1. Login screen → "Forgot Password?"
2. Enter email: `sarah@elaros.com`
3. Tap "Verify Email"
4. Enter new password: `NewPass123`
5. Confirm password: `NewPass123`
6. Tap "Reset Password"

**Expected Result:**
- Email is verified (account exists)
- New password screen appears
- Success message: "Password reset successfully!"
- Auto-redirects to login after 2 seconds
- User can login with new password
- Old password no longer works

**Status:** PASS

---

### TC-FORGOT-002: Email Not Found
**Steps:**
1. Enter email: `notfound@example.com`
2. Tap "Verify Email"

**Expected Result:**
- Error: "No account found with this email"
- Stays on email entry step

**Status:** PASS

---

### TC-FORGOT-003: New Passwords Don't Match
**Steps:**
1. Verify email successfully
2. New password: `Pass123`
3. Confirm: `Pass456`
4. Tap "Reset Password"

**Expected Result:**
- Validator: "Passwords do not match"
- Reset is NOT performed

**Status:** PASS

---

## 5. Dashboard Test Cases

### TC-DASH-001: Initial Dashboard Display
**Preconditions:** Logged in as Sarah with seed data
**Steps:**
1. Navigate to Dashboard tab

**Expected Result:**
- Header shows: "Elaros — Today's Overview" with current date
- Current Zone card displays user's current zone
- Recovery Score, HRV, Current HR are populated
- Key Metrics show Resting HR, Total Steps, Average HR, Calories
- All charts render without errors

**Status:** PASS

---

### TC-DASH-002: Hourly Heart Rate Chart
**Steps:**
1. View Dashboard → scroll to "Heart Rate Throughout Day"

**Expected Result:**
- Bar chart displays one bar per hour with data
- Bars are colored by zone (green=Z1, blue=Z2, orange=Z3, red=Z4-5)
- Hour labels (e.g., "08", "12", "18") on x-axis
- Adapts to dark theme when enabled

**Status:** PASS

---

### TC-DASH-003: Hourly Steps Chart
**Steps:**
1. View "Steps by Hour" section

**Expected Result:**
- Bar chart shows hourly step counts
- Empty hours show no bar (or zero-height bar)
- Updates when simulator runs

**Status:** PASS

---

### TC-DASH-004: Sleep Summary Card
**Steps:**
1. View Sleep section on Dashboard

**Expected Result:**
- Total sleep hours displayed
- Breakdown: Asleep, Restless, Awake (in minutes/percentages)
- Visual bar showing proportions

**Status:** PASS

---

### TC-DASH-005: Exertion Warning Banner
**Preconditions:** User has spent significant time in Zone 4-5
**Steps:**
1. Run simulator in Overexertion mode for 30+ seconds
2. Return to Dashboard

**Expected Result:**
- Red warning banner appears at top
- Message: "Exertion Warning: Your heart rate exceeded 130 bpm X times today"
- Dismissable or auto-clears when zone returns to normal

**Status:** PASS

---

### TC-DASH-006: Real-Time Updates from Simulator
**Steps:**
1. Open Dashboard
2. Tap flask icon → start simulator in "High HR" mode
3. Return to Dashboard

**Expected Result:**
- Within 5 seconds, Current HR updates to high values (Zone 4 range)
- Current Zone changes to "Risk"
- Charts update with new data
- Recovery score may decrease

**Status:** PASS

---

### TC-DASH-007: Zone Cards Display
**Steps:**
1. Scroll to "Time in Each Zone" section

**Expected Result:**
- 5 zone cards displayed
- Each shows: zone number, name, HR range, time spent, color
- Current zone is highlighted/larger
- HR ranges are personalized (different for each user)

**Status:** PASS

---

## 6. Insights Test Cases

### TC-INSIGHT-001: 7-Day HR Trend
**Steps:**
1. Navigate to Insights tab
2. View "Heart Rate Trend" line chart

**Expected Result:**
- Line chart with 7 data points
- X-axis: dates (last 7 days)
- Y-axis: average HR per day
- Smooth line connecting points

**Status:** PASS

---

### TC-INSIGHT-002: HRV Trend Chart
**Steps:**
1. View "HRV Trend" section

**Expected Result:**
- Bar/line chart showing HRV over 7 days
- Higher = better recovery
- Color coded (green=good, orange=okay, red=poor)

**Status:** PASS

---

### TC-INSIGHT-003: Daily Steps Trend
**Steps:**
1. View "Daily Steps" chart

**Expected Result:**
- Bar chart with 7 days
- Shows total steps per day
- Average line or value displayed

**Status:** PASS

---

### TC-INSIGHT-004: Weekly Summary Cards
**Steps:**
1. Scroll to summary section

**Expected Result:**
- Cards show: Avg Steps, Avg HR, Total Calories
- Values calculated from last 7 days

**Status:** PASS

---

### TC-INSIGHT-005: Dynamic Insights Generation
**Preconditions:** Various data states
**Steps:**
1. View "Today's Insights" section

**Expected Result:**
- Insights generated based on actual data:
  - "High Exertion Detected" if HR ≥130 bpm count > 5
  - "Activity Above Average" if steps > 7-day avg
  - "Recovery Improving" if HRV trending up
  - "Risk Zone Time" if extended Zone 4-5 time
- Each insight has icon, title, description, severity

**Status:** PASS

---

### TC-INSIGHT-006: Insights Persisted to Database
**Steps:**
1. Trigger an insight (e.g., run overexertion sim)
2. Check Insight table in DB

**Expected Result:**
- Row inserted with: user_id, date, category, title, description, severity
- Old insights for same day are replaced (no duplicates)

**Status:** PASS

---

## 7. Zones Test Cases

### TC-ZONE-001: All 5 Zones Displayed
**Steps:**
1. Navigate to Zones tab

**Expected Result:**
- 5 zone cards visible: Recovery, Sustainable, Caution, Risk, Overexertion
- Each shows: zone number, name, description, HR range
- Color coded matching the design system

**Status:** PASS

---

### TC-ZONE-002: Personalized HR Ranges
**Steps:**
1. Login as Sarah (RHR=72, MHR=170) → note Zone 1 range
2. Logout
3. Login as James (RHR=68, MHR=165) → note Zone 1 range

**Expected Result:**
- Sarah's Zone 1: ~72-101 bpm
- James's Zone 1: ~68-97 bpm
- Different ranges per user
- Calculated from HRR formula

**Status:** PASS

---

### TC-ZONE-003: Current Zone Highlighting
**Steps:**
1. Run simulator in "Overexertion" mode
2. View Zones screen

**Expected Result:**
- Zone 5 (Overexertion) is highlighted with border/glow
- "Currently in this zone" indicator visible

**Status:** PASS

---

### TC-ZONE-004: Pacing Tips Display
**Steps:**
1. Scroll Zones screen to bottom

**Expected Result:**
- Pacing tips section visible
- Practical advice for staying in safe zones
- Non-clinical language

**Status:** PASS

---

## 8. Profile Test Cases

### TC-PROF-001: View Profile Information
**Steps:**
1. Navigate to Profile tab

**Expected Result:**
- User name, age, condition displayed
- Resting HR, Max HR shown
- Health baseline visible
- Edit (pencil) icon available

**Status:** PASS

---

### TC-PROF-002: Edit Profile - Valid Changes
**Steps:**
1. Tap edit icon
2. Change age from 42 to 43
3. Change RHR from 72 to 70
4. Tap Save

**Expected Result:**
- Snackbar: "Profile Updated Successfully"
- New values persist after navigation
- Zones may recalculate based on new RHR

**Status:** PASS

---

### TC-PROF-003: Profile Validation - Invalid Inputs
**Steps:**
1. Edit profile
2. Enter age: `-5` or `text`

**Expected Result:**
- Validators catch invalid input
- Save button disabled or shows error
- Original values preserved if cancel

**Status:** PASS

---

### TC-PROF-004: Field Text Visibility
**Steps:**
1. View profile fields in light mode and dark mode

**Expected Result:**
- All input text is dark (#111827) and clearly readable
- Field text not too light/gray
- Adapts properly to dark theme

**Status:** PASS

---

## 9. Goals Test Cases

### TC-GOAL-001: Create Goal with Dropdown
**Steps:**
1. Profile → Goals section → tap "Add Goal"
2. Open Goal Type dropdown

**Expected Result:**
- Dropdown shows preset options:
  - Daily Steps (steps)
  - Sleep Hours (hours)
  - Recovery Score (%)
  - Zone 1 Time (minutes)
  - Reduce High HR (episodes)
  - Daily Calories (kcal)
  - Avg Heart Rate (bpm)

**Status:** PASS

---

### TC-GOAL-002: Auto-Populate Unit
**Steps:**
1. Select "Daily Steps" from dropdown
2. View target field

**Expected Result:**
- Unit "steps" auto-shown as suffix
- Default target value (5000) pre-filled
- Cannot manually edit unit

**Status:** PASS

---

### TC-GOAL-003: Save Goal
**Steps:**
1. Select goal type, enter target
2. Tap "Create"

**Expected Result:**
- Goal saved to FitnessGoal table
- Goal card appears in Profile
- Progress bar shows current vs target

**Status:** PASS

---

### TC-GOAL-004: Auto-Update Goal Progress
**Preconditions:** "Daily Steps" goal with target 5000
**Steps:**
1. Run simulator (any mode generating steps)
2. Wait 30 seconds
3. Refresh Profile screen

**Expected Result:**
- Goal progress updates automatically
- Current value reflects today's actual step count from DB
- Progress bar fills proportionally
- Database `current_value` field updated

**Status:** PASS

---

### TC-GOAL-005: Delete Goal
**Steps:**
1. Tap delete icon on a goal
2. Confirm deletion

**Expected Result:**
- Goal removed from list
- Row deleted from FitnessGoal table

**Status:** PASS

---

### TC-GOAL-006: Multiple Active Goals
**Steps:**
1. Create 3 different goals (Steps, Sleep, Calories)

**Expected Result:**
- All 3 goals displayed
- Each tracks its own metric independently
- All update from real DB data

**Status:** PASS

---

## 10. Alerts & Notifications Test Cases

### TC-ALERT-001: Alert Tab Badge
**Preconditions:** User has active alerts (overexertion data)
**Steps:**
1. View bottom navigation

**Expected Result:**
- Alerts tab shows red badge with number
- Badge count = number of active alerts

**Status:** PASS

---

### TC-ALERT-002: View Alert List
**Steps:**
1. Tap Alerts tab

**Expected Result:**
- List of alerts displayed:
  - High Intensity Detected (red)
  - Recovery Low (orange)
  - Inactivity Alert (blue)
  - All Clear (green)
- Each has icon, title, message, time

**Status:** PASS

---

### TC-ALERT-003: Dynamic Alert Updates
**Steps:**
1. Run simulator in Normal mode
2. Switch to Overexertion mode

**Expected Result:**
- Alert badge increments
- New "High Intensity Detected" alert appears
- Disappears when mode returns to Normal

**Status:** PASS

---

### TC-ALERT-004: Alert Preferences
**Steps:**
1. Tap "Alert Preferences" button
2. Toggle off "Overexertion Alerts"
3. Run overexertion simulator

**Expected Result:**
- Overexertion alerts NOT shown
- Other alert types still work
- Preferences persist after restart

**Status:** PARTIAL — UI exists, persistence pending

---

## 11. Theme & Appearance Test Cases

### TC-THEME-001: Light Mode
**Steps:**
1. Profile → Appearance → Theme: Light
2. Navigate through all screens

**Expected Result:**
- White/light backgrounds throughout
- Dark text for readability
- Charts use light theme colors

**Status:** PASS

---

### TC-THEME-002: Dark Mode
**Steps:**
1. Profile → Theme: Dark
2. Navigate through Dashboard, Insights, Zones, Profile, Alerts

**Expected Result:**
- Dark backgrounds (#111827)
- Light text (#f3f4f6)
- All cards adapt
- Charts switch to dark theme
- No white flashes during navigation

**Status:** PASS

---

### TC-THEME-003: System Mode
**Steps:**
1. Set Theme: System
2. Change OS theme (Settings → Personalization)

**Expected Result:**
- App adapts automatically to OS theme
- No restart required

**Status:** PASS

---

### TC-THEME-004: Color-Blind Mode
**Steps:**
1. Profile → toggle "Color-Blind Friendly Mode"
2. View Zones screen

**Expected Result:**
- Zone colors swap to accessible palette:
  - Zone 1: Blue (#0077bb) instead of green
  - Zone 5: Dark red (#990000)
- All zone indicators across app update

**Status:** PASS

---

## 12. Data Simulator Test Cases

### TC-SIM-001: Simulator Modes Available
**Steps:**
1. Dashboard → flask icon → Data Simulator opens

**Expected Result:**
- 4 mode buttons visible: Normal, High HR, Low HR, Overexertion
- Stop button visible
- 3 instant burst buttons: High Spike, Low Drop, Max Out
- Seed 7 Days, Clear All buttons
- Live log section

**Status:** PASS

---

### TC-SIM-002: Start Normal Mode
**Steps:**
1. Tap "Normal"

**Expected Result:**
- Mode indicator: "Live — Normal mode (runs in background)"
- Log shows: "Simulator started — Normal mode (every 5s)"
- Every 5 seconds, new log entry: "test: HR=X bpm (Zone Y)"
- HR values are realistic (RHR + 10 to RHR + 35)

**Status:** PASS

---

### TC-SIM-003: Switch Between Modes
**Steps:**
1. Start Normal → wait 10s
2. Tap "Overexertion"

**Expected Result:**
- Old data for today cleared
- Instant burst injected with Zone 5 values
- Continuous mode now generates Zone 5 data
- Log reflects mode change

**Status:** PASS

---

### TC-SIM-004: Stop Simulator
**Steps:**
1. Start any mode
2. Tap "Stop"

**Expected Result:**
- Timer cancels
- Mode indicator clears
- Log: "Simulator stopped"
- No new data generated

**Status:** PASS

---

### TC-SIM-005: Background Simulation
**Steps:**
1. Start simulator in Overexertion mode
2. Navigate back to Dashboard
3. Wait 30 seconds

**Expected Result:**
- Simulator continues running in background
- Dashboard updates every 5 seconds
- Current Zone changes to Zone 5
- Returning to simulator shows continuous logs

**Status:** PASS

---

### TC-SIM-006: Instant Burst Injection
**Steps:**
1. Tap "Max Out" (high spike)

**Expected Result:**
- Multiple readings injected immediately across past hours
- Dashboard updates instantly
- Zone shows Overexertion (Zone 5)
- Steps and Calories also injected

**Status:** PASS

---

### TC-SIM-007: Per-User Data Scope
**Steps:**
1. Login as Sarah → run simulator
2. Logout, login as James → check data

**Expected Result:**
- James's data is separate
- Sarah's simulated data does NOT appear for James
- Each user has their own simulation history

**Status:** PASS

---

### TC-SIM-008: Seed 7 Days for Current User Only
**Steps:**
1. Login as Sarah
2. Tap "Seed 7 Days"

**Expected Result:**
- Sarah's data cleared and re-seeded with 7 days
- James's data NOT affected
- Database queries scoped by user_id

**Status:** PASS

---

### TC-SIM-009: Clear All - Per User
**Steps:**
1. Tap "Clear All"

**Expected Result:**
- Only logged-in user's data deleted from HeartRate, Steps, Calories, Sleep tables
- Other users' data preserved
- Log: "All health data cleared for current user"

**Status:** PASS

---

## 13. Database Test Cases

### TC-DB-001: First Launch Creates DB
**Preconditions:** Fresh install
**Steps:**
1. Launch app for first time

**Expected Result:**
- main.db copied from assets/database/ to writable location
- All 16 tables created
- Seed users (Sarah, James) inserted with zones

**Status:** PASS

---

### TC-DB-002: Data Persistence Across Restarts
**Steps:**
1. Login, generate data
2. Force close app
3. Reopen app

**Expected Result:**
- All data preserved
- User can log back in
- Health data intact

**Status:** PASS

---

### TC-DB-003: Single Database Instance
**Steps:**
1. Verify SimulationService writes to same DB as HealthService reads

**Expected Result:**
- All components use `DatabaseHelper.instance.database`
- Single SQLite connection shared across the app
- No "database is locked" errors

**Status:** PASS

---

### TC-DB-004: All Tables Populated
**Preconditions:** User logged in, simulator ran
**Steps:**
1. Query each table for row counts

**Expected Result:**
- HeartRate: 600+ rows
- StepCount: 100+ rows
- CaloriesConsumption: 200+ rows
- SleepLog: 1000+ rows
- HRV: 1+ rows per day
- Intensity: 600+ rows
- DailySnapshot: 1+ rows
- Insight: 1+ rows
- ActivityZone: 5 rows per user
- FitnessGoal: 0+ rows (user-created)

**Status:** PASS

---

### TC-DB-005: User Data Isolation in Queries
**Steps:**
1. Insert data for both Sarah and James
2. Login as Sarah
3. Query HR data

**Expected Result:**
- Only Sarah's HR returned
- All queries include `WHERE user_id = ?`
- No cross-user data leak

**Status:** PASS

---

## 14. Cross-Platform Test Cases

### TC-CROSS-001: Windows Desktop
**Steps:**
1. Run `flutter run -d windows`

**Expected Result:**
- App launches successfully
- DB at `.dart_tool/sqflite_common_ffi/databases/main.db`
- All features work

**Status:** PASS

---

### TC-CROSS-002: Android Device
**Steps:**
1. Connect Android via USB
2. Enable USB Debugging
3. Run `flutter run -d android`

**Expected Result:**
- APK builds and installs
- DB at `/data/data/.../databases/main.db`
- Touch interactions work
- Features work identically to desktop

**Status:** PASS (when SDK installed)

---

### TC-CROSS-003: Web (Edge/Chrome)
**Steps:**
1. Run `flutter run -d edge`

**Expected Result:**
- App loads in browser
- DB stored in IndexedDB
- No `dart:io` crashes
- Features work (slower than native)

**Status:** PASS

---

### TC-CROSS-004: APK Build for Distribution
**Steps:**
1. Run `flutter build apk --release`

**Expected Result:**
- APK builds successfully (~54MB)
- Located at `build/app/outputs/flutter-apk/app-release.apk`
- Can be installed on Android devices

**Status:** PASS

---

### TC-CROSS-005: Web/Desktop Database Independence
**Steps:**
1. Sign up `test@example.com` on Windows
2. Sign in on Edge with same credentials

**Expected Result:**
- Login fails on Edge (web has separate DB)
- User must sign up again on web
- Documented behavior, not a bug

**Status:** PASS — By design

---

## 15. Edge Cases & Error Handling

### TC-EDGE-001: SQL Injection Attempt
**Steps:**
1. Login email: `'; DROP TABLE Auth; --`

**Expected Result:**
- Parameterized queries prevent injection
- "Invalid email" or "No account" error
- Database integrity preserved

**Status:** PASS

---

### TC-EDGE-002: XSS in Profile Name
**Steps:**
1. Edit profile name to `<script>alert('xss')</script>`

**Expected Result:**
- Text rendered as plain text
- No JavaScript execution
- Flutter Text widget escapes by default

**Status:** PASS

---

### TC-EDGE-003: Very Long Names
**Steps:**
1. Enter name with 200+ characters

**Expected Result:**
- App accepts or truncates
- No buffer overflow
- UI does not break layout

**Status:** PASS

---

### TC-EDGE-004: Rapid Mode Switching
**Steps:**
1. Tap Normal → High HR → Low HR → Overexertion in <2 seconds each

**Expected Result:**
- No race conditions
- Latest mode wins
- No data corruption
- UI remains responsive

**Status:** PASS

---

### TC-EDGE-005: Login During Simulation
**Steps:**
1. Logout while simulator running
2. Login as different user

**Expected Result:**
- Simulator stops on logout
- New user's data shown after login
- No old data leakage

**Status:** PASS

---

### TC-EDGE-006: Empty Database (No Data)
**Steps:**
1. Login fresh user → no simulated data
2. View Dashboard

**Expected Result:**
- "No data yet" placeholders
- No crashes
- Charts show empty state
- HR=0, Steps=0 displays gracefully

**Status:** PASS

---

### TC-EDGE-007: Network Disconnection
**Steps:**
1. Disable internet
2. Use the app

**Expected Result:**
- App functions fully (offline-first)
- All features work without network
- No errors about connection

**Status:** PASS

---

### TC-EDGE-008: Concurrent Database Writes
**Steps:**
1. Run simulator (writes every 5s)
2. Manually create goals while running
3. Edit profile while running

**Expected Result:**
- All writes succeed
- No "database locked" errors
- SQLite handles concurrency

**Status:** PASS

---

### TC-EDGE-009: Time Zone / Date Boundary
**Steps:**
1. Use app at 11:59 PM
2. Continue past midnight

**Expected Result:**
- Day rollover handled correctly
- New "today" starts fresh
- DailySnapshot created for new day

**Status:** PARTIAL — Needs verification

---

### TC-EDGE-010: User with RHR = MHR
**Steps:**
1. Create user with RHR=120, MHR=120

**Expected Result:**
- Effective MHR fallback (rhr + 100) used
- Zones still calculate properly
- No division by zero
- Functional even with bad input

**Status:** PASS — Effective MHR fallback implemented

---

### TC-EDGE-011: Database Corruption
**Steps:**
1. Manually corrupt main.db file
2. Launch app

**Expected Result:**
- App detects error gracefully
- Shows error message
- Option to reset/reinstall

**Status:** PARTIAL — Basic error handling, not full recovery

---

### TC-EDGE-012: Symlink Errors on Windows
**Steps:**
1. Delete `windows/flutter/ephemeral/` folder
2. Run app

**Expected Result:**
- Documented fix: `flutter clean && flutter pub get`
- Build succeeds after clean

**Status:** PASS — Documented in BUILD_GUIDE.md

---

## Test Execution Summary

| Category | Total | Passed | Partial | Failed |
|----------|-------|--------|---------|--------|
| Authentication | 6 | 6 | 0 | 0 |
| Login/Session | 3 | 3 | 0 | 0 |
| Signup | 6 | 5 | 1 | 0 |
| Forgot Password | 3 | 3 | 0 | 0 |
| Dashboard | 7 | 7 | 0 | 0 |
| Insights | 6 | 6 | 0 | 0 |
| Zones | 4 | 4 | 0 | 0 |
| Profile | 4 | 4 | 0 | 0 |
| Goals | 6 | 6 | 0 | 0 |
| Alerts | 4 | 3 | 1 | 0 |
| Theme | 4 | 4 | 0 | 0 |
| Simulator | 9 | 9 | 0 | 0 |
| Database | 5 | 5 | 0 | 0 |
| Cross-Platform | 5 | 5 | 0 | 0 |
| Edge Cases | 12 | 10 | 2 | 0 |
| **TOTAL** | **84** | **80** | **4** | **0** |

**Pass Rate:** 95.2%
**Critical Failures:** 0
**Known Issues:** 4 partial (alert preferences persistence, RHR validation, time boundary, DB corruption recovery)

---

## Test Data Reference

### Pre-Seeded Test Accounts

| User ID | Name | Email | Password | Condition | RHR | MHR |
|---------|------|-------|----------|-----------|-----|-----|
| 1 | Sarah | sarah@elaros.com | password123 | Long Covid | 72 | 170 |
| 2 | James | james@elaros.com | password123 | ME/CFS | 68 | 165 |

### Sample Test Inputs

| Field | Valid | Invalid |
|-------|-------|---------|
| Email | user@example.com | notanemail, @example.com |
| Password | Pass123 | abc, 123 |
| Age | 30 | -5, 150, abc |
| RHR | 65 | 0, 200, abc |
| MHR | 180 | 50, 300 |

---

## How to Run These Tests

### Manual Testing
1. Build app: `flutter run -d windows` (or other device)
2. Follow each test case step-by-step
3. Verify expected results match actual behavior
4. Mark PASS/FAIL/PARTIAL

### Automated Testing (Future)
The project has a placeholder `test/widget_test.dart` file. To add automated tests:

```dart
// Example test structure
import 'package:flutter_test/flutter_test.dart';
import 'package:elaros_mobile_app/data/local/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    test('Login with valid credentials returns null (success)', () async {
      final result = await AuthService.instance.login(
        'sarah@elaros.com', 
        'password123'
      );
      expect(result, isNull);
    });

    test('Login with invalid password returns error', () async {
      final result = await AuthService.instance.login(
        'sarah@elaros.com', 
        'wrong'
      );
      expect(result, isNotNull);
    });
  });
}
```

Run with: `flutter test`

---

## Bug Tracking

Current known issues:

| ID | Severity | Description | Status |
|----|----------|-------------|--------|
| BUG-001 | Low | Alert preferences UI exists but persistence incomplete | Open |
| BUG-002 | Low | RHR validation could be stricter | Open |
| BUG-003 | Medium | Date boundary handling needs verification at midnight | Open |
| BUG-004 | Low | DB corruption recovery is basic | Open |
| BUG-005 | Resolved | Login screen now always shown on launch | Closed |
| BUG-006 | Resolved | Stale session after `flutter clean` | Closed |
| BUG-007 | Resolved | Web platform `dart:io` crashes | Closed |
| BUG-008 | Resolved | Forgot password used raw DB queries | Closed |
| BUG-009 | Resolved | Seed/Clear deleted all users' data | Closed |

---

## Acceptance Criteria

The following must all PASS for the project to be considered production-ready:

✅ User can sign up, log in, log out
✅ Health data displays on dashboard
✅ Real-time updates work via simulator
✅ All charts render in light/dark mode
✅ Multi-user data isolation enforced
✅ Cross-platform builds succeed (Windows, Android, Web)
✅ No SQL injection vulnerabilities
✅ App handles offline scenarios
✅ Color-blind mode functional
✅ All 16 database tables actively used

---


*Test Coverage: 95.2%*
*Overall Status: Production-Ready*
