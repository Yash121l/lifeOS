import { Circle, AlertCircle, CheckCircle2, Clock, CalendarDays } from 'lucide-react';
import clsx from 'clsx';

const mockListTasks = [
  { id: '1', title: 'Complete Web UI Scaffold', priority: 'high', status: 'done', dueDate: 'Today', project: 'LifeOS', tags: ['Frontend'] },
  { id: '2', title: 'Connect Firebase Backend', priority: 'high', status: 'in-progress', dueDate: 'Tomorrow', project: 'LifeOS', tags: ['Backend'] },
  { id: '3', title: 'Draft Marketing Copy', priority: 'medium', status: 'todo', dueDate: 'Friday', project: 'Personal', tags: ['Writing'] },
  { id: '4', title: 'Update dependencies vault', priority: 'low', status: 'blocked', dueDate: 'Next Week', project: 'Maintenance', tags: ['Ops'] },
  { id: '5', title: 'Client Sync Prep', priority: 'medium', status: 'todo', dueDate: 'Today', project: 'Freelance', tags: ['Meetings'] },
];

export function TaskListView() {
  const getStatusIcon = (status: string) => {
    switch(status) {
      case 'done': return <CheckCircle2 size={18} className="text-success" />;
      case 'in-progress': return <Clock size={18} className="text-warning" />;
      case 'blocked': return <AlertCircle size={18} className="text-error" />;
      default: return <Circle size={18} className="text-tertiary" />;
    }
  };

  const getPriorityColor = (priority: string) => {
    switch(priority) {
      case 'high': return 'bg-error';
      case 'medium': return 'bg-warning';
      case 'low': return 'bg-success';
      default: return 'bg-tertiary';
    }
  };

  return (
    <div className="w-full h-full overflow-y-auto pr-4 no-scrollbar">
      <div className="glass-card overflow-hidden">
        {/* Table Header */}
        <div className="grid grid-cols-12 gap-4 p-4 border-b border-[var(--border-strong)] bg-[rgba(0,0,0,0.2)] text-xs font-semibold uppercase text-secondary tracking-wider">
          <div className="col-span-6 flex items-center gap-2">Task Name</div>
          <div className="col-span-2">Project</div>
          <div className="col-span-2">Due Date</div>
          <div className="col-span-2 text-right">Priority</div>
        </div>

        {/* List Body */}
        <div className="flex flex-col">
          {mockListTasks.map((task, index) => (
            <div 
              key={task.id} 
              className={clsx(
                "grid grid-cols-12 gap-4 p-4 items-center group transition-colors hover:bg-[rgba(255,255,255,0.03)] cursor-pointer",
                index !== mockListTasks.length - 1 && "border-b border-[var(--border-subtle)]"
              )}
            >
              {/* Title & Status */}
              <div className="col-span-6 flex items-center gap-3">
                <button className="opacity-70 hover:opacity-100 transition-opacity focus:outline-none">
                  {getStatusIcon(task.status)}
                </button>
                <div className="flex flex-col">
                  <span className={clsx("font-medium text-sm", task.status === 'done' ? 'text-secondary line-through' : 'text-primary')}>
                    {task.title}
                  </span>
                  <div className="flex gap-2 mt-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    {task.tags.map(tag => (
                      <span key={tag} className="text-[10px] px-1.5 py-0.5 rounded bg-[rgba(255,255,255,0.05)] text-tertiary border border-[var(--border-subtle)]">
                        {tag}
                      </span>
                    ))}
                  </div>
                </div>
              </div>

              {/* Project */}
              <div className="col-span-2">
                <span className="text-xs px-2 py-1 rounded bg-[var(--bg-tertiary)] text-secondary border border-[var(--border-subtle)]">
                  {task.project}
                </span>
              </div>

              {/* Due Date */}
              <div className="col-span-2 flex items-center gap-1.5 text-xs text-secondary">
                <CalendarDays size={14} className={task.dueDate === 'Today' ? 'text-accent-primary' : 'text-tertiary'} />
                <span className={task.dueDate === 'Today' ? 'text-accent-primary font-medium' : ''}>
                  {task.dueDate}
                </span>
              </div>

              {/* Priority */}
              <div className="col-span-2 flex items-center justify-end gap-2">
                <span className="text-xs text-secondary capitalize">{task.priority}</span>
                <div className={`w-2 h-2 rounded-full ${getPriorityColor(task.priority)} shadow-[0_0_8px_currentColor] opacity-80`} />
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
