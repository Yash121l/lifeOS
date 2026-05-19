import {
  eachHourOfInterval,
  endOfDay,
  format,
  isSameDay,
  isWithinInterval,
  startOfDay,
} from 'date-fns';
import { useMemo, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import {
  formatDateTimeInput,
  getWeekDays,
  startOfCurrentWeek,
} from '../../core/utils/formatters';
import { createTimeBlock } from '../../core/models/index';
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
    <div className="grid gap-6 md:gap-8">
      <section className="flex flex-col gap-4 md:flex-row md:items-start md:justify-between">
        <div>
          <p className="text-sm font-semibold uppercase tracking-widest text-primary">Time</p>
          <h2 className="mt-1 font-display text-2xl font-semibold tracking-tight sm:text-3xl">Weekly schedule</h2>
          <p className="mt-2 text-muted-foreground">
            Build a browser-first calendar surface for deep work, meetings, and
            linked tasks.
          </p>
        </div>
      </section>

      <div className="grid gap-6 lg:grid-cols-[1fr_22rem]">
        <Card className="bg-card/50 backdrop-blur-xl border-white/10 flex flex-col min-h-[600px] overflow-hidden">
          <CardContent className="p-0 flex-1 overflow-auto">
            <div className="grid grid-cols-[3.5rem_repeat(7,minmax(6rem,1fr))] divide-x divide-y divide-white/5 border-b border-white/5 min-w-[700px]">
              <div className="sticky top-0 z-10 bg-black/40 backdrop-blur-sm border-b border-white/5" />
              {weekDays.map((day) => (
                <div key={day.toISOString()} className="sticky top-0 z-10 flex flex-col items-center justify-center py-3 bg-black/40 backdrop-blur-sm border-b border-white/5">
                  <span className="text-xs font-medium text-muted-foreground uppercase">{format(day, 'EEE')}</span>
                  <strong className="text-sm font-display mt-0.5">{format(day, 'd')}</strong>
                </div>
              ))}

              {hours.slice(6, 22).map((hour) => (
                <div key={hour.toISOString()} className="contents group">
                  <div className="sticky left-0 z-10 flex items-start justify-end pr-2 py-2 text-[10px] font-medium text-muted-foreground bg-background/95 backdrop-blur-sm border-r border-white/5">
                    {format(hour, 'ha')}
                  </div>
                  {weekDays.map((day) => (
                    <div
                      key={`${day.toISOString()}-${hour.toISOString()}`}
                      className="relative min-h-[4rem] p-1 bg-white/[0.01] hover:bg-white/[0.03] transition-colors"
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
                            className="absolute inset-x-1 top-1 rounded-md border border-white/10 bg-card/80 p-2 shadow-sm backdrop-blur-md overflow-hidden z-20 group/block hover:z-30 transition-all hover:scale-[1.02] hover:-translate-y-0.5 duration-200"
                            style={{ borderLeftColor: `#${block.colorHex}`, borderLeftWidth: '3px' }}
                          >
                            <strong className="block text-xs font-semibold leading-tight mb-0.5 truncate">{block.title}</strong>
                            <small className="block text-[10px] text-muted-foreground opacity-80 uppercase tracking-wider truncate">{block.blockType}</small>
                          </div>
                        ))}
                    </div>
                  ))}
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <aside className="w-full">
          <Card className="bg-card/50 backdrop-blur-xl border-white/10 sticky top-[calc(var(--spacing)*4+var(--navbar-height,5rem))]">
            <CardHeader className="pb-4 flex flex-row items-center justify-between">
              <div>
                <p className="text-xs font-semibold uppercase tracking-widest text-primary mb-1">Planner</p>
                <CardTitle className="text-lg font-display">Add block</CardTitle>
              </div>
              <Badge variant="secondary" className="bg-primary/20 text-primary">{visibleBlocks.length} this week</Badge>
            </CardHeader>

            <CardContent>
              <form
                className="grid gap-5"
                onSubmit={(event) => void handleCreateBlock(event)}
              >
                <div className="grid gap-2">
                  <label className="text-sm font-medium text-muted-foreground">Title</label>
                  <Input
                    className="bg-black/20"
                    value={draft.title}
                    onChange={(event) =>
                      setDraft((current) => ({ ...current, title: event.target.value }))
                    }
                    placeholder="Deep work: ship PWA layer"
                    required
                  />
                </div>

                <div className="grid gap-5 sm:grid-cols-2">
                  <div className="grid gap-2">
                    <label className="text-sm font-medium text-muted-foreground">Start</label>
                    <Input
                      type="datetime-local"
                      className="bg-black/20 [color-scheme:dark]"
                      value={draft.startTime}
                      onChange={(event) =>
                        setDraft((current) => ({
                          ...current,
                          startTime: event.target.value,
                        }))
                      }
                      required
                    />
                  </div>

                  <div className="grid gap-2">
                    <label className="text-sm font-medium text-muted-foreground">End</label>
                    <Input
                      type="datetime-local"
                      className="bg-black/20 [color-scheme:dark]"
                      value={draft.endTime}
                      onChange={(event) =>
                        setDraft((current) => ({
                          ...current,
                          endTime: event.target.value,
                        }))
                      }
                      required
                    />
                  </div>
                </div>

                <div className="grid gap-5 sm:grid-cols-2">
                  <div className="grid gap-2">
                    <label className="text-sm font-medium text-muted-foreground">Type</label>
                    <select
                      className="flex h-10 w-10 min-w-full items-center justify-between rounded-md border border-input bg-black/20 px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
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
                  </div>

                  <div className="grid gap-2">
                    <label className="text-sm font-medium text-muted-foreground">Task link</label>
                    <select
                      className="flex h-10 w-10 min-w-full items-center justify-between rounded-md border border-input bg-black/20 px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
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
                  </div>
                </div>

                <div className="grid gap-2">
                  <label className="text-sm font-medium text-muted-foreground">Accent color</label>
                  <Input
                    type="color"
                    className="bg-black/20 h-10 w-full p-1 cursor-pointer"
                    value={`#${draft.colorHex.replace('#', '')}`}
                    onChange={(event) =>
                      setDraft((current) => ({
                        ...current,
                        colorHex: event.target.value.replace('#', ''),
                      }))
                    }
                  />
                </div>

                <Button type="submit" className="mt-2 w-full rounded-full">
                  Save block
                </Button>
              </form>
            </CardContent>
          </Card>
        </aside>
      </div>
    </div>
  );
}
