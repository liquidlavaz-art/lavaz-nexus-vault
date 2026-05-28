package com.lavaz.nexusvault

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.webkit.WebSettings
import android.webkit.WebView
import androidx.appcompat.app.AppCompatActivity
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity : AppCompatActivity() {

    private lateinit var webView: WebView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        webView = findViewById(R.id.webView)
        configureWebView()
        loadHtmlContent()
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun configureWebView() {
        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            databaseEnabled = true
            cacheMode = WebSettings.LOAD_DEFAULT
            mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
            useWideViewPort = true
            loadWithOverviewMode = true
            setSupportZoom(true)
            builtInZoomControls = false
            displayZoomControls = false
            defaultTextEncodingName = "utf-8"
            textZoom = 100
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                forceDark = WebSettings.FORCE_DARK_OFF
            }
        }

        webView.webViewClient = LavazWebViewClient()
        webView.webChromeClient = LavazWebChromeClient()
    }

    private fun loadHtmlContent() {
        try {
            val htmlContent = readRawResource(R.raw.index)
            val baseUrl = "file:///android_asset/"
            webView.loadDataWithBaseURL(
                baseUrl,
                htmlContent,
                "text/html",
                "utf-8",
                null
            )
        } catch (e: Exception) {
            e.printStackTrace()
            webView.loadData(
                "<h1>Error Loading Content</h1><p>${e.message}</p>",
                "text/html",
                "utf-8"
            )
        }
    }

    private fun readRawResource(resourceId: Int): String {
        return try {
            resources.openRawResource(resourceId).use { inputStream ->
                BufferedReader(InputStreamReader(inputStream)).use { reader ->
                    reader.readText()
                }
            }
        } catch (e: Exception) {
            "<h1>Resource Error</h1><p>Could not read resource: ${e.message}</p>"
        }
    }

    override fun onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack()
        } else {
            super.onBackPressed()
        }
    }

    override fun onDestroy() {
        webView.destroy()
        super.onDestroy()
    }
}
