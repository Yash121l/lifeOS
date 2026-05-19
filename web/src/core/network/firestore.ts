import { Timestamp, type DocumentData } from 'firebase/firestore';
import {
  createNoteItem,
  createProject,
  createTaskItem,
  createTimeBlock,
  createTransactionItem,
  type NoteItem,
  type Project,
  type TaskItem,
  type TimeBlock,
  type TransactionItem,
} from '../models';

function asDate(value: unknown): Date | null {
  if (!value) return null;
  if (value instanceof Date) return value;
  if (value instanceof Timestamp) return value.toDate();
  if (typeof value === 'string' || typeof value === 'number') {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }
  if (
    typeof value === 'object' &&
    value !== null &&
    'seconds' in value &&
    typeof (value as { seconds: unknown }).seconds === 'number'
  ) {
    return new Date((value as { seconds: number }).seconds * 1000);
  }
  return null;
}

export function serializeForFirestore<T extends Record<string, unknown>>(
  data: T,
): T {
  return Object.entries(data).reduce((next, [key, value]) => {
    next[key as keyof T] = value as T[keyof T];
    return next;
  }, {} as T);
}

export function parseTask(id: string, data: DocumentData): TaskItem {
  return createTaskItem({
    ...data,
    id,
    dueDate: asDate(data.dueDate),
    createdAt: asDate(data.createdAt) ?? new Date(),
    updatedAt: asDate(data.updatedAt) ?? new Date(),
    projectId: typeof data.projectId === 'string' ? data.projectId : null,
  });
}

export function parseTimeBlock(id: string, data: DocumentData): TimeBlock {
  return createTimeBlock({
    ...data,
    id,
    startTime: asDate(data.startTime) ?? new Date(),
    endTime: asDate(data.endTime) ?? new Date(),
    createdAt: asDate(data.createdAt) ?? new Date(),
    updatedAt: asDate(data.updatedAt) ?? new Date(),
    linkedTaskId:
      typeof data.linkedTaskId === 'string' ? data.linkedTaskId : null,
  });
}

export function parseNote(id: string, data: DocumentData): NoteItem {
  return createNoteItem({
    ...data,
    id,
    createdAt: asDate(data.createdAt) ?? new Date(),
    updatedAt: asDate(data.updatedAt) ?? new Date(),
  });
}

export function parseTransaction(
  id: string,
  data: DocumentData,
): TransactionItem {
  return createTransactionItem({
    ...data,
    id,
    date: asDate(data.date) ?? new Date(),
    createdAt: asDate(data.createdAt) ?? new Date(),
    updatedAt: asDate(data.updatedAt) ?? new Date(),
  });
}

export function parseProject(id: string, data: DocumentData): Project {
  return createProject({
    ...data,
    id,
    taskIds: Array.isArray(data.taskIds)
      ? data.taskIds.filter((value): value is string => typeof value === 'string')
      : [],
    createdAt: asDate(data.createdAt) ?? new Date(),
    updatedAt: asDate(data.updatedAt) ?? new Date(),
  });
}
