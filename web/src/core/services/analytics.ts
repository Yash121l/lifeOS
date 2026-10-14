import posthog from 'posthog-js';

// PostHog product analytics. The key lives in .env.production, so dev builds
// skip init, and so does any localhost preview. GitHub Pages has no server to
// proxy through, so events go straight to PostHog US.
const key = import.meta.env.VITE_POSTHOG_KEY as string | undefined;
const isLocal = ['localhost', '127.0.0.1', '[::1]'].includes(window.location.hostname);
let enabled = false;

export function initAnalytics() {
  if (!key || isLocal) return;
  try {
    posthog.init(key, {
      api_host: 'https://us.i.posthog.com',
      ui_host: 'https://us.posthog.com',
      defaults: '2026-08-30',
      capture_pageview: 'history_change',
      capture_pageleave: true,
      autocapture: true,
      enable_heatmaps: true,
      capture_dead_clicks: true,
      capture_exceptions: true,
      capture_performance: { web_vitals: true },
      session_recording: { maskAllInputs: true },
    });
    posthog.register({ app: 'lifeos' });
    enabled = true;
  } catch {
    // Analytics must never break the app.
  }
}

export function track(event: string, properties?: Record<string, unknown>) {
  if (enabled) posthog.capture(event, properties);
}

export function identifyUser(user: { uid: string; email: string | null; displayName: string | null }) {
  if (!enabled) return;
  posthog.identify(user.uid, {
    email: user.email ?? undefined,
    name: user.displayName ?? undefined,
  });
}

export function resetUser() {
  if (enabled) posthog.reset();
}
