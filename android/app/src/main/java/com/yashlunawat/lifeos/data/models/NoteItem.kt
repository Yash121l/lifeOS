package com.yashlunawat.lifeos.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "notes")
data class NoteItem(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val title: String,
    val content: String,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis(),
    var tagsRaw: String = "",
    val isPinned: Boolean = false
) {
    var tags: List<String>
        get() = tagsRaw.split(",").map { it.trim() }.filter { it.isNotEmpty() }
        set(value) {
            tagsRaw = value.joinToString(",")
        }

    val preview: String
        get() = content.take(120)
}
