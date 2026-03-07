package com.yashlunawat.lifeos.ui.screens.time

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CapsuleShape
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.horizontalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddCircle
import com.yashlunawat.lifeos.data.LifeOSViewModel
import com.yashlunawat.lifeos.data.models.TimeBlock
import com.yashlunawat.lifeos.ui.theme.*
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TimeScreen(viewModel: LifeOSViewModel, onNavigateToEventEntry: () -> Unit) {
    val blocks by viewModel.timeBlocks.collectAsState()
    
    var selectedDate by remember { mutableStateOf(Calendar.getInstance().apply { 
        set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0); set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0) 
    }.timeInMillis) }

    val todayStr = SimpleDateFormat("MMM d, yyyy", Locale.getDefault()).format(Date())
    val selectedStr = SimpleDateFormat("MMM d, yyyy", Locale.getDefault()).format(Date(selectedDate))
    val isToday = todayStr == selectedStr

    val selectedDayBlocks = blocks.filter {
        val blockCal = Calendar.getInstance().apply { timeInMillis = it.startTime }
        val selCal = Calendar.getInstance().apply { timeInMillis = selectedDate }
        blockCal.get(Calendar.YEAR) == selCal.get(Calendar.YEAR) &&
        blockCal.get(Calendar.DAY_OF_YEAR) == selCal.get(Calendar.DAY_OF_YEAR)
    }.sortedBy { it.startTime }

    val daysOfWeek = remember {
        val dates = mutableListOf<Long>()
        val cal = Calendar.getInstance().apply { 
            set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0); set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
        }
        cal.add(Calendar.DAY_OF_YEAR, -3)
        for (i in 0..17) {
            dates.add(cal.timeInMillis)
            cal.add(Calendar.DAY_OF_YEAR, 1)
        }
        dates
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("") },
                actions = {
                    TextButton(
                        onClick = { 
                            selectedDate = Calendar.getInstance().apply { 
                                set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0); set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0) 
                            }.timeInMillis 
                        },
                        enabled = !isToday,
                        colors = ButtonDefaults.textButtonColors(contentColor = if (isToday) DSTextTertiary else DSAccent),
                        modifier = Modifier.background(if (isToday) DSSurfaceLight else DSAccent.copy(alpha = 0.15f), CapsuleShape).padding(horizontal = 8.dp).height(32.dp)
                    ) {
                        Text("Today", fontSize = 12.sp)
                    }
                    Spacer(modifier = Modifier.width(8.dp))
                    IconButton(onClick = onNavigateToEventEntry) {
                        Icon(Icons.Default.AddCircle, contentDescription = "Add", tint = DSAccent, modifier = Modifier.size(24.dp))
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = DSBackground)
            )
        },
        containerColor = DSBackground
    ) { padding ->
        Column(modifier = Modifier.fillMaxSize().padding(padding)) {
            // Day Picker
            Row(modifier = Modifier.horizontalScroll(rememberScrollState()).padding(horizontal = 16.dp, vertical = 8.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                daysOfWeek.forEach { dateInMillis ->
                    val isSel = dateInMillis == selectedDate
                    val isTdy = SimpleDateFormat("MMM d, yyyy", Locale.getDefault()).format(Date(dateInMillis)) == todayStr
                    val dayName = SimpleDateFormat("EEE", Locale.getDefault()).format(Date(dateInMillis))
                    val dayNum = SimpleDateFormat("d", Locale.getDefault()).format(Date(dateInMillis))

                    Surface(
                        onClick = { selectedDate = dateInMillis },
                        color = Color.Transparent
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp), modifier = Modifier.width(44.dp)) {
                            Text(dayName, fontSize = 11.sp, color = if (isSel) Color.White else DSTextTertiary)
                            Box(modifier = Modifier.size(36.dp).background(if (isSel) DSAccent else Color.Transparent, CircleShape), contentAlignment = Alignment.Center) {
                                Text(dayNum, fontSize = 16.sp, fontWeight = FontWeight.Bold, color = if (isSel) Color.White else DSTextPrimary)
                            }
                            if (isTdy && !isSel) {
                                Box(modifier = Modifier.size(4.dp).background(DSAccent, CircleShape))
                            } else {
                                Spacer(modifier = Modifier.size(4.dp))
                            }
                        }
                    }
                }
            }

            // Time Grid
            Box(modifier = Modifier.weight(1f).verticalScroll(rememberScrollState())) {
                Column(modifier = Modifier.padding(horizontal = 16.dp)) {
                    for (hour in 6..23) {
                        val ampm = if (hour < 12) "AM" else "PM"
                        val h = if (hour % 12 == 0) 12 else hour % 12
                        
                        Row(modifier = Modifier.height(60.dp), crossAxisAlignment = Alignment.Top) {
                            Text("$h $ampm", fontSize = 10.sp, color = DSTextTertiary, modifier = Modifier.width(40.dp))
                            Spacer(modifier = Modifier.width(8.dp))
                            HorizontalDivider(color = DSCardBorder, modifier = Modifier.padding(top = 6.dp))
                        }
                    }
                    Spacer(modifier = Modifier.height(120.dp))
                }

                // Blocks overlay
                selectedDayBlocks.forEach { block ->
                    val cal = Calendar.getInstance().apply { timeInMillis = block.startTime }
                    val hour = cal.get(Calendar.HOUR_OF_DAY)
                    val minute = cal.get(Calendar.MINUTE)
                    
                    val startOffset = maxOf(0, (hour - 6) * 60 + minute).dp
                    val duration = block.durationMinutes.dp
                    
                    val hexStr = if (block.colorHex.startsWith("#")) block.colorHex else "#${block.colorHex}"
                    val color = try { Color(android.graphics.Color.parseColor(hexStr)) } catch (e: Exception) { DSAccent }

                    val format = SimpleDateFormat("h:mm a", Locale.getDefault())
                    val timeStr = "${format.format(Date(block.startTime))} - ${format.format(Date(block.endTime))}"

                    Box(
                        modifier = Modifier
                            .padding(start = 72.dp, end = 16.dp)
                            .offset(y = startOffset)
                            .height(maxOf(30.dp, duration))
                            .fillMaxWidth()
                            .background(color.copy(alpha = 0.85f), RoundedCornerShape(8.dp))
                            .padding(8.dp)
                    ) {
                        Box(modifier = Modifier.width(3.dp).fillMaxHeight().background(Color.White.copy(alpha = 0.4f), RoundedCornerShape(2.dp)).align(Alignment.CenterStart))
                        
                        Column(modifier = Modifier.padding(start = 8.dp)) {
                            Text(block.title, fontSize = 12.sp, fontWeight = FontWeight.SemiBold, color = Color.White, maxLines = 1)
                            Text(timeStr, fontSize = 10.sp, color = Color.White.copy(alpha = 0.7f))
                        }
                    }
                }
            }
        }
    }
}
