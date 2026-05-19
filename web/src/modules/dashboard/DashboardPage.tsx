import { CheckCircle2, Clock3, NotebookTabs, Wallet, ArrowUpRight, TrendingUp, Sparkles } from 'lucide-react';
import { compareAsc, isToday } from 'date-fns';
import {
  formatCurrency,
  formatTaskDueDate,
  getGreeting,
} from '../../core/utils/formatters';
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
} from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { useAuth } from '../auth/AuthProvider';
import { useData } from '../data/DataProvider';
import { Progress } from '@/components/ui/progress';

export default function DashboardPage() {
  const { displayName } = useAuth();
  const { notes, tasks, timeBlocks, transactions } = useData();

  const completedTasks = tasks.filter((task) => task.isCompleted).length;
  const pendingTasks = tasks.filter((task) => !task.isCompleted).length;
  const taskProgress = tasks.length > 0 ? (completedTasks / tasks.length) * 100 : 0;

  const todayFocusMinutes = timeBlocks
    .filter((block) => isToday(block.startTime))
    .reduce(
      (total, block) =>
        total +
        (block.endTime.getTime() - block.startTime.getTime()) / 60000,
      0,
    );
  const balance = transactions.reduce((total, transaction) => {
    const nextValue = transaction.isExpense
      ? -transaction.amount
      : transaction.amount;
    return total + nextValue;
  }, 0);

  const upcomingTasks = tasks
    .filter((task) => !task.isCompleted)
    .sort((left, right) =>
      compareAsc(left.dueDate ?? left.createdAt, right.dueDate ?? right.createdAt),
    )
    .slice(0, 4);

  const recentNotes = [...notes]
    .sort((left, right) => right.updatedAt.getTime() - left.updatedAt.getTime())
    .slice(0, 3);

  const nextBlocks = timeBlocks
    .filter((block) => block.endTime >= new Date())
    .sort((left, right) => compareAsc(left.startTime, right.startTime))
    .slice(0, 4);

  return (
    <div className="flex flex-col gap-8 pb-12 animate-in fade-in duration-700">
      {/* Hero Section */}
      <section className="flex flex-col gap-6 md:flex-row md:items-end md:justify-between">
        <div className="space-y-2">
          <div className="flex items-center gap-2">
            <span className="flex h-2 w-2 rounded-full bg-[#007AFF] animate-pulse" />
            <p className="text-xs font-bold uppercase tracking-[0.2em] text-[#007AFF]/80">Live Workspace</p>
          </div>
          <h2 className="font-display text-3xl font-bold tracking-tight sm:text-4xl text-gradient-apple">
            {getGreeting(displayName)}
          </h2>
          <p className="text-muted-foreground text-base max-w-xl leading-relaxed">
            Your personal operating system, synchronized and ready for the day ahead.
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-3">
          <Badge variant="outline" className="glass px-3 py-1 text-[10px] uppercase tracking-wider font-semibold">
            <TrendingUp size={12} className="mr-2 text-emerald-400" />
            Productivity: High
          </Badge>
          <Badge variant="outline" className="glass px-3 py-1 text-[10px] uppercase tracking-wider font-semibold">
            <Sparkles size={12} className="mr-2 text-amber-400" />
            Cloud Active
          </Badge>
        </div>
      </section>

      {/* Stats Grid */}
      <section className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <Card className="glass group hover:bg-white/[0.04] transition-all duration-300">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-bold uppercase tracking-widest text-muted-foreground/70">Tasks</CardTitle>
            <div className="flex h-9 w-9 items-center justify-center rounded-2xl bg-[#34C759]/10 text-[#34C759] group-hover:scale-110 transition-transform">
              <CheckCircle2 size={18} />
            </div>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <div className="text-3xl font-display font-bold">{completedTasks}</div>
              <p className="text-xs text-muted-foreground mt-1">
                {pendingTasks} remaining objectives
              </p>
            </div>
            <div className="space-y-1.5">
              <div className="flex items-center justify-between text-[10px] font-bold uppercase tracking-tight">
                <span>Completion</span>
                <span>{Math.round(taskProgress)}%</span>
              </div>
              <Progress value={taskProgress} className="h-1 bg-white/5" />
            </div>
          </CardContent>
        </Card>

        <Card className="glass group hover:bg-white/[0.04] transition-all duration-300">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-bold uppercase tracking-widest text-muted-foreground/70">Focus</CardTitle>
            <div className="flex h-9 w-9 items-center justify-center rounded-2xl bg-[#AF52DE]/10 text-[#AF52DE] group-hover:scale-110 transition-transform">
              <Clock3 size={18} />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-display font-bold">
              {Math.floor(todayFocusMinutes / 60)}h {Math.round(todayFocusMinutes % 60)}m
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              Time allocated today
            </p>
            <div className="mt-5 flex items-center gap-1.5 overflow-hidden">
               {Array.from({ length: 12 }).map((_, i) => (
                 <div 
                   key={i} 
                   className={`h-1.5 flex-1 rounded-full ${i < todayFocusMinutes / 30 ? 'bg-[#AF52DE]' : 'bg-white/5'}`} 
                 />
               ))}
            </div>
          </CardContent>
        </Card>

        <Card className="glass group hover:bg-white/[0.04] transition-all duration-300">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-bold uppercase tracking-widest text-muted-foreground/70">Knowledge</CardTitle>
            <div className="flex h-9 w-9 items-center justify-center rounded-2xl bg-[#FF9500]/10 text-[#FF9500] group-hover:scale-110 transition-transform">
              <NotebookTabs size={18} />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-display font-bold">{notes.length}</div>
            <p className="text-xs text-muted-foreground mt-1">
              Captured insights
            </p>
            <div className="mt-5 flex -space-x-2">
              {recentNotes.map((_, i) => (
                <div key={i} className="h-6 w-6 rounded-full border-2 border-[#1c1c1e] bg-gradient-to-br from-[#FF9500]/20 to-[#FFCC00]/20" />
              ))}
              <div className="flex h-6 w-6 items-center justify-center rounded-full border-2 border-[#1c1c1e] bg-white/5 text-[8px] font-bold">+ {notes.length}</div>
            </div>
          </CardContent>
        </Card>

        <Card className="glass group hover:bg-white/[0.04] transition-all duration-300">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-xs font-bold uppercase tracking-widest text-muted-foreground/70">Finance</CardTitle>
            <div className="flex h-9 w-9 items-center justify-center rounded-2xl bg-[#5AC8FA]/10 text-[#5AC8FA] group-hover:scale-110 transition-transform">
              <Wallet size={18} />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-display font-bold text-gradient-blue">{formatCurrency(balance)}</div>
            <p className="text-xs text-muted-foreground mt-1">
              Current net liquidity
            </p>
            <div className="mt-5 flex items-center justify-between">
              <div className="flex flex-col">
                <span className="text-[10px] font-bold uppercase tracking-tighter opacity-50">Volume</span>
                <span className="text-xs font-bold tracking-tight">{transactions.length} tx</span>
              </div>
              <ArrowUpRight size={14} className="text-[#5AC8FA]" />
            </div>
          </CardContent>
        </Card>
      </section>

      {/* Detail Sections */}
      <section className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
        {/* Tasks Detail */}
        <Card className="glass flex flex-col border-white/[0.05] overflow-hidden">
          <CardHeader className="pb-3 bg-white/[0.02]">
            <div className="flex items-center justify-between">
              <CardTitle className="text-xl font-display">Priorities</CardTitle>
              <Badge variant="secondary" className="bg-white/5 hover:bg-white/10 cursor-pointer">View all</Badge>
            </div>
            <CardDescription className="text-xs">Your immediate next actions.</CardDescription>
          </CardHeader>
          <CardContent className="p-4 flex-1">
            <div className="space-y-3">
              {upcomingTasks.length ? (
                upcomingTasks.map((task) => (
                  <div key={task.id} className="group relative flex items-center justify-between gap-4 rounded-xl border border-white/[0.03] bg-white/[0.01] p-3 transition-all hover:bg-white/[0.04] hover:translate-x-1">
                    <div className="min-w-0">
                      <strong className="block truncate text-sm font-semibold tracking-tight">{task.title}</strong>
                      <span className="block truncate text-[10px] text-muted-foreground uppercase font-medium mt-0.5">{task.notes || 'Capture essential notes'}</span>
                    </div>
                    <Badge variant="outline" className={`shrink-0 text-[9px] font-bold border-white/10 bg-white/5 uppercase ${task.priority === 2 ? 'text-rose-400' : task.priority === 1 ? 'text-amber-400' : 'text-[#34C759]'}`}>
                      {formatTaskDueDate(task.dueDate)}
                    </Badge>
                  </div>
                ))
              ) : (
                <div className="flex flex-col items-center justify-center py-10 text-center opacity-40">
                  <div className="h-10 w-10 rounded-full border border-dashed border-white/20 mb-3" />
                  <p className="text-xs">No active priorities</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Calendar Detail */}
        <Card className="glass flex flex-col border-white/[0.05] overflow-hidden">
          <CardHeader className="pb-3 bg-white/[0.02]">
            <div className="flex items-center justify-between">
              <CardTitle className="text-xl font-display">Timeline</CardTitle>
              <Badge variant="secondary" className="bg-white/5 hover:bg-white/10 cursor-pointer">Open</Badge>
            </div>
            <CardDescription className="text-xs">Scheduled focus blocks.</CardDescription>
          </CardHeader>
          <CardContent className="p-4 flex-1">
            <div className="space-y-3">
              {nextBlocks.length ? (
                nextBlocks.map((block) => (
                  <div key={block.id} className="group flex items-center justify-between gap-4 rounded-xl border border-white/[0.03] bg-white/[0.01] p-3 transition-all hover:bg-white/[0.04] hover:translate-x-1">
                    <div className="min-w-0">
                      <strong className="block truncate text-sm font-semibold tracking-tight">{block.title}</strong>
                      <span className="block truncate text-[10px] text-muted-foreground uppercase font-medium mt-0.5">{block.blockType}</span>
                    </div>
                    <Badge variant="secondary" className="shrink-0 text-[10px] font-bold bg-white/10">
                      {block.startTime.toLocaleTimeString([], {
                        hour: 'numeric',
                        minute: '2-digit',
                      })}
                    </Badge>
                  </div>
                ))
              ) : (
                <div className="flex flex-col items-center justify-center py-10 text-center opacity-40">
                  <div className="h-10 w-10 rounded-full border border-dashed border-white/20 mb-3" />
                  <p className="text-xs">Schedule focus time</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Knowledge Detail */}
        <Card className="glass flex flex-col border-white/[0.05] overflow-hidden md:col-span-2 lg:col-span-1">
          <CardHeader className="pb-3 bg-white/[0.02]">
            <div className="flex items-center justify-between">
              <CardTitle className="text-xl font-display">Insights</CardTitle>
              <Badge variant="secondary" className="bg-white/5 hover:bg-white/10 cursor-pointer">Browse</Badge>
            </div>
            <CardDescription className="text-xs">Recently captured knowledge.</CardDescription>
          </CardHeader>
          <CardContent className="p-4 flex-1">
            <div className="space-y-3">
              {recentNotes.length ? (
                recentNotes.map((note) => (
                  <div key={note.id} className="group flex items-center justify-between gap-4 rounded-xl border border-white/[0.03] bg-white/[0.01] p-3 transition-all hover:bg-white/[0.04] hover:translate-x-1">
                    <div className="min-w-0">
                      <strong className="block truncate text-sm font-semibold tracking-tight">{note.title}</strong>
                      <span className="block truncate text-[10px] text-muted-foreground uppercase font-medium mt-0.5">{note.tagsRaw || 'General insight'}</span>
                    </div>
                    <Badge variant="secondary" className="shrink-0 text-[10px] font-bold bg-white/10">
                      {note.updatedAt.toLocaleDateString()}
                    </Badge>
                  </div>
                ))
              ) : (
                <div className="flex flex-col items-center justify-center py-10 text-center opacity-40">
                  <div className="h-10 w-10 rounded-full border border-dashed border-white/20 mb-3" />
                  <p className="text-xs">Memory is currently empty</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </section>
    </div>
  );
}

