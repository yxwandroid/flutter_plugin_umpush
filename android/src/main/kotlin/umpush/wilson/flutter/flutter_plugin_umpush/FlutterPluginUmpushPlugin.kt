package umpush.wilson.flutter.flutter_plugin_umpush
import android.util.Log
import com.umeng.message.PushAgent
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterPluginUmpushPlugin : MethodCallHandler {

    private val tag = "flutter_plugin_push"

    companion object {
        var mRegistrar: Registrar? = null
        var mChannel: MethodChannel? = null
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_plugin_umpush")
            var   instance = FlutterPluginUmpushPlugin()
            channel.setMethodCallHandler(instance)
            mChannel = channel
            mRegistrar = registrar

        }
    }


    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.i(tag, "onMethodCall: ${call.method}")
        when {
            "configure" == call.method -> {
                //查看缓存是否存在Token，存在在回调
                val umsgPushMsg = UmengApplication.getPushData(mRegistrar!!.context(), UmengApplication.UMENG_PUSH_MESSAGE)
                if (umsgPushMsg != null && umsgPushMsg != "") {
                    mRegistrar!!.activity().runOnUiThread(java.lang.Runnable {
                        mChannel!!.invokeMethod("onMessage", umsgPushMsg, object : Result {
                            override fun success(o: Any?) {
                                //删除数据
                                UmengApplication.savePushData(mRegistrar!!.context(), UmengApplication.UMENG_PUSH_MESSAGE, null)
                            }

                            override fun error(s: String, s1: String?, o: Any?) {

                            }

                            override fun notImplemented() {

                            }
                        })
                    })

                }
                result.success(null)
            }
            "setAlias" == call.method -> {
                //添加一个获取Token的方法
                val useName = call.argument<String>("alias")
                val umengDeviceToken = UmengApplication.getPushData(mRegistrar!!.context(), UmengApplication.UMENG_PUSH_DEVICE_TOKEN)
                val alias = umengDeviceToken + useName!!
                val mPushAgent = PushAgent.getInstance(mRegistrar!!.context())
                //别名绑定，将某一类型的别名ID绑定至某设备，老的绑定设备信息被覆盖，别名ID和deviceToken是一对一的映射关系
                mPushAgent.setAlias(alias, "自有id") { isSuccess, message ->
                    if (isSuccess) {
                        mRegistrar!!.activity().runOnUiThread(java.lang.Runnable {
                            mChannel!!.invokeMethod("onGetAlias",alias)
                        })
                    }else{
                        Log.e(tag, "设置别名失败")
                    }
                }

                result.success(null)
            }
            "deviceToken" == call.method -> {
                val umengDeviceToken = UmengApplication.getPushData(mRegistrar!!.context(), UmengApplication.UMENG_PUSH_DEVICE_TOKEN)
                mRegistrar!!.activity().runOnUiThread(java.lang.Runnable {
                    mChannel!!.invokeMethod("deviceToken",umengDeviceToken)
                })
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
