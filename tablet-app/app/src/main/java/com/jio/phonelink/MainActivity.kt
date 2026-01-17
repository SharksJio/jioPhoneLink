package com.jio.phonelink

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import com.jio.phonelink.databinding.ActivityMainBinding
import com.jio.phonelink.viewmodel.PhoneLinkViewModel

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private lateinit var viewModel: PhoneLinkViewModel
    private lateinit var notificationAdapter: NotificationAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        viewModel = ViewModelProvider(this)[PhoneLinkViewModel::class.java]

        setupUI()
        setupObservers()
        
        // Start WebSocket server
        viewModel.startServer()
    }

    private fun setupUI() {
        // Setup notifications list
        notificationAdapter = NotificationAdapter()
        binding.notificationsRecyclerView.apply {
            layoutManager = LinearLayoutManager(this@MainActivity)
            adapter = notificationAdapter
        }

        // Setup QR code for pairing
        binding.pairButton.setOnClickListener {
            viewModel.generatePairingQR()
        }
    }

    private fun setupObservers() {
        viewModel.connectionStatus.observe(this) { isConnected ->
            binding.connectionStatus.text = if (isConnected) {
                "Connected"
            } else {
                "Waiting for connection..."
            }
        }

        viewModel.batteryLevel.observe(this) { battery ->
            binding.batteryText.text = "Battery: ${battery}%"
        }

        viewModel.networkSignal.observe(this) { signal ->
            binding.networkText.text = "Signal: $signal"
        }

        viewModel.notifications.observe(this) { notifications ->
            notificationAdapter.submitList(notifications)
        }

        viewModel.messages.observe(this) { messages ->
            // Update messages UI
        }

        viewModel.qrCodeBitmap.observe(this) { bitmap ->
            bitmap?.let {
                binding.qrCodeImage.setImageBitmap(it)
            }
        }

        viewModel.errorMessage.observe(this) { error ->
            error?.let {
                Toast.makeText(this, it, Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        viewModel.stopServer()
    }
}
