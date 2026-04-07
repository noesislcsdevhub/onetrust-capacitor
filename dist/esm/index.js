import { registerPlugin } from '@capacitor/core';
// IMPORTANT: the plugin name MUST remain "OneTrust" so that consumer code
// (e.g. OutSystems) calling the original Cordova plugin name continues to
// resolve. A mismatch causes "plugin not implemented".
const OneTrust = registerPlugin('OneTrust', {
    web: () => import('./web').then(m => new m.OneTrustWeb()),
});
export * from './definitions';
export { OneTrust };
//# sourceMappingURL=index.js.map