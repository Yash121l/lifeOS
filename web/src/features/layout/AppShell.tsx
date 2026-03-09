import { Menu, PanelLeftClose, Sparkles } from 'lucide-react';
import { useState } from 'react';
import { NavLink, Outlet, useLocation } from 'react-router-dom';
import { formatSyncTime } from '../../lib/formatters';
import { useInstallPrompt } from '../../lib/pwa';
import { useAuth } from '../auth/AuthProvider';
import { useData } from '../data/DataProvider';

const navItems = [
  { label: 'Dashboard', path: '/dashboard' },
  { label: 'Tasks', path: '/tasks' },
  { label: 'Time', path: '/time' },
  { label: 'Knowledge', path: '/knowledge' },
  { label: 'Finance', path: '/finance' },
  { label: 'Settings', path: '/settings' },
];

const routeTitles: Record<string, string> = {
  '/dashboard': 'Overview',
  '/tasks': 'Task system',
  '/time': 'Calendar and focus blocks',
  '/knowledge': 'Notes and documents',
  '/finance': 'Cash flow and budgets',
  '/settings': 'Workspace settings',
};

export default function AppShell() {
  const location = useLocation();
  const { displayName, initials, signOutUser } = useAuth();
  const { canInstall, promptToInstall } = useInstallPrompt();
  const { syncState } = useData();
  const [isMobileNavOpen, setIsMobileNavOpen] = useState(false);

  return (
    <div className="app-shell">
      <aside className={`sidebar ${isMobileNavOpen ? 'sidebar--open' : ''}`}>
        <div className="sidebar__brand">
          <span className="brand-mark">
            <Sparkles size={18} />
          </span>
          <div>
            <strong>LifeOS</strong>
            <span>Web workspace</span>
          </div>
        </div>

        <nav className="sidebar__nav">
          {navItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              onClick={() => setIsMobileNavOpen(false)}
              className={({ isActive }) =>
                `nav-link ${isActive ? 'nav-link--active' : ''}`
              }
            >
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>

        <div className="sidebar__footer">
          <div className="profile-chip">
            <span>{initials}</span>
            <div>
              <strong>{displayName}</strong>
              <small>{syncState.isOnline ? 'Online' : 'Offline mode'}</small>
            </div>
          </div>
        </div>
      </aside>

      <div className="app-shell__content">
        <header className="topbar">
          <div className="topbar__title">
            <button
              className="button button--icon button--ghost topbar__menu"
              type="button"
              onClick={() => setIsMobileNavOpen((open) => !open)}
            >
              {isMobileNavOpen ? <PanelLeftClose size={18} /> : <Menu size={18} />}
            </button>
            <div>
              <p className="eyebrow">LifeOS workspace</p>
              <h1>{routeTitles[location.pathname] ?? 'Workspace'}</h1>
            </div>
          </div>

          <div className="topbar__actions">
            <span
              className={`status-pill ${
                syncState.isOnline ? 'status-pill--online' : 'status-pill--offline'
              }`}
            >
              {syncState.isOnline ? 'Connected' : 'Offline'}
            </span>
            <span className="status-pill">
              {syncState.hasPendingWrites
                ? 'Queued changes'
                : formatSyncTime(syncState.lastSyncedAt)}
            </span>
            {canInstall ? (
              <button
                className="button button--secondary"
                type="button"
                onClick={() => void promptToInstall()}
              >
                Install app
              </button>
            ) : null}
            <button
              className="button button--ghost"
              type="button"
              onClick={() => void signOutUser()}
            >
              Sign out
            </button>
          </div>
        </header>

        {!syncState.isOnline ? (
          <div className="banner banner--warning">
            You are offline. Firestore persistence will keep edits queued locally.
          </div>
        ) : null}

        {syncState.hasPendingWrites ? (
          <div className="banner banner--info">
            Syncing queued changes to the cloud.
          </div>
        ) : null}

        <main className="workspace">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
