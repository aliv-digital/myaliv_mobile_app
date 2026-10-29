package com.example.myaliv_mobile_app

import com.example.myaliv_mobile_app.biometric.BiometricChannelHandler
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        BiometricChannelHandler(this).register(flutterEngine.dartExecutor.binaryMessenger)
    }
}
