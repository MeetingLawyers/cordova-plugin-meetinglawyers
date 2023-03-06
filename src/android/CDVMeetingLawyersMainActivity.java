package com.meetinglawyers.cordova;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.widget.ImageView;


public class CDVMeetingLawyersMainActivity extends AppCompatActivity {
    public static String PRIMARY_COLOR = "primary_color";
    public static String NAVIGATION_NAME = "navigation_name_resource";
    private int primaryColor;
    private String navigationImageName;

    private Toolbar toolbar;
    private ImageView imageView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String package_name = getApplication().getPackageName();
        setContentView(getApplication().getResources().getIdentifier("activity_meetinglawyers_main", "layout", package_name));
        getIntentParameters();
        configView();
    }

    private void getIntentParameters() {
        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            this.primaryColor = extras.getInt(PRIMARY_COLOR);
            this.navigationImageName = extras.getString(NAVIGATION_NAME);
        }
    }

    private void configView() {
        String package_name = getApplication().getPackageName();
        int toolbarId = getApplication().getResources().getIdentifier("toolbar", "id", package_name);
        int imageViewId = getApplication().getResources().getIdentifier("toolbar_image", "id", package_name);
        toolbar = (Toolbar) findViewById(toolbarId);
        imageView = (ImageView) findViewById(imageViewId);

        if (primaryColor != 0) {
            toolbar.setBackgroundColor(primaryColor);
        }

        if (navigationImageName != null) {
            int navigationResourceId = getApplication().getResources().getIdentifier(navigationImageName, "drawable", package_name);
            if (navigationResourceId != 0) {
                imageView.setImageResource(navigationResourceId);
            }
        }

        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(""); // hide title
            getSupportActionBar().setDisplayHomeAsUpEnabled(false);
        }
    }
}
