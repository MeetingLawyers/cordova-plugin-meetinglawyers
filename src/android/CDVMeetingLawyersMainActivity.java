package com.meetinglawyers.cordova;

import androidx.fragment.app.FragmentActivity;
import android.os.Bundle;

public class CDVMeetingLawyersMainActivity extends FragmentActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String package_name = getApplication().getPackageName();
        setContentView(getApplication().getResources().getIdentifier("activity_meetinglawyers_main", "layout", package_name));
    }
}
