package com.meetinglawyers.cordova;

import android.app.Application;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;

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

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        switch (action) {
            case METHOD_INIT:
                String apiKey = args.getString(0);
                String env = args.getString(1);
                this.initialize(apiKey, env, callbackContext);
                return true;
        }
        
        return false;
    }

    private void initialize(String apikey, String env, CallbackContext callbackContext) {
        if (apikey != null && apikey.length() > 0) {
            CustomerSdkBuildMode buildMode = CustomerSdkBuildMode.PROD;
            if (env != null && env.equals(ENV_DEV)) {
                buildMode = CustomerSdkBuildMode.DEV;
            }

            MeetingLawyersClient.newInstance(((Application) this.cordova.getContext().getApplicationContext()),
                    apikey,
                    buildMode,
                    false,
                    "ENCRYPTION_PASSWORD",
                    this.cordova.getContext().getResources().getConfiguration().locale);

            callbackContext.success();   
        } else {
            callbackContext.error("Expected one non-empty string apiKey on first argument.");
        }
    }
}
