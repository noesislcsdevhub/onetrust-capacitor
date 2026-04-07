import { WebPlugin } from '@capacitor/core';
// The OneTrust CMP SDK is mobile-only. Web is intentionally unsupported —
// every method rejects so consumers fail fast in the browser instead of
// silently believing OneTrust is running.
export class OneTrustWeb extends WebPlugin {
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
//# sourceMappingURL=web.js.map