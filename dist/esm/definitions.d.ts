import type { PluginListenerHandle } from '@capacitor/core';
/**
 * Device permission types accepted by showConsentUI.
 * Mirrors the Cordova `OneTrust.devicePermission` enum.
 */
export declare const OTDevicePermission: Readonly<{
    idfa: 0;
}>;
export interface OTSyncParams {
    identifier: string;
    syncProfileAuth: string;
}
export interface OTSdkInitParams {
    countryCode?: string;
    regionCode?: string;
    setAPIVersion?: string;
    syncParams?: OTSyncParams;
    /** Android-only UX customization JSON. Ignored on iOS. */
    androidUXParams?: Record<string, unknown>;
}
export interface StartSDKOptions {
    storageLocation: string;
    domainIdentifier: string;
    languageCode: string;
    params?: OTSdkInitParams;
}
export interface StartSDKResult {
    /** 1 on success. Cordova returned a raw int; wrapped here. */
    status: number;
}
export interface CategoryIdOptions {
    categoryId: string;
}
export interface ConsentStatusResult {
    /** -1 = not collected, 0 = not given, 1 = given */
    status: number;
}
export interface ShouldShowBannerResult {
    /** 1 = should show, 0 = should not. Mirrors Cordova's int convention. */
    shouldShow: number;
}
export interface IsBannerShownResult {
    /** Cordova returned a raw int; preserved as-is. */
    shown: number;
}
export interface CachedIdentifierResult {
    identifier: string;
}
export interface BannerDataResult {
    /** Raw OneTrust banner data JSON. */
    data: Record<string, unknown>;
}
export interface PreferenceCenterDataResult {
    /** Raw OneTrust preference center data JSON. */
    data: Record<string, unknown>;
}
export interface ConsentJSForWebviewResult {
    js: string;
}
export interface ShowConsentUIOptions {
    /** Use OTDevicePermission.idfa (= 0). Other values reserved. */
    OTDevicePermission: number;
}
export interface ShowConsentUIResult {
    /**
     * iOS: ATT status string ("authorized" | "denied" | "notDetermined" | "restricted").
     * Android: always -1 (ATT not supported on Android).
     */
    status: string | number;
}
/** Payload of a per-category consent change event. */
export interface ConsentChangedEvent {
    categoryId: string;
    consentStatus: number;
}
/** Payload of the allSDKViewsDismissed event. */
export interface AllSDKViewsDismissedEvent {
}
export interface OneTrustPlugin {
    startSDK(options: StartSDKOptions): Promise<StartSDKResult>;
    /**
     * @deprecated Cordova exposed this name but never wired it natively on
     * either platform. Calling it will reject. Use startSDK.
     */
    initOTSDKData(options: StartSDKOptions): Promise<StartSDKResult>;
    showBannerUI(): Promise<void>;
    showPreferenceCenterUI(): Promise<void>;
    showConsentUI(options: ShowConsentUIOptions): Promise<ShowConsentUIResult>;
    dismissUI(): Promise<void>;
    getConsentStatusForCategory(options: CategoryIdOptions): Promise<ConsentStatusResult>;
    shouldShowBanner(): Promise<ShouldShowBannerResult>;
    isBannerShown(): Promise<IsBannerShownResult>;
    getCachedIdentifier(): Promise<CachedIdentifierResult>;
    getBannerData(): Promise<BannerDataResult>;
    getPreferenceCenterData(): Promise<PreferenceCenterDataResult>;
    getOTConsentJSForWebview(): Promise<ConsentJSForWebviewResult>;
    /**
     * Begin observing consent changes for a category. After calling this, the
     * plugin will emit an event whose name equals the categoryId, with payload
     * { categoryId, consentStatus }. Listen with addListener(categoryId, ...).
     */
    observeChanges(options: CategoryIdOptions): Promise<void>;
    /**
     * Stop observing consent changes for a category.
     *
     * NOTE: In Cordova this was implemented on iOS only. On Android the call
     * will reject — use removeAllListeners() as a fallback there.
     */
    stopObservingChanges(options: CategoryIdOptions): Promise<void>;
    /** Per-category consent change events use the categoryId as the eventName. */
    addListener(eventName: string, listenerFunc: (event: ConsentChangedEvent) => void): Promise<PluginListenerHandle>;
    /** Fired when the OneTrust UI is fully dismissed. */
    addListener(eventName: 'allSDKViewsDismissed', listenerFunc: (event: AllSDKViewsDismissedEvent) => void): Promise<PluginListenerHandle>;
    removeAllListeners(): Promise<void>;
}
