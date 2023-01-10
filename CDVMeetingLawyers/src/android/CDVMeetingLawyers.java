package com.meetinglawyers.cordova;

import android.app.Application;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;

import org.jetbrains.annotations.NotNull;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.meetinglawyers.sdk.MeetingLawyersClient;
import com.meetinglawyers.sdk.data.CustomerSdkBuildMode;

/**
 * This class echoes a string called from JavaScript.
 */
public class CDVMeetingLawyers extends CordovaPlugin {
    public static final String ENV_DEV = "DEVELOPMENT";
    
    public static final String METHOD_INIT = "initialize";
    public static final String METHOD_AUTHENTICATE = "authenticate";

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        switch (action) {
            case METHOD_INIT:
                String apiKey = args.getString(0);
                String env = args.getString(1);
                this.initialize(apiKey, env, callbackContext);
                return true;
            case METHOD_AUTHENTICATE:
                String userid = args.getString(0);
                this.authenticate(userid, callbackContext);
                return true;
        }
        
        return false;
    }

    private void initialize(String apikey, String env, CallbackContext callbackContext) {
        if (apikey != null && apikey.length() > 0) {
            this.cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    CustomerSdkBuildMode buildMode = CustomerSdkBuildMode.PROD;
                    if (env != null && env.equals(ENV_DEV)) {
                        buildMode = CustomerSdkBuildMode.DEV;
                    }
                    MeetingLawyersClient.newInstance(((Application) cordova.getContext().getApplicationContext()),
                            apikey,
                            buildMode,
                            false,
                            "ENCRYPTION_PASSWORD",
                            cordova.getContext().getResources().getConfiguration().locale);

                    callbackContext.success();
                }
            });
        } else {
            callbackContext.error("Expected one non-empty string apiKey on first argument.");
        }
    }

    private void authenticate(String userid, CallbackContext callbackContext) {
        if (userid != null && userid.length() > 0) {
            this.cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    MeetingLawyersClient instance = MeetingLawyersClient.Companion.getInstance();
                    if (instance != null) {
                        instance.authenticate(
                                userid,
                                new MeetingLawyersClient.AuthenticationListener() {
                                    @Override
                                    public void onAuthenticated() {
                                        callbackContext.success();
                                    }
                                    @Override
                                    public void onAuthenticationError(@NotNull Throwable throwable) {
                                        callbackContext.error("MeetingLawyers not initialized, call initialize first");
                                    }
                                });
                    } else {
                        callbackContext.error("MeetingLawyers not initialized, call initialize first");
                    }
                }
            });
        } else {
            callbackContext.error("Expected one non-empty string userid on first argument.");
        }
    }
}
