package com.jio.phonelink.model

data class Notification(
    val title: String,
    val body: String,
    val packageName: String?,
    val timestamp: String
)

data class Message(
    val address: String,
    val body: String,
    val date: String
)

data class CallLog(
    val number: String,
    val type: String,
    val date: String,
    val duration: Long
)

data class DeviceInfo(
    val batteryLevel: Int,
    val batteryState: String,
    val networkSignal: String
)
