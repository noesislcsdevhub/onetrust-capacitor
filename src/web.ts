import { WebPlugin } from '@capacitor/core';

import type {
  OneTrustPlugin,
  StartSDKOptions,
  StartSDKResult,
  CategoryIdOptions,
  ConsentStatusResult,
  ShouldShowBannerResult,
  IsBannerShownResult,
  CachedIdentifierResult,
  BannerDataResult,
  PreferenceCenterDataResult,
  ConsentJSForWebviewResult,
  ShowConsentUIOptions,
  ShowConsentUIResult,
} from './definitions';

// The OneTrust CMP SDK is mobile-only. Web is intentionally unsupported —
// every method rejects so consumers fail fast in the browser instead of
// silently believing OneTrust is running.
export class OneTrustWeb extends WebPlugin implements OneTrustPlugin {

  async startSDK(_options: StartSDKOptions): Promise<StartSDKResult> {
    throw this.unimplemented('startSDK is not available on web.');
  }

  async initOTSDKData(_options: StartSDKOptions): Promise<StartSDKResult> {
    throw this.unimplemented('initOTSDKData is not available on web.');
  }

  async showBannerUI(): Promise<void> {
    throw this.unimplemented('showBannerUI is not available on web.');
  }

  async showPreferenceCenterUI(): Promise<void> {
    throw this.unimplemented('showPreferenceCenterUI is not available on web.');
  }

  async showConsentUI(_options: ShowConsentUIOptions): Promise<ShowConsentUIResult> {
    throw this.unimplemented('showConsentUI is not available on web.');
  }

  async dismissUI(): Promise<void> {
    throw this.unimplemented('dismissUI is not available on web.');
  }

  async getConsentStatusForCategory(
    _options: CategoryIdOptions,
  ): Promise<ConsentStatusResult> {
    throw this.unimplemented('getConsentStatusForCategory is not available on web.');
  }

  async shouldShowBanner(): Promise<ShouldShowBannerResult> {
    throw this.unimplemented('shouldShowBanner is not available on web.');
  }

  async isBannerShown(): Promise<IsBannerShownResult> {
    throw this.unimplemented('isBannerShown is not available on web.');
  }

  async getCachedIdentifier(): Promise<CachedIdentifierResult> {
    throw this.unimplemented('getCachedIdentifier is not available on web.');
  }

  async getBannerData(): Promise<BannerDataResult> {
    throw this.unimplemented('getBannerData is not available on web.');
  }

  async getPreferenceCenterData(): Promise<PreferenceCenterDataResult> {
    throw this.unimplemented('getPreferenceCenterData is not available on web.');
  }

  async getOTConsentJSForWebview(): Promise<ConsentJSForWebviewResult> {
    throw this.unimplemented('getOTConsentJSForWebview is not available on web.');
  }

  async observeChanges(_options: CategoryIdOptions): Promise<void> {
    throw this.unimplemented('observeChanges is not available on web.');
  }

  async stopObservingChanges(_options: CategoryIdOptions): Promise<void> {
    throw this.unimplemented('stopObservingChanges is not available on web.');
  }
}
