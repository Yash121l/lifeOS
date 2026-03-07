package com.yashlunawat.lifeos.ui.screens.finance

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.CompareArrows
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material.icons.filled.Repeat
import androidx.compose.material.icons.filled.TrendingUp
import com.yashlunawat.lifeos.data.LifeOSViewModel
import com.yashlunawat.lifeos.data.models.TransactionItem
import com.yashlunawat.lifeos.data.services.SettingsManager
import com.yashlunawat.lifeos.ui.components.GlassCard
import com.yashlunawat.lifeos.ui.theme.*
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FinanceScreen(viewModel: LifeOSViewModel, onNavigateToEntry: () -> Unit) {
    val transactions by viewModel.transactions.collectAsState()

    val calendar = Calendar.getInstance()
    val todayStart = calendar.apply {
        set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0); set(Calendar.SECOND, 0)
    }.timeInMillis
    val weekAgo = todayStart - 7 * 24 * 60 * 60 * 1000L
    val monthStart = calendar.apply {
        set(Calendar.DAY_OF_MONTH, 1)
    }.timeInMillis

    val todaySpend = transactions.filter { it.isExpense && it.date >= todayStart }.sumOf { it.amount }
    val weeklySpend = transactions.filter { it.isExpense && it.date >= weekAgo }.sumOf { it.amount }
    val monthlySpend = transactions.filter { it.isExpense && it.date >= monthStart }.sumOf { it.amount }
    val monthlyBudget = 2000.0
    val budgetProgress = (monthlySpend / monthlyBudget).coerceIn(0.0, 1.0).toFloat()

    val recentTransactions = transactions.take(15)
    
    val groupedTransactions = recentTransactions.groupBy { tx ->
        when {
            tx.date >= todayStart -> "Today"
            tx.date >= todayStart - 24 * 60 * 60 * 1000L -> "Yesterday"
            else -> SimpleDateFormat("MMM d", Locale.getDefault()).format(Date(tx.date))
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Finance") },
                actions = {
                    IconButton(onClick = onNavigateToEntry) {
                        Icon(Icons.Default.Add, contentDescription = "Add Transaction", tint = DSTextSecondary)
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
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // Grid Layout
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.height(IntrinsicSize.Min)) {
                Box(modifier = Modifier.weight(1f).fillMaxHeight()) {
                    NetWorthCard()
                }
                Box(modifier = Modifier.weight(1f).fillMaxHeight()) {
                    BudgetRingCard(budgetProgress)
                }
            }

            TodaySpendCard(todaySpend, weeklySpend)
            QuickActionsRow(onNavigateToEntry)
            AiInsightCard(todaySpend, weeklySpend)
            TransactionsSection(groupedTransactions)
            Spacer(modifier = Modifier.height(120.dp))
        }
    }
}

@Composable
fun NetWorthCard() {
    GlassCard(tint = DSSuccess, padding = 16.dp, modifier = Modifier.fillMaxSize()) {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Net Worth", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                Spacer(modifier = Modifier.weight(1f))
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(2.dp)) {
                    Icon(Icons.Default.TrendingUp, contentDescription = null, tint = DSSuccess, modifier = Modifier.size(10.dp))
                    Text("+2.4%", fontSize = 10.sp, color = DSSuccess)
                }
            }
            Text("${SettingsManager.currencySymbol}10,400", fontSize = 26.sp, fontWeight = FontWeight.Bold, color = DSTextPrimary)
            // Mini chart placeholder
            Spacer(modifier = Modifier.height(30.dp))
        }
    }
}

@Composable
fun BudgetRingCard(progress: Float) {
    GlassCard(padding = 16.dp, modifier = Modifier.fillMaxSize()) {
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Box(contentAlignment = Alignment.Center, modifier = Modifier.size(50.dp)) {
                CircularProgressIndicator(progress = 1f, color = DSSurfaceLight, strokeWidth = 6.dp)
                CircularProgressIndicator(
                    progress = progress,
                    color = if (progress > 0.8f) DSError else DSAccent,
                    strokeWidth = 6.dp,
                    strokeCap = StrokeCap.Round
                )
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("${(progress * 100).toInt()}%", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = DSTextPrimary)
                    Text("used", fontSize = 9.sp, color = DSTextTertiary)
                }
            }
            Text("Monthly", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
        }
    }
}

@Composable
fun TodaySpendCard(todaySpend: Double, weeklySpend: Double) {
    GlassCard(tint = DSError, padding = 16.dp) {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text("Today", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                Text(
                    text = "${SettingsManager.currencySymbol}${String.format(Locale.getDefault(), "%.2f", todaySpend)}",
                    fontSize = 24.sp, fontWeight = FontWeight.Bold, color = if (todaySpend > 0) DSError else DSTextSecondary
                )
            }
            Spacer(modifier = Modifier.weight(1f))
            Box(modifier = Modifier.width(1.dp).height(30.dp).background(DSCardBorder))
            Spacer(modifier = Modifier.width(16.dp))
            Column(verticalArrangement = Arrangement.spacedBy(4.dp), horizontalAlignment = Alignment.End) {
                Text("This Week", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                Text(
                    text = "${SettingsManager.currencySymbol}${String.format(Locale.getDefault(), "%.2f", weeklySpend)}",
                    fontSize = 24.sp, fontWeight = FontWeight.Bold, color = DSTextSecondary
                )
            }
        }
    }
}

@Composable
fun AiInsightCard(todaySpend: Double, weeklySpend: Double) {
    val insightText = when {
        weeklySpend > 500 -> "You've spent ${SettingsManager.currencySymbol}${weeklySpend.toInt()} this week. Consider reducing discretionary spending."
        todaySpend == 0.0 -> "No spending today — great discipline! \uD83C\uDFAF"
        else -> "You're on track with your budget this month."
    }

    GlassCard(tint = DSAccent, padding = 16.dp) {
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            Icon(Icons.Default.Psychology, contentDescription = null, tint = DSAccent, modifier = Modifier.size(20.dp))
            Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text("AI Insight", style = MaterialTheme.typography.labelSmall, color = DSAccent)
                Text(insightText, style = MaterialTheme.typography.bodyMedium, color = DSTextSecondary)
            }
        }
    }
}

@Composable
fun QuickActionsRow(onNavigateToEntry: () -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        ActionButton("Expense", Icons.Default.ArrowUpward, DSError, onNavigateToEntry, Modifier.weight(1f))
        ActionButton("Income", Icons.Default.ArrowDownward, DSSuccess, onNavigateToEntry, Modifier.weight(1f))
        ActionButton("Transfer", Icons.Default.CompareArrows, DSAccent, {}, Modifier.weight(1f))
    }
}

@Composable
fun ActionButton(title: String, icon: androidx.compose.ui.graphics.vector.ImageVector, color: Color, onClick: () -> Unit, modifier: Modifier = Modifier) {
    Surface(onClick = onClick, color = Color.Transparent, modifier = modifier) {
        GlassCard(padding = 12.dp) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                Icon(icon, contentDescription = null, tint = color, modifier = Modifier.size(16.dp))
                Text(title, style = MaterialTheme.typography.labelSmall, color = DSTextSecondary)
            }
        }
    }
}

@Composable
fun TransactionsSection(groupedTransactions: Map<String, List<TransactionItem>>) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Recent Transactions", style = MaterialTheme.typography.headlineMedium, color = DSTextPrimary)
        if (groupedTransactions.isEmpty()) {
            GlassCard(padding = 16.dp) {
                Text("No transactions yet", style = MaterialTheme.typography.bodyLarge, color = DSTextTertiary)
            }
        } else {
            groupedTransactions.forEach { (dateStr, txs) ->
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(dateStr, style = MaterialTheme.typography.labelSmall, color = DSTextTertiary, modifier = Modifier.padding(top = 8.dp))
                    txs.forEach { tx ->
                        TransactionRow(tx)
                    }
                }
            }
        }
    }
}

@Composable
fun TransactionRow(tx: TransactionItem) {
    GlassCard(padding = 12.dp) {
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(modifier = Modifier.size(36.dp).background(DSSurfaceLight, CircleShape), contentAlignment = Alignment.Center) {
                Text(tx.categoryEmoji, fontSize = 20.sp)
            }
            Column(verticalArrangement = Arrangement.spacedBy(2.dp), modifier = Modifier.weight(1f)) {
                Text(tx.title, style = MaterialTheme.typography.bodyLarge, color = DSTextPrimary, maxLines = 1)
                Row(horizontalArrangement = Arrangement.spacedBy(4.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text(tx.category, style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                    if (tx.isRecurring) {
                        Icon(Icons.Default.Repeat, contentDescription = null, tint = DSTextTertiary, modifier = Modifier.size(9.dp))
                    }
                }
            }
            Text(
                text = "${if (tx.isExpense) "-" else "+"}${SettingsManager.currencySymbol}${String.format(Locale.getDefault(), "%.2f", tx.amount)}",
                fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = if (tx.isExpense) DSError else DSSuccess
            )
        }
    }
}
