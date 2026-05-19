import { useState, useMemo } from 'react';
import { 
  Plus, 
  Search, 
  FileText, 
  Calendar, 
  Clock, 
  MoreHorizontal, 
  Trash2, 
  Folder, 
  Hash,
  Sparkles,
  Command,
  ChevronRight,
  BookOpen
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import Editor from '../../core/components/editor/Editor';
import { createNoteItem } from '../../core/models/index';
import type { NoteItem } from '../../core/models/index';
import { useData } from '../data/DataProvider';

export default function KnowledgePage() {
  const { deleteNote, saveNote, notes } = useData();
  const [selectedNoteId, setSelectedNoteId] = useState<string | null>(
    notes[0]?.id ?? null,
  );
  const [searchQuery, setSearchQuery] = useState('');

  const selectedNote = useMemo(
    () => notes.find((note) => note.id === selectedNoteId),
    [notes, selectedNoteId],
  );

  const filteredNotes = useMemo(() => {
    return notes.filter(note => 
      note.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      note.content.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (note.tagsRaw?.toLowerCase() || '').includes(searchQuery.toLowerCase())
    );
  }, [notes, searchQuery]);

  async function handleCreateNote() {
    const note = createNoteItem({
      title: 'Untitled Note',
      content: '',
      tagsRaw: '',
    });
    await saveNote(note);
    setSelectedNoteId(note.id);
  }

  async function handleUpdateNote(updates: Partial<NoteItem>) {
    if (!selectedNote) return;
    await saveNote({ ...selectedNote, ...updates, updatedAt: new Date() });
  }

  return (
    <div className="flex h-[calc(100vh-var(--navbar-height)-4rem)] gap-8 animate-in fade-in duration-700">
      {/* Sidebar */}
      <aside className="flex w-80 flex-col gap-6">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <span className="flex h-2 w-2 rounded-full bg-[#AF52DE]" />
            <p className="text-xs font-bold uppercase tracking-[0.2em] text-[#AF52DE]/80">Archive</p>
          </div>
          <h2 className="font-display text-2xl font-bold tracking-tight text-gradient-apple">Knowledge Base</h2>
        </div>

        <div className="flex flex-col gap-4">
          <div className="relative group">
            <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground group-focus-within:text-[#AF52DE] transition-colors" />
            <Input 
              placeholder="Search insights..." 
              className="pl-9 h-10 border-white/10 bg-white/5 focus-visible:ring-[#AF52DE]/50"
              value={searchQuery}
              onChange={e => setSearchQuery(e.target.value)}
            />
          </div>
          
          <Button 
            onClick={handleCreateNote} 
            className="w-full h-11 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-white font-semibold flex items-center justify-center gap-2 transition-all group"
          >
            <Plus size={16} className="text-[#AF52DE] group-hover:scale-110 transition-transform" />
            Capture New Insight
          </Button>
        </div>

        <Separator className="bg-white/5" />

        <div className="flex-1 overflow-y-auto pr-2 space-y-2 custom-scrollbar">
          {filteredNotes.length > 0 ? (
            filteredNotes.map((note) => (
              <button
                key={note.id}
                onClick={() => setSelectedNoteId(note.id)}
                className={`group relative flex w-full flex-col gap-2 rounded-xl p-4 text-left transition-all hover:bg-white/[0.04] ${
                  selectedNoteId === note.id ? 'bg-white/[0.06] shadow-lg ring-1 ring-white/10' : ''
                }`}
              >
                {selectedNoteId === note.id && (
                  <div className="absolute left-0 top-4 bottom-4 w-1 rounded-r-full bg-[#AF52DE]" />
                )}
                <div className="flex items-start justify-between">
                  <h3 className={`text-sm font-bold tracking-tight line-clamp-1 ${selectedNoteId === note.id ? 'text-white' : 'text-zinc-400 group-hover:text-zinc-200'}`}>
                    {note.title || 'Untitled Note'}
                  </h3>
                  <ChevronRight size={14} className={`shrink-0 transition-transform ${selectedNoteId === note.id ? 'translate-x-0 opacity-100' : '-translate-x-2 opacity-0'}`} />
                </div>
                <p className="text-[11px] text-zinc-500 line-clamp-2 leading-relaxed font-medium">
                  {note.content.replace(/[#*`]/g, '').slice(0, 100) || 'No content yet...'}
                </p>
                <div className="flex items-center gap-3 pt-1">
                  <div className="flex items-center gap-1 text-[9px] font-bold uppercase tracking-tighter text-zinc-600">
                    <Clock size={10} />
                    {note.updatedAt.toLocaleDateString([], { month: 'short', day: 'numeric' })}
                  </div>
                  {note.tagsRaw && (
                    <div className="flex items-center gap-1 text-[9px] font-bold uppercase tracking-tighter text-[#AF52DE]/60">
                      <Hash size={10} />
                      {note.tagsRaw.split(',')[0]}
                    </div>
                  )}
                </div>
              </button>
            ))
          ) : (
            <div className="flex flex-col items-center justify-center py-20 text-center opacity-20">
               <BookOpen size={32} className="mb-4" />
               <p className="text-xs font-bold uppercase tracking-widest">Repository Empty</p>
            </div>
          )}
        </div>
      </aside>

      {/* Editor Area */}
      <main className="flex flex-1 flex-col min-w-0">
        {selectedNote ? (
          <Card className="glass flex flex-1 flex-col border-white/[0.05] overflow-hidden shadow-2xl">
            <CardHeader className="bg-white/[0.02] border-b border-white/[0.05] p-6">
              <div className="flex items-center justify-between gap-4">
                <div className="flex-1 min-w-0">
                  <input
                    className="w-full bg-transparent text-2xl font-bold tracking-tight focus:outline-none placeholder:opacity-20 text-gradient-apple"
                    value={selectedNote.title}
                    onChange={(e) => handleUpdateNote({ title: e.target.value })}
                    placeholder="Insight Title"
                  />
                  <div className="flex items-center gap-4 mt-3">
                    <div className="flex items-center gap-2 relative">
                      <Hash size={14} className="text-muted-foreground" />
                      <input
                        className="bg-transparent text-[10px] font-bold uppercase tracking-widest text-[#AF52DE] focus:outline-none placeholder:text-zinc-700"
                        value={selectedNote.tagsRaw || ''}
                        onChange={(e) => handleUpdateNote({ tagsRaw: e.target.value })}
                        placeholder="ADD TAGS..."
                      />
                    </div>
                    <Separator orientation="vertical" className="h-3 bg-white/10" />
                    <div className="flex items-center gap-1.5 text-[10px] font-medium text-muted-foreground uppercase tracking-tight">
                       <Clock size={12} />
                       Last indexed: {selectedNote.updatedAt.toLocaleString()}
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                   <Button variant="ghost" size="icon" className="h-9 w-9 rounded-xl hover:bg-white/5">
                     <Sparkles size={18} className="text-amber-400" />
                   </Button>
                   <Button 
                    variant="ghost" 
                    size="icon" 
                    className="h-9 w-9 rounded-xl text-rose-500/60 hover:text-rose-400 hover:bg-rose-500/10"
                    onClick={() => {
                      if (confirm('Verify: Permanently delete this insight?')) {
                        void deleteNote(selectedNote.id);
                        setSelectedNoteId(null);
                      }
                    }}
                    >
                     <Trash2 size={18} />
                   </Button>
                </div>
              </div>
            </CardHeader>
            <CardContent className="flex-1 overflow-y-auto p-0 custom-scrollbar bg-black/20">
              <div className="mx-auto max-w-4xl py-12 px-8">
                <Editor
                  content={selectedNote.content}
                  onChange={(content) => handleUpdateNote({ content })}
                />
              </div>
            </CardContent>
            <footer className="h-10 border-t border-white/[0.05] bg-white/[0.01] px-6 flex items-center justify-between">
              <div className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-zinc-600">
                <Command size={10} />
                <span>Slash for commands</span>
              </div>
              <div className="text-[10px] font-bold uppercase tracking-widest text-zinc-600">
                {selectedNote.content.split(/\s+/).filter(Boolean).length} Words
              </div>
            </footer>
          </Card>
        ) : (
          <div className="flex flex-1 flex-col items-center justify-center text-center opacity-30">
            <div className="h-20 w-20 rounded-3xl bg-white/5 flex items-center justify-center mb-6">
               <FileText size={40} className="text-[#AF52DE]" />
            </div>
            <h3 className="text-xl font-display font-bold text-white mb-2">No active selection</h3>
            <p className="text-sm max-w-xs leading-relaxed">
              Select an insight from the repository or capture a new one to begin.
            </p>
          </div>
        )}
      </main>
    </div>
  );
}
