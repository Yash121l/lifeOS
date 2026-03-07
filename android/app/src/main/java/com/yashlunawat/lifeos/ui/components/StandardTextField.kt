package com.yashlunawat.lifeos.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.yashlunawat.lifeos.ui.theme.DSCardBorder
import com.yashlunawat.lifeos.ui.theme.DSSurfaceLight
import com.yashlunawat.lifeos.ui.theme.DSTextPrimary
import com.yashlunawat.lifeos.ui.theme.DSTextSecondary

@Composable
fun StandardTextField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null
) {
    BasicTextField(
        value = value,
        onValueChange = onValueChange,
        modifier = modifier.fillMaxWidth(),
        textStyle = MaterialTheme.typography.bodyLarge.copy(color = DSTextPrimary),
        cursorBrush = SolidColor(DSTextPrimary),
        decorationBox = { innerTextField ->
            Row(
                modifier = Modifier
                    .background(DSSurfaceLight, RoundedCornerShape(12.dp))
                    .border(1.dp, DSCardBorder, RoundedCornerShape(12.dp))
                    .padding(16.dp), // DSSpacing.md
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (icon != null) {
                    Icon(
                        imageVector = icon,
                        contentDescription = null,
                        tint = DSTextSecondary
                    )
                    Spacer(modifier = Modifier.width(12.dp)) // DSSpacing.sm
                }
                
                Box(modifier = Modifier.weight(1f)) {
                    if (value.isEmpty()) {
                        Text(
                            text = placeholder,
                            color = DSTextSecondary,
                            style = MaterialTheme.typography.bodyLarge
                        )
                    }
                    innerTextField()
                }
            }
        }
    )
}
