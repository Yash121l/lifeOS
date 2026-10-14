/* eslint-disable react-refresh/only-export-components */
import {
  collection,
  deleteDoc,
  doc,
  onSnapshot,
  orderBy,
  query,
  setDoc,
} from 'firebase/firestore';
import {
  createContext,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from 'react';
import { db } from '../../core/network/firebase';
import {
  parseNote,
  parseProject,
  parseTask,
  parseTimeBlock,
  parseTransaction,
  serializeForFirestore,
} from '../../core/network/firestore';
import type {
  NoteItem,
  Project,
  TaskItem,
  TimeBlock,
  TransactionItem,
} from '../../core/models/index';
import { useAuth } from '../auth/AuthProvider';
import { track } from '../../core/services/analytics';

type CollectionName =
  | 'tasks'
  | 'timeBlocks'
  | 'notes'
  | 'transactions'
  | 'projects';

interface SyncState {
  isOnline: boolean;
  isFromCache: boolean;
  hasPendingWrites: boolean;
  lastSyncedAt: Date | null;
}

interface DataContextValue {
  tasks: TaskItem[];
  timeBlocks: TimeBlock[];
  notes: NoteItem[];
  transactions: TransactionItem[];
  projects: Project[];
  isLoading: boolean;
  syncState: SyncState;
  saveTask: (task: TaskItem) => Promise<void>;
  deleteTask: (taskId: string) => Promise<void>;
  saveTimeBlock: (block: TimeBlock) => Promise<void>;
  deleteTimeBlock: (blockId: string) => Promise<void>;
  saveNote: (note: NoteItem) => Promise<void>;
  deleteNote: (noteId: string) => Promise<void>;
  saveTransaction: (transaction: TransactionItem) => Promise<void>;
  deleteTransaction: (transactionId: string) => Promise<void>;
  saveProject: (project: Project) => Promise<void>;
  deleteProject: (projectId: string) => Promise<void>;
}

const DataContext = createContext<DataContextValue | null>(null);

export function DataProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const [tasks, setTasks] = useState<TaskItem[]>([]);
  const [timeBlocks, setTimeBlocks] = useState<TimeBlock[]>([]);
  const [notes, setNotes] = useState<NoteItem[]>([]);
  const [transactions, setTransactions] = useState<TransactionItem[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [loadedUserId, setLoadedUserId] = useState<string | null>(null);
  const [syncState, setSyncState] = useState<SyncState>({
    isOnline: typeof navigator === 'undefined' ? true : navigator.onLine,
    isFromCache: false,
    hasPendingWrites: false,
    lastSyncedAt: null,
  });

  useEffect(() => {
    const updateStatus = () => {
      setSyncState((current) => ({
        ...current,
        isOnline: navigator.onLine,
      }));
    };

    updateStatus();
    window.addEventListener('online', updateStatus);
    window.addEventListener('offline', updateStatus);

    return () => {
      window.removeEventListener('online', updateStatus);
      window.removeEventListener('offline', updateStatus);
    };
  }, []);

  useEffect(() => {
    if (!user) {
      return;
    }
    const currentUserId = user.uid;

    const readyCollections = new Set<CollectionName>();
    const metadataState: Record<
      CollectionName,
      { fromCache: boolean; hasPendingWrites: boolean }
    > = {
      tasks: { fromCache: false, hasPendingWrites: false },
      timeBlocks: { fromCache: false, hasPendingWrites: false },
      notes: { fromCache: false, hasPendingWrites: false },
      transactions: { fromCache: false, hasPendingWrites: false },
      projects: { fromCache: false, hasPendingWrites: false },
    };

    function updateCollectionMeta(
      collectionName: CollectionName,
      fromCache: boolean,
      hasPendingWrites: boolean,
    ) {
      metadataState[collectionName] = { fromCache, hasPendingWrites };
      readyCollections.add(collectionName);

      const values = Object.values(metadataState);

      setSyncState((current) => ({
        ...current,
        isFromCache: values.some((entry) => entry.fromCache),
        hasPendingWrites: values.some((entry) => entry.hasPendingWrites),
        lastSyncedAt: navigator.onLine ? new Date() : current.lastSyncedAt,
      }));

      if (readyCollections.size === 5) {
        setLoadedUserId(currentUserId);
      }
    }

    const unsubscribeTasks = onSnapshot(
      query(
        collection(db, 'users', currentUserId, 'tasks'),
        orderBy('createdAt', 'desc'),
      ),
      { includeMetadataChanges: true },
      (snapshot) => {
        setTasks(snapshot.docs.map((item) => parseTask(item.id, item.data())));
        updateCollectionMeta(
          'tasks',
          snapshot.metadata.fromCache,
          snapshot.metadata.hasPendingWrites,
        );
      },
    );

    const unsubscribeTimeBlocks = onSnapshot(
      query(
        collection(db, 'users', currentUserId, 'timeBlocks'),
        orderBy('startTime', 'asc'),
      ),
      { includeMetadataChanges: true },
      (snapshot) => {
        setTimeBlocks(
          snapshot.docs.map((item) => parseTimeBlock(item.id, item.data())),
        );
        updateCollectionMeta(
          'timeBlocks',
          snapshot.metadata.fromCache,
          snapshot.metadata.hasPendingWrites,
        );
      },
    );

    const unsubscribeNotes = onSnapshot(
      query(
        collection(db, 'users', currentUserId, 'notes'),
        orderBy('updatedAt', 'desc'),
      ),
      { includeMetadataChanges: true },
      (snapshot) => {
        setNotes(snapshot.docs.map((item) => parseNote(item.id, item.data())));
        updateCollectionMeta(
          'notes',
          snapshot.metadata.fromCache,
          snapshot.metadata.hasPendingWrites,
        );
      },
    );

    const unsubscribeTransactions = onSnapshot(
      query(
        collection(db, 'users', currentUserId, 'transactions'),
        orderBy('date', 'desc'),
      ),
      { includeMetadataChanges: true },
      (snapshot) => {
        setTransactions(
          snapshot.docs.map((item) => parseTransaction(item.id, item.data())),
        );
        updateCollectionMeta(
          'transactions',
          snapshot.metadata.fromCache,
          snapshot.metadata.hasPendingWrites,
        );
      },
    );

    const unsubscribeProjects = onSnapshot(
      query(
        collection(db, 'users', currentUserId, 'projects'),
        orderBy('createdAt', 'desc'),
      ),
      { includeMetadataChanges: true },
      (snapshot) => {
        setProjects(snapshot.docs.map((item) => parseProject(item.id, item.data())));
        updateCollectionMeta(
          'projects',
          snapshot.metadata.fromCache,
          snapshot.metadata.hasPendingWrites,
        );
      },
    );

    return () => {
      unsubscribeTasks();
      unsubscribeTimeBlocks();
      unsubscribeNotes();
      unsubscribeTransactions();
      unsubscribeProjects();
    };
  }, [user]);

  async function saveDocument<T extends { id: string; userId: string; updatedAt: Date }>(
    collectionName: CollectionName,
    value: T,
  ) {
    if (!user) return;

    const nextValue = {
      ...value,
      userId: user.uid,
      updatedAt: new Date(),
    };

    setSyncState((current) => ({
      ...current,
      hasPendingWrites: true,
    }));

    await setDoc(
      doc(db, 'users', user.uid, collectionName, nextValue.id),
      serializeForFirestore(nextValue),
    );
  }

  async function deleteDocument(
    collectionName: CollectionName,
    documentId: string,
  ) {
    if (!user) return;
    await deleteDoc(doc(db, 'users', user.uid, collectionName, documentId));
  }

  const effectiveIsLoading = Boolean(user && loadedUserId !== user.uid);

  const value: DataContextValue = {
    tasks: user ? tasks : [],
    timeBlocks: user ? timeBlocks : [],
    notes: user ? notes : [],
    transactions: user ? transactions : [],
    projects: user ? projects : [],
    isLoading: effectiveIsLoading,
    syncState,
    saveTask: async (task) => {
      const previous = tasks.find((t) => t.id === task.id);
      await saveDocument('tasks', task);
      if (!previous) {
        track('task_created', {
          priority: task.priority,
          has_due_date: task.dueDate !== null,
          has_project: task.projectId !== null,
        });
      } else if (task.isCompleted && !previous.isCompleted) {
        track('task_completed', { priority: task.priority });
      }
    },
    deleteTask: async (taskId) => {
      await deleteDocument('tasks', taskId);
    },
    saveTimeBlock: async (block) => {
      const isNew = !timeBlocks.some((b) => b.id === block.id);
      await saveDocument('timeBlocks', block);
      if (isNew) track('time_block_created');
    },
    deleteTimeBlock: async (blockId) => {
      await deleteDocument('timeBlocks', blockId);
    },
    saveNote: async (note) => {
      const isNew = !notes.some((n) => n.id === note.id);
      await saveDocument('notes', note);
      if (isNew) track('note_created');
    },
    deleteNote: async (noteId) => {
      await deleteDocument('notes', noteId);
    },
    saveTransaction: async (transaction) => {
      const isNew = !transactions.some((t) => t.id === transaction.id);
      await saveDocument('transactions', transaction);
      // Category and kind only; amounts and titles stay out.
      if (isNew) {
        track('transaction_added', {
          is_expense: transaction.isExpense,
          category: transaction.category,
          is_recurring: transaction.isRecurring,
        });
      }
    },
    deleteTransaction: async (transactionId) => {
      await deleteDocument('transactions', transactionId);
    },
    saveProject: async (project) => {
      const isNew = !projects.some((p) => p.id === project.id);
      await saveDocument('projects', project);
      if (isNew) track('project_created');
    },
    deleteProject: async (projectId) => {
      await deleteDocument('projects', projectId);
    },
  };

  return <DataContext.Provider value={value}>{children}</DataContext.Provider>;
}

export function useData() {
  const context = useContext(DataContext);

  if (!context) {
    throw new Error('useData must be used inside DataProvider');
  }

  return context;
}
