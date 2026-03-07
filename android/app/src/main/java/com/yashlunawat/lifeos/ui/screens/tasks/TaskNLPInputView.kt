package com.yashlunawat.lifeos.ui.screens.tasks

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import com.yashlunawat.lifeos.data.LifeOSViewModel
import com.yashlunawat.lifeos.data.services.NLPTaskParser
import com.yashlunawat.lifeos.ui.theme.*

@Composable
fun TaskNLPInputView(viewModel: LifeOSViewModel) {
    var textInput by remember { mutableStateOf("") }
    var isProcessing by remember { mutableStateOf(false) }

    val scale by animateFloatAsState(targetValue = if (isProcessing) 0.85f else 1f, label = "scale")

    fun processNLP() {
        if (textInput.isBlank()) return
        isProcessing = true
        
        val newTask = NLPTaskParser.parse(textInput)
        viewModel.addTask(newTask)
        
        textInput = ""
        isProcessing = false
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color(0xFF1C1C1E).copy(alpha = 0.7f), RoundedCornerShape(16.dp))
            .border(
                0.5.dp,
                if (textInput.isEmpty()) DSCardBorder else DSAccent.copy(alpha = 0.3f),
                RoundedCornerShape(16.dp)
            )
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Icon(
            imageVector = Icons.Default.AutoAwesome,
            contentDescription = null,
            tint = if (textInput.isEmpty()) DSTextTertiary else DSAccent,
            modifier = Modifier.size(14.dp)
        )

        TextField(
            value = textInput,
            onValueChange = { textInput = it },
            placeholder = { Text("Try: \"Call Mom tomorrow\"", color = DSTextTertiary) },
            colors = TextFieldDefaults.colors(
                focusedContainerColor = Color.Transparent,
                unfocusedContainerColor = Color.Transparent,
                focusedIndicatorColor = Color.Transparent,
                unfocusedIndicatorColor = Color.Transparent,
                focusedTextColor = DSTextPrimary,
                unfocusedTextColor = DSTextPrimary
            ),
            modifier = Modifier.weight(1f),
            keyboardOptions = KeyboardOptions.Default.copy(imeAction = ImeAction.Send),
            keyboardActions = KeyboardActions(onSend = { processNLP() })
        )

        if (textInput.isNotEmpty()) {
            IconButton(onClick = { processNLP() }) {
                Icon(
                    imageVector = Icons.Default.ArrowUpward,
                    contentDescription = "Add",
                    tint = DSAccent,
                    modifier = Modifier.scale(scale)
                )
            }
        }
    }
}
