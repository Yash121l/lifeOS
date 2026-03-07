package com.yashlunawat.lifeos.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "transactions")
data class TransactionItem(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val title: String,
    val amount: Double,
    val date: Long = System.currentTimeMillis(),
    val category: String = "Other",
    val isExpense: Boolean = true,
    val isRecurring: Boolean = false,
    val iconName: String = "creditcard"
) {
    val categoryEmoji: String
        get() = when (category.lowercase()) {
            "food", "dining" -> "🍕"
            "transport", "travel" -> "🚗"
            "shopping" -> "🛍️"
            "entertainment" -> "🎮"
            "bills", "utilities" -> "💡"
            "health" -> "💊"
            "education" -> "📚"
            "subscription" -> "🔄"
            "income", "salary" -> "💰"
            else -> "💳"
        }
}
