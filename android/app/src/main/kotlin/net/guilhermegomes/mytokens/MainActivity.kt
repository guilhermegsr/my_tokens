package net.guilhermegomes.mytokens

import android.os.Build
import android.os.Bundle
import android.os.SystemClock
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth needs a FragmentActivity host to show the biometric prompt.
class MainActivity : FlutterFragmentActivity() {
    private val clockChannel = "net.guilhermegomes.mytokens/clock"

    override fun onCreate(savedInstanceState: Bundle?) {
        // Block screenshots and the app-switcher preview so TOTP codes
        // never leak to the gallery or recents.
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, clockChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Monotonic since boot; unaffected by user clock changes.
                    "monotonic" -> result.success(SystemClock.elapsedRealtime())
                    // The time the OS itself synced via NTP. No INTERNET
                    // permission needed; null when the device never synced.
                    "networkTime" -> result.success(networkTimeMillis())
                    else -> result.notImplemented()
                }
            }
    }

    private fun networkTimeMillis(): Long? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                SystemClock.currentNetworkTimeClock().millis()
            } catch (e: Exception) {
                null // DateTimeException when no network time is available.
            }
        } else {
            null
        }
}
