package umpush.wilson.flutter.flutter_plugin_umpush;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Notification;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.google.gson.Gson;
import com.umeng.commonsdk.UMConfigure;
import com.umeng.message.IUmengCallback;
import com.umeng.message.IUmengRegisterCallback;
import com.umeng.message.MsgConstant;
import com.umeng.message.PushAgent;
import com.umeng.message.UmengMessageHandler;
import com.umeng.message.UmengNotificationClickHandler;
import com.umeng.message.entity.UMessage;

import org.android.agoo.huawei.HuaWeiRegister;
import org.android.agoo.mezu.MeizuRegister;
import org.android.agoo.xiaomi.MiPushRegistar;

import io.flutter.plugin.common.MethodChannel;

public class UmengApplication extends io.flutter.app.FlutterApplication {
    private static final String TAG = "UmengApplication";
    public static final String UMENG_PUSH_DEVICE_TOKEN = "umeng_push_device_token";
    public static final String UMENG_PUSH_MESSAGE = "umeng_push_message";
    public static int count = 0;


    public static void savePushData(Context context, String key, String value) {
        SharedPreferences userSettings = context.getSharedPreferences("umeng_push_data", 0);
        SharedPreferences.Editor editor = userSettings.edit();
        editor.putString(key, value);
        editor.commit();
        Log.i(TAG, "uMessage：保存数据成功");
    }

    public static String getPushData(Context context, String key) {
        SharedPreferences userSettings = context.getSharedPreferences("umeng_push_data", 0);
        return userSettings.getString(key, null);
    }

    /**
     * flutter回调结果函数
     */
    public static final MethodChannel.Result FLUTTER_METHOD_CALLBACK = new MethodChannel.Result() {
        @Override
        public void success(Object o) {

            Log.i(TAG, "call flutter result: " + o.toString());
        }

        @Override
        public void error(String s, String s1, Object o) {
            Log.i(TAG, "call flutter result: object: " + o.toString() + " s: " + s + " s1: " + s1);
        }

        @Override
        public void notImplemented() {
            Log.i(TAG, "call flutter result: notImplemented");

        }
    };

    private String metaValue(String metaKey) {
        PackageManager packageManager = this.getPackageManager();
        ApplicationInfo appInfo = null;
        try {
            appInfo = packageManager.getApplicationInfo(this.getPackageName(), PackageManager.GET_META_DATA);
            String value = appInfo.metaData.get(metaKey).toString();
            Log.i(TAG, metaKey + ":" + value);
            if (value == null || value.equals("")) {
                value = "";
            }
            return value;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return "";
    }

    public static String formatMsg(UMessage uMessage) {
        return new Gson().toJson(uMessage, UMessage.class);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        UMConfigure.setLogEnabled(true);
        // 初始化组件化基础库, 统计SDK/推送SDK/分享SDK都必须调用此初始化接口

        String appKey = this.metaValue("UMENG_APPKEY");
        String appSecret = this.metaValue("UMENG_MESSAGE_SECRET");
        // Log.d(TAG, "appSecret: " + appSecret);
//        UMConfigure.init(this, UMConfigure.DEVICE_TYPE_PHONE, appSecret);
        UMConfigure.init(this, appKey, "Umeng", UMConfigure.DEVICE_TYPE_PHONE, appSecret);

        PushAgent pushAgent = PushAgent.getInstance(this);
//        pushAgent.setDisplayNotificationNumber(10);
        pushAgent.setNotificationPlaySound(MsgConstant.NOTIFICATION_PLAY_SDK_ENABLE);
        // sdk关闭通知声音
        // pushAgent.setNotificationPlaySound(MsgConstant.NOTIFICATION_PLAY_SDK_DISABLE);
        // 通知声音由服务端控制
        // pushAgent.setNotificationPlaySound(MsgConstant.NOTIFICATION_PLAY_SERVER);
        // pushAgent.setNotificationPlayLights(MsgConstant.NOTIFICATION_PLAY_SDK_DISABLE);
        // pushAgent.setNotificationPlayVibrate(MsgConstant.NOTIFICATION_PLAY_SDK_DISABLE);
        UmengMessageHandler messageHandler = new UmengMessageHandler() {
            @Override
            public void dealWithCustomMessage(final Context context, final UMessage uMessage) {
                Log.d(TAG, "uMessage: " + uMessage.toString());
                Toast.makeText(context, uMessage.custom, Toast.LENGTH_LONG).show();
            }

            @Override
            public void handleMessage(Context context, UMessage uMessage) {
                super.handleMessage(context, uMessage);

                Log.i(TAG, " handleMessage  ：-------->  "+count +"---"+ uMessage);
                String manufacturer = Build.MANUFACTURER.toLowerCase();
                if (TextUtils.isEmpty(manufacturer)) {
                    return;
                }
                if (manufacturer.contains("xiaomi")) {
                    return;
                }else{
                    count++;
                    BadgerUtil.addBadger(context, count);
                }
            }
//
            @Override
            public Notification getNotification(Context context, UMessage uMessage) {

                String manufacturer = Build.MANUFACTURER.toLowerCase();
                if (TextUtils.isEmpty(manufacturer)) {
                    return super.getNotification(context, uMessage);
                }
                if (manufacturer.contains("xiaomi")) {
                    count++;
                    Notification notification = new NotificationCompat.Builder(context, "badge")
                            .setContentTitle(uMessage.title)
                            .setContentText(uMessage.text)
                            .setSmallIcon(R.mipmap.ic_launcher)
                            .setBadgeIconType(NotificationCompat.BADGE_ICON_SMALL)
                            .setNumber(count)
                            .setAutoCancel(true)
                            .build();
                    return notification;
                }else{
                    return super.getNotification(context, uMessage);
                }
            }
        };

//        pushAgent.setDisplayNotificationNumber(1);
        pushAgent.setMessageHandler(messageHandler);
        UmengNotificationClickHandler notificationClickHandler = new UmengNotificationClickHandler() {
            public void launchApp(Context context, UMessage uMessage) {
                String umengPushMsg = formatMsg(uMessage);
                Log.i(TAG, "umengPushMsg: " + umengPushMsg);
                FlutterPluginUmpushPlugin.Companion.getMChannel().invokeMethod("onMessage", umengPushMsg, FLUTTER_METHOD_CALLBACK);
                super.launchApp(context, uMessage);
            }

            public void openUrl(Context context, UMessage uMessage) {
                String umengPushMsg = formatMsg(uMessage);
                Log.i(TAG, "umengPushMsg: " + umengPushMsg);
                FlutterPluginUmpushPlugin.Companion.getMChannel().invokeMethod("onMessage", umengPushMsg, FLUTTER_METHOD_CALLBACK);
                super.openUrl(context, uMessage);
            }

            public void openActivity(Context context, UMessage uMessage) {
                String umengPushMsg = formatMsg(uMessage);
                Log.i(TAG, "umengPushMsg: " + umengPushMsg);
                FlutterPluginUmpushPlugin.Companion.getMChannel().invokeMethod("onMessage", umengPushMsg, FLUTTER_METHOD_CALLBACK);
                super.openActivity(context, uMessage);
            }

            public void dealWithCustomAction(Context context, UMessage uMessage) {
                String umengPushMsg = formatMsg(uMessage);
                Log.i(TAG, "umengPushMsg: " + umengPushMsg);
                FlutterPluginUmpushPlugin.Companion.getMChannel().invokeMethod("onMessage", umengPushMsg, FLUTTER_METHOD_CALLBACK);
                super.dealWithCustomAction(context, uMessage);
            }
        };
        pushAgent.setNotificationClickHandler(notificationClickHandler);
        pushAgent.register(new IUmengRegisterCallback() {
                                       @Override
                                       public void onSuccess(String deviceToken) {
                                           Log.i(TAG, "device token: " + deviceToken);
                                           UmengApplication.savePushData(getApplicationContext(), UMENG_PUSH_DEVICE_TOKEN, deviceToken);
                                       }

                                       @Override
                                       public void onFailure(String s, String s1) {
                                           Log.i(TAG, "register failed: " + s + " " + s1);
                                       }
                                   });
        pushAgent.onAppStart();
        HuaWeiRegister.register(this);
        MeizuRegister.register(this, this.metaValue("MZ_APP_ID"), this.metaValue("MZ_APP_KEY"));
        MiPushRegistar.register(this, this.metaValue("XM_APP_ID"), this.metaValue("XM_APP_KEY"));


        registerActivityLifecycleCallbacks(lifecycleCallbacks);
    }


    private ActivityLifecycleCallbacks lifecycleCallbacks = new ActivityLifecycleCallbacks() {


        @Override
        public void onActivityCreated(Activity activity, Bundle bundle) {


        }

        @Override
        public void onActivityStarted(Activity activity) {
            Log.d("wilsonActivity","onActivityStarted");
            count =0;
            BadgerUtil.addBadger(activity, count);
            final Activity mActivity = activity;
            Log.d("wilsonActivity","onActivityCreated");
            NotificationManagerCompat notification = NotificationManagerCompat.from(activity);
            boolean isEnabled = notification.areNotificationsEnabled();
            if (!isEnabled) {
                //未打开通知
                AlertDialog alertDialog = new AlertDialog.Builder(activity)
                        .setTitle("提示")
                        .setMessage("请在“通知”中打开通知权限")
                        .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.cancel();
                            }
                        })
                        .setPositiveButton("去设置", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.cancel();
                                Intent intent = new Intent();
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                    intent.setAction("android.settings.APP_NOTIFICATION_SETTINGS");
                                    intent.putExtra("android.provider.extra.APP_PACKAGE",mActivity.getPackageName());
                                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {  //5.0
                                    intent.setAction("android.settings.APP_NOTIFICATION_SETTINGS");
                                    intent.putExtra("app_package", mActivity.getPackageName());
                                    intent.putExtra("app_uid",mActivity.getApplicationInfo().uid);
                                    startActivity(intent);
                                } else if (Build.VERSION.SDK_INT == Build.VERSION_CODES.KITKAT) {  //4.4
                                    intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                                    intent.addCategory(Intent.CATEGORY_DEFAULT);
                                    intent.setData(Uri.parse("package:" + mActivity.getPackageName()));
                                } else if (Build.VERSION.SDK_INT >= 15) {
                                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                    intent.setAction("android.settings.APPLICATION_DETAILS_SETTINGS");
                                    intent.setData(Uri.fromParts("package",mActivity.getPackageName(), null));
                                }
                                startActivity(intent);

                            }
                        })
                        .create();
                alertDialog.show();
                alertDialog.getButton(DialogInterface.BUTTON_NEGATIVE).setTextColor(Color.BLACK);
                alertDialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(Color.BLACK);
            }
        }

        @Override
        public void onActivityResumed(Activity activity) {
            Log.d("wilsonActivity","onActivityResumed");

            //关闭通知
            PushAgent pushAgent = PushAgent.getInstance(activity);
            pushAgent.disable(new IUmengCallback() {
                @Override
                public void onSuccess() {
                    Log.d("wilsonActivity","关闭通知");

                }
                @Override
                public void onFailure(String s, String s1) {
                }
            });
        }

        @Override
        public void onActivityPaused(Activity activity) {
            //开启通知
            Log.d("wilsonActivity","onActivityPaused");
            PushAgent pushAgent = PushAgent.getInstance(activity);
            pushAgent.enable(new IUmengCallback() {
                @Override
                public void onSuccess() {
                    Log.d("wilsonActivity","开启通知 ");
                }
                @Override
                public void onFailure(String s, String s1) {
                }
            });

        }

        @Override
        public void onActivityStopped(Activity activity) {
            Log.d("wilsonActivity","onActivityStopped");
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
            Log.d("wilsonActivity","onActivitySaveInstanceState");
        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            Log.d("wilsonActivity","onActivityDestroyed");
        }
    };

}
