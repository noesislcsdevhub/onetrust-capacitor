#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(OneTrustPlugin, "OneTrust",

    // -----------------------
    // Initialization
    // -----------------------
    CAP_PLUGIN_METHOD(startSDK, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(initOTSDKData, CAPPluginReturnPromise);
    // -----------------------
    // UI
    // -----------------------
    CAP_PLUGIN_METHOD(showBannerUI, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(showPreferenceCenterUI, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(showConsentUI, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(dismissUI, CAPPluginReturnPromise);
    // -----------------------
    // Query for consent
    // -----------------------
    CAP_PLUGIN_METHOD(getConsentStatusForCategory, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(shouldShowBanner, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(isBannerShown, CAPPluginReturnPromise);
    // -----------------------
    // Identity
    // -----------------------
    CAP_PLUGIN_METHOD(getCachedIdentifier, CAPPluginReturnPromise);
    // -----------------------
    // BYOUI
    // -----------------------
    CAP_PLUGIN_METHOD(getBannerData, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(getPreferenceCenterData, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(getOTConsentJSForWebview, CAPPluginReturnPromise);
    // -----------------------
    // Consent change observation
    // -----------------------
    CAP_PLUGIN_METHOD(observeChanges, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(stopObservingChanges, CAPPluginReturnPromise);
    // -----------------------
    // Listeners (Capacitor built-in)
    // -----------------------
    CAP_PLUGIN_METHOD(addListener, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(removeAllListeners, CAPPluginReturnPromise);
)
