package com.jio.phonelink.viewmodel

import android.app.Application
import android.graphics.Bitmap
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.google.zxing.BarcodeFormat
import com.google.zxing.MultiFormatWriter
import com.google.zxing.common.BitMatrix
import com.jio.phonelink.model.Notification
import com.jio.phonelink.model.Message
import com.jio.phonelink.server.WebSocketServer
import java.net.InetAddress
import java.net.NetworkInterface

class PhoneLinkViewModel(application: Application) : AndroidViewModel(application) {
    private val _connectionStatus = MutableLiveData<Boolean>(false)
    val connectionStatus: LiveData<Boolean> = _connectionStatus

    private val _batteryLevel = MutableLiveData<Int>(0)
    val batteryLevel: LiveData<Int> = _batteryLevel

    private val _networkSignal = MutableLiveData<String>("Unknown")
    val networkSignal: LiveData<String> = _networkSignal

    private val _notifications = MutableLiveData<List<Notification>>(emptyList())
    val notifications: LiveData<List<Notification>> = _notifications

    private val _messages = MutableLiveData<List<Message>>(emptyList())
    val messages: LiveData<List<Message>> = _messages

    private val _qrCodeBitmap = MutableLiveData<Bitmap?>()
    val qrCodeBitmap: LiveData<Bitmap?> = _qrCodeBitmap

    private val _errorMessage = MutableLiveData<String?>()
    val errorMessage: LiveData<String?> = _errorMessage

    private var webSocketServer: WebSocketServer? = null

    fun startServer() {
        try {
            val port = 8080
            webSocketServer = WebSocketServer(port) { message ->
                handleIncomingMessage(message)
            }
            webSocketServer?.start()
            
            val ipAddress = getLocalIpAddress()
            generatePairingQR(ipAddress)
        } catch (e: Exception) {
            _errorMessage.postValue("Failed to start server: ${e.message}")
        }
    }

    fun stopServer() {
        webSocketServer?.stop()
    }

    fun generatePairingQR(address: String? = null) {
        try {
            val ipAddress = address ?: getLocalIpAddress()
            val qrContent = ipAddress
            
            val width = 512
            val height = 512
            val bitMatrix: BitMatrix = MultiFormatWriter().encode(
                qrContent,
                BarcodeFormat.QR_CODE,
                width,
                height
            )
            
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565)
            for (x in 0 until width) {
                for (y in 0 until height) {
                    bitmap.setPixel(x, y, if (bitMatrix[x, y]) 0xFF000000.toInt() else 0xFFFFFFFF.toInt())
                }
            }
            
            _qrCodeBitmap.postValue(bitmap)
        } catch (e: Exception) {
            _errorMessage.postValue("Failed to generate QR code: ${e.message}")
        }
    }

    private fun handleIncomingMessage(message: Map<String, Any>) {
        when (message["type"]) {
            "notification" -> {
                val data = message["data"] as? Map<String, Any>
                data?.let {
                    val notification = Notification(
                        title = it["title"] as? String ?: "",
                        body = it["body"] as? String ?: "",
                        packageName = it["packageName"] as? String,
                        timestamp = it["timestamp"] as? String ?: ""
                    )
                    addNotification(notification)
                }
            }
            "device_info" -> {
                val data = message["data"] as? Map<String, Any>
                data?.let {
                    val battery = it["battery"] as? Map<String, Any>
                    battery?.let { b ->
                        val level = b["level"] as? Int ?: 0
                        _batteryLevel.postValue(level)
                    }
                }
            }
            "sms_sync" -> {
                val data = message["data"] as? Map<String, Any>
                data?.let {
                    // Handle SMS sync
                }
            }
        }
        
        _connectionStatus.postValue(true)
    }

    private fun addNotification(notification: Notification) {
        val currentList = _notifications.value?.toMutableList() ?: mutableListOf()
        currentList.add(0, notification)
        _notifications.postValue(currentList)
    }

    private fun getLocalIpAddress(): String {
        try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            while (interfaces.hasMoreElements()) {
                val networkInterface = interfaces.nextElement()
                val addresses = networkInterface.inetAddresses
                while (addresses.hasMoreElements()) {
                    val address = addresses.nextElement()
                    if (!address.isLoopbackAddress && address is InetAddress) {
                        val hostAddress = address.hostAddress
                        if (hostAddress?.indexOf(':') == -1) {
                            return hostAddress ?: ""
                        }
                    }
                }
            }
        } catch (e: Exception) {
            _errorMessage.postValue("Failed to get IP address: ${e.message}")
        }
        return "0.0.0.0"
    }
}
