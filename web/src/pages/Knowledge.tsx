import { useState } from 'react';
import { FileText, Plus } from 'lucide-react';
import Editor from '../components/editor/Editor';

const DEMO_NOTE = `<h1>System Architecture Plan</h1><p>This document tracks the initial foundation for the LifeOS application.</p><p></p><ul data-type="taskList"><li data-type="taskItem" data-checked="true"><label><input type="checkbox" checked="checked"><span></span></label><div><p>Complete PRD</p></div></li><li data-type="taskItem" data-checked="false"><label><input type="checkbox"><span></span></label><div><p>Build iOS app</p></div></li><li data-type="taskItem" data-checked="false"><label><input type="checkbox"><span></span></label><div><p>Build Web App</p></div></li></ul><p></p><blockquote>A good system requires minimal context switching to stay effective.</blockquote><p></p><h2>API Design</h2><p>We will use standard REST routing to handle external integrations if required.</p>`;

export default function Knowledge() {
  const [activeNote, setActiveNote] = useState<string>('System Architecture Plan');

  const notesList = [
    { id: '1', title: 'System Architecture Plan', snippet: 'This document tracks...' },
    { id: '2', title: 'Weekly Resync', snippet: 'Topics for this week...' },
    { id: '3', title: 'Book Summaries', snippet: 'Reading log for Q4...' },
  ];

  return (
    <div className="knowledge-view flex h-full">
      {/* Sidebar for Notes Index */}
      <div className="notes-sidebar w-72 border-r border-[var(--border-strong)] flex flex-col h-full bg-[rgba(20,20,20,0.3)] pr-6 mr-6">
        <div className="flex justify-between items-center mb-6 pl-4">
          <h2 className="text-xl font-semibold">Knowledge</h2>
          <button className="icon-btn bg-accent-glow text-accent">
            <Plus size={18} />
          </button>
        </div>
        
        <div className="flex-1 overflow-y-auto pl-4 flex flex-col gap-2">
          {notesList.map((note) => (
            <div 
              key={note.id} 
              className={`p-3 rounded-lg cursor-pointer border transition-all duration-200 ${activeNote === note.title ? 'bg-[rgba(59,130,246,0.1)] border-[#3b82f6] shadow-[0_0_15px_rgba(59,130,246,0.15)]' : 'border-transparent hover:bg-[rgba(255,255,255,0.05)]'}`}
              onClick={() => setActiveNote(note.title)}
            >
              <h3 className="text-sm font-medium text-primary mb-1 line-clamp-1 flex items-center gap-2">
                <FileText size={14} className="text-accent" />
                {note.title}
              </h3>
              <p className="text-xs text-tertiary line-clamp-1">{note.snippet}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Main Editor View */}
      <div className="editor-main flex-1 overflow-y-auto no-scrollbar relative animate-fade-in">
        <div className="w-full max-w-4xl mx-auto px-8">
          {/* Top metadata actions could go here */}
          <div className="h-10 w-full flex items-center justify-end border-b border-[var(--border-subtle)] mb-8">
            <span className="text-xs text-tertiary">Last edited 2 mins ago</span>
          </div>

          <Editor initialContent={activeNote === 'System Architecture Plan' ? DEMO_NOTE : `<h1>${activeNote}</h1><p>Start typing or use '/' for commands...</p>`} />
        </div>
      </div>
    </div>
  );
}
