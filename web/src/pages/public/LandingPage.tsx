import { motion, useScroll, useTransform } from 'framer-motion';
import { ChevronRight, Calendar, CheckCircle, PieChart, Book, Apple } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useRef } from 'react';

export default function LandingPage() {
  const { scrollY } = useScroll();
  const heroRef = useRef(null);
  const { scrollYProgress } = useScroll({
    target: heroRef,
    offset: ['start start', 'end start']
  });

  // Parallax transforms
  const yHeroText = useTransform(scrollYProgress, [0, 1], [0, 300]);
  const opacityHeroText = useTransform(scrollYProgress, [0, 0.8], [1, 0]);
  const scaleHeroImage = useTransform(scrollYProgress, [0, 1], [1, 1.2]);
  
  const bgGradientY = useTransform(scrollY, [0, 1000], [0, -200]);

  const features = [
    {
      title: 'Time & Schedule',
      description: 'A unified calendar that respects your deep work and auto-reschedules conflicts.',
      icon: <Calendar className="w-8 h-8 text-indigo-400" />,
      color: 'from-indigo-500/20 to-indigo-500/5',
      borderColor: 'border-indigo-500/20',
      delay: 0.1
    },
    {
      title: 'Task Intelligence',
      description: 'Natural language input with auto-prioritization using the Eisenhower matrix.',
      icon: <CheckCircle className="w-8 h-8 text-emerald-400" />,
      color: 'from-emerald-500/20 to-emerald-500/5',
      borderColor: 'border-emerald-500/20',
      delay: 0.2
    },
    {
      title: 'Wealth Tracking',
      description: 'Real-time account aggregation and smart budget guardrails.',
      icon: <PieChart className="w-8 h-8 text-amber-400" />,
      color: 'from-amber-500/20 to-amber-500/5',
      borderColor: 'border-amber-500/20',
      delay: 0.3
    },
    {
      title: 'Knowledge Base',
      description: 'Quick capture notes with bi-directional linking to tasks and events.',
      icon: <Book className="w-8 h-8 text-sky-400" />,
      color: 'from-sky-500/20 to-sky-500/5',
      borderColor: 'border-sky-500/20',
      delay: 0.4
    }
  ];

  return (
    <div className="min-h-screen bg-neutral-950 text-neutral-50 font-sans overflow-x-hidden selection:bg-indigo-500/30">
      
      {/* Dynamic Animated Background Glow */}
      <motion.div 
        style={{ y: bgGradientY }}
        className="fixed top-[-20%] left-[-10%] w-[120%] h-[120%] z-0 pointer-events-none"
      >
        <div className="absolute top-1/4 left-1/4 w-[600px] h-[600px] bg-indigo-600/20 rounded-full blur-[150px] mix-blend-screen animate-pulse" />
        <div className="absolute top-1/3 right-1/4 w-[500px] h-[500px] bg-purple-600/20 rounded-full blur-[120px] mix-blend-screen" />
        <div className="absolute bottom-1/4 left-1/3 w-[700px] h-[700px] bg-emerald-600/10 rounded-full blur-[150px] mix-blend-screen" />
      </motion.div>

      {/* Navbar */}
      <nav className="fixed top-0 inset-x-0 z-50 backdrop-blur-2xl bg-neutral-950/40 border-b border-white/5">
        <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3 group cursor-pointer">
            <div className="w-8 h-8 rounded-xl bg-gradient-to-tr from-indigo-500 to-purple-500 flex items-center justify-center shadow-[0_0_20px_rgba(99,102,241,0.3)] group-hover:shadow-[0_0_30px_rgba(99,102,241,0.5)] transition-shadow duration-500">
              <span className="font-bold text-white text-lg leading-none tracking-tighter">L</span>
            </div>
            <span className="font-semibold text-lg tracking-tight">LifeOS</span>
          </div>
          <div className="flex items-center gap-6">
            <Link to="/auth" className="text-sm font-medium text-neutral-400 hover:text-white transition-colors">Log In</Link>
            <Link to="/auth" className="text-sm font-medium bg-white text-black px-4 py-2 rounded-full hover:scale-105 hover:bg-neutral-200 transition-all duration-300 shadow-[0_0_20px_rgba(255,255,255,0.1)]">
              Get Started
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section with Parallax */}
      <section ref={heroRef} className="relative min-h-[100vh] flex items-center justify-center px-6 pt-20 z-10">
        <motion.div 
          style={{ y: yHeroText, opacity: opacityHeroText }}
          className="max-w-5xl mx-auto text-center"
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
          >
            <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/5 border border-white/10 text-sm font-medium text-indigo-300 mb-8 backdrop-blur-md shadow-2xl">
              <span className="w-2 h-2 rounded-full bg-indigo-400 animate-[pulse_2s_ease-in-out_infinite]" />
              LifeOS v1.0 is now available
            </span>
          </motion.div>
          
          <motion.h1 
            className="text-6xl md:text-8xl lg:text-9xl font-bold tracking-tighter leading-[1.05] mb-8"
            initial={{ opacity: 0, y: 40 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.1, ease: [0.16, 1, 0.3, 1] }}
          >
            Stop managing apps.<br />
            <span className="bg-gradient-to-r from-indigo-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
              Start managing your life.
            </span>
          </motion.h1>
          
          <motion.p 
            className="text-xl lg:text-2xl text-neutral-400 mb-12 max-w-3xl mx-auto font-light leading-relaxed"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2, ease: [0.16, 1, 0.3, 1] }}
          >
            When your calendar knows your budget, your tasks know your location, and your notes are linked to your schedule. The unified system for high performers.
          </motion.p>
          
          <motion.div 
            className="flex flex-col sm:flex-row items-center justify-center gap-6"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.3, ease: [0.16, 1, 0.3, 1] }}
          >
            <button className="flex items-center justify-center gap-3 bg-white text-black px-8 py-4 rounded-full font-semibold text-lg hover:scale-105 transition-all duration-300 shadow-[0_0_40px_rgba(255,255,255,0.2)] w-full sm:w-auto">
              <Apple className="w-6 h-6 fill-black" />
              Download for iOS
            </button>
            <Link to="/auth" className="group flex items-center justify-center gap-2 px-8 py-4 rounded-full font-semibold text-lg text-white bg-white/5 border border-white/10 hover:bg-white/10 transition-all duration-300 w-full sm:w-auto">
              Open Web App
              <ChevronRight className="w-5 h-5 text-neutral-400 group-hover:text-white group-hover:translate-x-1 transition-all" />
            </Link>
          </motion.div>
        </motion.div>

        {/* Abstract Floating UI Elements for Parallax */}
        <motion.div 
          style={{ y: useTransform(scrollYProgress, [0, 1], [0, -400]), scale: scaleHeroImage }}
          className="absolute right-[-5%] top-[20%] w-64 h-64 bg-indigo-500/10 rounded-3xl border border-white/5 backdrop-blur-3xl rotate-12 pointer-events-none hidden lg:block"
        />
        <motion.div 
          style={{ y: useTransform(scrollYProgress, [0, 1], [0, -200]) }}
          className="absolute left-[-2%] bottom-[20%] w-48 h-48 bg-purple-500/10 rounded-full border border-white/5 backdrop-blur-3xl pointer-events-none hidden lg:block"
        />
      </section>

      {/* Bento Grid Features Section with Scroll Reveals */}
      <section className="py-32 px-6 relative z-10">
        <div className="max-w-7xl mx-auto">
          <motion.div 
            className="text-center mb-24"
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.8, ease: "easeOut" }}
          >
            <h2 className="text-4xl lg:text-6xl font-bold tracking-tighter mb-6">Everything in one place.</h2>
            <p className="text-neutral-400 text-xl max-w-2xl mx-auto font-light">Four powerful modules designed to work seamlessly together, eliminating context switching forever.</p>
          </motion.div>
          
          <div className="grid md:grid-cols-2 gap-8 lg:gap-10">
            {features.map((feature, index) => (
              <motion.div 
                key={feature.title}
                initial={{ opacity: 0, y: 60, scale: 0.95 }}
                whileInView={{ opacity: 1, y: 0, scale: 1 }}
                viewport={{ once: true, margin: "-50px" }}
                transition={{ duration: 0.8, delay: feature.delay, ease: [0.16, 1, 0.3, 1] }}
                whileHover={{ y: -10, scale: 1.02 }}
                className={`group p-10 rounded-[2.5rem] bg-gradient-to-br ${feature.color} border ${feature.borderColor} backdrop-blur-md shadow-2xl relative overflow-hidden`}
              >
                <div className="absolute inset-0 bg-gradient-to-br from-white/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
                <div className="relative z-10">
                  <div className="w-16 h-16 rounded-2xl bg-black/50 flex items-center justify-center mb-8 border border-white/5 shadow-inner group-hover:scale-110 transition-transform duration-500">
                    {feature.icon}
                  </div>
                  <h3 className="text-3xl font-semibold mb-4 tracking-tight">{feature.title}</h3>
                  <p className="text-neutral-400 leading-relaxed text-lg font-light">
                    {feature.description}
                  </p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Full-width Call to Action with Scroll Scale */}
      <section className="py-32 px-6 relative z-10 overflow-hidden">
        <motion.div 
          initial={{ opacity: 0, scale: 0.9 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 1, ease: "easeOut" }}
          className="max-w-6xl mx-auto rounded-[3rem] bg-gradient-to-br from-indigo-900/40 to-purple-900/40 border border-white/10 p-12 md:p-24 text-center relative backdrop-blur-xl shadow-2xl"
        >
          <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-10 mix-blend-overlay" />
          <h2 className="text-4xl md:text-6xl font-bold tracking-tighter mb-8 relative z-10">Ready to take control?</h2>
          <p className="text-xl text-indigo-200/70 mb-10 max-w-2xl mx-auto font-light relative z-10">Join thousands of high performers who have unified their workflow with LifeOS.</p>
          <button className="relative z-10 bg-white text-black px-10 py-5 rounded-full font-semibold text-lg hover:scale-105 transition-all duration-300 shadow-[0_0_40px_rgba(255,255,255,0.3)]">
            Get LifeOS for iOS
          </button>
        </motion.div>
      </section>

      {/* Footer */}
      <footer className="border-t border-white/5 py-12 px-6 relative z-10 bg-black/50 backdrop-blur-lg">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center gap-6">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-xl bg-gradient-to-tr from-indigo-500 to-purple-500 flex items-center justify-center">
              <span className="font-bold text-white text-sm">L</span>
            </div>
            <span className="font-medium text-neutral-300 text-lg">LifeOS</span>
          </div>
          <div className="flex gap-8 text-sm text-neutral-400 font-medium">
            <Link to="/privacy" className="hover:text-white transition-colors">Privacy Policy</Link>
            <Link to="/terms" className="hover:text-white transition-colors">Terms of Service</Link>
            <Link to="/support" className="hover:text-white transition-colors">Support</Link>
          </div>
          <p className="text-sm text-neutral-600 font-medium">© 2026 LifeOS Inc. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
