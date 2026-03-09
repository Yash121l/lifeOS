import { useState } from 'react';
import { DndContext, DragOverlay, closestCorners, KeyboardSensor, PointerSensor, useSensor, useSensors } from '@dnd-kit/core';
import type { DragStartEvent, DragOverEvent } from '@dnd-kit/core';
import { arrayMove, sortableKeyboardCoordinates } from '@dnd-kit/sortable';
import { KanbanColumn } from './KanbanColumn';
import { TaskCard } from './TaskCard';

export type Id = string | number;

export type Task = {
  id: Id;
  columnId: Id;
  content: string;
  priority: 'low' | 'medium' | 'high';
  tags: string[];
};

export type Column = {
  id: Id;
  title: string;
};

const defaultCols: Column[] = [
  { id: 'todo', title: 'To Do' },
  { id: 'in-progress', title: 'In Progress' },
  { id: 'blocked', title: 'Blocked' },
  { id: 'done', title: 'Done' },
];

const defaultTasks: Task[] = [
  { id: '1', columnId: 'todo', content: 'Finalize Web Assets', priority: 'high', tags: ['Design'] },
  { id: '2', columnId: 'todo', content: 'Configure Payment Gateway', priority: 'medium', tags: ['Backend'] },
  { id: '3', columnId: 'in-progress', content: 'Implement Board Drag Drop', priority: 'high', tags: ['Frontend'] },
  { id: '4', columnId: 'blocked', content: 'Wait for API Keys', priority: 'low', tags: ['DevOps'] },
  { id: '5', columnId: 'done', content: 'Project Scaffolding', priority: 'medium', tags: ['Setup'] },
];

export function KanbanBoard() {
  const [columns] = useState<Column[]>(defaultCols);
  const [tasks, setTasks] = useState<Task[]>(defaultTasks);
  const [activeTask, setActiveTask] = useState<Task | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 5 } }),
    useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates })
  );

  function onDragStart(event: DragStartEvent) {
    if (event.active.data.current?.type === 'Task') {
      setActiveTask(event.active.data.current.task);
    }
  }

  function onDragOver(event: DragOverEvent) {
    const { active, over } = event;
    if (!over) return;

    const activeId = active.id;
    const overId = over.id;

    if (activeId === overId) return;

    const isActiveTask = active.data.current?.type === 'Task';
    const isOverTask = over.data.current?.type === 'Task';
    const isOverColumn = over.data.current?.type === 'Column';

    if (!isActiveTask) return;

    // Dropping a Task over another Task
    if (isActiveTask && isOverTask) {
      setTasks((tasks) => {
        const activeIndex = tasks.findIndex((t) => t.id === activeId);
        const overIndex = tasks.findIndex((t) => t.id === overId);

        if (tasks[activeIndex].columnId !== tasks[overIndex].columnId) {
          const newTasks = [...tasks];
          newTasks[activeIndex].columnId = tasks[overIndex].columnId;
          return arrayMove(newTasks, activeIndex, overIndex);
        }

        return arrayMove(tasks, activeIndex, overIndex);
      });
    }

    // Dropping a Task over an empty Column
    if (isActiveTask && isOverColumn) {
      setTasks((tasks) => {
        const activeIndex = tasks.findIndex((t) => t.id === activeId);
        const newTasks = [...tasks];
        newTasks[activeIndex].columnId = overId;
        return arrayMove(newTasks, activeIndex, activeIndex); // Triggers re-render
      });
    }
  }

  function onDragEnd() {
    setActiveTask(null);
  }

  return (
    <div className="flex gap-6 h-full overflow-x-auto p-2 no-scrollbar">
      <DndContext sensors={sensors} collisionDetection={closestCorners} onDragStart={onDragStart} onDragOver={onDragOver} onDragEnd={onDragEnd}>
        {columns.map((col) => (
          <KanbanColumn key={col.id} column={col} tasks={tasks.filter(t => t.columnId === col.id)} />
        ))}

        <DragOverlay>
          {activeTask ? <TaskCard task={activeTask} isDragOverlay /> : null}
        </DragOverlay>
      </DndContext>
    </div>
  );
}
