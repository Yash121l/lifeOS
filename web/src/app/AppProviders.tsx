import type { ReactNode } from 'react';
import { AuthProvider } from '../modules/auth/AuthProvider';
import { DataProvider } from '../modules/data/DataProvider';

export default function AppProviders({ children }: { children: ReactNode }) {
  return (
    <AuthProvider>
      <DataProvider>{children}</DataProvider>
    </AuthProvider>
  );
}
