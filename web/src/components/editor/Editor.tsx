import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Placeholder from '@tiptap/extension-placeholder';
import TaskList from '@tiptap/extension-task-list';
import TaskItem from '@tiptap/extension-task-item';
import { useState, useCallback } from 'react';
import { Type, List, CheckSquare, ListOrdered, Quote } from 'lucide-react';
import './Editor.css';

interface SlashCommandMenuProps {
  x: number;
  y: number;
  onSelect: (command: string) => void;
  close: () => void;
}

function SlashCommandMenu({ x, y, onSelect }: SlashCommandMenuProps) {
  const commands = [
    { id: 'h1', label: 'Heading 1', icon: Type, description: 'Big section heading.' },
    { id: 'h2', label: 'Heading 2', icon: Type, description: 'Medium section heading.' },
    { id: 'h3', label: 'Heading 3', icon: Type, description: 'Small section heading.' },
    { id: 'bulletList', label: 'Bulleted List', icon: List, description: 'Create a simple bulleted list.' },
    { id: 'orderedList', label: 'Numbered List', icon: ListOrdered, description: 'Create a list with numbering.' },
    { id: 'taskList', label: 'To-do List', icon: CheckSquare, description: 'Track tasks with a to-do list.' },
    { id: 'blockquote', label: 'Quote', icon: Quote, description: 'Capture a quote.' },
  ];

  return (
    <div className="slash-menu glass-card" style={{ top: y, left: x }}>
      <div className="slash-menu-header text-xs text-tertiary px-3 py-2 font-semibold uppercase">Basic blocks</div>
      {commands.map((cmd) => (
        <button key={cmd.id} className="slash-menu-item" onClick={() => onSelect(cmd.id)}>
          <div className="slash-icon bg-secondary">
            <cmd.icon size={18} />
          </div>
          <div className="slash-text">
            <span className="font-medium text-sm text-primary">{cmd.label}</span>
            <span className="text-xs text-secondary">{cmd.description}</span>
          </div>
        </button>
      ))}
    </div>
  );
}

export default function Editor({ initialContent = '' }: { initialContent?: string }) {
  const [slashMenu, setSlashMenu] = useState<{ x: number; y: number } | null>(null);

  const editor = useEditor({
    extensions: [
      StarterKit.configure({
        heading: { levels: [1, 2, 3] },
      }),
      Placeholder.configure({
        placeholder: ({ node }) => {
          if (node.type.name === 'heading') {
            return 'Heading';
          }
          return 'Type \'/\' for commands';
        },
      }),
      TaskList,
      TaskItem.configure({ nested: true }),
    ],
    content: initialContent,
    onUpdate: ({ editor }) => {
      // Basic check for slash command
      const { state, view } = editor;
      const { selection } = state;
      const { $head } = selection;
      const lineText = $head.parent.textContent;

      if (lineText.endsWith('/')) {
        const coords = view.coordsAtPos($head.pos);
        // Position menu below the slash
        setSlashMenu({ x: coords.left, y: coords.bottom + window.scrollY + 10 });
      } else {
        setSlashMenu(null);
      }
    },
    editorProps: {
      attributes: {
        class: 'prose prose-invert focus:outline-none max-w-none min-h-[500px]',
      },
    },
  });

  const handleCommandSelect = useCallback((commandId: string) => {
    if (!editor) return;

    // Delete the slash
    editor.chain().focus().deleteRange({ from: editor.state.selection.from - 1, to: editor.state.selection.from }).run();

    // Execute command
    switch (commandId) {
      case 'h1': editor.chain().focus().toggleHeading({ level: 1 }).run(); break;
      case 'h2': editor.chain().focus().toggleHeading({ level: 2 }).run(); break;
      case 'h3': editor.chain().focus().toggleHeading({ level: 3 }).run(); break;
      case 'bulletList': editor.chain().focus().toggleBulletList().run(); break;
      case 'orderedList': editor.chain().focus().toggleOrderedList().run(); break;
      case 'taskList': editor.chain().focus().toggleTaskList().run(); break;
      case 'blockquote': editor.chain().focus().toggleBlockquote().run(); break;
    }
    setSlashMenu(null);
  }, [editor]);

  // Global keydown handler to close menu on Escape
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape' && slashMenu) {
      setSlashMenu(null);
    }
    // Very naive up/down selection logic could go here, omitting for brevity
  };

  if (!editor) {
    return null;
  }

  return (
    <div className="editor-container" onKeyDown={handleKeyDown}>
      <EditorContent editor={editor} />
      {slashMenu && (
        <SlashCommandMenu
          x={slashMenu.x}
          y={slashMenu.y}
          onSelect={handleCommandSelect}
          close={() => setSlashMenu(null)}
        />
      )}
    </div>
  );
}
