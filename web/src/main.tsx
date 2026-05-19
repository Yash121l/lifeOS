import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import AppProviders from './app/AppProviders.tsx';
import { registerServiceWorker } from './core/services/pwa.ts';
import './core/theme/index.css';

registerServiceWorker();

// Force dark mode for premium Apple-tier aesthetic
document.documentElement.classList.add('dark');

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <AppProviders>
      <App />
    </AppProviders>
  </StrictMode>,
);
