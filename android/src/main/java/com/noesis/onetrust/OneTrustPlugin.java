package com.noesis.onetrust;
import android.content.Intent;
import androidx.activity.result.ActivityResult;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.ActivityCallback;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.noesis.onetrust.modules.CmpModule;
import com.noesis.onetrust.modules.CmpModule.OneTrustHost;

@CapacitorPlugin(name = "OneTrust")
public class OneTrustPlugin extends Plugin implements OneTrustHost {

    private CmpModule cmp;

    @Override
    public void load() {
        super.load();
        cmp = new CmpModule(getContext(), getActivity(), this);
    }

    @Override
    public void emitConsentChanged(String categoryId, int consentStatus) {
        JSObject payload = new JSObject();
        payload.put("categoryId", categoryId);
        payload.put("consentStatus", consentStatus);
        notifyListeners(categoryId, payload);
    }

    @Override
    public void emitAllSDKViewsDismissed() {
        notifyListeners("allSDKViewsDismissed", new JSObject());
    }

    @Override
    public void launchCmpActivity(int uiType) {
        Intent intent = new Intent(getContext(), CMPActivity.class);
        intent.putExtra("UIType", uiType);
        /* We don't have a PluginCall to associate the launch with since the
        showBannerUI/showPreferenceCenterUI calls already resolved.

        Use a synthetic call so we can route through Capacitors activity-result helper and have 
        onCmpActivityResult fire on dismissal. 
        */
        startActivityForResult(
                 null, // call
                 intent, // intent 
                "onCmpActivityResult" // callback
        );
    }

    @ActivityCallback
    private void onCmpActivityResult(PluginCall call, ActivityResult result) {
        // call is null (we passed null in launchCmpActivity); ignore it.
        // Cordova emitted "allSDKViewsDismissed" on any onActivityResult with
        // requestCode == 1, regardless of the result code. Mirror that.
        emitAllSDKViewsDismissed();
    }

    // -- Initialization -------------------------------------------------------

    @PluginMethod
    public void startSDK(PluginCall call) {
        String storageLocation = call.getString("storageLocation");
        String domainIdentifier = call.getString("domainIdentifier");
        String languageCode = call.getString("languageCode");
        JSObject params = call.getObject("params"); // may be null

        if (storageLocation == null || domainIdentifier == null || languageCode == null) {
            call.reject("startSDK requires storageLocation, domainIdentifier and languageCode.");
            return;
        }

        cmp.startSDK(storageLocation, domainIdentifier, languageCode, params, call);
    }

    @PluginMethod
    public void initOTSDKData(PluginCall call) {
        // Cordova exposed this name in JS but never wired it natively. Mirror.
        call.reject("initOTSDKData is deprecated and was never implemented natively. Use startSDK.");
    }

    // -- UI -------------------------------------------------------------------

    @PluginMethod
    public void showBannerUI(PluginCall call) {
        cmp.showBannerUI(call);
    }

    @PluginMethod
    public void showPreferenceCenterUI(PluginCall call) {
        cmp.showPreferenceCenterUI(call);
    }

    @PluginMethod
    public void showConsentUI(PluginCall call) {
        // Android: ATT is iOS-only. Cordova always returned -1;
        JSObject ret = new JSObject();
        ret.put("status", -1);
        call.resolve(ret);
    }

    @PluginMethod
    public void dismissUI(PluginCall call) {
        cmp.dismissUI(call);
    }

    // -- Query for consent ----------------------------------------------------

    @PluginMethod
    public void getConsentStatusForCategory(PluginCall call) {
        String categoryId = call.getString("categoryId");
        if (categoryId == null) {
            call.reject("categoryId is required.");
            return;
        }
        cmp.getConsentStatusForCategory(categoryId, call);
    }

    @PluginMethod
    public void shouldShowBanner(PluginCall call) {
        cmp.shouldShowBanner(call);
    }

    @PluginMethod
    public void isBannerShown(PluginCall call) {
        cmp.isBannerShown(call);
    }

    // -- Identity -------------------------------------------------------------

    @PluginMethod
    public void getCachedIdentifier(PluginCall call) {
        cmp.getCachedIdentifier(call);
    }

    // -- BYOUI ----------------------------------------------------------------

    @PluginMethod
    public void getBannerData(PluginCall call) {
        cmp.getBannerData(call);
    }

    @PluginMethod
    public void getPreferenceCenterData(PluginCall call) {
        cmp.getPreferenceCenterData(call);
    }

    @PluginMethod
    public void getOTConsentJSForWebview(PluginCall call) {
        cmp.getOTConsentJSForWebview(call);
    }

    // -- Consent change observation ------------------------------------------

    @PluginMethod
    public void observeChanges(PluginCall call) {
        String categoryId = call.getString("categoryId");
        if (categoryId == null) {
            call.reject("categoryId is required.");
            return;
        }
        cmp.observeChanges(categoryId, call);
    }

    @PluginMethod
    public void stopObservingChanges(PluginCall call) {
        // Cordova Android did not implement this — preserve the asymmetry.
        // Consumers should use removeAllListeners() as a fallback.
        call.reject("stopObservingChanges is not implemented on Android (Cordova parity). Use removeAllListeners().");
    }

    // -- Lifecycle ------------------------------------------------------------

    @Override
    protected void handleOnDestroy() {
        if (cmp != null) {
            cmp.tearDown();
        }
        super.handleOnDestroy();
    }
}
