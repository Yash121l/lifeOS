package com.yashlunawat.lifeos.data.services

import com.yashlunawat.lifeos.data.models.TaskItem
import java.util.Calendar

object NLPTaskParser {
    fun parse(input: String): TaskItem {
        var priority = 1
        if (input.contains("high", ignoreCase = true)) priority = 2
        if (input.contains("low", ignoreCase = true)) priority = 0
        
        var date: Long? = null
        val calendar = Calendar.getInstance()
        if (input.contains("tomorrow", ignoreCase = true)) {
            calendar.add(Calendar.DAY_OF_YEAR, 1)
            date = calendar.timeInMillis
        } else if (input.contains("today", ignoreCase = true)) {
            date = calendar.timeInMillis
        }
        
        return TaskItem(
            title = input.replace("high priority", "", ignoreCase = true)
                         .replace("low priority", "", ignoreCase = true)
                         .replace("tomorrow", "", ignoreCase = true)
                         .replace("today", "", ignoreCase = true)
                         .trim(),
            priority = priority,
            dueDate = date
        )
    }
}
