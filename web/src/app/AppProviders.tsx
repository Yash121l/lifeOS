import type { ReactNode } from 'react';
import { AuthProvider } from '../features/auth/AuthProvider';
import { DataProvider } from '../features/data/DataProvider';

export default function AppProviders({ children }: { children: ReactNode }) {
  return (
    <AuthProvider>
      <DataProvider>{children}</DataProvider>
    </AuthProvider>
  );
}
