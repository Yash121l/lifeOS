import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import AppProviders from './app/AppProviders.tsx';
import { registerServiceWorker } from './lib/pwa.ts';
import './styles/index.css';

registerServiceWorker();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <AppProviders>
      <App />
    </AppProviders>
  </StrictMode>,
);
