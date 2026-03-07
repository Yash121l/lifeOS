package com.yashlunawat.lifeos.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.yashlunawat.lifeos.data.models.NoteItem
import com.yashlunawat.lifeos.data.models.Project
import com.yashlunawat.lifeos.data.models.TaskItem
import com.yashlunawat.lifeos.data.models.TimeBlock
import com.yashlunawat.lifeos.data.models.TransactionItem

@Database(
    entities = [
        NoteItem::class,
        Project::class,
        TaskItem::class,
        TimeBlock::class,
        TransactionItem::class
    ],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun lifeOSDao(): LifeOSDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "lifeos_database"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}
