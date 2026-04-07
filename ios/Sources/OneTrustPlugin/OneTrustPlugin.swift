import Foundation
import Capacitor


@objc(OneTrustPlugin)
public class OneTrustPlugin: CAPPlugin, OneTrustHost {

    private lazy var cmp = CmpModule(plugin: self, host: self)

    public func emitConsentChanged(categoryId: String, consentStatus: Int) {
        notifyListeners(categoryId, data: [
            "categoryId": categoryId,
            "consentStatus": consentStatus
        ])
    }

    public func emitAllSDKViewsDismissed() {
        notifyListeners("allSDKViewsDismissed", data: [:])
    }

    
    @objc func startSDK(_ call: CAPPluginCall) { cmp.startSDK(call) }
    @objc func initOTSDKData(_ call: CAPPluginCall) {
        call.reject("initOTSDKData is deprecated and was never implemented natively. Use startSDK.")
    }
    @objc func showBannerUI(_ call: CAPPluginCall)          { cmp.showBannerUI(call) }
    @objc func showPreferenceCenterUI(_ call: CAPPluginCall) { cmp.showPreferenceCenterUI(call) }
    @objc func showConsentUI(_ call: CAPPluginCall)         { cmp.showConsentUI(call) }
    @objc func dismissUI(_ call: CAPPluginCall)             { cmp.dismissUI(call) }
    @objc func getConsentStatusForCategory(_ call: CAPPluginCall) { cmp.getConsentStatusForCategory(call) }
    @objc func shouldShowBanner(_ call: CAPPluginCall)            { cmp.shouldShowBanner(call) }
    @objc func isBannerShown(_ call: CAPPluginCall)               { cmp.isBannerShown(call) }
    @objc func getCachedIdentifier(_ call: CAPPluginCall) { cmp.getCachedIdentifier(call) }
    @objc func getBannerData(_ call: CAPPluginCall)           { cmp.getBannerData(call) }
    @objc func getPreferenceCenterData(_ call: CAPPluginCall) { cmp.getPreferenceCenterData(call) }
    @objc func getOTConsentJSForWebview(_ call: CAPPluginCall) { cmp.getOTConsentJSForWebview(call) }
    @objc func observeChanges(_ call: CAPPluginCall)     { cmp.observeChanges(call) }
    @objc func stopObservingChanges(_ call: CAPPluginCall) { cmp.stopObservingChanges(call) }
}
