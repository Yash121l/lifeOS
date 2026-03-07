package com.yashlunawat.lifeos.data.services

object SettingsManager {
    var currencyCode: String = "USD"
    var isCalendarSyncEnabled: Boolean = false
    val availableCurrencies = listOf("USD", "EUR", "GBP", "INR", "JPY")

    val currencySymbol: String
        get() = when (currencyCode) {
            "USD" -> "$"
            "EUR" -> "€"
            "GBP" -> "£"
            "INR" -> "₹"
            "JPY" -> "¥"
            else -> "$"
        }
}
