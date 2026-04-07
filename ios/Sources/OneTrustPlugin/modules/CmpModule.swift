import Foundation
import Capacitor
import UIKit
import AppTrackingTransparency

#if canImport(OTPublishersHeadlessSDK)
import OTPublishersHeadlessSDK
#endif


@objc public protocol OneTrustHost: AnyObject {
    func emitConsentChanged(categoryId: String, consentStatus: Int)
    func emitAllSDKViewsDismissed()
}

@objc public class CmpModule: NSObject {

    private weak var plugin: CAPPlugin?
    private weak var host: OneTrustHost?

    /// Tracks observed category names so we can clean up on tearDown.
    private var observedCategories = Set<String>()

    @objc public init(plugin: CAPPlugin, host: OneTrustHost) {
        self.plugin = plugin
        self.host = host
        super.init()

        #if canImport(OTPublishersHeadlessSDK)
        // Register self as the OT event listener so allSDKViewsDismissed
        // forwards to the host. Setup UI on the root view controller after
        // the next runloop tick — we need the bridge to be fully attached.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            OTPublishersHeadlessSDK.shared.addEventListener(self)
            if let vc = self.rootViewController() {
                OTPublishersHeadlessSDK.shared.setupUI(vc)
            }
        }
        #endif
    }

    // ------------------------------------------------------------------------
    // Initialization
    // ------------------------------------------------------------------------

    @objc public func startSDK(_ call: CAPPluginCall) {
        guard let storageLocation = call.getString("storageLocation"),
              let domainIdentifier = call.getString("domainIdentifier"),
              let languageCode = call.getString("languageCode") else {
            call.reject("startSDK requires storageLocation, domainIdentifier and languageCode.")
            return
        }

        #if canImport(OTPublishersHeadlessSDK)
        var initParams: OTSdkParams? = nil
        if let paramsData = call.getObject("params") {
            initParams = buildSDKParams(withParamsObject: paramsData as NSDictionary)
        }

        OTPublishersHeadlessSDK.shared.startSDK(
            storageLocation: storageLocation,
            domainIdentifier: domainIdentifier,
            languageCode: languageCode,
            params: initParams
        ) { otResponse in
            if otResponse.status {
                call.resolve(["status": 1])
            } else {
                call.reject("Failed to initialize OneTrust SDK. --> \(otResponse.error.debugDescription)")
            }
        }
        #else
        call.reject("OneTrust SDK is not linked. Add the OneTrust-CMP-XCFramework pod.")
        #endif
    }

    // ------------------------------------------------------------------------
    // UI
    // ------------------------------------------------------------------------

    @objc public func showBannerUI(_ call: CAPPluginCall) {
        #if canImport(OTPublishersHeadlessSDK)
        DispatchQueue.main.async {
            OTPublishersHeadlessSDK.shared.showBannerUI()
            call.resolve()
        }
        #else
        call.reject("OneTrust SDK is not linked.")
        #endif
    }

    @objc public func showPreferenceCenterUI(_ call: CAPPluginCall) {
        #if canImport(OTPublishersHeadlessSDK)
        DispatchQueue.main.async {
            OTPublishersHeadlessSDK.shared.showPreferenceCenterUI()
            call.resolve()
        }
        #else
        call.reject("OneTrust SDK is not linked.")
        #endif
    }

    @objc public func showConsentUI(_ call: CAPPluginCall) {

        guard #available(iOS 14, *) else {
            call.resolve(["status": -1])
            return
        }

        #if canImport(OTPublishersHeadlessSDK)
        guard let permissionInt = call.getInt("OTDevicePermission"),
              let permissionType = appPermissionType(fromInt: permissionInt),
              let vc = rootViewController() else {
            call.reject("showConsentUI requires OTDevicePermission and a host view controller.")
            return
        }

        OTPublishersHeadlessSDK.shared.showConsentUI(for: permissionType, from: vc) { [weak self] in
            let status = self?.getATTStatusAsString() ?? "notDetermined"
            call.resolve(["status": status])
        }
        #else
        call.reject("OneTrust SDK is not linked.")
        #endif
    }

    @objc public func dismissUI(_ call: CAPPluginCall) {
        #if canImport(OTPublishersHeadlessSDK)
        DispatchQueue.main.async {
            OTPublishersHeadlessSDK.shared.dismissUI()
            call.resolve()
        }
        #else
        call.reject("OneTrust SDK is not linked.")
        #endif
    }

    // ------------------------------------------------------------------------
    // Query for consent
    // ------------------------------------------------------------------------

    @objc public func shouldShowBanner(_ call: CAPPluginCall) {
        #if canImport(OTPublishersHeadlessSDK)
        let shouldShow = OTPublishersHeadlessSDK.shared.shouldShowBanner() ? 1 : 0
        call.resolve(["shouldShow": shouldShow])
        #else
        call.reject("OneTrust SDK is not linked.")
        #endif
    }

    @objc public func isBannerShown(_ call: CAPPluginCall) {
        #if canImport(OTPublishersHeadlessSDK)
        let shown = OTPublishersHeadlessSDK.shared.isBannerShown()
        call.resolve(["shown": shown])
        #else
        call.reject("OneTrust SDK is not linked.")
        #endif
    }

    @objc public func getConsentStatusForCategory(_ call: CAPPluginCall) {
        guard let category = call.getString("categoryId") else {
            call.reject("categoryId is required.")
            return
        }

        #if canImport(OTPublishersHeadlessSDK)
        let status = OTPublishersHeadlessSDK.shared.getConsentStatus(forCategory: category)
        call.resolve(["status": Int(status)])
        #else
        call.reject("OneTrust SDK is not linked.")
        #endif
    }

    // ------------------------------------------------------------------------
    // Identity
    // ------------------------------------------------------------------------

    @objc public func getCachedIdentifier(_ call: CAPPluginCall) {
        #if canImport(OTPublishersHeadlessSDK)
        let identifier = OTPublishersHeadlessSDK.shared.cache.dataSubjectIdentifier ?? ""
        call.resolve(["identifier": identifier])
        #else
        call.reject("OneTrust SDK is not linked.")
        #endif
    }

    // ------------------------------------------------------------------------
    // BYOUI
    // ------------------------------------------------------------------------

    @objc public func getBannerData(_ call: CAPPluginCall) {
        #if canImport(OTPublishersHeadlessSDK)
        if let bannerData = OTPublishersHeadlessSDK.shared.getBannerData() {
            call.resolve(["data": bannerData])
        } else {
            call.reject("No banner data found")
        }
        #else
        call.reject("OneTrust SDK is not linked.")
        #endif
    }

    @objc public func getPreferenceCenterData(_ call: CAPPluginCall) {
        #if canImport(OTPublishersHeadlessSDK)
        if let pcData = OTPublishersHeadlessSDK.shared.getPreferenceCenterData() {
            call.resolve(["data": pcData])
        } else {
            call.reject("No banner data found")
        }
        #else
        call.reject("OneTrust SDK is not linked.")
        #endif
    }

    @objc public func getOTConsentJSForWebview(_ call: CAPPluginCall) {
        #if canImport(OTPublishersHeadlessSDK)
        if let js = OTPublishersHeadlessSDK.shared.getOTConsentJSForWebView() {
            call.resolve(["js": js])
        } else {
            call.reject("No JS Found for WebView")
        }
        #else
        call.reject("OneTrust SDK is not linked.")
        #endif
    }

    // ------------------------------------------------------------------------
    // Consent change observation
    // ------------------------------------------------------------------------

    @objc public func observeChanges(_ call: CAPPluginCall) {
        guard let category = call.getString("categoryId") else {
            call.reject("categoryId is required.")
            return
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(consentChanged(_:)),
            name: Notification.Name(category),
            object: nil
        )
        observedCategories.insert(category)
        call.resolve()
    }

    @objc public func stopObservingChanges(_ call: CAPPluginCall) {
        guard let category = call.getString("categoryId") else {
            call.reject("categoryId is required.")
            return
        }
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(category),
            object: nil
        )
        observedCategories.remove(category)
        call.resolve()
    }

    // ------------------------------------------------------------------------
    // Internals
    // ------------------------------------------------------------------------

    @objc private func consentChanged(_ notification: Notification) {
        let consentStatus = (notification.object as? Int) ?? -1
        host?.emitConsentChanged(
            categoryId: notification.name.rawValue,
            consentStatus: consentStatus
        )
    }

    private func getATTStatusAsString() -> String? {
        guard #available(iOS 14, *) else { return nil }
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .authorized:    return "authorized"
        case .denied:        return "denied"
        case .notDetermined: return "notDetermined"
        case .restricted:    return "restricted"
        @unknown default:    return "notDetermined"
        }
    }

    // Resolves the host view controller via the Capacitor bridge first,
    // falling back to UIScene-based key window lookup. The Cordova plugin used the deprecated `UIApplication.shared.keyWindow`
    //  we use the modern equivalent so this builds clean on iOS 15+.
    private func rootViewController() -> UIViewController? {
        if let vc = plugin?.bridge?.viewController {
            return vc
        }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }

    public func tearDown() {
        for category in observedCategories {
            NotificationCenter.default.removeObserver(
                self,
                name: Notification.Name(category),
                object: nil
            )
        }
        observedCategories.removeAll()
    }

    deinit {
        tearDown()
    }
}

// ---------------------------------------------------------------------------
// SDK-dependent helpers — only compiled when the OneTrust pod is linked.
// ---------------------------------------------------------------------------

#if canImport(OTPublishersHeadlessSDK)

extension CmpModule {

    fileprivate func buildSDKParams(withParamsObject params: NSDictionary) -> OTSdkParams {
        var profileSyncParams: OTProfileSyncParams? = nil

        // profileSyncParams: only attach if BOTH identifier and JWT are present.
        if let syncParamsData = params.value(forKey: "syncParams") as? [String: String],
           let identifier = syncParamsData["identifier"],
           let jwt = syncParamsData["syncProfileAuth"] {
            profileSyncParams = OTProfileSyncParams()
            profileSyncParams!.setIdentifier(identifier)
            profileSyncParams!.setSyncProfileAuth(jwt)
            profileSyncParams!.setSyncProfile("true")
        }

        let countryCode = params.value(forKey: "countryCode") as? String
        let regionCode  = params.value(forKey: "regionCode") as? String

        let otParams = OTSdkParams(countryCode: countryCode, regionCode: regionCode)

        if let profileSyncParams = profileSyncParams {
            otParams.setProfileSyncParams(profileSyncParams)
            otParams.setShouldCreateProfile("true")
        }

        if let overrideVersion = params.value(forKey: "setAPIVersion") as? String {
            otParams.setSDKVersion(overrideVersion)
        }

        return otParams
    }

    fileprivate func appPermissionType(fromInt raw: Int) -> AppPermissionType? {
        switch raw {
        case 0:  return .idfa
        default: return nil
        }
    }
}

extension CmpModule: OTEventListener {
    public func allSDKViewsDismissed(interactionType: ConsentInteractionType) {
        host?.emitAllSDKViewsDismissed()
    }
}

#else

extension CmpModule {
    fileprivate func buildSDKParams(withParamsObject params: NSDictionary) -> NSObject {
        return NSObject()
    }
    fileprivate func appPermissionType(fromInt raw: Int) -> Int? {
        return nil
    }
}

#endif
