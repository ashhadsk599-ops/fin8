import React, { useState, useEffect } from 'react';
import { 
  X, Smartphone, Share, Download, HelpCircle, 
  CheckCircle2, Sparkles, Menu, ArrowRight, Info
} from 'lucide-react';

interface InstallGuideModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const InstallGuideModal: React.FC<InstallGuideModalProps> = ({ isOpen, onClose }) => {
  const [platform, setPlatform] = useState<'ios' | 'android' | 'desktop'>('desktop');
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);
  const [installState, setInstallState] = useState<'idle' | 'installing' | 'installed'>('idle');

  useEffect(() => {
    // Platform detection
    const userAgent = window.navigator.userAgent.toLowerCase();
    if (/iphone|ipad|ipod/.test(userAgent)) {
      setPlatform('ios');
    } else if (/android/.test(userAgent)) {
      setPlatform('android');
    } else {
      setPlatform('desktop');
    }

    // Check if app is launched in standalone display mode
    const isStandalone = window.matchMedia('(display-mode: standalone)').matches || (window.navigator as any).standalone === true;
    if (isStandalone) {
      localStorage.setItem('pwa_installed', 'true');
    }

    // Listen for beforeinstallprompt event (Android / Chrome Desktop)
    const handleBeforeInstallPrompt = (e: Event) => {
      e.preventDefault();
      setDeferredPrompt(e);
    };

    window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt);

    // Listen for appinstalled event
    const handleAppInstalled = () => {
      setInstallState('installed');
      localStorage.setItem('pwa_installed', 'true');
      setDeferredPrompt(null);
    };

    window.addEventListener('appinstalled', handleAppInstalled);

    return () => {
      window.removeEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
      window.removeEventListener('appinstalled', handleAppInstalled);
    };
  }, []);

  const isStandalone = typeof window !== 'undefined' && (
    window.matchMedia('(display-mode: standalone)').matches ||
    (window.navigator as any).standalone === true
  );
  const isAlreadyInstalled = typeof window !== 'undefined' && (
    localStorage.getItem('pwa_installed') === 'true' ||
    localStorage.getItem('pwa_dismissed') === 'true'
  );

  if (!isOpen || isStandalone || isAlreadyInstalled) return null;

  const handleAlreadyInstalled = () => {
    localStorage.setItem('pwa_installed', 'true');
    localStorage.setItem('pwa_dismissed', 'true');
    onClose();
  };

  const handleDismiss = () => {
    localStorage.setItem('pwa_dismissed', 'true');
    onClose();
  };

  const triggerNativeInstall = async () => {
    if (!deferredPrompt) return;
    setInstallState('installing');
    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if (outcome === 'accepted') {
      setInstallState('installed');
      localStorage.setItem('pwa_installed', 'true');
    } else {
      setInstallState('idle');
    }
    setDeferredPrompt(null);
  };

  return (
    <div id="pwa-install-modal" className="fixed inset-0 bg-brand-dark/60 backdrop-blur-md z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 animate-fade-in">
      {/* Container card */}
      <div className="bg-brand-cream w-full max-w-md rounded-t-3xl sm:rounded-3xl shadow-2xl border-t sm:border border-brand-green-light/20 overflow-hidden flex flex-col max-h-[92vh] animate-slide-up">
        
        {/* Header banner */}
        <div className="bg-brand-green-dark p-5 text-white relative">
          <div className="absolute top-0 right-0 w-32 h-32 bg-brand-green-medium/20 rounded-bl-full pointer-events-none" />
          
          <button 
            onClick={handleDismiss}
            className="absolute top-4 right-4 bg-white/10 hover:bg-white/20 p-2 rounded-full text-white transition cursor-pointer"
            title="Close"
          >
            <X className="w-4 h-4" />
          </button>

          <span className="text-[10px] uppercase font-extrabold tracking-widest text-brand-orange bg-brand-orange/10 px-2.5 py-1 rounded-full inline-block mb-2">
            ✨ Native Web App
          </span>
          <h3 className="text-lg font-black tracking-tight flex items-center gap-2">
            <Smartphone className="w-5 h-5 text-brand-orange animate-bounce" /> 
            Install Cura Meal
          </h3>
          <p className="text-xs text-white/85 mt-1 max-w-sm">
            Get instant home-screen access, full-screen bedside view, and sterilized recovery food delivery in one click.
          </p>
        </div>

        {/* Benefits Scroll Panel */}
        <div className="p-5 overflow-y-auto no-scrollbar space-y-5 flex-1">
          
          {/* Quick Perks Row */}
          <div className="grid grid-cols-3 gap-3">
            <div className="bg-white p-3 rounded-2xl border border-brand-green-light/10 text-center space-y-1">
              <span className="text-xl block">📱</span>
              <p className="text-[9px] font-bold text-brand-green-dark">Standalone View</p>
              <p className="text-[8px] text-brand-light">No address bar</p>
            </div>
            <div className="bg-white p-3 rounded-2xl border border-brand-green-light/10 text-center space-y-1">
              <span className="text-xl block">⚡</span>
              <p className="text-[9px] font-bold text-brand-green-dark">Instant Launch</p>
              <p className="text-[8px] text-brand-light">Loads under 1s</p>
            </div>
            <div className="bg-white p-3 rounded-2xl border border-brand-green-light/10 text-center space-y-1">
              <span className="text-xl block">🩺</span>
              <p className="text-[9px] font-bold text-brand-green-dark">Bedside Access</p>
              <p className="text-[8px] text-brand-light">Quick re-orders</p>
            </div>
          </div>

          {/* Core OS Guides */}
          {platform === 'ios' ? (
            /* iOS iPad / iPhone Instructions */
            <div className="space-y-4">
              <div className="bg-brand-green-light/20 p-3 rounded-2xl flex items-center gap-2.5 border border-brand-green-light/30">
                <Info className="w-4 h-4 text-brand-green-dark flex-shrink-0" />
                <p className="text-[10px] text-brand-green-dark font-medium leading-relaxed">
                  Your iPhone uses Safari to install mobile web apps securely on your home screen.
                </p>
              </div>

              <div className="space-y-3.5">
                <h4 className="text-xs font-black text-brand-green-dark uppercase tracking-wider">Step-by-Step iOS Guide</h4>
                
                {/* Step 1 */}
                <div className="flex items-start gap-3">
                  <span className="w-5 h-5 rounded-full bg-brand-green-dark text-white text-[10px] font-black flex items-center justify-center flex-shrink-0 mt-0.5">1</span>
                  <div className="text-xs leading-relaxed">
                    <p className="font-bold text-brand-dark flex items-center gap-1.5">
                      Open Safari & Tap <span className="bg-gray-100 px-1.5 py-0.5 rounded border border-gray-200 inline-flex items-center gap-0.5"><Share className="w-3.5 h-3.5 text-blue-500" /> Share</span>
                    </p>
                    <p className="text-[10px] text-brand-light">Look at the bottom toolbar of Safari on your phone.</p>
                  </div>
                </div>

                {/* Step 2 */}
                <div className="flex items-start gap-3">
                  <span className="w-5 h-5 rounded-full bg-brand-green-dark text-white text-[10px] font-black flex items-center justify-center flex-shrink-0 mt-0.5">2</span>
                  <div className="text-xs leading-relaxed">
                    <p className="font-bold text-brand-dark">Scroll down and tap "Add to Home Screen"</p>
                    <p className="text-[10px] text-brand-light">Icon looks like a grey plus <span className="font-bold text-brand-dark font-mono">+</span> inside an outline box.</p>
                  </div>
                </div>

                {/* Step 3 */}
                <div className="flex items-start gap-3">
                  <span className="w-5 h-5 rounded-full bg-brand-green-dark text-white text-[10px] font-black flex items-center justify-center flex-shrink-0 mt-0.5">3</span>
                  <div className="text-xs leading-relaxed">
                    <p className="font-bold text-brand-dark">Tap "Add" in the top-right corner</p>
                    <p className="text-[10px] text-brand-light">The "Cura Meal" icon will immediately appear on your phone grid!</p>
                  </div>
                </div>
              </div>
            </div>
          ) : platform === 'android' ? (
            /* Android Instructions */
            <div className="space-y-4">
              {deferredPrompt ? (
                /* Native Button available */
                <div className="bg-white p-4 rounded-3xl border border-brand-green-light/45 shadow-sm text-center space-y-3.5">
                  <p className="text-xs text-brand-dark font-semibold">Your Android phone is fully compatible with 1-click install!</p>
                  <button
                    onClick={triggerNativeInstall}
                    disabled={installState === 'installing'}
                    className="w-full bg-brand-green-dark hover:bg-brand-green-dark/95 text-white font-black text-xs py-3.5 px-4 rounded-2xl shadow-md transition flex items-center justify-center gap-2 cursor-pointer"
                  >
                    <Download className="w-4 h-4 text-brand-orange" />
                    <span>{installState === 'installing' ? 'Installing...' : 'Install App Now'}</span>
                  </button>
                </div>
              ) : (
                /* Fallback Android Chrome Menu directions */
                <div className="space-y-3.5">
                  <h4 className="text-xs font-black text-brand-green-dark uppercase tracking-wider">Step-by-Step Android Guide</h4>

                  {/* Step 1 */}
                  <div className="flex items-start gap-3">
                    <span className="w-5 h-5 rounded-full bg-brand-green-dark text-white text-[10px] font-black flex items-center justify-center flex-shrink-0 mt-0.5">1</span>
                    <div className="text-xs leading-relaxed">
                      <p className="font-bold text-brand-dark flex items-center gap-1">
                        Tap the Chrome menu <span className="bg-gray-100 p-1 rounded border border-gray-200 inline-block"><Menu className="w-3.5 h-3.5" /></span> or <span className="font-bold">⋮</span>
                      </p>
                      <p className="text-[10px] text-brand-light">Located in the top-right corner of Chrome browser.</p>
                    </div>
                  </div>

                  {/* Step 2 */}
                  <div className="flex items-start gap-3">
                    <span className="w-5 h-5 rounded-full bg-brand-green-dark text-white text-[10px] font-black flex items-center justify-center flex-shrink-0 mt-0.5">2</span>
                    <div className="text-xs leading-relaxed">
                      <p className="font-bold text-brand-dark">Tap "Install App" or "Add to Home Screen"</p>
                      <p className="text-[10px] text-brand-light">This starts Chrome's automatic phone configuration.</p>
                    </div>
                  </div>

                  {/* Step 3 */}
                  <div className="flex items-start gap-3">
                    <span className="w-5 h-5 rounded-full bg-brand-green-dark text-white text-[10px] font-black flex items-center justify-center flex-shrink-0 mt-0.5">3</span>
                    <div className="text-xs leading-relaxed">
                      <p className="font-bold text-brand-dark">Tap "Install" on the pop-up prompt</p>
                      <p className="text-[10px] text-brand-light">The icon will place on your app drawer and desktop!</p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          ) : (
            /* Desktop / General / PC / Simulated Phone instruction */
            <div className="space-y-4">
              <div className="bg-white p-4 rounded-3xl border border-brand-green-light/20 shadow-sm space-y-3.5">
                <p className="text-xs font-bold text-brand-dark text-center">📱 Scan to Open on Your Phone</p>
                
                {/* Simulated QR Code or Quick Link Box */}
                <div className="bg-brand-cream p-4 rounded-2xl border border-gray-100 flex flex-col items-center justify-center space-y-2.5">
                  <div className="w-36 h-36 bg-white p-2 rounded-xl shadow-inner border border-gray-200 flex flex-col justify-between relative overflow-hidden">
                    {/* Simulated QR block style */}
                    <div className="grid grid-cols-4 gap-1 opacity-80 h-full">
                      {[...Array(16)].map((_, i) => (
                        <div 
                          key={i} 
                          className={`rounded-sm ${(i * 7 + 13) % 2 === 0 ? 'bg-brand-green-dark' : 'bg-brand-cream'} ${
                            (i === 0 || i === 3 || i === 12) ? 'ring-2 ring-brand-green-dark bg-white' : ''
                          }`} 
                        />
                      ))}
                    </div>
                    {/* Central leaf over QR code */}
                    <div className="absolute inset-0 m-auto w-10 h-10 bg-white rounded-full flex items-center justify-center shadow">
                      <span className="text-sm">🍃</span>
                    </div>
                  </div>
                  
                  <p className="text-[10px] text-brand-light text-center leading-normal max-w-xs">
                    Scan this quick-install box with your phone's camera to instantly launch the secure mobile web app link, or load this link in Safari/Chrome:
                  </p>
                  
                  <div className="bg-white border border-gray-200 px-3 py-1.5 rounded-xl select-all">
                    <span className="text-[9px] font-mono font-bold text-brand-green-dark break-all">{window.location.href}</span>
                  </div>
                </div>
                
                {deferredPrompt && (
                  <button 
                    onClick={triggerNativeInstall}
                    className="w-full bg-brand-green-dark hover:bg-brand-green-dark/95 text-white font-black text-xs py-3.5 px-4 rounded-2xl shadow flex items-center justify-center gap-1.5 cursor-pointer"
                  >
                    <Download className="w-4 h-4 text-brand-orange" />
                    <span>Install on Chrome Desktop</span>
                  </button>
                )}
              </div>
            </div>
          )}

          {/* Success / Status Message */}
          {installState === 'installed' && (
            <div className="bg-emerald-50 text-emerald-800 p-3.5 rounded-2xl flex items-center gap-2.5 border border-emerald-100 text-xs font-bold animate-pulse">
              <CheckCircle2 className="w-4.5 h-4.5 text-emerald-600 flex-shrink-0" />
              <span>Cura Meal installed successfully! Look for it on your home screen.</span>
            </div>
          )}

        </div>

        {/* Footer */}
        <div className="p-4 bg-white border-t border-gray-100 flex flex-col sm:flex-row gap-2 justify-between items-center text-[10px] text-brand-light">
          <button
            onClick={handleAlreadyInstalled}
            className="text-xs font-bold text-brand-green-dark bg-brand-green-light/20 hover:bg-brand-green-light/40 px-3 py-1.5 rounded-xl transition cursor-pointer flex items-center gap-1"
          >
            <CheckCircle2 className="w-3.5 h-3.5 text-brand-green-dark" />
            Already Installed Shortcut
          </button>
          
          <button 
            onClick={handleDismiss}
            className="font-bold text-brand-light hover:text-brand-dark hover:underline cursor-pointer py-1"
          >
            Don't show again
          </button>
        </div>

      </div>
    </div>
  );
};
