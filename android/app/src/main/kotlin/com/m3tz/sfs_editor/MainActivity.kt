package com.m3tz.sfs_editor

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.embedding.engine.FlutterEngine

import java.io.File

import android.net.Uri
import android.content.Intent
import android.app.Activity
import android.content.Context
import android.content.ActivityNotFoundException
import android.widget.Toast
import androidx.core.content.FileProvider


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.flutter.dev/sfs_channel"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->
       if(call.method == "send_media") {
            val path = call.argument<String>("path")
            val file = path?.let { File(it) }
            val intent = Intent(Intent.ACTION_SEND)
            intent.type  = "image/*"
            // val fileUri = Uri.fromFile(file)
            val fileUri = file?.let {
                FileProvider.getUriForFile(
                    context,
                    "com.example.sfs_editor.provider",
                    it
                )
            }
            intent.putExtra(Intent.EXTRA_STREAM, fileUri)
            intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
            try {
                intent.setPackage("com.snapchat.android")
            } catch (e: ActivityNotFoundException) {
                // Handle the error, inform the user 
                Toast.makeText(this, "Snapchat not found or unable to share", Toast.LENGTH_SHORT).show()
            }
            startActivity(intent)
            result.success("Success")
        } else {
            result.notImplemented()
        }
    }
  }
}
