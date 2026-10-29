package com.example.myaliv_mobile_app.biometric

import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_STRONG
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_WEAK
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/// Handles the `new.app.myaliv/biometric` method channel. Invokes
/// `BiometricPrompt` with a specific authenticator class so Face Lock and
/// Fingerprint buttons on the Flutter side launch distinct system prompts
/// instead of the unified any-biometric prompt that `local_auth` surfaces.
class BiometricChannelHandler(
    private val activity: FragmentActivity,
) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "new.app.myaliv/biometric"
        private const val TAG = "BiometricChannel"
    }

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "authenticate" -> {
                val type = call.argument<String>("type") ?: ""
                val title = call.argument<String>("title") ?: "Sign in"
                val subtitle = call.argument<String>("subtitle")
                val negative = call.argument<String>("negativeButton") ?: "Cancel"
                authenticate(type, title, subtitle, negative, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun authenticate(
        type: String,
        title: String,
        subtitle: String?,
        negative: String,
        result: MethodChannel.Result,
    ) {
        Log.d(TAG, "authenticate(type=$type) sdk=${Build.VERSION.SDK_INT} hasFaceFeature=${activity.packageManager.hasSystemFeature(PackageManager.FEATURE_FACE)}")

        // BIOMETRIC_WEAK (face unlock Class 2) is an API 30+ constant. Below
        // that we can't filter face-only, so surface "notAvailable" to the UI.
        if (type == "face" && Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            Log.w(TAG, "Face auth requested but SDK<R; returning notAvailable")
            result.success(buildResult("notAvailable", message = "Face unlock requires Android 11+"))
            return
        }

        val requestedFlag = when (type) {
            "face" -> BIOMETRIC_WEAK
            "fingerprint" -> BIOMETRIC_STRONG
            else -> {
                result.success(buildResult("error", message = "Unknown type: $type"))
                return
            }
        }

        val biometricManager = BiometricManager.from(activity)
        var effectiveFlag = requestedFlag
        val canAuth = biometricManager.canAuthenticate(requestedFlag)
        Log.d(TAG, "canAuthenticate(flag=${flagName(requestedFlag)}) = ${canAuthName(canAuth)}")

        if (canAuth != BiometricManager.BIOMETRIC_SUCCESS) {
            // Pixel 8+ edge case: face unlock is Class 3 (strong) so BIOMETRIC_WEAK
            // reports NONE_ENROLLED even though the device has face enrolled. Retry
            // with BIOMETRIC_STRONG if the device actually has face hardware + a
            // strong biometric enrolled.
            val canStrong = biometricManager.canAuthenticate(BIOMETRIC_STRONG)
            Log.d(TAG, "fallback probe: canAuthenticate(STRONG) = ${canAuthName(canStrong)}")
            val isFaceClass3Retry = type == "face" &&
                canAuth == BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED &&
                activity.packageManager.hasSystemFeature(PackageManager.FEATURE_FACE) &&
                canStrong == BiometricManager.BIOMETRIC_SUCCESS

            if (isFaceClass3Retry) {
                Log.i(TAG, "Face-Class-3 retry: using BIOMETRIC_STRONG for face request")
                effectiveFlag = BIOMETRIC_STRONG
            } else {
                Log.w(TAG, "Returning early with ${mapCanAuthenticate(canAuth)}; raw=$canAuth")
                result.success(buildResult(mapCanAuthenticate(canAuth), errorCode = canAuth))
                return
            }
        }

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle(title)
            .apply { subtitle?.let { setSubtitle(it) } }
            .setNegativeButtonText(negative)
            .setConfirmationRequired(false)
            .setAllowedAuthenticators(effectiveFlag)
            .build()

        val callback = object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(r: BiometricPrompt.AuthenticationResult) {
                Log.i(TAG, "onAuthenticationSucceeded authType=${r.authenticationType}")
                result.success(buildResult("success"))
            }

            override fun onAuthenticationFailed() {
                Log.d(TAG, "onAuthenticationFailed (transient mismatch; prompt stays open)")
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                Log.w(TAG, "onAuthenticationError code=$errorCode msg=$errString -> ${mapErrorCode(errorCode)}")
                result.success(buildResult(mapErrorCode(errorCode), errorCode = errorCode, message = errString.toString()))
            }
        }

        Log.i(TAG, "Launching BiometricPrompt flag=${flagName(effectiveFlag)}")

        val prompt = BiometricPrompt(
            activity,
            ContextCompat.getMainExecutor(activity),
            callback,
        )
        prompt.authenticate(promptInfo)
    }

    private fun flagName(flag: Int): String = when (flag) {
        BIOMETRIC_WEAK -> "BIOMETRIC_WEAK"
        BIOMETRIC_STRONG -> "BIOMETRIC_STRONG"
        else -> "flag=$flag"
    }

    private fun canAuthName(code: Int): String = when (code) {
        BiometricManager.BIOMETRIC_SUCCESS -> "SUCCESS"
        BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> "NONE_ENROLLED"
        BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE -> "NO_HARDWARE"
        BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE -> "HW_UNAVAILABLE"
        BiometricManager.BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED -> "SECURITY_UPDATE_REQUIRED"
        BiometricManager.BIOMETRIC_ERROR_UNSUPPORTED -> "UNSUPPORTED"
        BiometricManager.BIOMETRIC_STATUS_UNKNOWN -> "STATUS_UNKNOWN"
        else -> "code=$code"
    }

    private fun mapCanAuthenticate(code: Int): String = when (code) {
        BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> "notEnrolled"
        BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE -> "notAvailable"
        BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE -> "notAvailable"
        BiometricManager.BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED -> "notSupported"
        else -> "error"
    }

    private fun mapErrorCode(code: Int): String = when (code) {
        BiometricPrompt.ERROR_USER_CANCELED,
        BiometricPrompt.ERROR_NEGATIVE_BUTTON,
        BiometricPrompt.ERROR_CANCELED -> "cancelled"
        BiometricPrompt.ERROR_LOCKOUT,
        BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> "lockedOut"
        BiometricPrompt.ERROR_NO_BIOMETRICS -> "notEnrolled"
        BiometricPrompt.ERROR_HW_NOT_PRESENT,
        BiometricPrompt.ERROR_HW_UNAVAILABLE -> "notAvailable"
        else -> "error"
    }

    private fun buildResult(
        result: String,
        errorCode: Int? = null,
        message: String? = null,
    ): Map<String, Any?> = mapOf(
        "result" to result,
        "errorCode" to errorCode,
        "message" to message,
    )
}
