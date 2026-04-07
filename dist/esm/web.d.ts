import { WebPlugin } from '@capacitor/core';
import type { OneTrustPlugin, StartSDKOptions, StartSDKResult, CategoryIdOptions, ConsentStatusResult, ShouldShowBannerResult, IsBannerShownResult, CachedIdentifierResult, BannerDataResult, PreferenceCenterDataResult, ConsentJSForWebviewResult, ShowConsentUIOptions, ShowConsentUIResult } from './definitions';
export declare class OneTrustWeb extends WebPlugin implements OneTrustPlugin {
    startSDK(_options: StartSDKOptions): Promise<StartSDKResult>;
    initOTSDKData(_options: StartSDKOptions): Promise<StartSDKResult>;
    showBannerUI(): Promise<void>;
    showPreferenceCenterUI(): Promise<void>;
    showConsentUI(_options: ShowConsentUIOptions): Promise<ShowConsentUIResult>;
    dismissUI(): Promise<void>;
    getConsentStatusForCategory(_options: CategoryIdOptions): Promise<ConsentStatusResult>;
    shouldShowBanner(): Promise<ShouldShowBannerResult>;
    isBannerShown(): Promise<IsBannerShownResult>;
    getCachedIdentifier(): Promise<CachedIdentifierResult>;
    getBannerData(): Promise<BannerDataResult>;
    getPreferenceCenterData(): Promise<PreferenceCenterDataResult>;
    getOTConsentJSForWebview(): Promise<ConsentJSForWebviewResult>;
    observeChanges(_options: CategoryIdOptions): Promise<void>;
    stopObservingChanges(_options: CategoryIdOptions): Promise<void>;
}
