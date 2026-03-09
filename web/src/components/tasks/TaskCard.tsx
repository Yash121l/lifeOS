import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import type { Task } from './KanbanBoard';
import { GripVertical } from 'lucide-react';
import clsx from 'clsx';

export function TaskCard({ task, isDragOverlay }: { task: Task; isDragOverlay?: boolean }) {
  const { setNodeRef, attributes, listeners, transform, transition, isDragging } = useSortable({
    id: task.id,
    data: { type: 'Task', task },
  });

  const style = {
    transition,
    transform: CSS.Transform.toString(transform),
  };

  if (isDragging) {
    return (
      <div 
        ref={setNodeRef} style={style}
        className="glass-card border-2 border-accent-primary opacity-30 h-[100px] rounded-lg"
      />
    );
  }

  const priorityColor = {
    high: 'var(--error)',
    medium: 'var(--warning)',
    low: 'var(--success)'
  };

  return (
    <div
      ref={setNodeRef} style={style}
      className={clsx(
        "glass-card p-4 rounded-lg cursor-grab hover:shadow-lg transition-all group",
        isDragOverlay && "rotate-2 shadow-xl scale-105"
      )}
      {...attributes} {...listeners}
    >
      <div className="flex gap-2">
        <div className="text-tertiary opacity-0 group-hover:opacity-100 transition-opacity mt-1 cursor-grab">
           <GripVertical size={16} />
        </div>
        <div className="flex-1">
          <p className="text-sm font-medium text-primary mb-3 leading-snug">{task.content}</p>
          
          <div className="flex items-center justify-between mt-auto">
            <div className="flex gap-2">
              {task.tags.map(tag => (
                <span key={tag} className="text-[10px] px-2 py-1 rounded bg-[rgba(255,255,255,0.05)] text-secondary border border-[var(--border-subtle)]">
                  {tag}
                </span>
              ))}
            </div>
            
            <div className="flex items-center gap-1">
               <div className="w-2 h-2 rounded-full" style={{ backgroundColor: priorityColor[task.priority] }} />
               <span className="text-xs text-secondary capitalize">{task.priority}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
