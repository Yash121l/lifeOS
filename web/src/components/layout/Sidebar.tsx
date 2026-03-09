import { NavLink } from 'react-router-dom';
import { LayoutDashboard, CheckSquare, Calendar, Wallet, FileText, Settings, Sparkles } from 'lucide-react';
import clsx from 'clsx';

export default function Sidebar() {
  const navItems = [
    { name: 'Dashboard', path: '/dashboard', icon: LayoutDashboard },
    { name: 'Tasks', path: '/tasks', icon: CheckSquare },
    { name: 'Time', path: '/time', icon: Calendar },
    { name: 'Finance', path: '/finance', icon: Wallet },
    { name: 'Knowledge', path: '/knowledge', icon: FileText },
  ];

  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <div className="brand text-gradient">
          <Sparkles size={20} className="text-accent-primary" color="var(--accent-primary)" />
          <span>LifeOS</span>
        </div>
      </div>
      
      <nav className="sidebar-nav">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink 
              key={item.path} 
              to={item.path}
              className={({ isActive }) => clsx('nav-item', isActive && 'active')}
            >
              <Icon size={18} />
              <span>{item.name}</span>
            </NavLink>
          );
        })}
      </nav>

      <div className="sidebar-footer">
        <NavLink to="/settings" className={({ isActive }) => clsx('nav-item', isActive && 'active')}>
          <Settings size={18} />
          <span>Settings</span>
        </NavLink>
      </div>
    </aside>
  );
}
