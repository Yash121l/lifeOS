package com.yashlunawat.lifeos.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.yashlunawat.lifeos.ui.theme.DSCardBorder

@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    padding: Dp = 16.dp, // DSSpacing.md
    tint: Color = Color.White,
    content: @Composable () -> Unit
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(16.dp)) // DSRadius.lg
            .background(Color(0xFF141414).copy(alpha = 0.5f)) // Base glass
            .background(tint.copy(alpha = 0.05f))             // Tint overlay
            .border(
                width = 1.dp,
                color = DSCardBorder,
                shape = RoundedCornerShape(16.dp)
            )
            .padding(padding)
    ) {
        content()
    }
}
