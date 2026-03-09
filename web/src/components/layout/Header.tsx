import { Bell, Search } from 'lucide-react';

export default function Header() {
  return (
    <header className="app-header">
      <div className="header-search">
        <Search size={18} color="var(--text-tertiary)" />
        <input type="text" placeholder="Search LifeOS (⌘K)" />
      </div>

      <div className="header-actions">
        <button className="icon-btn">
          <Bell size={20} />
        </button>
        <div className="avatar"></div>
      </div>
    </header>
  );
}
