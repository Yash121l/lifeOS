import { CheckCircle2, Clock3, NotebookTabs, Wallet } from 'lucide-react';
import { compareAsc, isToday } from 'date-fns';
import {
  formatCurrency,
  formatTaskDueDate,
  getGreeting,
} from '../../lib/formatters';
import { useAuth } from '../auth/AuthProvider';
import { useData } from '../data/DataProvider';

export default function DashboardPage() {
  const { displayName } = useAuth();
  const { notes, tasks, timeBlocks, transactions } = useData();

  const completedTasks = tasks.filter((task) => task.isCompleted).length;
  const pendingTasks = tasks.filter((task) => !task.isCompleted).length;
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
    <div className="page-stack">
      <section className="hero hero--dashboard">
        <div>
          <p className="eyebrow">Today</p>
          <h2>{getGreeting(displayName)}</h2>
          <p className="text-subtle">
            This is your live snapshot across tasks, focus blocks, notes, and
            finances.
          </p>
        </div>
        <div className="hero__chips">
          <span className="metric-chip">Realtime sync</span>
          <span className="metric-chip">Offline ready</span>
          <span className="metric-chip">Responsive workspace</span>
        </div>
      </section>

      <section className="metrics-grid">
        <article className="metric-card panel">
          <div className="metric-card__icon">
            <CheckCircle2 size={20} />
          </div>
          <div>
            <p>Tasks completed</p>
            <strong>{completedTasks}</strong>
            <small>{pendingTasks} still open</small>
          </div>
        </article>

        <article className="metric-card panel">
          <div className="metric-card__icon">
            <Clock3 size={20} />
          </div>
          <div>
            <p>Focus scheduled today</p>
            <strong>{Math.round(todayFocusMinutes / 60)}h</strong>
            <small>{todayFocusMinutes} minutes total</small>
          </div>
        </article>

        <article className="metric-card panel">
          <div className="metric-card__icon">
            <NotebookTabs size={20} />
          </div>
          <div>
            <p>Knowledge base</p>
            <strong>{notes.length}</strong>
            <small>{recentNotes.length} recently touched</small>
          </div>
        </article>

        <article className="metric-card panel">
          <div className="metric-card__icon">
            <Wallet size={20} />
          </div>
          <div>
            <p>Net cash flow</p>
            <strong>{formatCurrency(balance)}</strong>
            <small>{transactions.length} logged transactions</small>
          </div>
        </article>
      </section>

      <section className="content-grid">
        <article className="panel">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Tasks</p>
              <h3>Upcoming priorities</h3>
            </div>
          </div>
          <div className="list-stack">
            {upcomingTasks.length ? (
              upcomingTasks.map((task) => (
                <div key={task.id} className="list-row">
                  <div>
                    <strong>{task.title}</strong>
                    <small>{task.notes || 'No extra notes yet'}</small>
                  </div>
                  <span
                    className={`priority-badge priority-badge--${task.priority}`}
                  >
                    {formatTaskDueDate(task.dueDate)}
                  </span>
                </div>
              ))
            ) : (
              <p className="empty-copy">
                No open tasks yet. Add one from the Tasks page.
              </p>
            )}
          </div>
        </article>

        <article className="panel">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Time</p>
              <h3>Next calendar blocks</h3>
            </div>
          </div>
          <div className="list-stack">
            {nextBlocks.length ? (
              nextBlocks.map((block) => (
                <div key={block.id} className="list-row">
                  <div>
                    <strong>{block.title}</strong>
                    <small>{block.blockType}</small>
                  </div>
                  <span className="status-pill">
                    {block.startTime.toLocaleTimeString([], {
                      hour: 'numeric',
                      minute: '2-digit',
                    })}
                  </span>
                </div>
              ))
            ) : (
              <p className="empty-copy">
                No upcoming blocks. Add focus time in the Time page.
              </p>
            )}
          </div>
        </article>

        <article className="panel">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Knowledge</p>
              <h3>Recent notes</h3>
            </div>
          </div>
          <div className="list-stack">
            {recentNotes.length ? (
              recentNotes.map((note) => (
                <div key={note.id} className="list-row">
                  <div>
                    <strong>{note.title}</strong>
                    <small>{note.tagsRaw || 'General note'}</small>
                  </div>
                  <span className="status-pill">
                    {note.updatedAt.toLocaleDateString()}
                  </span>
                </div>
              ))
            ) : (
              <p className="empty-copy">Your knowledge base is empty.</p>
            )}
          </div>
        </article>
      </section>
    </div>
  );
}
