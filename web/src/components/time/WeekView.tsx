import { format, addDays, startOfWeek } from 'date-fns';

export function WeekView() {
  const startDate = startOfWeek(new Date(), { weekStartsOn: 1 }); // Monday
  const weekDays = Array.from({ length: 7 }).map((_, i) => addDays(startDate, i));
  const hours = Array.from({ length: 14 }).map((_, i) => i + 8); // 8 AM to 9 PM

  const blocks = [
    { day: 0, hour: 9, duration: 1, title: 'Standup', color: 'var(--accent-primary)' },
    { day: 0, hour: 10, duration: 2, title: 'Deep Work: Web App', color: 'var(--success)' },
    { day: 1, hour: 14, duration: 1.5, title: 'Client Sync', color: 'var(--warning)' },
    { day: 2, hour: 11, duration: 1, title: 'Gym', color: 'var(--error)' },
  ];

  return (
    <div className="flex flex-col h-full bg-[rgba(20,20,20,0.3)] rounded-xl border border-[var(--border-strong)] overflow-hidden">
      {/* Header Row (Days) */}
      <div className="flex border-b border-[var(--border-subtle)]">
        <div className="w-16 flex-shrink-0" /> {/* Time column padding */}
        {weekDays.map((day, i) => (
          <div key={i} className="flex-1 text-center py-4 border-l border-[var(--border-subtle)] min-w-[120px]">
            <div className="text-secondary text-xs uppercase font-semibold mb-1">{format(day, 'EEE')}</div>
            <div className={`text-xl font-medium ${i === 0 ? 'text-accent bg-[rgba(59,130,246,0.1)] w-8 h-8 rounded-full flex items-center justify-center mx-auto' : 'text-primary'}`}>
              {format(day, 'd')}
            </div>
          </div>
        ))}
      </div>

      {/* Grid Container */}
      <div className="flex-1 overflow-y-auto no-scrollbar relative">
        <div className="flex min-w-max">
          {/* Time scale Y axis */}
          <div className="w-16 flex-shrink-0 sticky left-0 z-10 bg-[var(--bg-primary)]">
            {hours.map((hour) => (
              <div key={hour} className="h-20 border-b border-transparent relative">
                <span className="absolute -top-3 right-4 text-xs font-medium text-tertiary">
                   {hour}:00
                </span>
              </div>
            ))}
          </div>

          {/* Grid lines & events overlay */}
          <div className="flex-1 relative min-w-[840px] flex">
            {weekDays.map((_, dayIndex) => (
              <div key={dayIndex} className="flex-1 border-l border-[var(--border-subtle)] relative">
                {/* Horizontal lines for each hour */}
                {hours.map((_, hIndex) => (
                  <div key={`${dayIndex}-${hIndex}`} className="h-20 border-b border-[var(--border-subtle)] opacity-50" />
                ))}

                {/* Render overlay blocks for this specific day */}
                {blocks.filter(b => b.day === dayIndex).map((block, i) => {
                  const hourIndex = hours.indexOf(block.hour);
                  if (hourIndex === -1) return null;
                  
                  const topOffset = hourIndex * 80; // 80px per hour
                  const height = block.duration * 80;
                  
                  return (
                    <div 
                      key={i}
                      className="absolute left-1 right-1 rounded-md p-2 shadow-sm text-white overflow-hidden text-xs font-medium cursor-pointer transition-transform hover:scale-[1.02]"
                      style={{
                        top: topOffset + 1,
                        height: height - 2,
                        backgroundColor: block.color,
                        boxShadow: `0 4px 10px ${block.color}40`,
                        borderLeft: '3px solid rgba(255,255,255,0.4)'
                      }}
                    >
                      {block.title}
                    </div>
                  );
                })}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
