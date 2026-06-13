package net.guilhermegomes.mytokens

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
import android.os.SystemClock
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth needs a FragmentActivity host to show the biometric prompt.
class MainActivity : FlutterFragmentActivity() {
    private val clockChannel = "net.guilhermegomes.mytokens/clock"
    private val privacyChannel = "net.guilhermegomes.mytokens/privacy"

    override fun onCreate(savedInstanceState: Bundle?) {
        // Block screenshots and the app-switcher preview so TOTP codes
        // do not leak while Flutter is still loading the saved preference.
        setScreenCaptureAllowed(false)
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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, privacyChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setScreenCaptureAllowed" -> {
                        val allowed = call.arguments as? Boolean
                        if (allowed == null) {
                            result.error(
                                "invalid_args",
                                "setScreenCaptureAllowed requires a boolean",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        setScreenCaptureAllowed(allowed)
                        result.success(null)
                    }
                    "setSensitiveClipboardText" -> {
                        val text = call.arguments as? String
                        if (text == null) {
                            result.error(
                                "invalid_args",
                                "setSensitiveClipboardText requires a string",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        setSensitiveClipboardText(text)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setScreenCaptureAllowed(allowed: Boolean) {
        if (allowed) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    private fun setSensitiveClipboardText(text: String) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("", text)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val extras = PersistableBundle().apply {
                putBoolean("android.content.extra.IS_SENSITIVE", true)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    putBoolean(ClipDescription.EXTRA_IS_SENSITIVE, true)
                }
            }
            clip.description.extras = extras
        }
        clipboard.setPrimaryClip(clip)
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
