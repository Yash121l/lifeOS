import { lazy, Suspense } from 'react';
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { useAuth } from '../modules/auth/AuthProvider';
import { useData } from '../modules/data/DataProvider';

const AuthPage = lazy(() => import('../modules/auth/AuthPage'));
const AppShell = lazy(() => import('../modules/layout/AppShell'));
const DashboardPage = lazy(
  () => import('../modules/dashboard/DashboardPage'),
);
const TasksPage = lazy(() => import('../modules/tasks/TasksPage'));
const TimePage = lazy(() => import('../modules/time/TimePage'));
const KnowledgePage = lazy(
  () => import('../modules/knowledge/KnowledgePage'),
);
const FinancePage = lazy(() => import('../modules/finance/FinancePage'));
const SettingsPage = lazy(
  () => import('../modules/settings/SettingsPage'),
);

const LandingPage = lazy(() => import('../pages/public/LandingPage'));
const PrivacyPolicy = lazy(() => import('../pages/public/PrivacyPolicy'));
const TermsOfService = lazy(() => import('../pages/public/TermsOfService'));
const Support = lazy(() => import('../pages/public/Support'));

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
    <BrowserRouter basename={import.meta.env.BASE_URL}>
      <Suspense fallback={<SplashScreen />}>
        <Routes>
          <Route path="/" element={<LandingPage />} />
          <Route path="/privacy" element={<PrivacyPolicy />} />
          <Route path="/terms" element={<TermsOfService />} />
          <Route path="/support" element={<Support />} />

          <Route
            path="/auth"
            element={user ? <Navigate to="/app/dashboard" replace /> : <AuthPage />}
          />

          <Route
            path="/app"
            element={user ? <AppShell /> : <Navigate to="/auth" replace />}
          >
            <Route index element={<Navigate to="dashboard" replace />} />
            <Route path="dashboard" element={<DashboardPage />} />
            <Route path="tasks" element={<TasksPage />} />
            <Route path="time" element={<TimePage />} />
            <Route path="knowledge" element={<KnowledgePage />} />
            <Route path="finance" element={<FinancePage />} />
            <Route path="settings" element={<SettingsPage />} />
          </Route>

          <Route
            path="*"
            element={<Navigate to={user ? '/app/dashboard' : '/'} replace />}
          />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}
