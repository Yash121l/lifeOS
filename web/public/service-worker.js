const CACHE_NAME = 'lifeos-web-v2';
const toAbsoluteUrl = (path = '') => new URL(path, self.registration.scope).toString();
const APP_SHELL = [
  toAbsoluteUrl(''),
  toAbsoluteUrl('index.html'),
  toAbsoluteUrl('manifest.webmanifest'),
  toAbsoluteUrl('lifeos-icon.svg'),
];

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL)));
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key)),
      ),
    ),
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;

  const request = event.request;
  const acceptsHtml = request.headers.get('accept')?.includes('text/html');

  if (acceptsHtml) {
    event.respondWith(fetch(request).catch(() => caches.match(toAbsoluteUrl('index.html'))));
    return;
  }

  event.respondWith(
    caches.match(request).then((cachedResponse) => {
      if (cachedResponse) return cachedResponse;

      return fetch(request).then((response) => {
        const responseClone = response.clone();
        void caches
          .open(CACHE_NAME)
          .then((cache) => cache.put(request, responseClone));
        return response;
      });
    }),
  );
});
