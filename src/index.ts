import { registerPlugin } from '@capacitor/core';
import type { OneTrustPlugin } from './definitions';

// IMPORTANT: the plugin name MUST remain "OneTrust" so that consumer code
// (e.g. OutSystems) calling the original Cordova plugin name continues to
// resolve. A mismatch causes "plugin not implemented".
const OneTrust = registerPlugin<OneTrustPlugin>('OneTrust', {
  web: () => import('./web').then(m => new m.OneTrustWeb()),
});

export * from './definitions';
export { OneTrust };
