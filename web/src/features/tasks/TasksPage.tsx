import { useMemo, useState } from 'react';
import { formatTaskDueDate } from '../../lib/formatters';
import { createTaskItem } from '../../lib/models';
import type { Project, TaskItem } from '../../lib/models';
import { useData } from '../data/DataProvider';

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
  if (column === 'done') {
    return { ...task, isCompleted: true };
  }
  if (column === 'urgent') {
    return { ...task, isCompleted: false, urgency: 1 };
  }
  if (column === 'focus') {
    return { ...task, isCompleted: false, urgency: 0, priority: 2 };
  }
  return { ...task, isCompleted: false, urgency: 0 };
}

function projectLabel(projects: Project[], task: TaskItem) {
  return projects.find((project) => project.id === task.projectId)?.name ?? 'Personal';
}

export default function TasksPage() {
  const { deleteTask, projects, saveTask, tasks } = useData();
  const [view, setView] = useState<TaskView>('board');
  const [draggedTaskId, setDraggedTaskId] = useState<string | null>(null);
  const [draft, setDraft] = useState<DraftTask>(initialDraft);

  const openTasks = useMemo(
    () => tasks.filter((task) => !task.isCompleted),
    [tasks],
  );

  async function handleCreateTask(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
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
    <div className="page-stack">
      <section className="page-header">
        <div>
          <p className="eyebrow">Tasks</p>
          <h2>Planning board</h2>
          <p className="text-subtle">
            Capture tasks fast, sort them by urgency, and keep mobile and
            desktop views in sync.
          </p>
        </div>

        <div className="segmented-control">
          <button
            className={view === 'board' ? 'is-active' : ''}
            type="button"
            onClick={() => setView('board')}
          >
            Board
          </button>
          <button
            className={view === 'list' ? 'is-active' : ''}
            type="button"
            onClick={() => setView('list')}
          >
            List
          </button>
        </div>
      </section>

      <div className="content-grid content-grid--wide">
        <section className="panel">
          {view === 'board' ? (
            <div className="board-grid">
              {[
                ['queue', 'Queue'],
                ['focus', 'Focus'],
                ['urgent', 'Urgent'],
                ['done', 'Done'],
              ].map(([columnId, label]) => (
                <div
                  key={columnId}
                  className="board-column"
                  onDragOver={(event) => event.preventDefault()}
                  onDrop={() => {
                    if (!draggedTaskId) return;
                    const draggedTask = tasks.find(
                      (task) => task.id === draggedTaskId,
                    );
                    if (!draggedTask) return;
                    void moveTask(draggedTask, columnId as BoardColumn);
                    setDraggedTaskId(null);
                  }}
                >
                  <div className="board-column__header">
                    <strong>{label}</strong>
                    <span>
                      {
                        tasks.filter((task) => resolveColumn(task) === columnId)
                          .length
                      }
                    </span>
                  </div>
                  <div className="stack">
                    {tasks
                      .filter((task) => resolveColumn(task) === columnId)
                      .map((task) => (
                        <article
                          key={task.id}
                          className="task-card"
                          draggable
                          onDragStart={() => setDraggedTaskId(task.id)}
                          onDragEnd={() => setDraggedTaskId(null)}
                        >
                          <div className="task-card__top">
                            <strong>{task.title}</strong>
                            <span
                              className={`priority-badge priority-badge--${task.priority}`}
                            >
                              {task.priority === 2
                                ? 'High'
                                : task.priority === 1
                                  ? 'Medium'
                                  : 'Low'}
                            </span>
                          </div>
                          <p>{task.notes || 'No extra notes yet.'}</p>
                          <div className="task-card__meta">
                            <span>{projectLabel(projects, task)}</span>
                            <span>{formatTaskDueDate(task.dueDate)}</span>
                          </div>
                          <div className="task-card__actions">
                            {!task.isCompleted ? (
                              <button
                                className="button button--ghost"
                                type="button"
                                onClick={() =>
                                  void saveTask({ ...task, isCompleted: true })
                                }
                              >
                                Complete
                              </button>
                            ) : null}
                            <button
                              className="button button--ghost"
                              type="button"
                              onClick={() => void deleteTask(task.id)}
                            >
                              Delete
                            </button>
                          </div>
                        </article>
                      ))}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="table-shell">
              <div className="table-shell__header">
                <span>Task</span>
                <span>Project</span>
                <span>Due</span>
                <span>State</span>
              </div>
              {tasks.map((task) => (
                <div key={task.id} className="table-shell__row">
                  <div>
                    <strong>{task.title}</strong>
                    <small>{task.notes || 'No notes'}</small>
                  </div>
                  <span>{projectLabel(projects, task)}</span>
                  <span>{formatTaskDueDate(task.dueDate)}</span>
                  <span className="status-pill">
                    {task.isCompleted ? 'Done' : resolveColumn(task)}
                  </span>
                </div>
              ))}
            </div>
          )}
        </section>

        <aside className="panel">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Capture</p>
              <h3>Create task</h3>
            </div>
            <span className="status-pill">{openTasks.length} open</span>
          </div>

          <form
            className="form-grid"
            onSubmit={(event) => void handleCreateTask(event)}
          >
            <label className="field">
              <span>Title</span>
              <input
                value={draft.title}
                onChange={(event) =>
                  setDraft((current) => ({ ...current, title: event.target.value }))
                }
                placeholder="Ship responsive web dashboard"
                required
              />
            </label>

            <label className="field">
              <span>Due date</span>
              <input
                type="date"
                value={draft.dueDate}
                onChange={(event) =>
                  setDraft((current) => ({ ...current, dueDate: event.target.value }))
                }
              />
            </label>

            <div className="form-grid form-grid--split">
              <label className="field">
                <span>Priority</span>
                <select
                  value={draft.priority}
                  onChange={(event) =>
                    setDraft((current) => ({ ...current, priority: event.target.value }))
                  }
                >
                  <option value="0">Low</option>
                  <option value="1">Medium</option>
                  <option value="2">High</option>
                </select>
              </label>

              <label className="field">
                <span>Urgency</span>
                <select
                  value={draft.urgency}
                  onChange={(event) =>
                    setDraft((current) => ({ ...current, urgency: event.target.value }))
                  }
                >
                  <option value="0">Normal</option>
                  <option value="1">Urgent</option>
                </select>
              </label>
            </div>

            <div className="form-grid form-grid--split">
              <label className="field">
                <span>Estimate (min)</span>
                <input
                  type="number"
                  min="15"
                  step="15"
                  value={draft.timeEstimateMinutes}
                  onChange={(event) =>
                    setDraft((current) => ({
                      ...current,
                      timeEstimateMinutes: event.target.value,
                    }))
                  }
                />
              </label>

              <label className="field">
                <span>Project</span>
                <select
                  value={draft.projectId}
                  onChange={(event) =>
                    setDraft((current) => ({
                      ...current,
                      projectId: event.target.value,
                    }))
                  }
                >
                  <option value="">Personal</option>
                  {projects.map((project) => (
                    <option key={project.id} value={project.id}>
                      {project.name}
                    </option>
                  ))}
                </select>
              </label>
            </div>

            <label className="field">
              <span>Notes</span>
              <textarea
                rows={5}
                value={draft.notes}
                onChange={(event) =>
                  setDraft((current) => ({ ...current, notes: event.target.value }))
                }
                placeholder="Context, acceptance criteria, links..."
              />
            </label>

            <button className="button button--primary" type="submit">
              Save task
            </button>
          </form>
        </aside>
      </div>
    </div>
  );
}
