import {
  addDays,
  endOfWeek,
  format,
  formatDistanceToNowStrict,
  isToday,
  isTomorrow,
  startOfWeek,
} from 'date-fns';

export function formatCurrency(value: number): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    maximumFractionDigits: 2,
  }).format(value);
}

export function formatTaskDueDate(date: Date | null): string {
  if (!date) return 'No deadline';
  if (isToday(date)) return 'Today';
  if (isTomorrow(date)) return 'Tomorrow';
  return format(date, 'MMM d');
}

export function formatSyncTime(date: Date | null): string {
  if (!date) return 'Waiting for first sync';
  return formatDistanceToNowStrict(date, { addSuffix: true });
}

export function formatDateTimeInput(date: Date): string {
  const pad = (value: number) => String(value).padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

export function startOfCurrentWeek(): Date {
  return startOfWeek(new Date(), { weekStartsOn: 1 });
}

export function endOfCurrentWeek(): Date {
  return endOfWeek(new Date(), { weekStartsOn: 1 });
}

export function getWeekDays(reference = new Date()): Date[] {
  const start = startOfWeek(reference, { weekStartsOn: 1 });
  return Array.from({ length: 7 }, (_, index) => addDays(start, index));
}

export function getGreeting(displayName: string): string {
  const hour = new Date().getHours();
  const firstName = displayName.trim().split(' ')[0] || 'there';

  if (hour < 12) return `Good morning, ${firstName}`;
  if (hour < 18) return `Good afternoon, ${firstName}`;
  return `Good evening, ${firstName}`;
}
