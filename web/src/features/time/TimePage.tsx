import {
  eachHourOfInterval,
  endOfDay,
  format,
  isSameDay,
  isWithinInterval,
  startOfDay,
} from 'date-fns';
import { useMemo, useState } from 'react';
import {
  formatDateTimeInput,
  getWeekDays,
  startOfCurrentWeek,
} from '../../lib/formatters';
import { createTimeBlock } from '../../lib/models';
import { useData } from '../data/DataProvider';

export default function TimePage() {
  const { saveTimeBlock, tasks, timeBlocks } = useData();
  const [draft, setDraft] = useState(() => {
    const start = new Date();
    start.setMinutes(0, 0, 0);
    const end = new Date(start.getTime() + 60 * 60 * 1000);

    return {
      title: '',
      startTime: formatDateTimeInput(start),
      endTime: formatDateTimeInput(end),
      blockType: 'deepWork',
      linkedTaskId: '',
      colorHex: '1D4ED8',
    };
  });

  const weekDays = useMemo(() => getWeekDays(startOfCurrentWeek()), []);
  const hours = useMemo(
    () =>
      eachHourOfInterval({
        start: startOfDay(new Date()),
        end: endOfDay(new Date()),
      }),
    [],
  );

  const visibleBlocks = timeBlocks.filter((block) =>
    weekDays.some((day) =>
      isWithinInterval(block.startTime, {
        start: startOfDay(day),
        end: endOfDay(day),
      }),
    ),
  );

  async function handleCreateBlock(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    await saveTimeBlock(
      createTimeBlock({
        title: draft.title.trim(),
        startTime: new Date(draft.startTime),
        endTime: new Date(draft.endTime),
        blockType: draft.blockType,
        linkedTaskId: draft.linkedTaskId || null,
        colorHex: draft.colorHex.replace('#', ''),
      }),
    );
  }

  return (
    <div className="page-stack">
      <section className="page-header">
        <div>
          <p className="eyebrow">Time</p>
          <h2>Weekly schedule</h2>
          <p className="text-subtle">
            Build a browser-first calendar surface for deep work, meetings, and
            linked tasks.
          </p>
        </div>
      </section>

      <div className="content-grid content-grid--wide">
        <section className="panel schedule-panel">
          <div className="schedule-grid">
            <div className="schedule-grid__header" />
            {weekDays.map((day) => (
              <div key={day.toISOString()} className="schedule-grid__header">
                <span>{format(day, 'EEE')}</span>
                <strong>{format(day, 'd')}</strong>
              </div>
            ))}

            {hours.slice(6, 22).map((hour) => (
              <div key={hour.toISOString()} className="schedule-row">
                <div className="schedule-grid__time">{format(hour, 'ha')}</div>
                {weekDays.map((day) => (
                  <div
                    key={`${day.toISOString()}-${hour.toISOString()}`}
                    className="schedule-grid__cell"
                  >
                    {visibleBlocks
                      .filter(
                        (block) =>
                          isSameDay(block.startTime, day) &&
                          block.startTime.getHours() === hour.getHours(),
                      )
                      .map((block) => (
                        <div
                          key={block.id}
                          className="schedule-block"
                          style={{ borderLeftColor: `#${block.colorHex}` }}
                        >
                          <strong>{block.title}</strong>
                          <small>{block.blockType}</small>
                        </div>
                      ))}
                  </div>
                ))}
              </div>
            ))}
          </div>
        </section>

        <aside className="panel">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Planner</p>
              <h3>Add block</h3>
            </div>
            <span className="status-pill">{visibleBlocks.length} this week</span>
          </div>

          <form
            className="form-grid"
            onSubmit={(event) => void handleCreateBlock(event)}
          >
            <label className="field">
              <span>Title</span>
              <input
                value={draft.title}
                onChange={(event) =>
                  setDraft((current) => ({ ...current, title: event.target.value }))
                }
                placeholder="Deep work: ship PWA layer"
                required
              />
            </label>

            <div className="form-grid form-grid--split">
              <label className="field">
                <span>Start</span>
                <input
                  type="datetime-local"
                  value={draft.startTime}
                  onChange={(event) =>
                    setDraft((current) => ({
                      ...current,
                      startTime: event.target.value,
                    }))
                  }
                  required
                />
              </label>

              <label className="field">
                <span>End</span>
                <input
                  type="datetime-local"
                  value={draft.endTime}
                  onChange={(event) =>
                    setDraft((current) => ({
                      ...current,
                      endTime: event.target.value,
                    }))
                  }
                  required
                />
              </label>
            </div>

            <div className="form-grid form-grid--split">
              <label className="field">
                <span>Type</span>
                <select
                  value={draft.blockType}
                  onChange={(event) =>
                    setDraft((current) => ({
                      ...current,
                      blockType: event.target.value,
                    }))
                  }
                >
                  <option value="deepWork">Deep work</option>
                  <option value="meeting">Meeting</option>
                  <option value="personal">Personal</option>
                  <option value="routine">Routine</option>
                </select>
              </label>

              <label className="field">
                <span>Task link</span>
                <select
                  value={draft.linkedTaskId}
                  onChange={(event) =>
                    setDraft((current) => ({
                      ...current,
                      linkedTaskId: event.target.value,
                    }))
                  }
                >
                  <option value="">None</option>
                  {tasks.map((task) => (
                    <option key={task.id} value={task.id}>
                      {task.title}
                    </option>
                  ))}
                </select>
              </label>
            </div>

            <label className="field">
              <span>Accent color</span>
              <input
                type="color"
                value={`#${draft.colorHex.replace('#', '')}`}
                onChange={(event) =>
                  setDraft((current) => ({
                    ...current,
                    colorHex: event.target.value.replace('#', ''),
                  }))
                }
              />
            </label>

            <button className="button button--primary" type="submit">
              Save block
            </button>
          </form>
        </aside>
      </div>
    </div>
  );
}
