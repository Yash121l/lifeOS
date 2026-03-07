package com.yashlunawat.lifeos.data

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.yashlunawat.lifeos.data.local.AppDatabase
import com.yashlunawat.lifeos.data.models.NoteItem
import com.yashlunawat.lifeos.data.models.Project
import com.yashlunawat.lifeos.data.models.TaskItem
import com.yashlunawat.lifeos.data.models.TimeBlock
import com.yashlunawat.lifeos.data.models.TransactionItem
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class LifeOSViewModel(application: Application) : AndroidViewModel(application) {
    private val dao = AppDatabase.getDatabase(application).lifeOSDao()

    val tasks: StateFlow<List<TaskItem>> = dao.getAllTasks()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val projects: StateFlow<List<Project>> = dao.getAllProjects()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val transactions: StateFlow<List<TransactionItem>> = dao.getAllTransactions()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val timeBlocks: StateFlow<List<TimeBlock>> = dao.getAllTimeBlocks()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val notes: StateFlow<List<NoteItem>> = dao.getAllNotes()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    // Actions
    fun addTask(task: TaskItem) = viewModelScope.launch { dao.insertTask(task) }
    fun updateTask(task: TaskItem) = viewModelScope.launch { dao.updateTask(task) }
    fun deleteTask(task: TaskItem) = viewModelScope.launch { dao.deleteTask(task) }

    fun addProject(project: Project) = viewModelScope.launch { dao.insertProject(project) }
    fun deleteProject(project: Project) = viewModelScope.launch { dao.deleteProject(project) }

    fun addTransaction(tx: TransactionItem) = viewModelScope.launch { dao.insertTransaction(tx) }
    fun updateTransaction(tx: TransactionItem) = viewModelScope.launch { dao.updateTransaction(tx) }
    fun deleteTransaction(tx: TransactionItem) = viewModelScope.launch { dao.deleteTransaction(tx) }

    fun addTimeBlock(tb: TimeBlock) = viewModelScope.launch { dao.insertTimeBlock(tb) }
    fun updateTimeBlock(tb: TimeBlock) = viewModelScope.launch { dao.updateTimeBlock(tb) }
    fun deleteTimeBlock(tb: TimeBlock) = viewModelScope.launch { dao.deleteTimeBlock(tb) }

    fun addNote(note: NoteItem) = viewModelScope.launch { dao.insertNote(note) }
    fun updateNote(note: NoteItem) = viewModelScope.launch { dao.updateNote(note) }
    fun deleteNote(note: NoteItem) = viewModelScope.launch { dao.deleteNote(note) }
}
