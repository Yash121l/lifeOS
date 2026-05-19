import {
  Menu,
  PanelLeftClose,
  Sparkles,
  LayoutDashboard,
  CheckSquare,
  Calendar,
  Book,
  Wallet,
  Settings,
  Plus,
} from 'lucide-react';
import { useState } from 'react';
import { NavLink, Outlet, useLocation } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { useInstallPrompt } from '@/core/services/pwa';
import { formatSyncTime } from '@/core/utils/formatters';
import { useAuth } from '../auth/AuthProvider';
import { useData } from '../data/DataProvider';

const navItems = [
  { label: 'Dashboard', path: '/dashboard', icon: LayoutDashboard },
  { label: 'Tasks', path: '/tasks', icon: CheckSquare },
  { label: 'Time', path: '/time', icon: Calendar },
  { label: 'Knowledge', path: '/knowledge', icon: Book },
  { label: 'Finance', path: '/finance', icon: Wallet },
  { label: 'Settings', path: '/settings', icon: Settings },
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
    <div className="grid min-h-screen xl:grid-cols-[18rem_minmax(0,1fr)] bg-background text-foreground">
      <aside
        className={`fixed inset-y-0 left-0 z-10 flex w-[85vw] max-w-[18rem] -translate-x-full flex-col gap-6 border-r border-white/10 bg-black/50 p-5 backdrop-blur-xl transition-transform xl:static xl:w-auto xl:max-w-none xl:translate-x-0 ${
          isMobileNavOpen ? 'translate-x-0' : ''
        }`}
      >
        <div className="flex items-center gap-3">
          <span className="flex h-11 w-11 items-center justify-center rounded-2xl border border-sky-300/20 bg-gradient-to-br from-sky-400/30 to-orange-500/30 shadow-[0_16px_35px_rgba(14,165,233,0.2)]">
            <Sparkles size={18} />
          </span>
          <div>
            <strong className="font-display tracking-tight">LifeOS</strong>
            <span className="block text-sm text-muted-foreground">
              Web workspace
            </span>
          </div>
        </div>

        <nav className="grid gap-4">
          {navItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              onClick={() => setIsMobileNavOpen(false)}
              className={({ isActive }) =>
                `flex items-center gap-3 rounded-2xl border border-transparent px-4 py-3 text-muted-foreground transition-all hover:bg-white/10 hover:text-foreground ${
                  isActive ? 'bg-white/10 text-foreground' : ''
                }`
              }
            >
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>

        <div className="mt-auto">
          <div className="flex items-center gap-3 rounded-[1.1rem] border border-white/10 bg-white/5 p-3">
            <span className="flex h-10 w-10 items-center justify-center rounded-full bg-gradient-to-br from-sky-400/90 to-orange-500/90 text-sm font-medium">
              {initials}
            </span>
            <div>
              <strong className="block text-sm">{displayName}</strong>
              <span className="block text-xs text-muted-foreground">
                {syncState.isOnline ? 'Online' : 'Offline mode'}
              </span>
            </div>
          </div>
        </div>
      </aside>

      <div className="flex min-w-0 flex-col pb-20 xl:pb-0">
        <header className="sticky top-0 z-30 flex flex-col items-start gap-4 border-b border-white/10 bg-black/65 px-4 py-4 backdrop-blur-xl sm:flex-row sm:items-center sm:justify-between sm:px-6">
          <div className="flex items-center gap-4">
            <Button
              variant="ghost"
              size="icon"
              className="xl:hidden"
              onClick={() => setIsMobileNavOpen((open) => !open)}
            >
              {isMobileNavOpen ? <PanelLeftClose size={18} /> : <Menu size={18} />}
            </Button>
            <div>
              <p className="m-0 text-xs font-semibold uppercase tracking-widest text-[#0A84FF]">
                LifeOS workspace
              </p>
              <h1 className="m-0 mt-1 font-display text-2xl tracking-tight sm:text-3xl">
                {routeTitles[location.pathname] ?? 'Workspace'}
              </h1>
            </div>
          </div>

          <div className="flex flex-wrap items-center justify-end gap-3">
            <span
              className={`inline-flex items-center gap-1.5 rounded-full border border-white/10 bg-white/5 px-3 py-1.5 text-xs text-muted-foreground ${
                syncState.isOnline ? 'bg-emerald-400/10 text-emerald-300' : 'bg-rose-400/10 text-rose-300'
              }`}
            >
              {syncState.isOnline ? 'Connected' : 'Offline'}
            </span>
            <span className="inline-flex items-center gap-1.5 rounded-full border border-white/10 bg-white/5 px-3 py-1.5 text-xs text-muted-foreground">
              {syncState.hasPendingWrites
                ? 'Queued changes'
                : formatSyncTime(syncState.lastSyncedAt)}
            </span>
            {canInstall ? (
              <Button
                variant="secondary"
                className="rounded-full"
                onClick={() => void promptToInstall()}
              >
                Install app
              </Button>
            ) : null}
            <button
              className="ml-auto flex h-11 w-11 items-center justify-center rounded-full bg-gradient-to-br from-[#0A84FF] to-[#007AFF] text-white shadow-[0_4px_12px_rgba(10,132,255,0.25)] transition-transform hover:scale-105"
              type="button"
              aria-label="Quick capture"
            >
              <Plus size={20} strokeWidth={3} />
            </button>
            <Button
              variant="ghost"
              className="rounded-full"
              onClick={() => void signOutUser()}
            >
              Sign out
            </Button>
          </div>
        </header>

        {!syncState.isOnline ? (
          <div className="mx-6 border-l-4 border-amber-500 bg-amber-500/10 px-4 py-3 text-amber-100">
            You are offline. Firestore persistence will keep edits queued locally.
          </div>
        ) : null}

        {syncState.hasPendingWrites ? (
          <div className="mx-6 border-l-4 border-sky-500 bg-sky-500/10 px-4 py-3 text-sky-100">
            Syncing queued changes to the cloud.
          </div>
        ) : null}

        <main className="flex min-w-0 flex-1 flex-col overflow-auto p-4 sm:p-6">
          <Outlet />
        </main>
      </div>

      <nav className="fixed bottom-0 left-0 right-0 z-40 flex items-center justify-around border-t border-white/10 bg-black/75 px-4 pb-6 pt-2 backdrop-blur-xl xl:hidden">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              `flex flex-col items-center gap-1 p-2 transition-colors ${
                isActive ? 'text-[#0A84FF]' : 'text-muted-foreground'
              }`
            }
          >
            {({ isActive }) => (
              <>
                <item.icon size={22} strokeWidth={isActive ? 2.5 : 2} />
                <span className="text-[0.65rem] font-medium">{item.label}</span>
              </>
            )}
          </NavLink>
        ))}
        <button
          className="z-50 -mt-6 flex h-14 w-14 items-center justify-center rounded-full bg-gradient-to-br from-[#0A84FF] to-[#007AFF] text-white shadow-[0_8px_16px_rgba(10,132,255,0.3)]"
          type="button"
          aria-label="Quick capture"
        >
          <Plus size={24} strokeWidth={3} />
        </button>
      </nav>
    </div>
  );
}
