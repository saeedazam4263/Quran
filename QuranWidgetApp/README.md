# Quran Verses Widget — Setup Guide

This is source code, not a ready-to-run app. Two paths are documented here:

- **Path A (below, no Mac needed):** GitHub builds the app for free, you
  sideload it from Windows/Linux.
- **Path B (further down):** you have a Mac and use Xcode directly.

---

## Path A — Build with GitHub, install with Sideloadly (no Mac required)

### 1. Get the code onto GitHub
1. Create a free account at github.com if you don't have one.
2. Create a new **public** repository (public = free unlimited Actions
   minutes; private repos get 2,000 free min/month, still plenty).
3. On the repo page: **Add file → Upload files**, then drag in the whole
   unzipped `QuranWidgetApp` folder (modern browsers upload folders and
   keep the structure). Commit.

### 2. Let GitHub build the .ipa
1. Go to the **Actions** tab of your repo → you'll see "Build IPA" listed.
2. Click it → **Run workflow** → **Run workflow** (green button).
3. Wait 5–10 minutes. When it finishes (green check), click into the run
   and download the **QuranWidgetApp-ipa** artifact — it's a zip
   containing `QuranWidgetApp.ipa`.

### 3. Install Sideloadly on your Windows or Linux PC
1. Download from sideloadly.io (Windows and macOS builds; on Linux it
   runs under Wine).
2. Install Apple's device drivers if prompted (Sideloadly offers this,
   or install iTunes from apple.com first — that's the easiest source).

### 4. Sideload the app to your iPhone
1. Connect your iPhone to the PC with a USB cable, unlock it, tap
   **Trust This Computer**.
2. Open Sideloadly, drag `QuranWidgetApp.ipa` into it.
3. Enter your Apple ID (a free one is fine — this is just for signing,
   not the App Store). Sideloadly recommends an
   [app-specific password](https://support.apple.com/en-us/102654) rather
   than your real one.
4. Click **Start**. It installs directly onto your phone.
5. On the iPhone: **Settings → General → VPN & Device Management** →
   tap your Apple ID → **Trust**.
6. Open the app once, then add the widget: Lock Screen → touch & hold →
   **Customize** → tap below the clock → search "Quran Verses" → add it.

### Known limits of this free route
- A **free Apple ID** signature expires after **7 days** — after that the
  app just won't open until you re-run Sideloadly (same cable, ~1 minute,
  your data/settings stay put). A $99/year Apple Developer account
  extends this to 1 year.
- Only up to 3 free-signed apps per Apple ID at a time on a device.
- If you ever change `project.yml`'s `bundleIdPrefix` or the App Group
  id, update `Shared/AppGroupConstants.swift` to match exactly, or the
  app and widget won't be able to share data.

---

## Path B — You have access to a Mac (Xcode)

No Mac? Skip to Path A above. If you're using a rented cloud Mac or your
own, this is the same GitHub project — just skip GitHub Actions entirely
and open the folder directly in Xcode: File → Open, select the folder
(Xcode will need `project.yml` turned into a project first — easiest is
to install XcodeGen via Homebrew: `brew install xcodegen`, then run
`xcodegen generate` inside the folder, which creates
`QuranWidgetApp.xcodeproj` for you to open).

## What you need
- A Mac with Xcode installed (free from the Mac App Store)
- Homebrew + XcodeGen (`brew install xcodegen`) — generates the project
  from `project.yml` so you don't build target settings by hand
- Your iPhone, a USB cable, and your Apple ID signed into Xcode

## Steps
1. Open Terminal, `cd` into the `QuranWidgetApp` folder
2. Run `xcodegen generate` — this creates `QuranWidgetApp.xcodeproj`
3. Open that file in Xcode
4. Select the **QuranWidgetApp** target → Signing & Capabilities → set
   your Team (your Apple ID). Repeat for the **QuranWidgetExtension**
   target. Xcode will auto-enable signing and register the App Group
   capability that's already defined in `project.yml`
5. Plug in your iPhone, select it as the run destination, press ▶️ Run
6. First run: iPhone will ask you to trust the developer certificate —
   Settings → General → VPN & Device Management → trust it
7. Open the app once, then add the widget: Lock Screen → touch & hold →
   Customize → tap below the clock → search "Quran Verses" → add it

## Notes on how it works
- **Refresh interval**: set in the app's Settings tab (minutes, min 15).
  iOS ultimately schedules the exact refresh timing to preserve battery —
  your number is used as the target interval, which is standard for
  WidgetKit; Apple doesn't allow sub-15-minute guaranteed refreshes.
- **Translations**: English ships built-in. Other languages are downloaded
  once (Languages tab) and cached in the shared App Group container, so
  the widget can work offline afterward.
- **Data source**: verses and translations come from the free
  [AlQuran Cloud API](https://alquran.cloud/api) — no key required. You can
  swap the `editionIdentifier` values in `Shared/Ayah.swift` for other
  translations available on that API.
- **Styling**: pick from 6 built-in themes in the Styling tab. Note Apple
  renders true Lock Screen accessory widgets as tinted/monochrome by
  system design — full color themes show on the Home Screen widget and
  in the in-app preview.
