# AI Build Error Log – GK Quiz App

> This folder is auto-maintained by the AI assistant (Antigravity).
> All build errors, `flutter analyze` warnings, and debugging notes are logged here with timestamps.

---

## Log Format

```
## [YYYY-MM-DD HH:MM] – Phase: <phase>
**Error:** <error message>
**File:** <file path>
**Fix:** <what was done>
**Status:** RESOLVED / OPEN
```

---

## 2026-05-06 – Phase: Project Setup

### Entry 1
**Action:** Flutter project created with `flutter create --org com.gkquiz.india quiz_app`
**Status:** SUCCESS – 75 files written

### Entry 2
**Action:** Moved `prompt_1.md` from `C:\Users\LENOVO\Downloads\` → project root
**Status:** SUCCESS

### Entry 3
**Action:** Created `AI/` folder for error logging
**Status:** SUCCESS

---

## 2026-05-06 – Phase: flutter analyze (Post-Build)

### Error 1 – CRITICAL
**Error:** `CardTheme` can't be assigned to `CardThemeData?`
**File:** `lib/app/utils/theme.dart:75`
**Fix:** Change `CardTheme(...)` → `CardThemeData(...)`
**Status:** RESOLVED

### Error 2 – Test File
**Error:** `MyApp` isn't a class – default widget_test.dart references old class name
**File:** `test/widget_test.dart:16`
**Fix:** Remove default test file or update to use GKQuizApp
**Status:** RESOLVED

### Warnings (info level) – withOpacity deprecated
**Warning:** `withOpacity` deprecated, use `.withValues(alpha:)` instead
**Files:** Multiple view files
**Fix:** Replace `color.withOpacity(x)` → `color.withValues(alpha: x)` throughout
**Status:** RESOLVED

### Entry – prefer_const_constructors
**Warning:** Use `const` with `QuizResult(...)` in test
**File:** `test/quiz_test.dart:39`
**Fix:** Changed `final result` → `const result`, inlined duration
**Status:** RESOLVED

---

## 2026-05-06 – Phase: Final Verification ✅

### flutter analyze
**Result:** `No issues found! (ran in 15.8s)`
**Exit code:** 0

### flutter test
**Result:** `All tests passed! (7/7)`
**Exit code:** 0

---

## Notes
- ~~Test Ad IDs are used throughout~~ → **Real AdMob IDs now configured (2026-05-07)**
- Firebase Analytics requires `google-services.json` to be placed in `android/app/` before running on device.
- Run `flutter analyze` after each major phase and log any issues here.

---

## 2026-05-07 – Phase: Real AdMob IDs Configured ✅

### Entry – Live Ad Unit IDs Added
**Action:** Replaced Google test Ad Unit IDs with real GK Quiz AdMob IDs
**Files changed:**
- `lib/app/utils/constants.dart` – all 3 ad unit IDs + App ID constant
- `android/app/src/main/AndroidManifest.xml` – `APPLICATION_ID` meta-data

**IDs set:**

| Ad Type | Ad Unit ID |
|---------|-----------|
| App ID | `ca-app-pub-8244046288565559~1089907341` |
| Banner | `ca-app-pub-8244046288565559/5370493740` |
| Interstitial | `ca-app-pub-8244046288565559/6035112268` |
| Rewarded | `ca-app-pub-8244046288565559/9207914980` |

**Status:** SUCCESS – app will now serve live ads from the GK Quiz AdMob account

---

## 2026-05-07 – Phase: Debugging – No Ads on Pixel 10 ⚠️

### Root Cause Analysis
**Symptom:** Switched from test IDs → real IDs. Ads stopped showing on Pixel 10 (physical device).

**Causes identified:**
1. **Missing test device registration** – With real ad unit IDs, AdMob silently blocks ad requests
   from unregistered physical devices in debug builds to prevent invalid traffic/clicks.
   This is the #1 reason real ads don't show during development.
2. **New ad unit warm-up** – Fresh ad units on AdMob take 24–48h to start serving consistently.
3. **Error code 3 (NO_FILL)** – Common for new accounts/ad units.

### Fix Applied
**File:** `lib/main.dart`
- Added `MobileAds.instance.updateRequestConfiguration(RequestConfiguration(...))` 
  BEFORE `MobileAds.instance.initialize()` in debug mode
- Logs all adapter statuses on init

**File:** `lib/app/services/ad_service.dart`
- Added error code logging with `_printAdTroubleshootingTip(error.code)` for all ad types
- Error codes covered: 0 (internal), 1 (invalid request), 2 (network), 3 (no fill)

### Next Step for User
1. Run `flutter run` and check console for:
   ```
   [AdMob] Use RequestConfiguration.Builder().setTestDeviceIds(...)
   ```
2. Copy the device ID printed there
3. Paste it in `main.dart` → `testDeviceIds: ['YOUR_ID_HERE']`
4. Hot restart → ads will show immediately with test fill

### Error Code Reference
| Code | Meaning | Fix |
|------|---------|-----|
| 0 | Internal error | Hot restart |
| 1 | Invalid request | Check ad unit ID format |
| 2 | Network error | Check internet/firewall |
| 3 | No fill | Register device as test device; wait 24-48h for new units |

### Logcat Analysis (2026-05-07 – Pixel 10 connected)
```
I/Ads: Use RequestConfiguration.Builder().setTestDeviceIds(
         Arrays.asList("ADA2E5CA0C7456A294255F6DE5F90C2F")
       ) to get test ads on this device.

I/Ads: Ad failed to load : 3
[AdService] ❌ Banner FAILED | Code: 3 |
Message: Account not approved yet.
https://support.google.com/admob/answer/9905175#1
```

### TRUE Root Cause ⚠️
**AdMob account is NOT yet approved.**
Error message: `"Account not approved yet"`
This is why ads don't show — it has nothing to do with the device ID or code.

### Fix
1. **Pixel 10 test device ID** → `ADA2E5CA0C7456A294255F6DE5F90C2F` → added to `main.dart`
2. **AdMob account approval** → Go to https://admob.google.com → check account status
   - New AdMob accounts typically take **24–48 hours** to get approved
   - Until then, NO real ads will serve on ANY device
   - Use Google's test ad unit IDs temporarily (see below)

### Temporary Fix While Awaiting Account Approval
Switch back to Google's test IDs in `lib/app/utils/constants.dart` for development:
```dart
static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
```
Switch back to real IDs only after account is approved.

**Status:** OPEN – waiting for AdMob account approval


