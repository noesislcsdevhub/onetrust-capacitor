// ---------------------------------------------------------------------------
// OneTrust Capacitor plugin — TypeScript contract
// ---------------------------------------------------------------------------
// Faithful port of the cordova-plugin-onetrust-cmp surface (www/OneTrust.js).
// Method names match Cordova exactly. Return shapes are wrapped in JSObjects
// to satisfy the Capacitor bridge constraint (PluginCall.resolve requires an
// object), but the underlying values match Cordova's behavior.
//
// Cordova asymmetries preserved on purpose (do NOT "fix" without discussion):
//   - stopObservingChanges: implemented on iOS only in Cordova. Android
//     rejects the call. Mirrored.
//   - initOTSDKData: deprecated, never wired natively in Cordova. Mirrored.
//   - showConsentUI: Android always returns -1 (ATT is iOS-only).
// ---------------------------------------------------------------------------
/**
 * Device permission types accepted by showConsentUI.
 * Mirrors the Cordova `OneTrust.devicePermission` enum.
 */
export const OTDevicePermission = Object.freeze({
    idfa: 0,
});
//# sourceMappingURL=definitions.js.map