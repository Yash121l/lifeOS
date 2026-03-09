import { lazy, Suspense } from 'react';
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { useAuth } from '../features/auth/AuthProvider';
import { useData } from '../features/data/DataProvider';

const AuthPage = lazy(() => import('../features/auth/AuthPage'));
const AppShell = lazy(() => import('../features/layout/AppShell'));
const DashboardPage = lazy(
  () => import('../features/dashboard/DashboardPage'),
);
const TasksPage = lazy(() => import('../features/tasks/TasksPage'));
const TimePage = lazy(() => import('../features/time/TimePage'));
const KnowledgePage = lazy(
  () => import('../features/knowledge/KnowledgePage'),
);
const FinancePage = lazy(() => import('../features/finance/FinancePage'));
const SettingsPage = lazy(
  () => import('../features/settings/SettingsPage'),
);

function SplashScreen() {
  return (
    <div className="splash-screen">
      <div className="splash-screen__panel panel panel--accent">
        <p className="eyebrow">LifeOS</p>
        <h1>Booting workspace</h1>
        <p className="text-subtle">
          Checking session and restoring local data cache.
        </p>
      </div>
    </div>
  );
}

export default function AppRouter() {
  const { isLoading, user } = useAuth();
  const { isLoading: isDataLoading } = useData();

  if (isLoading || (user && isDataLoading)) {
    return <SplashScreen />;
  }

  return (
    <BrowserRouter>
      <Suspense fallback={<SplashScreen />}>
        <Routes>
          <Route
            path="/auth"
            element={user ? <Navigate to="/dashboard" replace /> : <AuthPage />}
          />

          <Route
            path="/"
            element={user ? <AppShell /> : <Navigate to="/auth" replace />}
          >
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route path="dashboard" element={<DashboardPage />} />
            <Route path="tasks" element={<TasksPage />} />
            <Route path="time" element={<TimePage />} />
            <Route path="knowledge" element={<KnowledgePage />} />
            <Route path="finance" element={<FinancePage />} />
            <Route path="settings" element={<SettingsPage />} />
          </Route>

          <Route
            path="*"
            element={<Navigate to={user ? '/dashboard' : '/auth'} replace />}
          />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}
