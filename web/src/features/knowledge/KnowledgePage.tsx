import { useEffect, useMemo, useState } from 'react';
import { createNoteItem } from '../../lib/models';
import Editor from '../../shared/editor/Editor';
import type { NoteItem } from '../../lib/models';
import { useData } from '../data/DataProvider';

function NoteEditorPane({
  note,
  onDelete,
  onSave,
}: {
  note: NoteItem;
  onDelete: (noteId: string) => Promise<void>;
  onSave: (note: NoteItem) => Promise<void>;
}) {
  const [draftTitle, setDraftTitle] = useState(note.title);
  const [draftContent, setDraftContent] = useState(note.content);
  const [draftTags, setDraftTags] = useState(note.tagsRaw);

  useEffect(() => {
    const timeout = window.setTimeout(() => {
      const hasChanges =
        note.title !== draftTitle ||
        note.content !== draftContent ||
        note.tagsRaw !== draftTags;

      if (!hasChanges) return;

      void onSave({
        ...note,
        title: draftTitle.trim() || 'Untitled note',
        content: draftContent,
        tagsRaw: draftTags,
      });
    }, 700);

    return () => {
      window.clearTimeout(timeout);
    };
  });

  return (
    <>
      <div className="form-grid">
        <label className="field">
          <span>Title</span>
          <input
            value={draftTitle}
            onChange={(event) => setDraftTitle(event.target.value)}
            placeholder="Untitled note"
          />
        </label>

        <label className="field">
          <span>Tags</span>
          <input
            value={draftTags}
            onChange={(event) => setDraftTags(event.target.value)}
            placeholder="product, roadmap, weekly review"
          />
        </label>
      </div>

      <Editor value={draftContent} onChange={setDraftContent} />

      <div className="inline-actions">
        <span className="status-pill">Autosaves every 700ms</span>
        <button
          className="button button--ghost"
          type="button"
          onClick={() => void onDelete(note.id)}
        >
          Delete note
        </button>
      </div>
    </>
  );
}

export default function KnowledgePage() {
  const { deleteNote, notes, saveNote } = useData();
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const sortedNotes = useMemo(
    () =>
      [...notes].sort((left, right) => {
        if (left.isPinned !== right.isPinned) {
          return left.isPinned ? -1 : 1;
        }
        return right.updatedAt.getTime() - left.updatedAt.getTime();
      }),
    [notes],
  );

  const selectedNote =
    sortedNotes.find((note) => note.id === selectedId) ?? sortedNotes[0] ?? null;

  async function handleCreateNote() {
    const note = createNoteItem();
    await saveNote(note);
    setSelectedId(note.id);
  }

  return (
    <div className="page-stack">
      <section className="page-header">
        <div>
          <p className="eyebrow">Knowledge</p>
          <h2>Connected note system</h2>
          <p className="text-subtle">
            TipTap editing, autosave, and synced notes with offline cache.
          </p>
        </div>

        <button
          className="button button--primary"
          type="button"
          onClick={() => void handleCreateNote()}
        >
          New note
        </button>
      </section>

      <div className="notes-layout">
        <aside className="panel notes-sidebar">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Library</p>
              <h3>{notes.length} notes</h3>
            </div>
          </div>

          <div className="stack">
            {sortedNotes.length ? (
              sortedNotes.map((note) => (
                <button
                  key={note.id}
                  className={`note-card ${selectedNote?.id === note.id ? 'note-card--active' : ''}`}
                  type="button"
                  onClick={() => setSelectedId(note.id)}
                >
                  <strong>{note.title}</strong>
                  <small>{note.tagsRaw || 'General'}</small>
                  <span>{note.updatedAt.toLocaleDateString()}</span>
                </button>
              ))
            ) : (
              <p className="empty-copy">
                Create your first note to start building the knowledge base.
              </p>
            )}
          </div>
        </aside>

        <section className="panel notes-editor">
          {selectedNote ? (
            <NoteEditorPane
              key={selectedNote.id}
              note={selectedNote}
              onDelete={deleteNote}
              onSave={saveNote}
            />
          ) : (
            <p className="empty-copy">No note selected.</p>
          )}
        </section>
      </div>
    </div>
  );
}
