package com.yashlunawat.lifeos.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.yashlunawat.lifeos.ui.theme.DSAccent
import com.yashlunawat.lifeos.ui.theme.DSCardBorder

enum class PrimaryButtonStyle {
    Solid, Outline, Ghost
}

@Composable
fun PrimaryButton(
    title: String,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    style: PrimaryButtonStyle = PrimaryButtonStyle.Solid,
    action: () -> Unit
) {
    val containerColor = when (style) {
        PrimaryButtonStyle.Solid -> DSAccent
        PrimaryButtonStyle.Outline, PrimaryButtonStyle.Ghost -> Color.Transparent
    }
    
    val contentColor = when (style) {
        PrimaryButtonStyle.Solid -> Color.White
        PrimaryButtonStyle.Outline, PrimaryButtonStyle.Ghost -> DSAccent
    }
    
    val border = when (style) {
        PrimaryButtonStyle.Outline -> BorderStroke(1.dp, DSCardBorder)
        else -> null
    }

    Button(
        onClick = action,
        modifier = modifier,
        shape = RoundedCornerShape(16.dp), // DSRadius.lg
        colors = ButtonDefaults.buttonColors(
            containerColor = containerColor,
            contentColor = contentColor
        ),
        border = border,
        elevation = if (style == PrimaryButtonStyle.Solid) ButtonDefaults.buttonElevation(defaultElevation = 2.dp) else null
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 4.dp), // To match DSSpacing.md total padding
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            if (icon != null) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
            }
            Text(
                text = title,
                style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.SemiBold)
            )
        }
    }
}
