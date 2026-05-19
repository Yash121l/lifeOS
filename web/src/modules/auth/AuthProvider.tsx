/* eslint-disable react-refresh/only-export-components */
import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import {
  createUserWithEmailAndPassword,
  onAuthStateChanged,
  sendPasswordResetEmail,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut,
  updateProfile,
  type User,
} from 'firebase/auth';
import { appleProvider, auth, googleProvider } from '../../core/network/firebase';

type AuthAction = 'idle' | 'email' | 'provider' | 'reset' | 'signout';

interface AuthContextValue {
  user: User | null;
  displayName: string;
  initials: string;
  isLoading: boolean;
  action: AuthAction;
  error: string | null;
  signInWithEmail: (email: string, password: string) => Promise<void>;
  signUpWithEmail: (
    displayName: string,
    email: string,
    password: string,
  ) => Promise<void>;
  signInWithGoogle: () => Promise<void>;
  signInWithApple: () => Promise<void>;
  sendResetLink: (email: string) => Promise<void>;
  signOutUser: () => Promise<void>;
  clearError: () => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

function getAuthMessage(error: unknown): string {
  if (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    typeof (error as { code: unknown }).code === 'string'
  ) {
    switch ((error as { code: string }).code) {
      case 'auth/invalid-credential':
        return 'The email or password is incorrect.';
      case 'auth/email-already-in-use':
        return 'That email is already attached to an account.';
      case 'auth/invalid-email':
        return 'Enter a valid email address.';
      case 'auth/weak-password':
        return 'Use a stronger password with at least 6 characters.';
      case 'auth/popup-closed-by-user':
        return 'The sign-in window was closed before completing the flow.';
      case 'auth/missing-email':
        return 'Enter your email address first.';
      default:
        break;
    }
  }

  return 'Something went wrong. Please try again.';
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [action, setAction] = useState<AuthAction>('idle');
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (nextUser) => {
      setUser(nextUser);
      setIsLoading(false);
    });

    return unsubscribe;
  }, []);

  async function runAction(kind: AuthAction, task: () => Promise<void>) {
    setAction(kind);
    setError(null);

    try {
      await task();
    } catch (nextError) {
      setError(getAuthMessage(nextError));
      throw nextError;
    } finally {
      setAction('idle');
    }
  }

  const value = useMemo<AuthContextValue>(() => {
    const displayName =
      user?.displayName ??
      user?.email?.split('@')[0] ??
      'LifeOS user';
    const initials = displayName
      .split(' ')
      .slice(0, 2)
      .map((part) => part[0]?.toUpperCase() ?? '')
      .join('')
      .slice(0, 2);

    return {
      user,
      displayName,
      initials,
      isLoading,
      action,
      error,
      clearError: () => setError(null),
      signInWithEmail: async (email, password) => {
        await runAction('email', async () => {
          await signInWithEmailAndPassword(auth, email, password);
        });
      },
      signUpWithEmail: async (nextDisplayName, email, password) => {
        await runAction('email', async () => {
          const result = await createUserWithEmailAndPassword(
            auth,
            email,
            password,
          );
          await updateProfile(result.user, { displayName: nextDisplayName });
        });
      },
      signInWithGoogle: async () => {
        await runAction('provider', async () => {
          await signInWithPopup(auth, googleProvider);
        });
      },
      signInWithApple: async () => {
        await runAction('provider', async () => {
          await signInWithPopup(auth, appleProvider);
        });
      },
      sendResetLink: async (email) => {
        await runAction('reset', async () => {
          await sendPasswordResetEmail(auth, email);
        });
      },
      signOutUser: async () => {
        await runAction('signout', async () => {
          await signOut(auth);
        });
      },
    };
  }, [action, error, isLoading, user]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);

  if (!context) {
    throw new Error('useAuth must be used inside AuthProvider');
  }

  return context;
}
