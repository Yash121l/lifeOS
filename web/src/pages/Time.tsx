import { WeekView } from '../components/time/WeekView';
import { Calendar as CalendarIcon, Settings2 } from 'lucide-react';

export default function Time() {
  return (
    <div className="time-view flex flex-col h-full animate-fade-in">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold mb-1 text-primary">Time</h1>
          <p className="text-sm text-secondary">A unified view of your schedule and deep focus blocks.</p>
        </div>

        <div className="flex gap-4">
           <button className="btn btn-secondary h-[38px]">
            <CalendarIcon size={16} /> Connect Calendar
          </button>
          <button className="btn btn-primary h-[38px]">
            <Settings2 size={16} /> Planning Mode
          </button>
        </div>
      </div>

      <div className="flex-1 min-h-0">
         <WeekView />
      </div>
    </div>
  );
}
