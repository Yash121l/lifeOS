import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Placeholder from '@tiptap/extension-placeholder';
import TaskList from '@tiptap/extension-task-list';
import TaskItem from '@tiptap/extension-task-item';
import { useEffect, useState } from 'react';
import { CheckSquare, List, ListOrdered, Quote, Type } from 'lucide-react';
import './Editor.css';

interface SlashCommandMenuProps {
  x: number;
  y: number;
  onSelect: (command: string) => void;
}

function SlashCommandMenu({
  x,
  y,
  onSelect,
}: SlashCommandMenuProps) {
  const commands = [
    {
      id: 'h1',
      label: 'Heading 1',
      icon: Type,
      description: 'Big section heading.',
    },
    {
      id: 'h2',
      label: 'Heading 2',
      icon: Type,
      description: 'Medium section heading.',
    },
    {
      id: 'h3',
      label: 'Heading 3',
      icon: Type,
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
  ];

  return (
    <div className="slash-menu panel" style={{ top: y, left: x }}>
      <div className="slash-menu__header">Basic blocks</div>
      {commands.map((command) => (
        <button
          key={command.id}
          className="slash-menu__item"
          onClick={() => onSelect(command.id)}
          type="button"
        >
          <span className="slash-menu__icon">
            <command.icon size={16} />
          </span>
          <span>
            <strong>{command.label}</strong>
            <small>{command.description}</small>
          </span>
        </button>
      ))}
    </div>
  );
}

interface EditorProps {
  value: string;
  onChange: (value: string) => void;
}

export default function Editor({ onChange, value }: EditorProps) {
  const [slashMenu, setSlashMenu] = useState<{ x: number; y: number } | null>(
    null,
  );

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
          return "Type '/' for commands";
        },
      }),
      TaskList,
      TaskItem.configure({ nested: true }),
    ],
    content: value,
    onUpdate: ({ editor: currentEditor }) => {
      onChange(currentEditor.getHTML());

      const { selection } = currentEditor.state;
      const lineText = selection.$head.parent.textContent;

      if (!lineText.endsWith('/')) {
        setSlashMenu(null);
        return;
      }

      const coordinates = currentEditor.view.coordsAtPos(selection.$head.pos);
      setSlashMenu({
        x: coordinates.left,
        y: coordinates.bottom + window.scrollY + 8,
      });
    },
    editorProps: {
      attributes: {
        class: 'editor-prose',
      },
    },
  });

  useEffect(() => {
    if (!editor) return;
    if (editor.getHTML() === value) return;
    editor.commands.setContent(value, { emitUpdate: false });
  }, [editor, value]);

  if (!editor) return null;

  function handleCommandSelect(commandId: string) {
    editor
      .chain()
      .focus()
      .deleteRange({
        from: editor.state.selection.from - 1,
        to: editor.state.selection.from,
      })
      .run();

    switch (commandId) {
      case 'h1':
        editor.chain().focus().toggleHeading({ level: 1 }).run();
        break;
      case 'h2':
        editor.chain().focus().toggleHeading({ level: 2 }).run();
        break;
      case 'h3':
        editor.chain().focus().toggleHeading({ level: 3 }).run();
        break;
      case 'bulletList':
        editor.chain().focus().toggleBulletList().run();
        break;
      case 'orderedList':
        editor.chain().focus().toggleOrderedList().run();
        break;
      case 'taskList':
        editor.chain().focus().toggleTaskList().run();
        break;
      case 'blockquote':
        editor.chain().focus().toggleBlockquote().run();
        break;
      default:
        break;
    }

    setSlashMenu(null);
  }

  return (
    <div className="editor-shell">
      <EditorContent editor={editor} />
      {slashMenu ? (
        <SlashCommandMenu
          x={slashMenu.x}
          y={slashMenu.y}
          onSelect={handleCommandSelect}
        />
      ) : null}
    </div>
  );
}
