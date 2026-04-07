var capacitorOneTrustPlugin = (function (exports, core) {
    'use strict';

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
    const OTDevicePermission = Object.freeze({
        idfa: 0,
    });

    // IMPORTANT: the plugin name MUST remain "OneTrust" so that consumer code
    // (e.g. OutSystems) calling the original Cordova plugin name continues to
    // resolve. A mismatch causes "plugin not implemented".
    const OneTrust = core.registerPlugin('OneTrust', {
        web: () => Promise.resolve().then(function () { return web; }).then(m => new m.OneTrustWeb()),
    });

    // The OneTrust CMP SDK is mobile-only. Web is intentionally unsupported —
    // every method rejects so consumers fail fast in the browser instead of
    // silently believing OneTrust is running.
    class OneTrustWeb extends core.WebPlugin {
        async startSDK(_options) {
            throw this.unimplemented('startSDK is not available on web.');
        }
        async initOTSDKData(_options) {
            throw this.unimplemented('initOTSDKData is not available on web.');
        }
        async showBannerUI() {
            throw this.unimplemented('showBannerUI is not available on web.');
        }
        async showPreferenceCenterUI() {
            throw this.unimplemented('showPreferenceCenterUI is not available on web.');
        }
        async showConsentUI(_options) {
            throw this.unimplemented('showConsentUI is not available on web.');
        }
        async dismissUI() {
            throw this.unimplemented('dismissUI is not available on web.');
        }
        async getConsentStatusForCategory(_options) {
            throw this.unimplemented('getConsentStatusForCategory is not available on web.');
        }
        async shouldShowBanner() {
            throw this.unimplemented('shouldShowBanner is not available on web.');
        }
        async isBannerShown() {
            throw this.unimplemented('isBannerShown is not available on web.');
        }
        async getCachedIdentifier() {
            throw this.unimplemented('getCachedIdentifier is not available on web.');
        }
        async getBannerData() {
            throw this.unimplemented('getBannerData is not available on web.');
        }
        async getPreferenceCenterData() {
            throw this.unimplemented('getPreferenceCenterData is not available on web.');
        }
        async getOTConsentJSForWebview() {
            throw this.unimplemented('getOTConsentJSForWebview is not available on web.');
        }
        async observeChanges(_options) {
            throw this.unimplemented('observeChanges is not available on web.');
        }
        async stopObservingChanges(_options) {
            throw this.unimplemented('stopObservingChanges is not available on web.');
        }
    }

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        OneTrustWeb: OneTrustWeb
    });

    exports.OTDevicePermission = OTDevicePermission;
    exports.OneTrust = OneTrust;

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
