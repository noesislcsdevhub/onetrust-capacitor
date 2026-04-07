# @noesis/onetrust-capacitor

Capacitor port of the [`cordova-plugin-onetrust-cmp`](https://github.com/OneTrust/OneTrust-Mobile-Cordova) plugin (version `202303.2.0`). Exposes the OneTrust Consent Management Platform (CMP) SDK to Capacitor apps with the same JS surface the original Cordova plugin provided, so OutSystems / Cordova consumer code keeps working when the build target switches from Cordova to Capacitor.

> **Cordova is the source of truth.** This is a port, not a redesign. Method names, parameters, return values, event names, and event payloads match the original Cordova plugin. Implementation differs internally where Capacitor requires it (PluginCall.resolve needs a JSObject, listeners replace `cordova.fireDocumentEvent`, etc.).

---

## Status

| Platform | Code | Build verified | Runtime validated |
|---|---|---|---|
| **Android** | ✅ Complete | ⏳ Pending first MABS build | ⏳ Pending |
| **iOS**     | ✅ Complete | ⏳ Pending macOS VM      | ⏳ Pending |
| **Web**     | ✅ Stubs only (rejects) | n/a | n/a |

Both native targets are implemented at the code level. Runtime validation comes after the first MABS build.

---

## Installation

```bash
npm install @noesis/onetrust-capacitor
npx cap sync
```

The plugin's Android `build.gradle` pulls `com.onetrust.cmp:native-sdk:202303.2.0.0` from Maven Central automatically. The iOS `podspec` pulls `OneTrust-CMP-XCFramework ~> 202303.2.0.0` automatically via CocoaPods on `pod install` (run by `npx cap sync ios`).

### iOS Info.plist

The OneTrust SDK uses `AppTrackingTransparency` (`showConsentUI` for IDFA). Add the usage description string to the **consuming app's** `Info.plist`:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

---

## Plugin name & registration

The plugin registers as `OneTrust` (NOT `OneTrustPlugin`). This matches the original Cordova `pluginName` from `www/OneTrust.js`, so OutSystems and any other consumer that calls into the Cordova plugin name resolves correctly. **Do not rename it.**

```ts
import { OneTrust } from '@noesis/onetrust-capacitor';
```

---

## API

All return values are wrapped in objects (Capacitor's `PluginCall.resolve` requires `JSObject`). The wrapped values match Cordova's underlying types.

### Initialization

```ts
await OneTrust.startSDK({
  storageLocation: 'cdn.cookielaw.org',
  domainIdentifier: 'YOUR-DOMAIN-ID',
  languageCode: 'en',
  params: {
    countryCode: 'US',
    regionCode: 'CA',
    setAPIVersion: '202303.2.0',
    androidUXParams: { /* Android-only UX JSON */ },
    syncParams: {
      identifier: 'user-id',
      syncProfileAuth: 'jwt-token',
    },
  },
});
// → { status: 1 }
```

### UI

```ts
await OneTrust.showBannerUI();
await OneTrust.showPreferenceCenterUI();

// iOS only — Android always returns -1 (ATT is iOS-exclusive).
const result = await OneTrust.showConsentUI({
  OTDevicePermission: OTDevicePermission.idfa, // 0
});
// iOS:    { status: 'authorized' | 'denied' | 'notDetermined' | 'restricted' }
// Android:{ status: -1 }

await OneTrust.dismissUI();
```

### Query for consent

```ts
const { status }     = await OneTrust.getConsentStatusForCategory({ categoryId: 'C0001' });
const { shouldShow } = await OneTrust.shouldShowBanner();   // 1 / 0
const { shown }      = await OneTrust.isBannerShown();      // raw int from SDK
```

### Identity & BYOUI

```ts
const { identifier } = await OneTrust.getCachedIdentifier();
const { data: bannerData }  = await OneTrust.getBannerData();
const { data: pcData }      = await OneTrust.getPreferenceCenterData();
const { js }                = await OneTrust.getOTConsentJSForWebview();
```

### Consent change events

```ts
// 1. Tell native to start watching the category.
await OneTrust.observeChanges({ categoryId: 'C0001' });

// 2. Listen. The eventName equals the categoryId — same as Cordova.
const handle = await OneTrust.addListener('C0001', (event) => {
  console.log(event.categoryId, event.consentStatus);
});

// 3. Stop (iOS only — Android rejects, see Cordova parity notes below).
await OneTrust.stopObservingChanges({ categoryId: 'C0001' });

// Cleanup the listener handle when done.
handle.remove();
```

### UI dismissal event

```ts
const handle = await OneTrust.addListener('allSDKViewsDismissed', () => {
  console.log('CMP UI fully dismissed');
});
```

---

## Cordova parity notes

These differences exist in the original Cordova plugin and are **preserved on purpose**. If you want any of them fixed, open an issue.

| Method | Behavior | Why |
|---|---|---|
| `stopObservingChanges` | iOS: works. **Android: rejects.** | Cordova's Android `OneTrust.java` has no case for `stopObservingChanges` in its action switch — calls hit the default branch and error. Mirrored. Use `removeAllListeners()` on Android. |
| `initOTSDKData` | **Both platforms reject.** | Cordova exposed it in `www/OneTrust.js` but never wired it natively on either side. Use `startSDK`. |
| `addCustomStylesAndroid` | JS-side console warning only — no native call. | Same as Cordova. Pass `androidUXParams` inside `startSDK`'s `params` object instead. |
| `showConsentUI` (Android) | Always resolves with `{ status: -1 }`. | ATT is iOS-only. Cordova returned -1; mirrored. |
| `getPreferenceCenterData` error message | `"No banner data found"` (yes, "banner") | Copy-paste bug in the original Cordova plugin. Mirrored for strict parity. |

---

## Architecture

Same shape as `diagnostic-capacitor`: thin Capacitor bridge that delegates to feature modules. OneTrust only has one logical feature area (CMP), so there is one module per platform.

```
onetrust-capacitor/
├─ src/
│  ├─ definitions.ts          ← TS contract (full Cordova surface)
│  ├─ index.ts                ← registerPlugin('OneTrust', ...)
│  └─ web.ts                  ← stub: every method rejects
├─ android/
│  └─ src/main/
│     ├─ AndroidManifest.xml  ← declares CMPActivity (dialog theme)
│     ├─ res/layout/activity_c_m_p.xml
│     └─ java/com/noesis/onetrust/
│        ├─ OneTrustPlugin.java        ← thin bridge, @CapacitorPlugin(name="OneTrust")
│        ├─ CMPActivity.java           ← transparent host for the CMP UI
│        └─ modules/CmpModule.java     ← all logic
└─ ios/
   └─ Sources/
      ├─ OneTrustPlugin/
      │  ├─ OneTrustPlugin.swift       ← thin bridge, @objc(OneTrustPlugin)
      │  └─ modules/CmpModule.swift    ← all logic, #if canImport guards
      └─ OneTrustPluginObjC/
         └─ Plugin.m                   ← CAP_PLUGIN(OneTrustPlugin, "OneTrust", ...)
```

**Why two iOS targets?** SPM does not support mixed Objective-C + Swift in a single target, so `Plugin.m` (which contains the `CAP_PLUGIN` macro) lives in its own ObjC target and the Swift target depends on it. Same pattern as `diagnostic-capacitor`.

**Why a separate `CMPActivity`?** The OneTrust SDK's `showBannerUI(activity)` and `showPreferenceCenterUI(activity)` need an Activity host. The original Cordova plugin uses a transparent dialog-themed Activity to overlay the CMP UI on top of the WebView. We mirror that pattern exactly. Dismissal flows back through Capacitor's `@ActivityCallback` and emits `allSDKViewsDismissed`.

---

## Build & release workflow

> All commands assume the plugin lives at `D:\Work\MobilePlugins\onetrust-capacitor`.

### One-time setup

```powershell
cd D:\Work\MobilePlugins\onetrust-capacitor
npm install
```

### Each release cycle

```powershell
cd D:\Work\MobilePlugins\onetrust-capacitor

# 1. Bump the version in package.json to match the next git tag
#    (e.g. "version": "1.0.1"). The podspec reads s.version = package['version']
#    and uses it as the CocoaPods git tag, so a mismatch breaks iOS.

# 2. Build the JS bundle. This populates dist/ which MUST be committed.
npm run build

# 3. Verify dist/ exists and has the expected files
dir dist
#    plugin.cjs.js
#    plugin.cjs.js.map
#    plugin.js
#    plugin.js.map
#    docs.json
#    esm/...

# 4. Commit and tag — the tag MUST match package.json version
git add -A
git commit -m "release: 1.0.1"
git tag v1.0.1
git push
git push --tags
```

> ⚠️ **Do NOT add `dist/` to `.gitignore`.** The published npm package's `main` field points to `dist/plugin.cjs.js`. If `dist/` isn't committed, MABS will install a package with no JS bridge and `Capacitor.Plugins.OneTrust` will be `undefined` at runtime. This is the same hard-fought lesson from `diagnostic-capacitor`.

### MABS / OutSystems integration

In your OutSystems Extensibility Configuration, point at this repo's tag:

```json
{
  "plugin": {
    "url": "https://github.com/<your-org>/onetrust-capacitor.git#v1.0.1"
  }
}
```

Then trigger a MABS build. The plugin will be picked up automatically.

---

## Testing locally with `diagnostic-cap-test`

The same test app pattern used for `diagnostic-capacitor` works here:

```powershell
# 1. Build the plugin
cd D:\Work\MobilePlugins\onetrust-capacitor
npm run build

# 2. In the test app, install from local path and sync
cd D:\Work\MobilePlugins\diagnostic-cap-test
npm install ../onetrust-capacitor
npx cap sync android
# or: npx cap sync ios
```

Then add smoke-test buttons to `capacitor-welcome.js` calling each `OneTrust.*` method and check the console.

---

## Validation checklist

### Android

- [ ] `startSDK` resolves `{ status: 1 }` with valid credentials
- [ ] `startSDK` rejects with the OneTrust error message on bad credentials
- [ ] `shouldShowBanner` returns `{ shouldShow: 1 }` before any consent action
- [ ] `showBannerUI` displays the OneTrust banner
- [ ] `showPreferenceCenterUI` displays the preference center
- [ ] `getConsentStatusForCategory` returns the expected `-1 / 0 / 1`
- [ ] `observeChanges` + `addListener` fires on consent change
- [ ] `allSDKViewsDismissed` fires when CMPActivity finishes
- [ ] `getBannerData` / `getPreferenceCenterData` return non-empty `data`
- [ ] `dismissUI` closes the CMP overlay
- [ ] `stopObservingChanges` rejects (Cordova parity — expected)

### iOS

- [ ] All Android items above
- [ ] `showConsentUI({ OTDevicePermission: 0 })` displays the ATT pre-prompt then the system ATT prompt
- [ ] `showConsentUI` resolves with the ATT status string
- [ ] `stopObservingChanges` resolves successfully (iOS-only, unlike Android)

---

## License

MIT
