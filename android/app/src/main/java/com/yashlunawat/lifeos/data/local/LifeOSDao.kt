package com.yashlunawat.lifeos.data.local

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.yashlunawat.lifeos.data.models.NoteItem
import com.yashlunawat.lifeos.data.models.Project
import com.yashlunawat.lifeos.data.models.TaskItem
import com.yashlunawat.lifeos.data.models.TimeBlock
import com.yashlunawat.lifeos.data.models.TransactionItem
import kotlinx.coroutines.flow.Flow

@Dao
interface LifeOSDao {
    // Tasks
    @Query("SELECT * FROM tasks ORDER BY dueDate ASC")
    fun getAllTasks(): Flow<List<TaskItem>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTask(task: TaskItem)

    @Update
    suspend fun updateTask(task: TaskItem)

    @Delete
    suspend fun deleteTask(task: TaskItem)

    // Projects
    @Query("SELECT * FROM projects")
    fun getAllProjects(): Flow<List<Project>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertProject(project: Project)

    @Delete
    suspend fun deleteProject(project: Project)

    // Transactions
    @Query("SELECT * FROM transactions ORDER BY date DESC")
    fun getAllTransactions(): Flow<List<TransactionItem>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTransaction(transaction: TransactionItem)

    @Update
    suspend fun updateTransaction(transaction: TransactionItem)

    @Delete
    suspend fun deleteTransaction(transaction: TransactionItem)

    // TimeBlocks
    @Query("SELECT * FROM time_blocks ORDER BY startTime ASC")
    fun getAllTimeBlocks(): Flow<List<TimeBlock>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTimeBlock(timeBlock: TimeBlock)

    @Update
    suspend fun updateTimeBlock(timeBlock: TimeBlock)

    @Delete
    suspend fun deleteTimeBlock(timeBlock: TimeBlock)

    // Notes
    @Query("SELECT * FROM notes ORDER BY isPinned DESC, updatedAt DESC")
    fun getAllNotes(): Flow<List<NoteItem>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertNote(note: NoteItem)

    @Update
    suspend fun updateNote(note: NoteItem)

    @Delete
    suspend fun deleteNote(note: NoteItem)
}
