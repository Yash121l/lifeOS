import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Placeholder from '@tiptap/extension-placeholder';
import TaskList from '@tiptap/extension-task-list';
import TaskItem from '@tiptap/extension-task-item';
import CodeBlockLowlight from '@tiptap/extension-code-block-lowlight';
import { common, createLowlight } from 'lowlight';
import { useEffect, useState, useRef } from 'react';
import {
  CheckSquare,
  List,
  ListOrdered,
  Quote,
  Type,
  Heading1,
  Heading2,
  Heading3,
  Code,
  Minus,
  Search
} from 'lucide-react';
import './Editor.css';

const lowlight = createLowlight(common);

interface SlashCommandMenuProps {
  x: number;
  y: number;
  onSelect: (command: string) => void;
  onClose: () => void;
}

function SlashCommandMenu({
  x,
  y,
  onSelect,
  onClose,
}: SlashCommandMenuProps) {
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [query, setQuery] = useState('');

  const commands = [
    {
      id: 'h1',
      label: 'Heading 1',
      icon: Heading1,
      description: 'Big section heading.',
    },
    {
      id: 'h2',
      label: 'Heading 2',
      icon: Heading2,
      description: 'Medium section heading.',
    },
    {
      id: 'h3',
      label: 'Heading 3',
      icon: Heading3,
      description: 'Small section heading.',
    },
    {
      id: 'bulletList',
      label: 'Bulleted List',
      icon: List,
      description: 'Create a simple bulleted list.',
    },
    {
      id: 'orderedList',
      label: 'Numbered List',
      icon: ListOrdered,
      description: 'Create a list with numbering.',
    },
    {
      id: 'taskList',
      label: 'To-do List',
      icon: CheckSquare,
      description: 'Track tasks with a to-do list.',
    },
    {
      id: 'blockquote',
      label: 'Quote',
      icon: Quote,
      description: 'Capture a quote.',
    },
    {
      id: 'codeBlock',
      label: 'Code Block',
      icon: Code,
      description: 'Add a code snippet.',
    },
    {
      id: 'horizontalRule',
      label: 'Divider',
      icon: Minus,
      description: 'Visually separate sections.',
    },
  ];

  const filteredCommands = commands.filter(c =>
    c.label.toLowerCase().includes(query.toLowerCase())
  );

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        setSelectedIndex((prev) => (prev + 1) % filteredCommands.length);
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        setSelectedIndex((prev) => (prev - 1 + filteredCommands.length) % filteredCommands.length);
      } else if (e.key === 'Enter') {
        e.preventDefault();
        if (filteredCommands[selectedIndex]) {
          onSelect(filteredCommands[selectedIndex].id);
        }
      } else if (e.key === 'Escape') {
        onClose();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [filteredCommands, selectedIndex, onSelect, onClose]);

  return (
    <div className="slash-menu" style={{ top: y, left: x }}>
      <div className="flex items-center gap-2 px-3 py-2 border-b border-white/5 bg-white/5">
        <Search size={14} className="text-muted-foreground" />
        <input
          autoFocus
          className="bg-transparent border-none outline-none text-sm w-full"
          placeholder="Search commands..."
          value={query}
          onChange={e => {
            setQuery(e.target.value);
            setSelectedIndex(0);
          }}
        />
      </div>
      <div className="slash-menu__header">Basic blocks</div>
      <div className="overflow-y-auto">
        {filteredCommands.map((command, index) => (
          <button
            key={command.id}
            className={`slash-menu__item ${index === selectedIndex ? 'is-selected' : ''}`}
            onClick={() => onSelect(command.id)}
            type="button"
          >
            <div className="slash-menu__icon">
              <command.icon size={16} />
            </div>
            <div className="slash-menu__content">
              <span className="slash-menu__label">{command.label}</span>
              <span className="slash-menu__description">{command.description}</span>
            </div>
          </button>
        ))}
        {filteredCommands.length === 0 && (
          <div className="px-3 py-4 text-xs text-center text-muted-foreground">
            No matching blocks.
          </div>
        )}
      </div>
    </div>
  );
}

interface EditorProps {
  content: string;
  onChange: (content: string) => void;
}

export default function Editor({ onChange, content }: EditorProps) {
  const [slashMenu, setSlashMenu] = useState<{ x: number; y: number } | null>(
    null,
  );

  const editor = useEditor({
    extensions: [
      StarterKit.configure({
        heading: { levels: [1, 2, 3] },
        codeBlock: false, // Disable default to use lowlight
      }),
      CodeBlockLowlight.configure({
        lowlight,
      }),
      Placeholder.configure({
        placeholder: ({ node }) => {
          if (node.type.name === 'heading') {
            return `Header ${node.attrs.level}`;
          }
          return "Type '/' for commands...";
        },
      }),
      TaskList,
      TaskItem.configure({ nested: true }),
    ],
    content: content,
    onUpdate: ({ editor: currentEditor }) => {
      onChange(currentEditor.getHTML());

      const { selection } = currentEditor.state;
      const { $head } = selection;
      const lineText = $head.parent.textContent;
      const textAfterSlash = lineText.slice($head.parentOffset - 1, $head.parentOffset);

      if (textAfterSlash === '/') {
        const coordinates = currentEditor.view.coordsAtPos($head.pos);
        setSlashMenu({
          x: coordinates.left,
          y: coordinates.bottom + window.scrollY + 8,
        });
      } else {
        setSlashMenu(null);
      }
    },
    editorProps: {
      attributes: {
        class: 'editor-prose',
      },
      handleKeyDown: (view, event) => {
        if (event.key === ' ' && slashMenu) {
          setSlashMenu(null);
        }
        return false;
      }
    },
  });

  useEffect(() => {
    if (!editor) return;
    if (editor.getHTML() === content) return;
    editor.commands.setContent(content, { emitUpdate: false });
  }, [editor, content]);

  if (!editor) return null;

  function handleCommandSelect(commandId: string) {
    const { selection } = editor.state;
    const { $head } = selection;
    
    // Delete the slash correctly
    editor.chain().focus()
      .deleteRange({
        from: $head.pos - 1,
        to: $head.pos,
      })
      .run();

    switch (commandId) {
      case 'h1': editor.chain().focus().toggleHeading({ level: 1 }).run(); break;
      case 'h2': editor.chain().focus().toggleHeading({ level: 2 }).run(); break;
      case 'h3': editor.chain().focus().toggleHeading({ level: 3 }).run(); break;
      case 'bulletList': editor.chain().focus().toggleBulletList().run(); break;
      case 'orderedList': editor.chain().focus().toggleOrderedList().run(); break;
      case 'taskList': editor.chain().focus().toggleTaskList().run(); break;
      case 'blockquote': editor.chain().focus().toggleBlockquote().run(); break;
      case 'codeBlock': editor.chain().focus().toggleCodeBlock().run(); break;
      case 'horizontalRule': editor.chain().focus().setHorizontalRule().run(); break;
    }

    setSlashMenu(null);
  }

  return (
    <div className="editor-shell p-4 sm:p-8">
      <EditorContent editor={editor} />
      {slashMenu && (
        <SlashCommandMenu
          x={slashMenu.x}
          y={slashMenu.y}
          onSelect={handleCommandSelect}
          onClose={() => setSlashMenu(null)}
        />
      )}
    </div>
  );
}
