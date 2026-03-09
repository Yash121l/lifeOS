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
    <div className="auth-screen">
      <section className="auth-hero panel panel--accent">
        <div className="auth-brand">
          <span className="brand-mark">
            <Sparkles size={18} />
          </span>
          <div>
            <p className="eyebrow">LifeOS Web</p>
            <h1>Run the iOS workflow in a responsive browser workspace.</h1>
          </div>
        </div>

        <p className="auth-copy">
          The web version keeps your daily operating system available on
          desktop, tablet, and installable PWA surfaces without giving up sync
          or offline support.
        </p>

        <div className="hero-grid">
          {featureCards.map((card) => (
            <article key={card.title} className="hero-stat">
              <h2>{card.title}</h2>
              <p>{card.description}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="auth-panel panel">
        <div className="auth-panel__header">
          <p className="eyebrow">Account</p>
          <h2>
            {mode === 'welcome' && 'Choose how to continue'}
            {mode === 'login' && 'Sign in'}
            {mode === 'signup' && 'Create your account'}
          </h2>
          <p className="text-subtle">
            {mode === 'welcome' && 'Use a provider or continue with email.'}
            {mode === 'login' &&
              'Access the same synced data across web, iOS, and Android.'}
            {mode === 'signup' &&
              'Set up a new account and start with the web workspace.'}
          </p>
        </div>

        <div className="stack">
          <button
            className="button button--primary"
            onClick={() => void signInWithGoogle()}
            disabled={isBusy}
            type="button"
          >
            <Sparkles size={18} />
            Continue with Google
          </button>
          <button
            className="button button--secondary"
            onClick={() => void signInWithApple()}
            disabled={isBusy}
            type="button"
          >
            <Apple size={18} />
            Continue with Apple
          </button>
        </div>

        <div className="divider">
          <span>or use email</span>
        </div>

        {mode === 'welcome' ? (
          <div className="stack">
            <button
              className="button button--ghost"
              onClick={() => setMode('login')}
              type="button"
            >
              Sign in with email
              <ArrowRight size={16} />
            </button>
            <button
              className="button button--ghost"
              onClick={() => setMode('signup')}
              type="button"
            >
              Create account
              <ArrowRight size={16} />
            </button>
          </div>
        ) : (
          <form
            className="auth-form"
            onSubmit={(event) => void handleEmailSubmit(event)}
          >
            {mode === 'signup' ? (
              <label className="field">
                <span>Name</span>
                <div className="field-shell">
                  <UserRound size={16} />
                  <input
                    value={displayName}
                    onChange={(event) => setDisplayName(event.target.value)}
                    placeholder="Yash Lunawat"
                    required
                  />
                </div>
              </label>
            ) : null}

            <label className="field">
              <span>Email</span>
              <div className="field-shell">
                <Mail size={16} />
                <input
                  type="email"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  placeholder="you@example.com"
                  required
                />
              </div>
            </label>

            <label className="field">
              <span>Password</span>
              <div className="field-shell">
                <LockKeyhole size={16} />
                <input
                  type="password"
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                  placeholder="Minimum 6 characters"
                  required
                />
              </div>
            </label>

            {error ? <p className="feedback feedback--error">{error}</p> : null}
            {resetFeedback ? (
              <p className="feedback feedback--success">{resetFeedback}</p>
            ) : null}

            <button className="button button--primary" type="submit" disabled={isBusy}>
              {mode === 'signup' ? 'Create account' : 'Sign in'}
            </button>

            {mode === 'login' ? (
              <button
                className="button button--ghost"
                type="button"
                disabled={isBusy || !email.trim()}
                onClick={() => void handleResetPassword()}
              >
                Send password reset link
              </button>
            ) : null}

            <button
              className="button button--link"
              type="button"
              onClick={() => {
                clearError();
                setResetFeedback(null);
                setMode(mode === 'login' ? 'signup' : 'login');
              }}
            >
              {mode === 'login'
                ? 'Need an account? Create one.'
                : 'Already have an account? Sign in.'}
            </button>
          </form>
        )}
      </section>
    </div>
  );
}
