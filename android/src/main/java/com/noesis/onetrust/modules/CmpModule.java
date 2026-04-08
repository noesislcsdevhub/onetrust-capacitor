package com.noesis.onetrust.modules;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.util.Log;

import com.getcapacitor.JSObject;
import com.getcapacitor.PluginCall;

import com.onetrust.otpublishers.headless.Public.DataModel.OTProfileSyncParams;
import com.onetrust.otpublishers.headless.Public.DataModel.OTSdkParams;
import com.onetrust.otpublishers.headless.Public.DataModel.OTUXParams;
import com.onetrust.otpublishers.headless.Public.Keys.OTBroadcastServiceKeys;
import com.onetrust.otpublishers.headless.Public.OTCallback;
import com.onetrust.otpublishers.headless.Public.OTPublishersHeadlessSDK;
import com.onetrust.otpublishers.headless.Public.Response.OTResponse;

import org.json.JSONObject;

import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class CmpModule {

    private static final String TAG = "OneTrustCmpModule";

    // SDK keys
    private static final String COUNTRY_CODE = "countryCode";
    private static final String REGION_CODE = "regionCode";
    private static final String SYNC_PARAMS = "syncParams";
    private static final String IDENTIFIER = "identifier";
    private static final String JWT = "syncProfileAuth";
    private static final String UX_PARAMS_JSON = "androidUXParams";
    private static final String API_VERSION = "setAPIVersion";

    /*
     Capabilities the bridge exposes to the module:
       * emitting events (modules cannot call notifyListeners themselves)
       * launching CMPActivity through Capacitor's activity-result plumbing so the bridge's @ActivityCallback fires on dismissal
    */
    public interface OneTrustHost {
        void emitConsentChanged(String categoryId, int consentStatus);
        void emitAllSDKViewsDismissed();
        void launchCmpActivity(int uiType);
    }

    private final Context context;
    private final Activity activity;
    private final OneTrustHost host;
    private final OTPublishersHeadlessSDK ot;
    private final ExecutorService threadPool = Executors.newCachedThreadPool();

    // Track registered receivers per category so we can clean up on tearDown.
    private final Set<String> observedCategories = new HashSet<>();

    private final BroadcastReceiver consentStatusChanged = new BroadcastReceiver() {
        @Override
        public void onReceive(Context ctx, Intent intent) {
            int status = intent.getIntExtra(OTBroadcastServiceKeys.EVENT_STATUS, -1);
            String category = intent.getAction();
            if (category != null) {
                host.emitConsentChanged(category, status);
            }
        }
    };

    public CmpModule(Context context, Activity activity, OneTrustHost host) {
        this.context = context;
        this.activity = activity;
        this.host = host;
        this.ot = new OTPublishersHeadlessSDK(context);
    }

    // ------------------------------------------------------------------------
    // Initialization
    // ------------------------------------------------------------------------

    public void startSDK(final String storageLocation,
                         final String domainId,
                         final String languageCode,
                         final JSObject initParams,
                         final PluginCall call) {
        threadPool.execute(new Runnable() {
            @Override
            public void run() {
                OTSdkParams sdkParams = null;
                if (initParams != null) {
                    sdkParams = generateSDKParams(initParams);
                }

                ot.startSDK(storageLocation, domainId, languageCode, sdkParams, new OTCallback() {
                    @Override
                    public void onSuccess(OTResponse otResponse) {
                        JSObject ret = new JSObject();
                        ret.put("status", 1); // Cordova convention: 1 on success
                        call.resolve(ret);
                    }

                    @Override
                    public void onFailure(OTResponse otResponse) {
                        call.reject("Failed to initialize OneTrust SDK. --> "
                                + otResponse.getResponseMessage());
                    }
                });
            }
        });
    }

    // ------------------------------------------------------------------------
    // UI
    // ------------------------------------------------------------------------

    public void showBannerUI(PluginCall call) {
        if (ot.getBannerData() != null) {
            host.launchCmpActivity(0);
        }
        call.resolve();
    }

    public void showPreferenceCenterUI(PluginCall call) {
        if (ot.getPreferenceCenterData() != null) {
            host.launchCmpActivity(1);
        }
        call.resolve();
    }

    public void dismissUI(PluginCall call) {
        if (activity != null) {
            activity.finishActivity(1);
        }
        call.resolve();
    }

    // ------------------------------------------------------------------------
    // Query for consent
    // ------------------------------------------------------------------------

    public void shouldShowBanner(final PluginCall call) {
        threadPool.execute(new Runnable() {
            @Override
            public void run() {
                int shouldShow = ot.shouldShowBanner() ? 1 : 0;
                JSObject ret = new JSObject();
                ret.put("shouldShow", shouldShow);
                call.resolve(ret);
            }
        });
    }

    public void isBannerShown(final PluginCall call) {
        threadPool.execute(new Runnable() {
            @Override
            public void run() {
                if (context != null) {
                    int bannerShown = ot.isBannerShown(context);
                    JSObject ret = new JSObject();
                    ret.put("shown", bannerShown);
                    call.resolve(ret);
                } else {
                    call.reject("No Android context available.");
                }
            }
        });
    }

    public void getConsentStatusForCategory(final String catId, final PluginCall call) {
        threadPool.execute(new Runnable() {
            @Override
            public void run() {
                int status = ot.getConsentStatusForGroupId(catId);
                JSObject ret = new JSObject();
                ret.put("status", status);
                call.resolve(ret);
            }
        });
    }

    // ------------------------------------------------------------------------
    // Identity
    // ------------------------------------------------------------------------

    public void getCachedIdentifier(final PluginCall call) {
        threadPool.execute(new Runnable() {
            @Override
            public void run() {
                String identifier = ot.getOTCache().getDataSubjectIdentifier();
                JSObject ret = new JSObject();
                ret.put("identifier", identifier == null ? "" : identifier);
                call.resolve(ret);
            }
        });
    }

    // ------------------------------------------------------------------------
    // BYOUI
    // ------------------------------------------------------------------------

    public void getBannerData(final PluginCall call) {
        threadPool.execute(new Runnable() {
            @Override
            public void run() {
                JSONObject bannerData = ot.getBannerData();
                if (bannerData != null) {
                    try {
                        JSObject ret = new JSObject();
                        ret.put("data", JSObject.fromJSONObject(bannerData));
                        call.resolve(ret);
                    } catch (org.json.JSONException e) {
                        call.reject("Failed to serialize banner data: " + e.getMessage());
                    }
                } else {
                    call.reject("No banner data found");
                }
            }
        });
    }

    public void getPreferenceCenterData(final PluginCall call) {
        threadPool.execute(new Runnable() {
            @Override
            public void run() {
                JSONObject pcData = ot.getPreferenceCenterData();
                if (pcData != null) {
                    try {
                        JSObject ret = new JSObject();
                        ret.put("data", JSObject.fromJSONObject(pcData));
                        call.resolve(ret);
                    } catch (org.json.JSONException e) {
                        call.reject("No banner data found");
                    }
                } else {
                    call.reject("No banner data found");
                }
            }
        });
    }
    public void getOTConsentJSForWebview(final PluginCall call) {
        threadPool.execute(new Runnable() {
            @Override
            public void run() {
                String js = ot.getOTConsentJSForWebView();
                if (js != null) {
                    JSObject ret = new JSObject();
                    ret.put("js", js);
                    call.resolve(ret);
                } else {
                    call.reject("No JS Found for WebView");
                }
            }
        });
    }

    // ------------------------------------------------------------------------
    // Consent change observation
    // ------------------------------------------------------------------------

    public void observeChanges(String catId, PluginCall call) {
        if (activity == null) {
            call.reject("No Android activity available to register receiver.");
            return;
        }
        try {
            // Register-once per category. Re-registering the same receiver with the same filter throws on some OEM builds.
            if (!observedCategories.contains(catId)) {
                IntentFilter filter = new IntentFilter(catId);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    // Android 13+ requires an exported flag for runtime receivers.
                    activity.registerReceiver(
                            consentStatusChanged,
                            filter,
                            Context.RECEIVER_NOT_EXPORTED
                    );
                } else {
                    activity.registerReceiver(consentStatusChanged, filter);
                }
                observedCategories.add(catId);
            }
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to register consent listener: " + e.getMessage());
        }
    }

    // ------------------------------------------------------------------------
    // Internals
    // ------------------------------------------------------------------------

    private OTSdkParams generateSDKParams(JSObject initParams) {
        OTSdkParams.SdkParamsBuilder builder = OTSdkParams.SdkParamsBuilder.newInstance();

        // Android-only UX params JSON blob
        if (initParams.has(UX_PARAMS_JSON)) {
            JSONObject uxParamsJSON = initParams.optJSONObject(UX_PARAMS_JSON);
            if (uxParamsJSON != null) {
                OTUXParams uxParams = OTUXParams.OTUXParamsBuilder.newInstance()
                        .setUXParams(uxParamsJSON)
                        .build();
                builder.setOTUXParams(uxParams);
            }
        }

        if (initParams.has(COUNTRY_CODE)) {
            builder.setOTCountryCode(initParams.optString(COUNTRY_CODE));
        }

        if (initParams.has(REGION_CODE)) {
            builder.setOTRegionCode(initParams.optString(REGION_CODE));
        }

        if (initParams.has(API_VERSION)) {
            builder.setAPIVersion(initParams.optString(API_VERSION));
        }

        // Profile sync params — fail gracefully if either field is missing.
        if (initParams.has(SYNC_PARAMS)) {
            JSONObject paramsObj = initParams.optJSONObject(SYNC_PARAMS);
            if (paramsObj != null && paramsObj.has(IDENTIFIER) && paramsObj.has(JWT)) {
                String identifier = paramsObj.optString(IDENTIFIER);
                String jwt = paramsObj.optString(JWT);

                OTProfileSyncParams profileSyncParams =
                        OTProfileSyncParams.OTProfileSyncParamsBuilder.newInstance()
                                .setIdentifier(identifier)
                                .setSyncProfileAuth(jwt)
                                .setSyncProfile("true")
                                .build();
                builder.shouldCreateProfile("true");
                builder.setProfileSyncParams(profileSyncParams);
            }
        }

        return builder.build();
    }

    public void tearDown() {
        // Best-effort unregister but only if we ever registered
        if (activity != null && !observedCategories.isEmpty()) {
            try {
                activity.unregisterReceiver(consentStatusChanged);
            } catch (IllegalArgumentException ignored) {
                // Receiver wasn't registered => we ignore it
            }
        }
        observedCategories.clear();
        threadPool.shutdownNow();
        Log.d(TAG, "CmpModule torn down.");
    }
}
