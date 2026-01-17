package com.jio.phonelink.server

import com.google.gson.Gson
import org.java_websocket.WebSocket
import org.java_websocket.handshake.ClientHandshake
import org.java_websocket.server.WebSocketServer as JavaWebSocketServer
import java.net.InetSocketAddress

class WebSocketServer(
    port: Int,
    private val onMessageReceived: (Map<String, Any>) -> Unit
) : JavaWebSocketServer(InetSocketAddress(port)) {

    private val gson = Gson()
    private val connectedClients = mutableSetOf<WebSocket>()

    override fun onOpen(conn: WebSocket?, handshake: ClientHandshake?) {
        conn?.let {
            connectedClients.add(it)
            println("New connection from: ${conn.remoteSocketAddress}")
        }
    }

    override fun onClose(conn: WebSocket?, code: Int, reason: String?, remote: Boolean) {
        conn?.let {
            connectedClients.remove(it)
            println("Closed connection to: ${conn.remoteSocketAddress}")
        }
    }

    override fun onMessage(conn: WebSocket?, message: String?) {
        message?.let {
            try {
                @Suppress("UNCHECKED_CAST")
                val data = gson.fromJson(it, Map::class.java) as? Map<String, Any>
                data?.let { validData ->
                    onMessageReceived(validData)
                } ?: run {
                    println("Error: Invalid message format")
                }
            } catch (e: Exception) {
                println("Error parsing message: ${e.message}")
            }
        }
    }

    override fun onError(conn: WebSocket?, ex: Exception?) {
        ex?.printStackTrace()
    }

    override fun onStart() {
        println("WebSocket server started on port: $port")
    }

    override fun broadcast(message: String) {
        connectedClients.forEach { client ->
            client.send(message)
        }
    }
}
