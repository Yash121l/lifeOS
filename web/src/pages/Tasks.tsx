import { useState } from 'react';
import { KanbanBoard } from '../components/tasks/KanbanBoard';
import { TaskListView } from '../components/tasks/TaskListView';
import { LayoutList, Columns3, Plus, Filter } from 'lucide-react';
import clsx from 'clsx';

export default function Tasks() {
  const [view, setView] = useState<'board' | 'list'>('board');

  return (
    <div className="tasks-view flex flex-col h-full animate-fade-in">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold mb-1 text-primary">Tasks</h1>
          <p className="text-sm text-secondary">Manage your projects and Eisenhower priorities.</p>
        </div>

        <div className="flex items-center gap-4">
          <div className="flex bg-[rgba(20,20,20,0.5)] p-1 rounded-lg border border-[var(--border-subtle)]">
            <button 
              className={clsx("p-2 rounded cursor-pointer transition-all", view === 'board' ? 'bg-secondary text-primary shadow-sm' : 'text-tertiary hover:text-secondary')}
              onClick={() => setView('board')}
            >
              <Columns3 size={18} />
            </button>
            <button 
              className={clsx("p-2 rounded cursor-pointer transition-all", view === 'list' ? 'bg-secondary text-primary shadow-sm' : 'text-tertiary hover:text-secondary')}
              onClick={() => setView('list')}
            >
              <LayoutList size={18} />
            </button>
          </div>
          
          <button className="btn btn-secondary text-sm h-[38px]">
            <Filter size={16} /> Filter
          </button>
          
          <button className="btn btn-primary text-sm h-[38px]">
            <Plus size={16} /> New Task
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-hidden">
        {view === 'board' ? (
          <KanbanBoard />
        ) : (
          <TaskListView />
        )}
      </div>
    </div>
  );
}
