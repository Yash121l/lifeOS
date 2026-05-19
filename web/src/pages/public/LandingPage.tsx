import { motion, useScroll, useTransform, AnimatePresence } from 'framer-motion';
import { useRef, useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

// --- Custom Hooks ---

// Hook to track mouse for the global custom cursor and localized lighting
function useMousePosition() {
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  
  useEffect(() => {
    const updateMousePosition = (e: MouseEvent) => {
      setMousePosition({ x: e.clientX, y: e.clientY });
    };
    window.addEventListener('mousemove', updateMousePosition);
    return () => window.removeEventListener('mousemove', updateMousePosition);
  }, []);

  return mousePosition;
}

// --- Custom Components ---

function TactileButton({ children, to }: { children: React.ReactNode, to: string }) {
  return (
    <Link to={to} className="relative inline-flex items-center justify-center group overflow-hidden bg-white text-black px-12 py-5 font-mono text-xs uppercase tracking-widest font-bold">
      <span className="relative z-10 mix-blend-difference text-white">{children}</span>
      <div className="absolute inset-0 bg-neutral-300 transform translate-y-[100%] group-hover:translate-y-0 transition-transform duration-500 ease-machined" />
    </Link>
  );
}

export default function LandingPage() {
  const containerRef = useRef(null);
  const mouse = useMousePosition();
  const { scrollYProgress } = useScroll({ target: containerRef });

  // Cursor state
  const [isHovering, setIsHovering] = useState(false);

  // Command palette simulation sequence
  const [cmdText, setCmdText] = useState("");
  const fullCmdText = "> Allocate 2 hours tomorrow for deep work, sync meeting notes, and move $500 to savings.";
  
  useEffect(() => {
    const handleScroll = () => {
      const scrollPos = window.scrollY;
      const windowHeight = window.innerHeight;
      const triggerPos = windowHeight * 3.5; // Roughly section 5
      
      if (scrollPos > triggerPos) {
        let i = 0;
        const interval = setInterval(() => {
          setCmdText(fullCmdText.substring(0, i));
          i++;
          if (i > fullCmdText.length) clearInterval(interval);
        }, 30);
        return () => clearInterval(interval);
      }
    };
    window.addEventListener('scroll', handleScroll, { once: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);


  return (
    <div 
      ref={containerRef} 
      className="noise-bg bg-black text-white min-h-screen selection:bg-white selection:text-black overflow-x-hidden font-sans"
    >
      {/* Engineered Custom Cursor */}
      <motion.div
        className="fixed top-0 left-0 w-2 h-2 rounded-sm bg-white mix-blend-difference pointer-events-none z-[9999] hidden md:block"
        animate={{
          x: mouse.x - 4,
          y: mouse.y - 4,
          scale: isHovering ? 4 : 1,
          rotate: isHovering ? 45 : 0,
        }}
        transition={{ type: 'spring', stiffness: 500, damping: 28, mass: 0.1 }}
      />

      {/* 1. The Philosophical Hook (Absolute Silence) */}
      <section className="relative h-[100vh] flex flex-col items-center justify-center p-6 text-center z-10">
        <motion.div 
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 2, ease: "easeOut" }}
          className="flex flex-col items-center gap-12"
        >
          {/* Breathing Neural Node */}
          <motion.div 
            animate={{ 
              boxShadow: ['0 0 0px 0px rgba(255,255,255,0.2)', '0 0 20px 2px rgba(255,255,255,0.4)', '0 0 0px 0px rgba(255,255,255,0.2)'] 
            }}
            transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
            className="w-2 h-2 bg-white"
          />
          <h1 className="text-xl md:text-2xl lg:text-3xl font-light tracking-tight text-white/80 max-w-2xl leading-relaxed">
            Your life produces too much context <br className="hidden md:block"/> to hold manually.
          </h1>
        </motion.div>
        
        <motion.div 
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 2, duration: 1 }}
          className="absolute bottom-12 text-[10px] uppercase tracking-[0.2em] text-white/30 font-mono"
        >
          Scroll to Boot Sequence
        </motion.div>
      </section>

      {/* 2. Emotional Problem (Density & Chaos) */}
      <section className="relative h-[120vh] flex items-center justify-center overflow-hidden border-t border-white/5">
        {/* Chaotic Background Elements */}
        <div className="absolute inset-0 opacity-20 pointer-events-none grid-bg" />
        <motion.div className="absolute top-1/4 left-1/4 text-xs font-mono text-technical-amber blur-[1px]">ERR_CONTEXT_OVERFLOW</motion.div>
        <motion.div className="absolute bottom-1/3 right-1/4 text-xs font-mono text-white/40 blur-[2px]">unresolved_tasks = 142;</motion.div>
        <motion.div className="absolute top-1/2 left-2/3 text-lg font-serif italic text-white/20 blur-[3px]">Where did I put that note?</motion.div>
        
        <div className="relative z-10 text-center px-6">
          <h2 className="text-4xl md:text-6xl lg:text-8xl font-display font-medium tracking-tighter uppercase leading-[0.85] mix-blend-difference">
            A system for thinking <br/> clearly in chaotic <br/> timelines.
          </h2>
        </div>
      </section>

      {/* 3. Visualized Cognition (Spatial Diagram) */}
      <section className="relative min-h-[100vh] py-32 px-6 md:px-12 lg:px-24 border-t border-white/5">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row gap-24 items-center">
          <div className="flex-1 space-y-8">
            <div className="text-[10px] font-mono uppercase tracking-widest text-technical-amber">Module // 01</div>
            <h3 className="text-3xl md:text-5xl font-light tracking-tight leading-tight">Memory. Decisions. Intent. <br/> Connected.</h3>
            <p className="text-sm md:text-base text-white/50 leading-relaxed max-w-md font-mono">
              The human brain is optimized for processing, not storage. LifeOS acts as an external cognitive drive, networking your time, wealth, and tasks into a single immutable graph.
            </p>
          </div>
          
          <div className="flex-1 relative w-full aspect-square md:aspect-auto md:h-[600px] machined-panel p-8 flex items-center justify-center">
            {/* Abstract Diagram */}
            <div className="relative w-full max-w-sm aspect-square border border-white/10 flex items-center justify-center">
              <div className="absolute top-0 bottom-0 left-1/2 w-px bg-white/10" />
              <div className="absolute left-0 right-0 top-1/2 h-px bg-white/10" />
              
              <div className="absolute top-4 left-4 text-[10px] font-mono text-white/40">TIME</div>
              <div className="absolute top-4 right-4 text-[10px] font-mono text-white/40">TASKS</div>
              <div className="absolute bottom-4 left-4 text-[10px] font-mono text-white/40">CAPITAL</div>
              <div className="absolute bottom-4 right-4 text-[10px] font-mono text-white/40">MEMORY</div>
              
              <motion.div 
                animate={{ rotate: 360 }}
                transition={{ duration: 60, repeat: Infinity, ease: "linear" }}
                className="w-32 h-32 border border-technical-amber/50 rounded-full flex items-center justify-center"
              >
                <div className="w-2 h-2 bg-technical-amber" />
              </motion.div>
            </div>
          </div>
        </div>
      </section>

      {/* 4. System Architecture (Code-editor breakdown) */}
      <section className="relative min-h-[100vh] bg-[#050505] py-32 px-6 md:px-12 lg:px-24 border-t border-white/5">
        <div className="max-w-6xl mx-auto">
          <div className="text-[10px] font-mono uppercase tracking-widest text-white/40 mb-16">System Architecture // v1.0</div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-px bg-white/10">
            {/* Chronos */}
            <div className="bg-[#050505] p-8 space-y-6 flex flex-col justify-between h-[400px]">
              <div>
                <div className="flex items-center gap-4 mb-6">
                  <div className="w-3 h-3 bg-white" />
                  <h4 className="font-mono text-sm uppercase tracking-widest">Chronos</h4>
                </div>
                <p className="text-xs text-white/50 leading-relaxed">Defend your time. Automated scheduling algorithms that resolve conflicts and allocate deep work blocks based on cognitive load parameters.</p>
              </div>
              <div className="text-[10px] font-mono text-technical-amber">STATUS: ONLINE</div>
            </div>

            {/* Capital */}
            <div className="bg-[#050505] p-8 space-y-6 flex flex-col justify-between h-[400px]">
              <div>
                <div className="flex items-center gap-4 mb-6">
                  <div className="w-3 h-3 border border-white" />
                  <h4 className="font-mono text-sm uppercase tracking-widest">Capital</h4>
                </div>
                <p className="text-xs text-white/50 leading-relaxed">Real-time liquidity and asset ledger. Strip away the bloated charts of standard budgeting apps. Just raw, actionable financial truths.</p>
              </div>
              <div className="text-[10px] font-mono text-technical-amber">STATUS: ONLINE</div>
            </div>

            {/* Cortex */}
            <div className="bg-[#050505] p-8 space-y-6 flex flex-col justify-between h-[400px]">
              <div>
                <div className="flex items-center gap-4 mb-6">
                  <div className="w-3 h-3 border border-white/30" />
                  <h4 className="font-mono text-sm uppercase tracking-widest">Cortex</h4>
                </div>
                <p className="text-xs text-white/50 leading-relaxed">A knowledge graph that captures thoughts at the speed of light. Automatically linked to active tasks and calendar events.</p>
              </div>
              <div className="text-[10px] font-mono text-technical-amber">STATUS: ONLINE</div>
            </div>

            {/* Nexus */}
            <div className="bg-[#050505] p-8 space-y-6 flex flex-col justify-between h-[400px]">
              <div>
                <div className="flex items-center gap-4 mb-6">
                  <div className="w-3 h-3 border border-technical-amber" />
                  <h4 className="font-mono text-sm uppercase tracking-widest">Nexus</h4>
                </div>
                <p className="text-xs text-white/50 leading-relaxed">The task execution engine. Priority queuing, dependency mapping, and friction-less completion states.</p>
              </div>
              <div className="text-[10px] font-mono text-technical-amber">STATUS: ONLINE</div>
            </div>
          </div>
        </div>
      </section>

      {/* 5. Human + AI Interaction (Animated Command Palette) */}
      <section className="relative min-h-[100vh] py-32 px-6 flex items-center justify-center border-t border-white/5 grid-bg">
        <div className="w-full max-w-3xl machined-panel p-2 shadow-2xl">
          <div className="bg-black border border-white/10 w-full rounded-sm overflow-hidden">
            {/* Window Header */}
            <div className="flex items-center px-4 py-3 border-b border-white/10 bg-white/[0.02]">
              <div className="text-[10px] font-mono text-white/40">LifeOS Command Interface</div>
            </div>
            
            {/* Input Area */}
            <div className="p-6 md:p-8 flex items-center gap-4 border-b border-white/10">
              <span className="text-technical-amber font-mono text-xl animate-pulse">_</span>
              <span className="font-mono text-sm md:text-base text-white/90">{cmdText}</span>
            </div>

            {/* Resolution Area (Simulated) */}
            <div className="p-6 md:p-8 bg-white/[0.01]">
              <div className="text-[10px] font-mono text-white/30 mb-4 uppercase">System Resolution</div>
              
              <AnimatePresence>
                {cmdText.length === fullCmdText.length && (
                  <motion.div 
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="space-y-3"
                  >
                    <div className="flex items-center gap-3 text-xs font-mono text-white/60">
                      <div className="w-2 h-2 bg-white" />
                      <span>Created Event: "Deep Work" (Tomorrow, 10:00 - 12:00)</span>
                    </div>
                    <div className="flex items-center gap-3 text-xs font-mono text-white/60">
                      <div className="w-2 h-2 border border-white" />
                      <span>Appended Notes: Sync Meeting -&gt; Cortex</span>
                    </div>
                    <div className="flex items-center gap-3 text-xs font-mono text-white/60">
                      <div className="w-2 h-2 bg-technical-amber" />
                      <span>Ledger Updated: -$500 Checking, +$500 Savings</span>
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </div>
        </div>
      </section>

      {/* 6-9. Technical Specs (Hardware Manual layout) */}
      <section className="relative py-32 px-6 md:px-12 lg:px-24 border-t border-white/5">
        <div className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-12 gap-12 md:gap-24">
          
          <div className="md:col-span-5 space-y-12">
            <h2 className="text-4xl md:text-5xl font-light tracking-tight leading-tight">
              Built by obsessive <br/> product thinkers.
            </h2>
            <div className="text-xs font-mono text-white/40 space-y-4">
              <p>We rejected the standard SaaS playbook.</p>
              <p>No infinite feature drops. No bloated dashboards.</p>
              <p>Just precise, engineered workflows that respect your attention and augment your cognition.</p>
            </div>
          </div>

          <div className="md:col-span-7">
            {/* Spec Table */}
            <div className="border-t border-white/10">
              {[
                { label: 'Architecture', val: 'React / Vite / TypeScript' },
                { label: 'Data Layer', val: 'Firebase Cloud Firestore' },
                { label: 'State Sync', val: 'Optimistic UI Updates (Real-time)' },
                { label: 'Motion Engine', val: 'Framer Motion (Custom Curves)' },
                { label: 'Security', val: 'End-to-End Auth / Rule Sets' },
              ].map((spec, i) => (
                <div key={i} className="flex justify-between items-center py-4 border-b border-white/10 group hover:bg-white/[0.02] transition-colors"
                  onMouseEnter={() => setIsHovering(true)}
                  onMouseLeave={() => setIsHovering(false)}
                >
                  <span className="font-mono text-xs uppercase text-white/50 group-hover:text-white transition-colors">{spec.label}</span>
                  <span className="font-mono text-xs text-right">{spec.val}</span>
                </div>
              ))}
            </div>
          </div>

        </div>
      </section>

      {/* 10. The Final Close */}
      <section className="relative h-[100vh] flex flex-col items-center justify-center p-6 text-center border-t border-white/5 z-10">
        <div className="space-y-12 flex flex-col items-center">
          <h2 className="text-3xl md:text-5xl lg:text-7xl font-display font-medium tracking-tighter uppercase leading-none mix-blend-difference">
            Boot the Sequence.
          </h2>
          
          <div 
            onMouseEnter={() => setIsHovering(true)}
            onMouseLeave={() => setIsHovering(false)}
          >
            <TactileButton to="/auth">Initialize Workspace</TactileButton>
          </div>
        </div>
      </section>

      {/* Stark Technical Footer */}
      <footer className="border-t border-white/10 p-6 md:p-12 flex flex-col md:flex-row justify-between items-start md:items-end gap-12 bg-black font-mono text-[10px] uppercase tracking-widest text-white/30">
        <div>
          <span className="text-white">LifeOS</span> // Build 1.0.42 <br/>
          (c) {new Date().getFullYear()} Cognitive Systems Inc.
        </div>
        
        <div className="flex gap-8">
          <div className="flex flex-col gap-2">
            <Link to="/privacy" className="hover:text-white transition-colors">Privacy Specification</Link>
            <Link to="/terms" className="hover:text-white transition-colors">Terms of Service</Link>
          </div>
          <div className="flex flex-col gap-2">
            <Link to="/support" className="hover:text-white transition-colors">Support Terminal</Link>
            <a href="#" className="hover:text-white transition-colors">Network [X]</a>
          </div>
        </div>
      </footer>
    </div>
  );
}
