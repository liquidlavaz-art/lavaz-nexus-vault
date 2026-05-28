package com.lavaz.nexusvault

import android.webkit.WebChromeClient
import android.webkit.WebView

class LavazWebChromeClient : WebChromeClient() {

    override fun onProgressChanged(view: WebView?, newProgress: Int) {
        super.onProgressChanged(view, newProgress)
    }

    override fun onReceivedTitle(view: WebView?, title: String?) {
        super.onReceivedTitle(view, title)
    }
}
