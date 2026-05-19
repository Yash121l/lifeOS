import { useMemo, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import { Separator } from '@/components/ui/separator';
import { formatTaskDueDate } from '../../core/utils/formatters';
import { createTaskItem } from '../../core/models/index';
import type { Project, TaskItem } from '../../core/models/index';
import { useData } from '../data/DataProvider';
import { 
  Plus, 
  LayoutGrid, 
  List as ListIcon, 
  Search, 
  Calendar, 
  Flag, 
  Clock, 
  Tag, 
  MoreHorizontal,
  CheckCircle2,
  Trash2,
  GripVertical
} from 'lucide-react';

type TaskView = 'board' | 'list';
type BoardColumn = 'queue' | 'focus' | 'urgent' | 'done';

interface DraftTask {
  title: string;
  dueDate: string;
  priority: string;
  urgency: string;
  timeEstimateMinutes: string;
  notes: string;
  projectId: string;
}

const initialDraft: DraftTask = {
  title: '',
  dueDate: '',
  priority: '1',
  urgency: '0',
  timeEstimateMinutes: '30',
  notes: '',
  projectId: '',
};

function resolveColumn(task: TaskItem): BoardColumn {
  if (task.isCompleted) return 'done';
  if (task.urgency === 1) return 'urgent';
  if (task.priority === 2) return 'focus';
  return 'queue';
}

function applyColumn(task: TaskItem, column: BoardColumn): TaskItem {
  if (column === 'done') return { ...task, isCompleted: true };
  if (column === 'urgent') return { ...task, isCompleted: false, urgency: 1 };
  if (column === 'focus') return { ...task, isCompleted: false, urgency: 0, priority: 2 };
  return { ...task, isCompleted: false, urgency: 0 };
}

function projectLabel(projects: Project[], task: TaskItem) {
  return projects.find((project) => project.id === task.projectId)?.name ?? 'Inbox';
}

function getPriorityColor(priority: number) {
  switch (priority) {
    case 2: return 'text-rose-400 border-rose-400/20 bg-rose-400/10';
    case 1: return 'text-amber-400 border-amber-400/20 bg-amber-400/10';
    default: return 'text-emerald-400 border-emerald-400/20 bg-emerald-400/10';
  }
}

export default function TasksPage() {
  const { deleteTask, projects, saveTask, tasks } = useData();
  const [view, setView] = useState<TaskView>('board');
  const [draggedTaskId, setDraggedTaskId] = useState<string | null>(null);
  const [draft, setDraft] = useState<DraftTask>(initialDraft);
  const [searchQuery, setSearchQuery] = useState('');

  const filteredTasks = useMemo(() => {
    return tasks.filter(task => 
      task.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (task.notes?.toLowerCase() || '').includes(searchQuery.toLowerCase())
    );
  }, [tasks, searchQuery]);

  const openTasks = useMemo(
    () => tasks.filter((task) => !task.isCompleted),
    [tasks],
  );

  async function handleCreateTask(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!draft.title.trim()) return;
    
    const task = createTaskItem({
      title: draft.title.trim(),
      dueDate: draft.dueDate ? new Date(draft.dueDate) : null,
      priority: Number(draft.priority) as 0 | 1 | 2,
      urgency: Number(draft.urgency) as 0 | 1,
      timeEstimateMinutes: Number(draft.timeEstimateMinutes) || 30,
      notes: draft.notes.trim(),
      projectId: draft.projectId || null,
    });

    await saveTask(task);
    setDraft(initialDraft);
  }

  async function moveTask(task: TaskItem, column: BoardColumn) {
    await saveTask(applyColumn(task, column));
  }

  return (
    <div className="flex flex-col gap-6 md:gap-8 pb-12 animate-in fade-in duration-700">
      <section className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <span className="flex h-2 w-2 rounded-full bg-emerald-500" />
            <p className="text-xs font-bold uppercase tracking-[0.2em] text-emerald-400/90">Objectives</p>
          </div>
          <h2 className="font-display text-2xl font-bold tracking-tight sm:text-3xl text-gradient-apple">Command Center</h2>
          <p className="text-muted-foreground text-sm max-w-xl">
            Strategy happens here. Organize tasks, prioritize work, and drive progress.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <div className="relative group min-w-[240px]">
            <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground group-focus-within:text-primary transition-colors" />
            <Input 
              placeholder="Search missions..." 
              className="pl-9 h-10 border-white/10 bg-white/5 focus-visible:ring-emerald-500/50"
              value={searchQuery}
              onChange={e => setSearchQuery(e.target.value)}
            />
          </div>
        </div>
      </section>

      <div className="grid gap-8 lg:grid-cols-[1fr_22rem]">
        <section className="min-w-0 space-y-6">
          <Tabs value={view} onValueChange={(v) => setView(v as TaskView)} className="w-full">
            <TabsList className="bg-black/20 border border-white/10 p-1 rounded-xl mb-6">
              <TabsTrigger value="board" className="rounded-lg px-6 data-[state=active]:bg-white/10 data-[state=active]:text-white">
                <LayoutGrid size={14} className="mr-2" />
                Planning Board
              </TabsTrigger>
              <TabsTrigger value="list" className="rounded-lg px-6 data-[state=active]:bg-white/10 data-[state=active]:text-white">
                <ListIcon size={14} className="mr-2" />
                Stream View
              </TabsTrigger>
            </TabsList>

            <TabsContent value="board" className="mt-0 outline-none">
              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6 items-start">
                {[
                  ['queue', 'Queue', 'text-muted-foreground'],
                  ['focus', 'Focus', 'text-primary'],
                  ['urgent', 'Urgent', 'text-rose-400'],
                  ['done', 'Done', 'text-emerald-400'],
                ].map(([columnId, label, colorClass]) => (
                  <div
                    key={columnId}
                    className="flex flex-col gap-4 min-h-[600px] border-none group/column"
                    onDragOver={(event) => event.preventDefault()}
                    onDrop={() => {
                      if (!draggedTaskId) return;
                      const draggedTask = tasks.find(t => t.id === draggedTaskId);
                      if (!draggedTask) return;
                      void moveTask(draggedTask, columnId as BoardColumn);
                      setDraggedTaskId(null);
                    }}
                  >
                    <div className="flex items-center justify-between px-2">
                       <div className="flex items-center gap-3">
                         <div className={`h-1.5 w-1.5 rounded-full ${columnId === 'queue' ? 'bg-muted-foreground' : columnId === 'focus' ? 'bg-primary' : columnId === 'urgent' ? 'bg-rose-400' : 'bg-emerald-400'}`} />
                         <span className="font-display font-bold text-xs uppercase tracking-widest opacity-80">{label}</span>
                       </div>
                       <Badge variant="secondary" className="h-5 px-1.5 text-[10px] font-bold bg-white/5 border border-white/5 opacity-50">
                         {filteredTasks.filter(t => resolveColumn(t) === columnId).length}
                       </Badge>
                    </div>
                    
                    <div className="flex flex-col gap-3 p-1">
                      {filteredTasks
                        .filter((task) => resolveColumn(task) === columnId)
                        .map((task) => (
                          <Card
                            key={task.id}
                            className={`glass group/card hover:bg-white/[0.04] transition-all duration-300 border-white/[0.05] shadow-sm relative overflow-hidden ${draggedTaskId === task.id ? 'opacity-40 scale-95' : ''}`}
                            draggable
                            onDragStart={() => setDraggedTaskId(task.id)}
                            onDragEnd={() => setDraggedTaskId(null)}
                          >
                            <div className={`absolute top-0 left-0 bottom-0 w-0.5 ${task.priority === 2 ? 'bg-rose-400' : task.priority === 1 ? 'bg-amber-400' : 'bg-emerald-400'}`} />
                            <CardContent className="p-4 flex flex-col gap-3">
                              <div className="flex items-start justify-between gap-3">
                                <h4 className="text-sm font-semibold tracking-tight leading-snug line-clamp-2">{task.title}</h4>
                                <Button variant="ghost" size="icon" className="h-6 w-6 opacity-0 group-hover/card:opacity-100 transition-opacity">
                                  <MoreHorizontal size={14} className="text-muted-foreground" />
                                </Button>
                              </div>
                              
                              <p className="text-xs text-muted-foreground line-clamp-3 font-medium opacity-80">
                                {task.notes || 'Capture essential mission details here.'}
                              </p>

                              <div className="flex flex-wrap items-center gap-2 mt-2 pt-3 border-t border-white/5">
                                <Badge variant="outline" className={`h-5 text-[9px] uppercase font-bold tracking-tight px-1.5 ${getPriorityColor(task.priority)}`}>
                                   {task.priority === 2 ? 'Tier 1' : task.priority === 1 ? 'Tier 2' : 'Tier 3'}
                                </Badge>
                                <div className="flex items-center gap-1.5 text-[10px] text-muted-foreground font-semibold uppercase tracking-tighter bg-white/5 px-1.5 py-0.5 rounded ml-auto">
                                  <Calendar size={10} />
                                  {formatTaskDueDate(task.dueDate)}
                                </div>
                              </div>
                              
                              <div className="flex items-center gap-1 mt-2 -mb-1 h-0 group-hover/card:h-8 overflow-hidden transition-all duration-300 opacity-0 group-hover/card:opacity-100">
                                {!task.isCompleted && (
                                  <Button
                                    variant="ghost"
                                    size="sm"
                                    className="h-7 flex-1 text-[10px] font-bold uppercase tracking-widest text-[#34C759] hover:bg-[#34C759]/10 hover:text-[#34C759]"
                                    onClick={() => void saveTask({ ...task, isCompleted: true })}
                                  >
                                    Execute
                                  </Button>
                                )}
                                <Button
                                  variant="ghost"
                                  size="icon"
                                  className="h-7 w-7 text-rose-500/60 hover:text-rose-400 hover:bg-rose-500/10"
                                  onClick={() => void deleteTask(task.id)}
                                >
                                  <Trash2 size={12} />
                                </Button>
                              </div>
                            </CardContent>
                          </Card>
                        ))}
                      
                      {/* Empty Column State */}
                      {filteredTasks.filter(t => resolveColumn(t) === columnId).length === 0 && (
                        <div className="flex flex-col items-center justify-center py-12 rounded-2xl border border-dashed border-white/5 opacity-20">
                          <Plus size={20} className="mb-2" />
                          <span className="text-[10px] font-bold uppercase">Ready</span>
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </TabsContent>

            <TabsContent value="list" className="mt-0 outline-none">
              <Card className="glass overflow-hidden border-white/[0.05]">
                <div className="grid grid-cols-[2rem_1fr_120px_100px_100px] items-center gap-4 border-b border-white/5 bg-white/[0.03] px-4 py-3 text-[10px] font-bold uppercase tracking-[0.1em] text-muted-foreground/70">
                  <span />
                  <span>Objective</span>
                  <span>Project</span>
                  <span>Timeline</span>
                  <span className="text-right">Condition</span>
                </div>
                <div className="flex flex-col divide-y divide-white/5">
                  {filteredTasks.map((task) => (
                    <div key={task.id} className="group grid grid-cols-[2rem_1fr_120px_100px_100px] items-center gap-4 px-4 py-3 hover:bg-white/[0.02] transition-all">
                      <div className="flex justify-center">
                         <div className={`h-2.5 w-2.5 rounded-sm border ${task.isCompleted ? 'bg-emerald-500 border-emerald-500' : 'border-white/20'}`} />
                      </div>
                      <div className="min-w-0">
                        <strong className={`block truncate text-sm font-semibold tracking-tight ${task.isCompleted ? 'line-through opacity-40' : ''}`}>{task.title}</strong>
                        <span className="block truncate text-[10px] text-muted-foreground font-medium mt-0.5">{task.notes || 'No mission payload'}</span>
                      </div>
                      <span className="truncate text-xs font-semibold text-muted-foreground/80">{projectLabel(projects, task)}</span>
                      <div className="flex items-center gap-1.5 text-[10px] text-muted-foreground font-bold font-mono">
                        <Clock size={10} className="opacity-50" />
                        {formatTaskDueDate(task.dueDate)}
                      </div>
                      <div className="flex justify-end">
                        <Badge variant="outline" className={`h-5 text-[9px] font-bold px-2 border-white/10 ${task.isCompleted ? 'text-emerald-400' : 'text-primary'}`}>
                          {task.isCompleted ? 'Done' : resolveColumn(task)}
                        </Badge>
                      </div>
                    </div>
                  ))}
                  {filteredTasks.length === 0 && (
                    <div className="p-16 text-center">
                      <p className="text-sm font-medium text-muted-foreground">No matching objectives found.</p>
                    </div>
                  )}
                </div>
              </Card>
            </TabsContent>
          </Tabs>
        </section>

        <aside className="w-full h-fit sticky top-24">
          <Card className="glass border-white/[0.05] overflow-hidden">
            <CardHeader className="pb-6 bg-white/[0.02]">
              <div className="flex items-center justify-between items-start">
                <div className="space-y-1">
                  <p className="text-xs font-bold uppercase tracking-widest text-emerald-400/80">Input</p>
                  <CardTitle className="text-xl font-display">New Objective</CardTitle>
                </div>
                <div className="h-10 w-10 rounded-full bg-emerald-500/10 flex items-center justify-center text-emerald-500">
                  <CheckCircle2 size={20} />
                </div>
              </div>
            </CardHeader>

            <CardContent className="pt-6">
              <form
                className="grid gap-6"
                onSubmit={(event) => void handleCreateTask(event)}
              >
                <div className="grid gap-2">
                  <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Title</label>
                  <Input
                    className="h-11 border-white/5 bg-black/40 focus-visible:ring-emerald-500/50"
                    value={draft.title}
                    onChange={(event) =>
                      setDraft((current) => ({ ...current, title: event.target.value }))
                    }
                    placeholder="E.g. Launch the alpha workspace"
                    required
                  />
                </div>

                <div className="grid gap-6 sm:grid-cols-2">
                   <div className="grid gap-2">
                    <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Timeline</label>
                    <div className="relative">
                      <Calendar size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
                      <Input
                        type="date"
                        className="h-10 pl-9 border-white/5 bg-black/40 [color-scheme:dark] text-xs font-semibold"
                        value={draft.dueDate}
                        onChange={(event) =>
                          setDraft((current) => ({ ...current, dueDate: event.target.value }))
                        }
                      />
                    </div>
                  </div>
                  <div className="grid gap-2">
                    <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Project</label>
                    <div className="relative">
                      <Tag size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
                      <select
                        className="flex h-10 w-full rounded-md border border-white/5 bg-black/40 pl-9 px-3 py-2 text-xs font-semibold appearance-none outline-none focus:ring-1 focus:ring-emerald-500/50 transition-all"
                        value={draft.projectId}
                        onChange={(event) =>
                          setDraft((current) => ({ ...current, projectId: event.target.value }))
                        }
                      >
                        <option value="">Inbox</option>
                        {projects.map((project) => (
                          <option key={project.id} value={project.id}>
                            {project.name}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>
                </div>

                <div className="grid gap-6 sm:grid-cols-2">
                  <div className="grid gap-2">
                    <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Priority</label>
                    <div className="relative">
                      <Flag size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
                      <select
                        className="flex h-10 w-full rounded-md border border-white/5 bg-black/40 pl-9 px-3 py-2 text-xs font-semibold appearance-none outline-none focus:ring-1 focus:ring-emerald-500/50 transition-all"
                        value={draft.priority}
                        onChange={(event) =>
                          setDraft((current) => ({ ...current, priority: event.target.value }))
                        }
                      >
                        <option value="0">Low (Tier 3)</option>
                        <option value="1">Medium (Tier 2)</option>
                        <option value="2">High (Tier 1)</option>
                      </select>
                    </div>
                  </div>

                  <div className="grid gap-2">
                    <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Estimate</label>
                    <div className="relative">
                      <Clock size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
                      <Input
                        type="number"
                        min="15"
                        step="15"
                        className="h-10 pl-9 border-white/5 bg-black/40 text-xs font-semibold"
                        value={draft.timeEstimateMinutes}
                        onChange={(event) =>
                          setDraft((current) => ({ ...current, timeEstimateMinutes: event.target.value }))
                        }
                      />
                    </div>
                  </div>
                </div>

                <div className="grid gap-2">
                  <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Notes</label>
                  <Textarea
                    rows={4}
                    className="border-white/5 bg-black/40 resize-none text-sm placeholder:text-muted-foreground/30 focus-visible:ring-emerald-500/50"
                    value={draft.notes}
                    onChange={(event) =>
                      setDraft((current) => ({ ...current, notes: event.target.value }))
                    }
                    placeholder="Any tactical details, relevant links, or context..."
                  />
                </div>

                <Button type="submit" className="h-12 w-full rounded-2xl bg-emerald-600 hover:bg-emerald-500 text-white font-bold uppercase tracking-widest text-xs transition-all hover:shadow-[0_0_20px_rgba(16,185,129,0.3)]">
                  Launch Objective
                </Button>
              </form>
            </CardContent>
          </Card>

          <Card className="glass border-white/[0.05] mt-6 bg-gradient-to-br from-white/[0.03] to-transparent">
             <CardContent className="p-6 flex items-center gap-4">
               <div className="h-12 w-12 rounded-2xl bg-white/5 flex items-center justify-center text-emerald-400">
                 <LayoutGrid size={24} />
               </div>
               <div>
                 <h5 className="text-sm font-bold tracking-tight">Focus Protocol</h5>
                 <p className="text-[10px] text-muted-foreground font-medium uppercase tracking-tight">Active mission context enabled</p>
               </div>
             </CardContent>
          </Card>
        </aside>
      </div>
    </div>
  );
}
