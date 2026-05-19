export type TaskPriority = 0 | 1 | 2;
export type TaskUrgency = 0 | 1;
export type EnergyLevel = 1 | 2 | 3;

export interface TaskItem {
  id: string;
  userId: string;
  title: string;
  priority: TaskPriority;
  dueDate: Date | null;
  isCompleted: boolean;
  energyLevel: EnergyLevel;
  timeEstimateMinutes: number;
  notes: string;
  urgency: TaskUrgency;
  projectId: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface TimeBlock {
  id: string;
  userId: string;
  title: string;
  startTime: Date;
  endTime: Date;
  colorHex: string;
  isCompleted: boolean;
  blockType: string;
  linkedTaskId: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface NoteItem {
  id: string;
  userId: string;
  title: string;
  content: string;
  createdAt: Date;
  updatedAt: Date;
  tagsRaw: string;
  isPinned: boolean;
}

export interface TransactionItem {
  id: string;
  userId: string;
  title: string;
  amount: number;
  date: Date;
  category: string;
  isExpense: boolean;
  isRecurring: boolean;
  iconName: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Project {
  id: string;
  userId: string;
  name: string;
  colorHex: string;
  taskIds: string[];
  createdAt: Date;
  updatedAt: Date;
}

export function createTaskItem(overrides: Partial<TaskItem> = {}): TaskItem {
  const now = new Date();

  return {
    id: crypto.randomUUID(),
    userId: '',
    title: '',
    priority: 1,
    dueDate: null,
    isCompleted: false,
    energyLevel: 2,
    timeEstimateMinutes: 30,
    notes: '',
    urgency: 0,
    projectId: null,
    createdAt: now,
    updatedAt: now,
    ...overrides,
  };
}

export function createTimeBlock(
  overrides: Partial<TimeBlock> = {},
): TimeBlock {
  const start = overrides.startTime ?? new Date();
  const end = overrides.endTime ?? new Date(start.getTime() + 60 * 60 * 1000);
  const now = new Date();

  return {
    id: crypto.randomUUID(),
    userId: '',
    title: '',
    startTime: start,
    endTime: end,
    colorHex: '1D4ED8',
    isCompleted: false,
    blockType: 'deepWork',
    linkedTaskId: null,
    createdAt: now,
    updatedAt: now,
    ...overrides,
  };
}

export function createNoteItem(overrides: Partial<NoteItem> = {}): NoteItem {
  const now = new Date();

  return {
    id: crypto.randomUUID(),
    userId: '',
    title: 'Untitled note',
    content: '<p>Start writing...</p>',
    createdAt: now,
    updatedAt: now,
    tagsRaw: '',
    isPinned: false,
    ...overrides,
  };
}

export function createTransactionItem(
  overrides: Partial<TransactionItem> = {},
): TransactionItem {
  const now = new Date();

  return {
    id: crypto.randomUUID(),
    userId: '',
    title: '',
    amount: 0,
    date: now,
    category: 'General',
    isExpense: true,
    isRecurring: false,
    iconName: 'wallet',
    createdAt: now,
    updatedAt: now,
    ...overrides,
  };
}

export function createProject(overrides: Partial<Project> = {}): Project {
  const now = new Date();

  return {
    id: crypto.randomUUID(),
    userId: '',
    name: '',
    colorHex: '1D4ED8',
    taskIds: [],
    createdAt: now,
    updatedAt: now,
    ...overrides,
  };
}
