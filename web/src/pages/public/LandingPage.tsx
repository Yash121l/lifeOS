import { motion, useScroll, useTransform, AnimatePresence } from 'framer-motion';
import { useRef, useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

// Hook to track mouse for the global custom cursor and localized lighting
function useMouse() {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  useEffect(() => {
    const handleMove = (e: MouseEvent) => {
      setPosition({ x: e.clientX, y: e.clientY });
    };
    window.addEventListener('mousemove', handleMove);
    return () => window.removeEventListener('mousemove', handleMove);
  }, []);
  return position;
}

// Tactical button component
function TactileButton({ children, to }: { children: React.ReactNode, to: string }) {
  return (
    <Link to={to} className="relative inline-flex items-center justify-center group overflow-hidden bg-white text-black px-12 py-5 font-mono text-xs uppercase tracking-widest font-bold">
      <span className="relative z-10 mix-blend-difference text-white">{children}</span>
      <div className="absolute inset-0 bg-neutral-300 transform translate-y-[100%] group-hover:translate-y-0 transition-transform duration-500 ease-machined" />
    </Link>
  );
}

export default function LandingPage() {
  const pageRef = useRef<HTMLDivElement>(null);
  const mouse = useMouse();
  const [hovered, setHovered] = useState(false);
  const [cmdInput, setCmdInput] = useState("");
  
  const fullCommand = "system.optimize --focus --sync-ledger --consolidate-notes";

  // Simulate typing when scrolled to the Command section
  useEffect(() => {
    const handleScroll = () => {
      const scrollPos = window.scrollY;
      const trigger = window.innerHeight * 3.8;
      if (scrollPos > trigger && cmdInput === "") {
        let i = 0;
        const typing = setInterval(() => {
          setCmdInput(fullCommand.substring(0, i));
          i++;
          if (i > fullCommand.length) clearInterval(typing);
        }, 40);
        return () => clearInterval(typing);
      }
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, [cmdInput]);

  return (
    <div 
      ref={pageRef}
      className="noise-bg bg-[#020202] text-[#F3F3F3] min-h-screen select-none overflow-x-hidden font-sans ambient-warmth"
    >
      {/* Engineered custom cursor */}
      <motion.div
        className="fixed top-0 left-0 w-2.5 h-2.5 bg-white mix-blend-difference pointer-events-none z-[9999] hidden md:block"
        animate={{
          x: mouse.x - 5,
          y: mouse.y - 5,
          scale: hovered ? 3 : 1,
          rotate: hovered ? 45 : 0
        }}
        transition={{ type: 'spring', stiffness: 600, damping: 30, mass: 0.1 }}
      />

      {/* Intentionally Silent Header */}
      <header className="fixed top-0 inset-x-0 z-50 p-8 flex justify-between items-start pointer-events-none">
        <div className="font-mono text-xs uppercase tracking-[0.2em] font-medium pointer-events-auto text-white/90">
          LifeOS <span className="opacity-30">®</span>
        </div>
        <div className="flex flex-col items-end gap-1 pointer-events-auto">
          <Link 
            to="/auth"
            className="font-mono text-[10px] uppercase tracking-[0.25em] text-white/60 hover:text-white transition-colors duration-300"
            onMouseEnter={() => setHovered(true)}
            onMouseLeave={() => setHovered(false)}
          >
            Access Console
          </Link>
          <span className="font-mono text-[8px] uppercase tracking-[0.3em] text-white/20">
            System v1.0.42
          </span>
        </div>
      </header>

      {/* 1. Philosophical Opening (Silent & Immersive) */}
      <section className="relative h-screen flex flex-col items-center justify-center p-6 text-center z-10">
        <div className="space-y-12 flex flex-col items-center">
          {/* Subtle Breathing Orb */}
          <motion.div 
            animate={{ 
              boxShadow: [
                '0 0 0px 0px rgba(255,255,255,0.1)', 
                '0 0 30px 1px rgba(255,255,255,0.2)', 
                '0 0 0px 0px rgba(255,255,255,0.1)'
              ] 
            }}
            transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
            className="w-1.5 h-1.5 bg-white rounded-full"
          />
          
          <motion.h1 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1.5, ease: [0.16, 1, 0.3, 1] }}
            className="text-lg md:text-2xl lg:text-3xl font-light tracking-tight text-white/80 max-w-2xl leading-relaxed font-sans"
          >
            Your life generates more context <br className="hidden md:block"/>
            than memory can reliably hold.
          </motion.h1>
        </div>

        <div className="absolute bottom-16 flex flex-col items-center gap-2">
          <span className="font-mono text-[9px] uppercase tracking-[0.3em] text-white/25">Scroll to initialize</span>
          <div className="w-px h-10 bg-white/10" />
        </div>
      </section>

      {/* 2. Cognitive Overload (Asymmetric Visual Chaos) */}
      <section className="relative min-h-screen py-32 px-6 flex items-center justify-center border-t border-white/5 overflow-hidden">
        <div className="absolute inset-0 opacity-[0.03] pointer-events-none grid-bg" />
        
        {/* Layered fragments simulating mental overload */}
        <div className="absolute top-1/4 left-10 text-[10px] font-mono text-white/25 blur-[0.5px]">
          [cortex] warning: cache saturation 98%
        </div>
        <div className="absolute bottom-1/4 right-12 text-[10px] font-mono text-white/15 blur-[1.5px]">
          ledger.sync_delay = 18.4s;
        </div>
        <div className="absolute top-1/2 right-1/4 text-xs font-serif italic text-white/20 blur-[2px]">
          "What was that article I saved on Friday?"
        </div>
        <div className="absolute bottom-1/3 left-1/5 text-[9px] font-mono text-white/20">
          task_queue.size &gt; 120
        </div>

        <div className="max-w-4xl mx-auto text-center z-10 space-y-8">
          <h2 className="text-4xl md:text-6xl lg:text-7xl font-light tracking-tighter uppercase leading-[0.95] text-white/90">
            A calmer environment <br className="hidden md:block"/>
            for ambitious minds.
          </h2>
          <p className="text-sm font-mono text-white/40 tracking-wider max-w-lg mx-auto leading-relaxed">
            Most tools optimize tasks. Very few help you think. LifeOS is built with the conviction that clarity requires absolute spatial infrastructure.
          </p>
        </div>
      </section>

      {/* 3. The Concept of LifeOS (System Kernel Visual) */}
      <section className="relative min-h-screen py-32 px-6 md:px-12 lg:px-24 border-t border-white/5">
        <div className="max-w-6xl mx-auto flex flex-col lg:flex-row gap-24 items-center">
          <div className="flex-1 space-y-12">
            <span className="font-mono text-[9px] uppercase tracking-[0.25em] text-white/40">// The Core Thesis</span>
            <h3 className="text-3xl md:text-5xl font-light tracking-tight leading-tight max-w-md">
              Not another application. <br className="hidden md:block"/>
              An operating layer.
            </h3>
            <p className="text-sm text-white/50 font-mono leading-relaxed max-w-md">
              LifeOS does not demand your attention. It quietly sits below your conscious focus, acting as a personal command ledger that coordinates time, thoughts, tasks, and wealth into a single, unified cognitive architecture.
            </p>
          </div>

          <div className="flex-1 w-full aspect-square border border-white/5 bezel-border bg-white/[0.01] p-12 flex items-center justify-center relative overflow-hidden">
            {/* Minimalist Graphic Design Kernel Representation */}
            <div className="relative w-64 h-64 border border-white/10 rounded-full flex items-center justify-center">
              <div className="absolute inset-4 border border-white/5 rounded-full" />
              <div className="absolute inset-12 border border-white/5 rounded-full" />
              <div className="absolute inset-24 border border-white/5 rounded-full" />
              
              <div className="w-1.5 h-1.5 bg-white rounded-full absolute top-0" />
              <div className="w-1.5 h-1.5 bg-white/20 rounded-full absolute bottom-12 left-12" />
              <div className="w-1.5 h-1.5 bg-white/25 rounded-full absolute top-24 right-4" />
              
              {/* Rotating focal vector */}
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 40, repeat: Infinity, ease: "linear" }}
                className="absolute inset-0 flex items-center justify-center"
              >
                <div className="w-1/2 h-[1px] bg-white/20 origin-left -translate-y-1/2" />
              </motion.div>
            </div>
          </div>
        </div>
      </section>

      {/* 4. Visualized Editorial Workflows (Magazine spread spacing) */}
      <section className="relative py-32 px-6 md:px-12 lg:px-24 border-t border-white/5 bg-[#010101]">
        <div className="max-w-6xl mx-auto space-y-48">
          
          <div className="text-[10px] font-mono uppercase tracking-[0.3em] text-white/30 mb-24">
            System Subspaces // 01 - 04
          </div>

          {/* Chronos & Cortex */}
          <div className="grid grid-cols-1 md:grid-cols-12 gap-16 md:gap-24 items-start">
            <div className="md:col-span-6 space-y-12">
              <div className="aspect-[4/3] w-full bg-white/[0.01] border border-white/5 p-8 flex flex-col justify-between bezel-border">
                <span className="font-mono text-[9px] uppercase tracking-widest text-white/40">Chronos // Time Defense</span>
                <div className="space-y-4">
                  <div className="w-full h-[1px] bg-white/10" />
                  <div className="flex justify-between text-xs font-mono text-white/60">
                    <span>Deep Work Block</span>
                    <span>10:00 - 12:00</span>
                  </div>
                  <div className="w-full h-[1px] bg-technical-amber/20" />
                  <div className="flex justify-between text-xs font-mono text-technical-amber">
                    <span>Cognitive Recovery</span>
                    <span>12:00 - 12:30</span>
                  </div>
                </div>
                <span className="font-mono text-[8px] uppercase tracking-widest text-white/20">System Allocator</span>
              </div>
              <div className="space-y-4">
                <h4 className="text-2xl font-light uppercase tracking-tight">Time Topology</h4>
                <p className="text-xs font-mono text-white/40 leading-relaxed max-w-sm">
                  Your calendar shouldn't just record commitments. It should defend your attention, automatically staging recovery windows and preserving deep work.
                </p>
              </div>
            </div>

            <div className="md:col-span-6 space-y-12 md:mt-24">
              <div className="aspect-[4/3] w-full bg-white/[0.01] border border-white/5 p-8 flex flex-col justify-between bezel-border">
                <span className="font-mono text-[9px] uppercase tracking-widest text-white/40">Cortex // Thought Vault</span>
                <div className="space-y-3 font-mono text-xs text-white/50">
                  <div>&gt; linking: "Systems Design" to "Dieter Rams"</div>
                  <div>&gt; indexing: "Long-term Value Architecture"</div>
                  <div className="w-16 h-1 bg-white/20" />
                </div>
                <span className="font-mono text-[8px] uppercase tracking-widest text-white/20">Memory Compounding</span>
              </div>
              <div className="space-y-4">
                <h4 className="text-2xl font-light uppercase tracking-tight">Knowledge Graph</h4>
                <p className="text-xs font-mono text-white/40 leading-relaxed max-w-sm">
                  Thoughts are not linear. Cortex networks your notes, ideas, and observations directly to relevant timeline events and tasks. Information compounds over time.
                </p>
              </div>
            </div>
          </div>

          {/* Capital & Nexus */}
          <div className="grid grid-cols-1 md:grid-cols-12 gap-16 md:gap-24 items-start">
            <div className="md:col-span-6 space-y-12">
              <div className="aspect-[4/3] w-full bg-white/[0.01] border border-white/5 p-8 flex flex-col justify-between bezel-border">
                <span className="font-mono text-[9px] uppercase tracking-widest text-white/40">Capital // Ledger</span>
                <div className="flex items-end h-24 gap-3">
                  {[20, 45, 30, 75, 60].map((h, i) => (
                    <div key={i} className="flex-1 bg-white/10 h-full origin-bottom" style={{ height: `${h}%` }} />
                  ))}
                </div>
                <span className="font-mono text-[8px] uppercase tracking-widest text-white/20">Asset Defense Engine</span>
              </div>
              <div className="space-y-4">
                <h4 className="text-2xl font-light uppercase tracking-tight">Wealth Integration</h4>
                <p className="text-xs font-mono text-white/40 leading-relaxed max-w-sm">
                  No complex accounting schemes. Just a stark, high-fidelity ledger tracking real-time liquidity and capital trajectories to keep you grounded.
                </p>
              </div>
            </div>

            <div className="md:col-span-6 space-y-12 md:mt-24">
              <div className="aspect-[4/3] w-full bg-white/[0.01] border border-white/5 p-8 flex flex-col justify-between bezel-border">
                <span className="font-mono text-[9px] uppercase tracking-widest text-white/40">Nexus // Action Queue</span>
                <div className="space-y-3">
                  <div className="flex items-center gap-3 text-xs font-mono">
                    <div className="w-1.5 h-1.5 bg-technical-amber" />
                    <span className="text-white/80">Refactor landing design</span>
                  </div>
                  <div className="flex items-center gap-3 text-xs font-mono opacity-40">
                    <div className="w-1.5 h-1.5 border border-white" />
                    <span>Deploy server triggers</span>
                  </div>
                </div>
                <span className="font-mono text-[8px] uppercase tracking-widest text-white/20">Frictionless Execution</span>
              </div>
              <div className="space-y-4">
                <h4 className="text-2xl font-light uppercase tracking-tight">Execution Nexus</h4>
                <p className="text-xs font-mono text-white/40 leading-relaxed max-w-sm">
                  Convert intent into motion. Nexus handles prioritization queuing and dependency scheduling, allowing you to execute without hesitation.
                </p>
              </div>
            </div>
          </div>

        </div>
      </section>

      {/* 5. Natural Language Command Console (Interactive Terminal) */}
      <section className="relative min-h-screen py-32 px-6 flex flex-col items-center justify-center border-t border-white/5 grid-bg">
        <div className="max-w-3xl w-full space-y-12">
          <div className="text-center space-y-4">
            <span className="font-mono text-[9px] uppercase tracking-[0.3em] text-white/30">// Human + System Interface</span>
            <h3 className="text-3xl md:text-4xl font-light tracking-tight">Designed for natural intent.</h3>
          </div>

          <div className="w-full border border-white/10 bezel-border rounded-sm overflow-hidden bg-black/60 backdrop-blur-xl">
            <div className="px-4 py-3 border-b border-white/10 bg-white/[0.01] flex justify-between items-center">
              <span className="font-mono text-[9px] text-white/40">lifeos_command_ledger</span>
              <span className="w-2 h-2 rounded-full bg-technical-amber animate-pulse" />
            </div>

            <div className="p-8 border-b border-white/10 font-mono text-sm md:text-base flex items-center gap-3">
              <span className="text-technical-amber">~</span>
              <span>{cmdInput}</span>
              <span className="w-1.5 h-4 bg-white/60 animate-pulse" />
            </div>

            <div className="p-8 bg-white/[0.005] font-mono text-xs space-y-4">
              <span className="text-[10px] text-white/30 uppercase tracking-wider block">Real-time Resolution Log</span>
              
              <AnimatePresence>
                {cmdInput.length === fullCommand.length && (
                  <motion.div 
                    initial={{ opacity: 0, y: 5 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="space-y-2.5 text-white/60"
                  >
                    <div>[ok] system.optimize: Scheduled Deep Work Tomorrow @ 10:00</div>
                    <div>[ok] ledger.balance: Transferred $500 to Vault</div>
                    <div>[ok] cortex.sync: Linked Sync Notes to Active Task Graph</div>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </div>
        </div>
      </section>

      {/* 6. Human Relationship (Muted Emotional Warmth) */}
      <section className="relative min-h-screen py-32 px-6 flex flex-col justify-center items-center text-center border-t border-white/5">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-technical-amber/5 rounded-full blur-[120px] pointer-events-none" />
        <div className="max-w-2xl space-y-8 relative z-10">
          <h2 className="text-3xl md:text-5xl font-light tracking-tight leading-tight">
            Designed for long timelines.
          </h2>
          <p className="text-sm font-mono text-white/40 leading-relaxed max-w-lg mx-auto">
            We build for decades, not trends. LifeOS respects your attention, minimizes active context switches, and creates space for sustained deep work.
          </p>
        </div>
      </section>

      {/* 7. Technical Specifications (Teenage Engineering Hardware Spec style) */}
      <section className="relative py-32 px-6 md:px-12 lg:px-24 border-t border-white/5 bg-[#010101]">
        <div className="max-w-5xl mx-auto grid grid-cols-1 lg:grid-cols-12 gap-16 lg:gap-24">
          <div className="lg:col-span-4 space-y-6">
            <span className="font-mono text-[9px] uppercase tracking-[0.3em] text-white/30">// Hardware & Architecture</span>
            <h4 className="text-2xl font-light uppercase tracking-tight">System Specifications</h4>
            <p className="text-xs font-mono text-white/40 leading-relaxed">
              Every detail engineered for speed, privacy, and long-term data preservation.
            </p>
          </div>

          <div className="lg:col-span-8 border-t border-white/10">
            {[
              { label: "Core Runtime", val: "React 19 / TypeScript 5" },
              { label: "Data Pipeline", val: "Firebase Firestore / Real-time Sync" },
              { label: "Local Caching", val: "Optimistic State Cache Engine" },
              { label: "Motion Physics", val: "Framer Motion Elite (Machined Easing)" },
              { label: "Authentication", val: "E2E Secure Identity Tokens" },
              { label: "Build Output", val: "Statically Compiled Assets // Zero Bloat" }
            ].map((spec, i) => (
              <div 
                key={i} 
                className="flex justify-between items-center py-5 border-b border-white/10 group hover:bg-white/[0.01] transition-colors"
                onMouseEnter={() => setHovered(true)}
                onMouseLeave={() => setHovered(false)}
              >
                <span className="font-mono text-xs uppercase text-white/50 group-hover:text-white transition-colors">
                  {spec.label}
                </span>
                <span className="font-mono text-xs text-white/90">{spec.val}</span>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 8. Community / Intellectual Cohort */}
      <section className="relative py-32 px-6 md:px-12 lg:px-24 border-t border-white/5 text-center">
        <div className="max-w-2xl mx-auto space-y-12">
          <span className="font-mono text-[9px] uppercase tracking-[0.3em] text-white/30">// Cognitive Alliance</span>
          <p className="text-xl md:text-2xl font-light italic leading-relaxed text-white/70">
            "We do not need more tools to capture inputs. We need environments that support intentional decisions."
          </p>
          <div className="font-mono text-[10px] uppercase tracking-[0.25em] text-white/40">
            — Founders, Engineers, and Researchers at LifeOS
          </div>
        </div>
      </section>

      {/* 9. Final Close (Tactile Snap Button) */}
      <section className="relative h-screen flex flex-col items-center justify-center p-6 text-center border-t border-white/5">
        <div className="space-y-16 flex flex-col items-center">
          <h2 className="text-4xl md:text-6xl lg:text-8xl font-light tracking-tighter uppercase leading-none">
            Boot the Sequence.
          </h2>
          
          <div 
            onMouseEnter={() => setHovered(true)}
            onMouseLeave={() => setHovered(false)}
          >
            <TactileButton to="/auth">Initialize Workspace</TactileButton>
          </div>
        </div>
      </section>

      {/* Atmospheric Stark Footer */}
      <footer className="border-t border-white/10 p-8 md:p-16 flex flex-col md:flex-row justify-between items-start md:items-end gap-12 bg-black font-mono text-[9px] uppercase tracking-[0.25em] text-white/30">
        <div>
          <span className="text-white">LifeOS</span> // Build 1.0.42 <br/>
          (c) {new Date().getFullYear()} Cognitive Systems Inc.
        </div>
        
        <div className="flex gap-12">
          <div className="flex flex-col gap-2">
            <Link to="/privacy" className="hover:text-white transition-colors">Privacy Specifications</Link>
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
