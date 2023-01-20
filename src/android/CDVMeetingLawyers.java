package com.meetinglawyers.cordova;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;

import com.meetinglawyers.sdk.MeetingLawyersClient;
import com.meetinglawyers.sdk.data.CustomerSdkBuildMode;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;

/**
 * This class echoes a string called from JavaScript.
 */
public class CDVMeetingLawyers extends CordovaPlugin {
    public static final String ENV_DEV = "DEVELOPMENT";
    
    public static final String METHOD_INIT = "initialize";
    public static final String METHOD_AUTHENTICATE = "authenticate";
    public static final String METHOD_OPEN_ACTIVITY = "open_list";
    public static final String METHOD_PRIMARY_COLOR = "primary_color";
    public static final String METHOD_SECONDARY_COLOR = "secondary_color";

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
            case METHOD_OPEN_ACTIVITY:
                this.openMainActivity(this.cordova.getActivity().getApplicationContext());
                return true;
            case METHOD_PRIMARY_COLOR:
                String primary = args.getString(0);
                this.setPrimaryColor(primary, callbackContext);
                return true;
            case METHOD_SECONDARY_COLOR:
                String secondary = args.getString(0);
                this.setSecondaryColor(secondary, callbackContext);
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

    private void openMainActivity(Context context) {
        Intent intent = new Intent(context, CDVMeetingLawyersMainActivity.class);
        this.cordova.getActivity().startActivity(intent);
    }

    private void setPrimaryColor(String color, CallbackContext callbackContext) {
        MeetingLawyersClient instance = MeetingLawyersClient.Companion.getInstance();
        if (instance != null) {
            instance.setPrimaryColor(Color.parseColor(color));
        } else {
            callbackContext.error("MeetingLawyers not initialized, call initialize first");
        }
    }

    private void setSecondaryColor(String color, CallbackContext callbackContext) {
        MeetingLawyersClient instance = MeetingLawyersClient.Companion.getInstance();
        if (instance != null) {
            instance.setSecondaryColor(Color.parseColor(color));
        } else {
            callbackContext.error("MeetingLawyers not initialized, call initialize first");
        }
    }
}
