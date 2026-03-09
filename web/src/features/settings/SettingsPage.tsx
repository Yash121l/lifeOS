import { createProject } from '../../lib/models';
import { formatSyncTime } from '../../lib/formatters';
import { useInstallPrompt } from '../../lib/pwa';
import { useAuth } from '../auth/AuthProvider';
import { useData } from '../data/DataProvider';

export default function SettingsPage() {
  const { canInstall, promptToInstall } = useInstallPrompt();
  const { displayName, user } = useAuth();
  const { projects, saveProject, syncState } = useData();

  return (
    <div className="page-stack">
      <section className="page-header">
        <div>
          <p className="eyebrow">Settings</p>
          <h2>Workspace configuration</h2>
          <p className="text-subtle">
            Profile details, sync visibility, install actions, and project
            setup.
          </p>
        </div>
      </section>

      <div className="content-grid">
        <section className="panel">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Profile</p>
              <h3>Account</h3>
            </div>
          </div>
          <div className="stack">
            <div className="list-row">
              <div>
                <strong>{displayName}</strong>
                <small>{user?.email ?? 'No email available'}</small>
              </div>
              <span className="status-pill">
                {syncState.isOnline ? 'Online' : 'Offline'}
              </span>
            </div>
            <div className="list-row">
              <div>
                <strong>Last sync</strong>
                <small>{formatSyncTime(syncState.lastSyncedAt)}</small>
              </div>
              <span className="status-pill">
                {syncState.isFromCache ? 'Cache' : 'Server'}
              </span>
            </div>
            {canInstall ? (
              <button
                className="button button--primary"
                type="button"
                onClick={() => void promptToInstall()}
              >
                Install LifeOS web app
              </button>
            ) : (
              <p className="empty-copy">
                Install prompt will appear automatically on supported browsers
                once the PWA criteria are met.
              </p>
            )}
          </div>
        </section>

        <section className="panel">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Projects</p>
              <h3>Task grouping</h3>
            </div>
            <button
              className="button button--secondary"
              type="button"
              onClick={() =>
                void saveProject(
                  createProject({
                    name: `Project ${projects.length + 1}`,
                    colorHex: '0F766E',
                  }),
                )
              }
            >
              Add project
            </button>
          </div>
          <div className="list-stack">
            {projects.length ? (
              projects.map((project) => (
                <div key={project.id} className="list-row">
                  <div>
                    <strong>{project.name}</strong>
                    <small>{project.taskIds.length} linked tasks</small>
                  </div>
                  <span className="status-pill">#{project.colorHex}</span>
                </div>
              ))
            ) : (
              <p className="empty-copy">
                No projects yet. Add one to organize task views.
              </p>
            )}
          </div>
        </section>
      </div>
    </div>
  );
}
