package com.yashlunawat.lifeos.ui.screens.knowledge

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CapsuleShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddCircle
import androidx.compose.material.icons.filled.NoteAlt
import androidx.compose.material.icons.filled.PushPin
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.ViewList
import androidx.compose.material.icons.filled.ViewModule
import com.yashlunawat.lifeos.data.LifeOSViewModel
import com.yashlunawat.lifeos.data.models.NoteItem
import com.yashlunawat.lifeos.ui.components.GlassCard
import com.yashlunawat.lifeos.ui.theme.*
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NotesScreen(viewModel: LifeOSViewModel, onNavigateToEditor: (Long?) -> Unit) {
    val notes by viewModel.notes.collectAsState()
    var searchQuery by remember { mutableStateOf("") }
    var viewModeList by remember { mutableStateOf(true) }
    var selectedTag by remember { mutableStateOf<String?>(null) }

    val filteredNotes = notes.filter {
        (searchQuery.isBlank() || it.title.contains(searchQuery, true) || it.content.contains(searchQuery, true)) &&
        (selectedTag == null || it.tags.contains(selectedTag))
    }.sortedByDescending { if (it.isPinned) 1 else 0 }

    val allTags = notes.flatMap { it.tags }.distinct().sorted()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Knowledge") },
                actions = {
                    IconButton(onClick = { viewModeList = !viewModeList }) {
                        Icon(if (viewModeList) Icons.Default.ViewModule else Icons.Default.ViewList, contentDescription = "View Mode", tint = DSTextSecondary)
                    }
                    IconButton(onClick = { onNavigateToEditor(null) }) {
                        Icon(Icons.Default.AddCircle, contentDescription = "Add Note", tint = DSAccent)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = DSBackground, titleContentColor = DSTextPrimary)
            )
        },
        containerColor = DSBackground
    ) { padding ->
        Column(modifier = Modifier.fillMaxSize().padding(padding)) {
            // Search Bar
            TextField(
                value = searchQuery,
                onValueChange = { searchQuery = it },
                placeholder = { Text("Search notes...", color = DSTextTertiary) },
                leadingIcon = { Icon(Icons.Default.Search, contentDescription = null, tint = DSTextTertiary) },
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = DSSurfaceLight, unfocusedContainerColor = DSSurfaceLight,
                    focusedIndicatorColor = Color.Transparent, unfocusedIndicatorColor = Color.Transparent,
                    focusedTextColor = DSTextPrimary
                ),
                shape = CapsuleShape,
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp)
            )

            // Tags
            if (allTags.isNotEmpty()) {
                androidx.compose.foundation.lazy.LazyRow(
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    item {
                        FilterChip(
                            selected = selectedTag == null,
                            onClick = { selectedTag = null },
                            label = { Text("All") },
                            colors = FilterChipDefaults.filterChipColors(selectedContainerColor = DSAccent, selectedLabelColor = Color.White)
                        )
                    }
                    items(allTags.toList()) { tag ->
                        FilterChip(
                            selected = selectedTag == tag,
                            onClick = { selectedTag = if (selectedTag == tag) null else tag },
                            label = { Text(tag) },
                            colors = FilterChipDefaults.filterChipColors(selectedContainerColor = DSAccent, selectedLabelColor = Color.White)
                        )
                    }
                }
            }

            // Content
            if (filteredNotes.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
                        Icon(Icons.Default.NoteAlt, contentDescription = null, tint = DSTextTertiary, modifier = Modifier.size(48.dp))
                        Text("No notes yet", style = MaterialTheme.typography.headlineMedium, color = DSTextSecondary)
                        Text("Capture your thoughts and ideas.", style = MaterialTheme.typography.bodyMedium, color = DSTextTertiary)
                    }
                }
            } else {
                if (viewModeList) {
                    LazyColumn(contentPadding = PaddingValues(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        items(filteredNotes) { note ->
                            NoteListRow(note) { onNavigateToEditor(note.id) }
                        }
                    }
                } else {
                    LazyVerticalGrid(columns = GridCells.Fixed(2), contentPadding = PaddingValues(16.dp), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        items(filteredNotes) { note ->
                            NoteGridCard(note) { onNavigateToEditor(note.id) }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun NoteListRow(note: NoteItem, onClick: () -> Unit) {
    Surface(onClick = onClick, color = Color.Transparent) {
        GlassCard(padding = 12.dp) {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    if (note.isPinned) {
                        Icon(Icons.Default.PushPin, contentDescription = "Pinned", tint = DSWarning, modifier = Modifier.size(12.dp))
                    }
                    Text(note.title, style = MaterialTheme.typography.headlineMedium, color = DSTextPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)
                }
                if (note.content.isNotBlank()) {
                    Text(note.content, style = MaterialTheme.typography.bodySmall, color = DSTextTertiary, maxLines = 2, overflow = TextOverflow.Ellipsis)
                }
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                    val dateStr = SimpleDateFormat("MMM d", Locale.getDefault()).format(Date(note.updatedAt))
                    Text(dateStr, fontSize = 10.sp, color = DSTextTertiary)
                    note.tags.take(2).forEach { tag ->
                        Text(tag, fontSize = 9.sp, color = DSAccent, modifier = Modifier.background(DSAccent.copy(alpha = 0.1f), CapsuleShape).padding(horizontal = 6.dp, vertical = 2.dp))
                    }
                }
            }
        }
    }
}

@Composable
fun NoteGridCard(note: NoteItem, onClick: () -> Unit) {
    Surface(onClick = onClick, color = Color.Transparent) {
        GlassCard(padding = 12.dp, modifier = Modifier.fillMaxWidth().height(140.dp)) {
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    if (note.isPinned) {
                        Icon(Icons.Default.PushPin, contentDescription = "Pinned", tint = DSWarning, modifier = Modifier.size(12.dp))
                    }
                    Spacer(modifier = Modifier.weight(1f))
                    val dateStr = SimpleDateFormat("MMM d", Locale.getDefault()).format(Date(note.updatedAt))
                    Text(dateStr, fontSize = 9.sp, color = DSTextTertiary)
                }
                Text(note.title, style = MaterialTheme.typography.headlineMedium, color = DSTextPrimary, maxLines = 2, overflow = TextOverflow.Ellipsis)
                if (note.content.isNotBlank()) {
                    Text(note.content, style = MaterialTheme.typography.bodySmall, color = DSTextTertiary, maxLines = 3, overflow = TextOverflow.Ellipsis)
                }
                Spacer(modifier = Modifier.weight(1f))
                if (note.tags.isNotEmpty()) {
                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        note.tags.take(2).forEach { tag ->
                            Text(tag, fontSize = 9.sp, color = DSAccent, modifier = Modifier.background(DSAccent.copy(alpha = 0.1f), CapsuleShape).padding(horizontal = 6.dp, vertical = 2.dp))
                        }
                    }
                }
            }
        }
    }
}
