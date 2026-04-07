# @noesis/onetrust-capacitor

Capacitor port of the [`cordova-plugin-onetrust-cmp`](https://github.com/OneTrust/OneTrust-Mobile-Cordova) plugin (version `202303.2.0`). Exposes the OneTrust Consent Management Platform (CMP) SDK to Capacitor apps with the same JS surface the original Cordova plugin provided, so OutSystems / Cordova consumer code keeps working when the build target switches from Cordova to Capacitor.


---

## Plugin name & registration

The plugin registers as `OneTrust` (NOT `OneTrustPlugin`). This matches the original Cordova `pluginName` from `www/OneTrust.js`, so OutSystems and any other consumer that calls into the Cordova plugin name resolves correctly. **Do not rename it.**

```ts
import { OneTrust } from '@noesis/onetrust-capacitor';
```

---

## API

All return values are wrapped in objects (Capacitor's `PluginCall.resolve` requires `JSObject`). The wrapped values match Cordova's underlying types.

---

## Cordova parity notes

These differences exist in the original Cordova plugin and are **preserved on purpose** to ensure the same output in Outsystems is given for Capacitor as it's executed for Cordova. 

| Method | Behavior | Why |
|---|---|---|
| `stopObservingChanges` | iOS: works. **Android: rejects.** | Cordova's Android `OneTrust.java` has no case for `stopObservingChanges` in its action switch — calls hit the default branch and error. Mirrored. Use `removeAllListeners()` on Android. |
| `initOTSDKData` | **Both platforms reject.** | Cordova exposed it in `www/OneTrust.js` but never wired it natively on either side. Use `startSDK`. |
| `addCustomStylesAndroid` | JS-side console warning only — no native call. | Same as Cordova. Pass `androidUXParams` inside `startSDK`'s `params` object instead. |
| `showConsentUI` (Android) | Always resolves with `{ status: -1 }`. | ATT is iOS-only. Cordova returned -1; mirrored. |
| `getPreferenceCenterData` error message | `"No banner data found"` (yes, "banner") | Copy-paste bug in the original Cordova plugin. Mirrored for strict parity. |
