package com.meetinglawyers.cordova;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;

import com.meetinglawyers.sdk.MeetingLawyersClient;
import com.meetinglawyers.sdk.data.CustomerSdkBuildMode;
import com.meetinglawyers.sdk.data.Repository;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class CDVMeetingLawyers extends CordovaPlugin {
    public static final String ENV_DEV = "DEVELOPMENT";

    public static final String STYLE_PRIMARY_COLOR = "primaryColor";
    public static final String STYLE_SECONDARY_COLOR = "secondaryColor";
    public static final String STYLE_NAVIGATION_COLOR = "navigationColor";
    public static final String STYLE_SPECIALITY_COLOR = "specialityColor";

    public static final String METHOD_INIT = "initialize";
    public static final String METHOD_AUTHENTICATE = "authenticate";
    public static final String METHOD_LOGOUT = "logout";
    public static final String METHOD_SET_FCM_TOKEN = "setFcmToken";
    public static final String METHOD_FCM_MESSAGE = "onFcmMessage";
    public static final String METHOD_FCM_BACKGROUND_MESSAGE = "onFcmBackgroundMessage";
    public static final String METHOD_OPEN_ACTIVITY = "openList";
    public static final String METHOD_SET_STYLE = "setStyle";
    public static final String METHOD_SET_NAVIGATION = "setNavigationImage";
    private String navigationImageName;

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
            case METHOD_LOGOUT:
                this.logout(callbackContext);
                return true;
            case METHOD_SET_FCM_TOKEN:
                String token = args.getString(0);
                this.setFCMToken(token, callbackContext);
                return true;
            case METHOD_FCM_MESSAGE:
                String dataJson = args.getString(0);
                this.fcmMessage(dataJson, callbackContext);
                return true;
            case METHOD_FCM_BACKGROUND_MESSAGE:
                String dataBackJson = args.getString(0);
                this.fcmBackgroundMessage(dataBackJson, callbackContext);
                return true;
            case METHOD_OPEN_ACTIVITY:
                this.openMainActivity(callbackContext);
                return true;
            case METHOD_SET_STYLE:
                JSONObject style = args.getJSONObject(0);
                this.setStyle(style, callbackContext);
                return true;
            case METHOD_SET_NAVIGATION:
                String imageName = args.getString(0);
                this.setNavigationImage(imageName, callbackContext);
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

    private void logout(CallbackContext callbackContext) {
        this.cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                MeetingLawyersClient instance = MeetingLawyersClient.Companion.getInstance();
                if (instance != null) {
                    instance.deauthenticate(new Repository.OnResetDataListener() {
                        @Override
                        public void onSuccess() {
                            callbackContext.success();
                        }

                        @Override
                        public void onError(Exception e) {
                            callbackContext.error("MeetingLawyers deauthenticate fails");
                        }
                    });
                } else {
                    callbackContext.error("MeetingLawyers not initialized, call initialize first");
                }
            }
        });
    }

    private void setFCMToken(String token, CallbackContext callbackContext) {
        if (token != null && token.length() > 0) {
            this.cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    MeetingLawyersClient instance = MeetingLawyersClient.Companion.getInstance();
                    if (instance != null) {
                        instance.onNewTokenReceived(token);
                        callbackContext.success();
                    } else {
                        callbackContext.error("MeetingLawyers not initialized, call initialize first");
                    }
                }
            });
        } else {
            callbackContext.error("Expected one non-empty string token on first argument.");
        }
    }

    private void fcmMessage(String dataJson, CallbackContext callbackContext) {
        if (dataJson != null && dataJson.length() > 0) {
            this.cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    MeetingLawyersClient instance = MeetingLawyersClient.Companion.getInstance();
                    if (instance != null) {
                        Boolean handled = instance.onFirebaseMessageReceived(dataJson);
                        callbackContext.success(handled.toString());
                    } else {
                        callbackContext.error("MeetingLawyers not initialized, call initialize first");
                    }
                }
            });
        } else {
            callbackContext.error("Expected one non-empty string token on first argument.");
        }
    }

    private void fcmBackgroundMessage(String dataJson, CallbackContext callbackContext) {
        if (dataJson != null && dataJson.length() > 0) {
            this.cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    MeetingLawyersClient instance = MeetingLawyersClient.Companion.getInstance();
                    if (instance != null) {
                        instance.onNotificationDataReceived(dataJson);
                        callbackContext.success(Boolean.toString(true));
                    } else {
                        callbackContext.error("MeetingLawyers not initialized, call initialize first");
                    }
                }
            });
        } else {
            callbackContext.error("Expected one non-empty string token on first argument.");
        }
    }

    private void openMainActivity(CallbackContext callbackContext) {
        MeetingLawyersClient instance = MeetingLawyersClient.Companion.getInstance();
        if (instance != null) {
            int navigationResourceId = 0;
            if (navigationImageName != null) {
                navigationResourceId = this.cordova.getActivity().getApplication().getResources().getIdentifier(navigationImageName, "drawable", this.cordova.getActivity().getApplication().getPackageName());
            }
            instance.launchProfessionalList(this.cordova.getContext(), navigationResourceId);
            callbackContext.success();
        } else {
            callbackContext.error("MeetingLawyers not initialized, call initialize first");
        }
    }

    private void setStyle(JSONObject style, CallbackContext callbackContext) throws JSONException {
        MeetingLawyersClient instance = MeetingLawyersClient.Companion.getInstance();
        if (instance != null) {
            if (style.has(STYLE_PRIMARY_COLOR)) {
                String primaryColor = style.getString(STYLE_PRIMARY_COLOR);
                instance.setPrimaryColor(Color.parseColor(primaryColor));
                // Secondary color
                if (style.has(STYLE_SECONDARY_COLOR)) {
                    String secondaryColor = style.getString(STYLE_SECONDARY_COLOR);
                    instance.setSecondaryColor(Color.parseColor(secondaryColor));
                } else {
                    instance.setSecondaryColor(Color.parseColor(primaryColor));
                }
                // Navigation color
                if (style.has(STYLE_NAVIGATION_COLOR)) {
                    String navigationColor = style.getString(STYLE_NAVIGATION_COLOR);
                    // instance.setcolor(Color.parseColor(secondaryColor));
                } else {
                    // instance.setSecondaryColor(Color.parseColor(primaryColor));
                }
                // Speciality color
                if (style.has(STYLE_SPECIALITY_COLOR)) {
                    String specialityColor = style.getString(STYLE_SPECIALITY_COLOR);
                    instance.setProfessionalSpecialityTextColor(Color.parseColor(specialityColor));
                } else {
                    instance.setProfessionalSpecialityTextColor(Color.parseColor(primaryColor));
                }
            }
            callbackContext.success();
        } else {
            callbackContext.error("MeetingLawyers not initialized, call initialize first");
        }
    }

    private void setNavigationImage(String imageName, CallbackContext callbackContext) {
        MeetingLawyersClient instance = MeetingLawyersClient.Companion.getInstance();
        if (instance != null) {
            if (imageName != null && imageName.length() > 0) {
                this.navigationImageName = imageName;
                callbackContext.success();
            } else {
                callbackContext.error("Expected one non-empty string token on first argument.");
            }
        } else {
            callbackContext.error("MeetingLawyers not initialized, call initialize first");
        }
    }
}
