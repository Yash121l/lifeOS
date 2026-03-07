package com.yashlunawat.lifeos.ui.screens.knowledge

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PushPin
import com.yashlunawat.lifeos.data.LifeOSViewModel
import com.yashlunawat.lifeos.data.models.NoteItem
import com.yashlunawat.lifeos.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NoteEditorScreen(noteId: Long?, viewModel: LifeOSViewModel, onNavigateBack: () -> Unit) {
    val notes by viewModel.notes.collectAsState()
    val initialNote = notes.find { it.id == noteId } ?: NoteItem(title = "", content = "")
    var note by remember { mutableStateOf(initialNote) }
    var tagInput by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(if (noteId == null) "New Note" else "Edit Note") },
                navigationIcon = {
                    TextButton(onClick = onNavigateBack) {
                        Text("Cancel", color = DSTextSecondary)
                    }
                },
                actions = {
                    TextButton(
                        onClick = {
                            val updated = note.copy(updatedAt = System.currentTimeMillis())
                            if (noteId == null) viewModel.addNote(updated) else viewModel.updateNote(updated)
                            onNavigateBack()
                        },
                        enabled = note.title.isNotBlank()
                    ) {
                        Text("Save", color = if (note.title.isNotBlank()) DSAccent else DSTextTertiary)
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
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Title
            TextField(
                value = note.title,
                onValueChange = { note = note.copy(title = it) },
                placeholder = { Text("Title", color = DSTextSecondary) },
                textStyle = MaterialTheme.typography.displaySmall,
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent, unfocusedContainerColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent, unfocusedIndicatorColor = Color.Transparent,
                    focusedTextColor = DSTextPrimary
                ),
                modifier = Modifier.fillMaxWidth()
            )

            HorizontalDivider(color = DSCardBorder)

            // Tags
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Tags", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                @OptIn(ExperimentalLayoutApi::class)
                FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    note.tags.forEach { tag ->
                        AssistChip(
                            onClick = { 
                                val newTags = note.tags.toMutableList().apply { remove(tag) }
                                note = note.copy(tags = newTags) 
                            },
                            label = { Text(tag) },
                            colors = AssistChipDefaults.assistChipColors(labelColor = DSAccent, containerColor = DSAccent.copy(alpha = 0.15f))
                        )
                    }
                    
                    TextField(
                        value = tagInput,
                        onValueChange = { 
                            if (it.endsWith(" ") || it.endsWith("\n")) {
                                val trimmed = it.trim()
                                if (trimmed.isNotBlank() && !note.tags.contains(trimmed)) {
                                    val newTags = note.tags.toMutableList().apply { add(trimmed) }
                                    note = note.copy(tags = newTags)
                                }
                                tagInput = ""
                            } else {
                                tagInput = it
                            }
                        },
                        placeholder = { Text("Add tag (space)", color = DSTextTertiary) },
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = Color.Transparent, unfocusedContainerColor = Color.Transparent,
                            focusedIndicatorColor = Color.Transparent, unfocusedIndicatorColor = Color.Transparent,
                            focusedTextColor = DSTextPrimary
                        ),
                        modifier = Modifier.width(150.dp)
                    )
                }
            }

            HorizontalDivider(color = DSCardBorder)

            // Pin toggle
            Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.PushPin, contentDescription = null, tint = if (note.isPinned) DSWarning else DSTextTertiary)
                Spacer(modifier = Modifier.width(12.dp))
                Text("Pin note", style = MaterialTheme.typography.bodyLarge, color = DSTextPrimary)
                Spacer(modifier = Modifier.weight(1f))
                Switch(
                    checked = note.isPinned,
                    onCheckedChange = { note = note.copy(isPinned = it) },
                    colors = SwitchDefaults.colors(checkedTrackColor = DSWarning)
                )
            }

            HorizontalDivider(color = DSCardBorder)

            // Content
            Column(modifier = Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Content", style = MaterialTheme.typography.labelSmall, color = DSTextTertiary)
                TextField(
                    value = note.content,
                    onValueChange = { note = note.copy(content = it) },
                    placeholder = { Text("Start typing...", color = DSTextSecondary) },
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = Color.Transparent, unfocusedContainerColor = Color.Transparent,
                        focusedIndicatorColor = Color.Transparent, unfocusedIndicatorColor = Color.Transparent,
                        focusedTextColor = DSTextPrimary
                    ),
                    modifier = Modifier.fillMaxWidth().heightIn(min = 300.dp)
                )
            }
        }
    }
}
