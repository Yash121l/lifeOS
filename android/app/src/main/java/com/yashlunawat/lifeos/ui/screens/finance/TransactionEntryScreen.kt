package com.yashlunawat.lifeos.ui.screens.finance

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CapsuleShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yashlunawat.lifeos.data.LifeOSViewModel
import com.yashlunawat.lifeos.data.models.TransactionItem
import com.yashlunawat.lifeos.data.services.SettingsManager
import com.yashlunawat.lifeos.ui.components.GlassCard
import com.yashlunawat.lifeos.ui.components.PrimaryButton
import com.yashlunawat.lifeos.ui.components.PrimaryButtonStyle
import com.yashlunawat.lifeos.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TransactionEntryScreen(viewModel: LifeOSViewModel, onNavigateBack: () -> Unit) {
    var amount by remember { mutableStateOf("") }
    var title by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf("Food") }
    var isExpense by remember { mutableStateOf(true) }
    var isRecurring by remember { mutableStateOf(false) }

    val categories = listOf("Food", "Transport", "Shopping", "Entertainment", "Bills", "Health", "Education", "Subscription", "Income", "Other")

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("New Transaction") },
                navigationIcon = {
                    TextButton(onClick = onNavigateBack) {
                        Text("Cancel", color = DSTextSecondary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = DSBackground, titleContentColor = DSTextPrimary)
            )
        },
        containerColor = DSBackground
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 24.dp),
            verticalArrangement = Arrangement.spacedBy(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Amount Input
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(if (isExpense) "Expense Amount" else "Income Amount", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)

                Row(verticalAlignment = Alignment.Bottom, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(SettingsManager.currencySymbol, fontSize = 32.sp, fontWeight = FontWeight.SemiBold, color = DSTextSecondary)
                    TextField(
                        value = amount,
                        onValueChange = { amount = it },
                        placeholder = { Text("0.00", color = if (isExpense) DSError.copy(alpha = 0.5f) else DSSuccess.copy(alpha = 0.5f)) },
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = Color.Transparent, unfocusedContainerColor = Color.Transparent,
                            focusedIndicatorColor = Color.Transparent, unfocusedIndicatorColor = Color.Transparent,
                            focusedTextColor = if (isExpense) DSError else DSSuccess
                        ),
                        textStyle = MaterialTheme.typography.displayLarge.copy(textAlign = TextAlign.Center),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                        modifier = Modifier.width(IntrinsicSize.Min)
                    )
                }

                // Type Toggle
                Row(
                    modifier = Modifier.background(DSSurfaceLight, CapsuleShape).padding(2.dp).width(200.dp)
                ) {
                    Button(
                        onClick = { isExpense = true },
                        colors = ButtonDefaults.buttonColors(containerColor = if (isExpense) DSError else Color.Transparent, contentColor = if (isExpense) Color.White else DSTextSecondary),
                        shape = CapsuleShape,
                        modifier = Modifier.weight(1f).height(32.dp),
                        contentPadding = PaddingValues(0.dp)
                    ) {
                        Text("Expense", style = MaterialTheme.typography.labelSmall)
                    }
                    Button(
                        onClick = { isExpense = false; selectedCategory = "Income" },
                        colors = ButtonDefaults.buttonColors(containerColor = if (!isExpense) DSSuccess else Color.Transparent, contentColor = if (!isExpense) Color.White else DSTextSecondary),
                        shape = CapsuleShape,
                        modifier = Modifier.weight(1f).height(32.dp),
                        contentPadding = PaddingValues(0.dp)
                    ) {
                        Text("Income", style = MaterialTheme.typography.labelSmall)
                    }
                }
            }

            // Details Form
            GlassCard(padding = 0.dp) {
                Column {
                    // Title
                    Row(modifier = Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text("Title", style = MaterialTheme.typography.bodyLarge, color = DSTextPrimary)
                        Spacer(modifier = Modifier.weight(1f))
                        TextField(
                            value = title,
                            onValueChange = { title = it },
                            placeholder = { Text("What was this for?", color = DSTextSecondary) },
                            colors = TextFieldDefaults.colors(
                                focusedContainerColor = Color.Transparent, unfocusedContainerColor = Color.Transparent,
                                focusedIndicatorColor = Color.Transparent, unfocusedIndicatorColor = Color.Transparent,
                                focusedTextColor = DSTextPrimary, unfocusedTextColor = DSTextSecondary
                            ),
                            textStyle = MaterialTheme.typography.bodyLarge.copy(textAlign = TextAlign.End),
                            modifier = Modifier.width(200.dp)
                        )
                    }

                    HorizontalDivider(color = DSCardBorder)

                    // Category
                    Row(modifier = Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text("Category", style = MaterialTheme.typography.bodyLarge, color = DSTextPrimary)
                        Spacer(modifier = Modifier.weight(1f))
                        // We will just use a DropdownMenu conceptually or simple text/button for now since Compose doesn't have a native compact picker.
                        var expanded by remember { mutableStateOf(false) }
                        Box {
                            TextButton(onClick = { expanded = true }) {
                                Text(selectedCategory, color = DSAccent)
                            }
                            DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                                categories.forEach { cat ->
                                    DropdownMenuItem(text = { Text(cat) }, onClick = { selectedCategory = cat; expanded = false })
                                }
                            }
                        }
                    }

                    HorizontalDivider(color = DSCardBorder)

                    // Recurring
                    Row(modifier = Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text("Recurring", style = MaterialTheme.typography.bodyLarge, color = DSTextPrimary)
                        Spacer(modifier = Modifier.weight(1f))
                        Switch(checked = isRecurring, onCheckedChange = { isRecurring = it }, colors = SwitchDefaults.colors(checkedTrackColor = DSAccent))
                    }
                }
            }

            PrimaryButton(
                title = "Add Transaction",
                style = PrimaryButtonStyle.Solid,
                action = {
                    val amountValue = amount.replace(",", ".").toDoubleOrNull()
                    if (amountValue != null && title.isNotBlank()) {
                        viewModel.addTransaction(
                            TransactionItem(
                                title = title,
                                amount = amountValue,
                                category = selectedCategory,
                                isExpense = isExpense,
                                isRecurring = isRecurring
                            )
                        )
                        onNavigateBack()
                    }
                }
            )
        }
    }
}
