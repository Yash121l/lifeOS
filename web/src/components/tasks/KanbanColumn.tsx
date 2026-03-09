import { SortableContext, useSortable } from '@dnd-kit/sortable';
import type { Column, Task } from './KanbanBoard';
import { TaskCard } from './TaskCard';
import { useMemo } from 'react';

interface Props {
  column: Column;
  tasks: Task[];
}

export function KanbanColumn({ column, tasks }: Props) {
  const taskIds = useMemo(() => tasks.map(t => t.id), [tasks]);

  const { setNodeRef } = useSortable({
    id: column.id,
    data: { type: 'Column', column },
  });

  return (
    <div
      ref={setNodeRef}
      className="bg-[rgba(20,20,20,0.5)] border border-[var(--border-strong)] rounded-xl w-80 h-full max-h-full flex flex-col backdrop-blur-md"
    >
      {/* Column header */}
      <div className="p-4 border-b border-[var(--border-subtle)] flex items-center justify-between">
        <h3 className="font-semibold text-primary">{column.title}</h3>
        <div className="bg-secondary rounded-full w-6 h-6 flex items-center justify-center text-xs text-tertiary">
          {tasks.length}
        </div>
      </div>

      {/* Task List container */}
      <div className="p-3 flex-1 overflow-y-auto flex flex-col gap-3 no-scrollbar h-[calc(100vh-250px)]">
        <SortableContext items={taskIds}>
          {tasks.map(task => (
            <TaskCard key={task.id} task={task} />
          ))}
        </SortableContext>
      </div>
    </div>
  );
}
