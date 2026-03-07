package com.yashlunawat.lifeos

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.yashlunawat.lifeos.data.LifeOSViewModel
import com.yashlunawat.lifeos.data.local.AppDatabase
import com.yashlunawat.lifeos.ui.theme.LifeOSTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        val database = AppDatabase.getDatabase(applicationContext)
        val factory = object : ViewModelProvider.Factory {
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                if (modelClass.isAssignableFrom(LifeOSViewModel::class.java)) {
                    @Suppress("UNCHECKED_CAST")
                    return LifeOSViewModel(database.lifeOSDao()) as T
                }
                throw IllegalArgumentException("Unknown ViewModel class")
            }
        }
        val viewModel = ViewModelProvider(this, factory)[LifeOSViewModel::class.java]

        setContent {
            LifeOSTheme {
                LifeOSApp(viewModel)
            }
        }
    }
}
