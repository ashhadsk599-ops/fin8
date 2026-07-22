import {StrictMode} from 'react';
import {createRoot} from 'react-dom/client';
import App from './App.tsx';
import './index.css';

const isDevHost = 
  window.location.hostname.includes('run.app') || 
  window.location.hostname.includes('localhost') || 
  window.location.hostname.includes('127.0.0.1');

if (isDevHost) {
  // In development/preview environments, we unregister any service workers 
  // and clear caches to guarantee the user always sees the absolute latest code updates.
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then((registrations) => {
      let unregisteredAny = false;
      const unregisterPromises = registrations.map((registration) => {
        return registration.unregister().then((unregistered) => {
          if (unregistered) {
            unregisteredAny = true;
            console.log('Unregistered service worker to prevent stale preview caching.');
          }
        });
      });

      Promise.all(unregisterPromises).then(() => {
        if (unregisteredAny) {
          const clearCachesAndReload = async () => {
            if (typeof caches !== 'undefined') {
              try {
                const keys = await caches.keys();
                await Promise.all(keys.map(key => caches.delete(key)));
              } catch (err) {
                console.error('Error clearing caches:', err);
              }
            }
            window.location.reload();
          };
          clearCachesAndReload();
        }
      });
    });
  }
} else {
  // Register Service Worker for PWA / Mobile App Experience in production
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('/sw.js')
        .then(reg => console.log('Service Worker registered successfully:', reg.scope))
        .catch(err => console.error('Service Worker registration failed:', err));
    });
  }
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
