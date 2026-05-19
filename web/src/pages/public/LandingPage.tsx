import { motion, useScroll, useTransform, AnimatePresence } from 'framer-motion';
import { useRef, useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

export default function LandingPage() {
  const containerRef = useRef(null);
  const { scrollYProgress } = useScroll({ target: containerRef });
  
  // Custom cursor logic for tactile feel
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  const [isHovering, setIsHovering] = useState(false);

  useEffect(() => {
    const updateMousePosition = (e: MouseEvent) => {
      setMousePosition({ x: e.clientX, y: e.clientY });
    };
    window.addEventListener('mousemove', updateMousePosition);
    return () => window.removeEventListener('mousemove', updateMousePosition);
  }, []);

  return (
    <div 
      ref={containerRef} 
      className="noise-bg bg-background text-foreground min-h-screen selection:bg-white selection:text-black overflow-x-hidden"
    >
      {/* Custom Minimal Cursor */}
      <motion.div
        className="fixed top-0 left-0 w-4 h-4 rounded-full bg-white mix-blend-difference pointer-events-none z-[100] hidden md:block"
        animate={{
          x: mousePosition.x - 8,
          y: mousePosition.y - 8,
          scale: isHovering ? 3 : 1,
        }}
        transition={{ type: 'spring', stiffness: 400, damping: 28, mass: 0.1 }}
      />

      {/* Brutalist Navbar */}
      <nav className="fixed top-0 inset-x-0 z-50 mix-blend-difference p-6 flex justify-between items-start pointer-events-none">
        <div className="font-display font-bold text-xl tracking-tighter uppercase pointer-events-auto text-white">
          LifeOS <span className="opacity-40">®</span>
        </div>
        <div className="flex flex-col items-end gap-1 pointer-events-auto">
          <Link 
            to="/auth" 
            className="text-xs uppercase tracking-widest font-medium hover:opacity-50 transition-opacity text-white"
            onMouseEnter={() => setIsHovering(true)}
            onMouseLeave={() => setIsHovering(false)}
          >
            Access Terminal
          </Link>
          <div className="text-[10px] uppercase tracking-widest text-white/40">
            System v1.0
          </div>
        </div>
      </nav>

      {/* Asymmetric Typography Hero */}
      <section className="relative min-h-[100vh] flex flex-col justify-end p-6 md:p-12 lg:p-24 pb-24 md:pb-32 z-10">
        <div className="grid grid-cols-1 md:grid-cols-12 gap-8 items-end">
          <div className="md:col-span-9 lg:col-span-10">
            <motion.h1 
              initial={{ opacity: 0, y: 50 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 1.2, ease: [0.16, 1, 0.3, 1] }}
              className="text-[12vw] md:text-[8vw] lg:text-[7vw] leading-[0.85] font-display font-medium tracking-tighter uppercase"
            >
              Your time, wealth, <br />
              <span className="text-white/20">and mind.</span> <br />
              Finally in sync.
            </motion.h1>
          </div>
          
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 1, delay: 0.5 }}
            className="md:col-span-3 lg:col-span-2 flex flex-col gap-8 md:pb-4"
          >
            <p className="text-xs uppercase tracking-widest leading-relaxed text-foreground/60 border-l border-white/10 pl-4">
              A single, opinionated system designed for high performers who refuse context switching.
            </p>
            <Link 
              to="/auth" 
              className="group relative inline-flex items-center justify-center bg-white text-black h-14 px-8 rounded-none overflow-hidden"
              onMouseEnter={() => setIsHovering(true)}
              onMouseLeave={() => setIsHovering(false)}
            >
              <div className="absolute inset-0 bg-neutral-200 transform translate-y-full group-hover:translate-y-0 transition-transform duration-500 ease-elite" />
              <span className="relative text-xs font-bold uppercase tracking-widest mix-blend-difference text-white">Initialize Workspace</span>
            </Link>
          </motion.div>
        </div>
      </section>

      {/* Sticky Editorial Narrative Section */}
      <section className="relative w-full border-t border-white/10">
        <div className="max-w-[100vw] mx-auto flex flex-col md:flex-row">
          
          {/* Left Sticky Copy */}
          <div className="w-full md:w-1/2 md:sticky md:top-0 h-auto md:h-screen flex flex-col justify-center p-6 md:p-12 lg:p-24 border-r border-white/10 z-20 bg-background">
            <h2 className="text-4xl md:text-5xl lg:text-7xl font-display tracking-tighter uppercase leading-[0.9] mb-8">
              One Interface. <br/>
              Zero Friction.
            </h2>
            <p className="text-lg md:text-xl text-foreground/60 font-light max-w-md leading-relaxed">
              We stripped away the noise. Forget managing six different subscriptions for tasks, calendars, notes, and budgets. This is the unified terminal for your life.
            </p>
          </div>

          {/* Right Scrolling Visuals */}
          <div className="w-full md:w-1/2 flex flex-col border-t md:border-t-0 border-white/10">
            
            {/* Feature 1 */}
            <div className="h-screen flex items-center justify-center p-6 md:p-12 border-b border-white/10 relative overflow-hidden group">
              <div className="absolute inset-0 bg-white/[0.02] transform origin-bottom scale-y-0 group-hover:scale-y-100 transition-transform duration-700 ease-elite" />
              <div className="w-full max-w-md space-y-8 relative z-10">
                <div className="text-xs uppercase tracking-widest text-foreground/40 font-bold">01 // Chronos</div>
                <h3 className="text-3xl font-display uppercase tracking-tighter">Time Topology</h3>
                <p className="text-sm text-foreground/60 leading-relaxed">
                  Your calendar shouldn't just display time, it should defend it. Automated deep work scheduling and conflict resolution built in.
                </p>
                <div className="aspect-video w-full bg-white/5 border border-white/10 flex items-center justify-center editorial-shadow">
                  <div className="w-1/2 h-1/2 border border-white/20 rounded-full flex items-center justify-center">
                    <div className="w-1 h-1/2 bg-white origin-bottom animate-spin" style={{ animationDuration: '4s', animationTimingFunction: 'linear' }} />
                  </div>
                </div>
              </div>
            </div>

            {/* Feature 2 */}
            <div className="h-screen flex items-center justify-center p-6 md:p-12 border-b border-white/10 relative overflow-hidden group">
              <div className="absolute inset-0 bg-white/[0.02] transform origin-bottom scale-y-0 group-hover:scale-y-100 transition-transform duration-700 ease-elite" />
              <div className="w-full max-w-md space-y-8 relative z-10">
                <div className="text-xs uppercase tracking-widest text-foreground/40 font-bold">02 // Capital</div>
                <h3 className="text-3xl font-display uppercase tracking-tighter">Wealth Ledger</h3>
                <p className="text-sm text-foreground/60 leading-relaxed">
                  Real-time liquidity tracking. No bloated dashboards, just stark, actionable financial truths.
                </p>
                <div className="aspect-video w-full bg-white/5 border border-white/10 flex items-end p-4 gap-2 editorial-shadow">
                  {[40, 70, 45, 90, 60].map((h, i) => (
                    <div key={i} className="flex-1 bg-white/20 origin-bottom hover:bg-white transition-colors duration-300" style={{ height: `${h}%` }} />
                  ))}
                </div>
              </div>
            </div>

            {/* Feature 3 */}
            <div className="h-screen flex items-center justify-center p-6 md:p-12 relative overflow-hidden group">
              <div className="absolute inset-0 bg-white/[0.02] transform origin-bottom scale-y-0 group-hover:scale-y-100 transition-transform duration-700 ease-elite" />
              <div className="w-full max-w-md space-y-8 relative z-10">
                <div className="text-xs uppercase tracking-widest text-foreground/40 font-bold">03 // Cortex</div>
                <h3 className="text-3xl font-display uppercase tracking-tighter">Knowledge Graph</h3>
                <p className="text-sm text-foreground/60 leading-relaxed">
                  Notes seamlessly linked to events and tasks. Capture thoughts at the speed of light.
                </p>
                <div className="aspect-video w-full bg-white/5 border border-white/10 p-6 flex flex-col gap-4 editorial-shadow">
                  <div className="w-3/4 h-4 bg-white/20" />
                  <div className="w-full h-2 bg-white/10" />
                  <div className="w-5/6 h-2 bg-white/10" />
                  <div className="w-4/6 h-2 bg-white/10" />
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* Massive Call to Action */}
      <section className="min-h-screen flex flex-col items-center justify-center p-6 md:p-12 text-center border-t border-white/10 relative overflow-hidden">
        <h2 className="text-[10vw] font-display font-bold tracking-tighter uppercase leading-none mb-12 mix-blend-difference z-10 text-white">
          Ready.
        </h2>
        <Link 
          to="/auth" 
          className="group relative inline-flex items-center justify-center bg-white text-black h-16 px-12 rounded-none overflow-hidden z-10"
          onMouseEnter={() => setIsHovering(true)}
          onMouseLeave={() => setIsHovering(false)}
        >
          <div className="absolute inset-0 bg-neutral-300 transform translate-y-full group-hover:translate-y-0 transition-transform duration-500 ease-elite" />
          <span className="relative text-sm font-bold uppercase tracking-widest mix-blend-difference text-white">Enter the system</span>
        </Link>
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[80vw] h-[80vw] rounded-full border border-white/5 opacity-50 pointer-events-none" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[60vw] h-[60vw] rounded-full border border-white/5 opacity-50 pointer-events-none" />
      </section>

      {/* Stark Footer */}
      <footer className="border-t border-white/10 p-6 md:p-12 grid grid-cols-1 md:grid-cols-4 gap-12 text-xs uppercase tracking-widest font-medium">
        <div className="md:col-span-2">
          <div className="font-display font-bold text-xl tracking-tighter mb-4">LifeOS</div>
          <p className="text-foreground/40 max-w-xs normal-case tracking-normal">
            Designed for those who require absolute control over their environment.
          </p>
        </div>
        <div className="flex flex-col gap-4">
          <span className="text-foreground/40 mb-2">Legal</span>
          <Link to="/privacy" className="hover:text-white transition-colors">Privacy Policy</Link>
          <Link to="/terms" className="hover:text-white transition-colors">Terms of Service</Link>
        </div>
        <div className="flex flex-col gap-4">
          <span className="text-foreground/40 mb-2">Connect</span>
          <Link to="/support" className="hover:text-white transition-colors">Support Terminal</Link>
          <a href="#" className="hover:text-white transition-colors">Twitter // X</a>
        </div>
      </footer>
    </div>
  );
}
