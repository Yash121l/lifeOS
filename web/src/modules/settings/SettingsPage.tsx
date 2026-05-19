import { createProject } from '../../core/models/index';
import { formatSyncTime } from '../../core/utils/formatters';
import { useInstallPrompt } from '../../core/services/pwa';
import { useAuth } from '../auth/AuthProvider';
import { useData } from '../data/DataProvider';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { User, Shield, LayoutGrid, Globe, Zap, Database } from 'lucide-react';

export default function SettingsPage() {
  const { canInstall, promptToInstall } = useInstallPrompt();
  const { displayName, user } = useAuth();
  const { projects, saveProject, syncState } = useData();

  return (
    <div className="flex flex-col gap-6 md:gap-8 max-w-5xl mx-auto pb-12">
      <section className="flex flex-col gap-2">
        <p className="text-sm font-semibold uppercase tracking-widest text-[#FF9F0A]">Settings</p>
        <h2 className="font-display text-2xl font-semibold tracking-tight sm:text-3xl">Workspace configuration</h2>
        <p className="text-muted-foreground text-sm max-w-2xl">
          Profile details, sync visibility, install actions, and project setup.
        </p>
      </section>

      <div className="grid gap-6 md:grid-cols-2">
        {/* Account Section */}
        <Card className="bg-card/50 backdrop-blur-xl border-white/10 overflow-hidden">
          <CardHeader className="pb-4">
            <div className="flex items-center gap-2 text-primary mb-1">
              <User size={16} />
              <p className="text-xs font-semibold uppercase tracking-widest">Profile</p>
            </div>
            <CardTitle className="text-xl font-display">Account Details</CardTitle>
            <CardDescription>Manage your identity and synchronization status.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="flex items-center justify-between p-4 rounded-xl bg-white/5 border border-white/5">
              <div className="flex flex-col">
                <span className="text-sm font-medium">{displayName}</span>
                <span className="text-xs text-muted-foreground">{user?.email ?? 'No email available'}</span>
              </div>
              <Badge variant={syncState.isOnline ? "default" : "secondary"} className={syncState.isOnline ? "bg-emerald-500/10 text-emerald-500 border-emerald-500/20" : ""}>
                {syncState.isOnline ? <Zap size={10} className="mr-1" /> : null}
                {syncState.isOnline ? 'Online' : 'Offline'}
              </Badge>
            </div>

            <div className="space-y-4">
              <div className="flex items-center justify-between group">
                <div className="flex items-center gap-3">
                  <div className="p-2 rounded-lg bg-primary/10 text-primary">
                    <Database size={16} />
                  </div>
                  <div className="flex flex-col">
                    <span className="text-sm font-medium">Last sync</span>
                    <span className="text-xs text-muted-foreground">{formatSyncTime(syncState.lastSyncedAt)}</span>
                  </div>
                </div>
                <Badge variant="outline" className="text-[10px] uppercase border-white/10 bg-white/5">
                  {syncState.isFromCache ? 'Local Cache' : 'Cloud Server'}
                </Badge>
              </div>

              <div className="flex items-center justify-between group">
                <div className="flex items-center gap-3">
                  <div className="p-2 rounded-lg bg-primary/10 text-primary">
                    <Shield size={16} />
                  </div>
                  <div className="flex flex-col">
                    <span className="text-sm font-medium">Data Protection</span>
                    <span className="text-xs text-muted-foreground">End-to-end encrypted storage</span>
                  </div>
                </div>
                <div className="h-2 w-2 rounded-full bg-emerald-500 shadow-sm shadow-emerald-500/50" />
              </div>
            </div>

            <Separator className="bg-white/5" />

            {canInstall ? (
              <Button
                className="w-full h-11"
                onClick={() => void promptToInstall()}
              >
                Install LifeOS web app
              </Button>
            ) : (
              <p className="text-xs text-center text-muted-foreground italic px-4">
                Install prompt will appear automatically on supported browsers once PWA criteria are met.
              </p>
            )}
          </CardContent>
        </Card>

        {/* Projects Section */}
        <Card className="bg-card/50 backdrop-blur-xl border-white/10 overflow-hidden">
          <CardHeader className="pb-4">
            <div className="flex items-center justify-between items-start">
              <div>
                <div className="flex items-center gap-2 text-primary mb-1">
                  <LayoutGrid size={16} />
                  <p className="text-xs font-semibold uppercase tracking-widest">Projects</p>
                </div>
                <CardTitle className="text-xl font-display">Task Grouping</CardTitle>
                <CardDescription>Organize your workload into logical buckets.</CardDescription>
              </div>
              <Button
                variant="outline"
                size="sm"
                className="h-9 border-white/10 bg-white/5 hover:bg-white/10"
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
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {projects.length ? (
                projects.map((project) => (
                  <div key={project.id} className="flex items-center justify-between p-3 rounded-xl border border-white/5 bg-white/[0.02] transition-colors hover:bg-white/[0.04]">
                    <div className="flex items-center gap-3">
                      <div className="h-2 w-2 rounded-full" style={{ backgroundColor: `#${project.colorHex}` }} />
                      <div className="flex flex-col">
                        <span className="text-sm font-medium">{project.name}</span>
                        <span className="text-xs text-muted-foreground">{project.taskIds.length} linked tasks</span>
                      </div>
                    </div>
                    <code className="text-[10px] text-muted-foreground font-mono bg-white/5 px-1.5 py-0.5 rounded uppercase tracking-tighter">
                      #{project.colorHex}
                    </code>
                  </div>
                ))
              ) : (
                <div className="flex flex-col items-center justify-center py-12 px-4 text-center border border-dashed border-white/10 rounded-xl">
                  <p className="text-sm text-muted-foreground mb-1">No projects yet</p>
                  <p className="text-xs text-muted-foreground/60">Add one to organize task views and priorities.</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

