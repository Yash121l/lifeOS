import { useMemo, useState } from 'react';
import {
  Apple,
  ArrowRight,
  LockKeyhole,
  Mail,
  Sparkles,
  UserRound,
} from 'lucide-react';
import { useAuth } from './AuthProvider';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';

type AuthMode = 'welcome' | 'login' | 'signup';

export default function AuthPage() {
  const {
    action,
    clearError,
    error,
    sendResetLink,
    signInWithApple,
    signInWithEmail,
    signInWithGoogle,
    signUpWithEmail,
  } = useAuth();
  const [mode, setMode] = useState<AuthMode>('welcome');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [resetFeedback, setResetFeedback] = useState<string | null>(null);

  const isBusy = action !== 'idle';

  const featureCards = useMemo(
    () => [
      {
        title: 'Unified operating system',
        description:
          'Tasks, schedule, notes, and money stay in one responsive surface.',
      },
      {
        title: 'Realtime sync',
        description:
          'Firestore-backed state keeps your data aligned across devices.',
      },
      {
        title: 'Offline-first',
        description:
          'IndexedDB cache and queued writes keep the app usable without network.',
      },
    ],
    [],
  );

  async function handleEmailSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    clearError();
    setResetFeedback(null);

    if (mode === 'signup') {
      await signUpWithEmail(displayName.trim(), email.trim(), password);
      return;
    }

    await signInWithEmail(email.trim(), password);
  }

  async function handleResetPassword() {
    clearError();
    setResetFeedback(null);
    await sendResetLink(email.trim());
    setResetFeedback('Password reset email sent.');
  }

  return (
    <div className="min-h-screen bg-background flex flex-col lg:flex-row items-stretch overflow-hidden">
      {/* Hero Section */}
      <section className="flex-1 p-8 lg:p-16 flex flex-col justify-center relative overflow-hidden bg-primary/5 dark:bg-primary/10">
        <div className="absolute inset-0 bg-gradient-to-br from-primary/20 via-transparent to-transparent opacity-50" />
        
        <div className="relative z-10 max-w-2xl">
          <div className="flex items-center gap-3 mb-8">
            <div className="h-10 w-10 rounded-xl bg-primary flex items-center justify-center text-primary-foreground shadow-lg shadow-primary/20">
              <Sparkles size={24} />
            </div>
            <h2 className="text-xl font-semibold tracking-tight">LifeOS Web</h2>
          </div>

          <h1 className="text-3xl lg:text-5xl font-bold tracking-tight mb-6 leading-tight">
            Run the iOS workflow in a <span className="text-primary italic">responsive</span> browser workspace.
          </h1>

          <p className="text-lg text-muted-foreground mb-12 max-w-xl leading-relaxed">
            The web version keeps your daily operating system available on
            desktop, tablet, and installable PWA surfaces without giving up sync
            or offline support.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {featureCards.map((card) => (
              <Card key={card.title} className="bg-background/40 backdrop-blur-md border-white/5 shadow-xl">
                <CardHeader className="p-4 pb-2">
                  <CardTitle className="text-sm font-bold">{card.title}</CardTitle>
                </CardHeader>
                <CardContent className="p-4 pt-0">
                  <p className="text-xs text-muted-foreground">{card.description}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Auth Panel */}
      <section className="w-full lg:w-[480px] p-8 lg:p-12 flex flex-col justify-center bg-card border-t lg:border-t-0 lg:border-l border-border shadow-2xl relative z-20">
        <div className="max-w-sm mx-auto w-full">
          <div className="mb-10">
            <h2 className="text-2xl font-bold tracking-tight mb-2">
              {mode === 'welcome' && 'Choose how to continue'}
              {mode === 'login' && 'Sign in'}
              {mode === 'signup' && 'Create your account'}
            </h2>
            <p className="text-muted-foreground text-sm">
              {mode === 'welcome' && 'Use a provider or continue with email.'}
              {mode === 'login' && 'Access the same synced data across web, iOS, and Android.'}
              {mode === 'signup' && 'Set up a new account and start with the web workspace.'}
            </p>
          </div>

          <div className="flex flex-col gap-3 mb-8">
            <Button 
              variant="outline" 
              className="w-full h-11 flex items-center justify-center gap-2 hover:bg-muted/50"
              onClick={() => void signInWithGoogle()}
              disabled={isBusy}
            >
              <Sparkles size={18} className="text-primary" />
              Continue with Google
            </Button>
            <Button 
              variant="outline" 
              className="w-full h-11 flex items-center justify-center gap-2 hover:bg-muted/50"
              onClick={() => void signInWithApple()}
              disabled={isBusy}
            >
              <Apple size={18} />
              Continue with Apple
            </Button>
          </div>

          <div className="relative mb-8">
            <div className="absolute inset-0 flex items-center">
              <span className="w-full border-t" />
            </div>
            <div className="relative flex justify-center text-xs uppercase">
              <span className="bg-card px-2 text-muted-foreground">or use email</span>
            </div>
          </div>

          {mode === 'welcome' ? (
            <div className="flex flex-col gap-3">
              <Button variant="secondary" className="w-full h-11" onClick={() => setMode('login')}>
                Sign in with email
                <ArrowRight size={16} className="ml-2" />
              </Button>
              <Button variant="ghost" className="w-full h-11" onClick={() => setMode('signup')}>
                Create account
                <ArrowRight size={16} className="ml-2" />
              </Button>
            </div>
          ) : (
            <form onSubmit={(event) => void handleEmailSubmit(event)} className="space-y-4">
              {mode === 'signup' && (
                <div className="space-y-2">
                  <Label htmlFor="displayName">Name</Label>
                  <div className="relative">
                    <UserRound className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground h-4 w-4" />
                    <Input
                      id="displayName"
                      className="pl-10 h-11"
                      value={displayName}
                      onChange={(event) => setDisplayName(event.target.value)}
                      placeholder="Yash Lunawat"
                      required
                    />
                  </div>
                </div>
              )}

              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground h-4 w-4" />
                  <Input
                    id="email"
                    type="email"
                    className="pl-10 h-11"
                    value={email}
                    onChange={(event) => setEmail(event.target.value)}
                    placeholder="you@example.com"
                    required
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="password">Password</Label>
                <div className="relative">
                  <LockKeyhole className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground h-4 w-4" />
                  <Input
                    id="password"
                    type="password"
                    className="pl-10 h-11"
                    value={password}
                    onChange={(event) => setPassword(event.target.value)}
                    placeholder="Minimum 6 characters"
                    required
                  />
                </div>
              </div>

              {error && <p className="text-sm font-medium text-destructive">{error}</p>}
              {resetFeedback && <p className="text-sm font-medium text-primary">{resetFeedback}</p>}

              <Button className="w-full h-11 text-base font-semibold" type="submit" disabled={isBusy}>
                {mode === 'signup' ? 'Create account' : 'Sign in'}
              </Button>

              <div className="flex flex-col gap-2 pt-2">
                {mode === 'login' && (
                  <Button
                    variant="link"
                    size="sm"
                    className="text-muted-foreground hover:text-primary h-auto p-0"
                    disabled={isBusy || !email.trim()}
                    onClick={() => void handleResetPassword()}
                  >
                    Forgot password?
                  </Button>
                )}
                <Button
                  variant="link"
                  size="sm"
                  className="text-muted-foreground hover:text-primary h-auto p-0"
                  onClick={() => {
                    clearError();
                    setResetFeedback(null);
                    setMode(mode === 'login' ? 'signup' : 'login');
                  }}
                >
                  {mode === 'login'
                    ? "Don't have an account? Sign up"
                    : 'Already have an account? Sign in'}
                </Button>
              </div>
            </form>
          )}
        </div>
      </section>
    </div>
  );
}

