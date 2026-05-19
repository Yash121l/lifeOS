import { Link } from 'react-router-dom';
import { Mail, MessageCircle, HelpCircle } from 'lucide-react';

export default function Support() {
  return (
    <div className="min-h-screen bg-neutral-950 text-neutral-50 font-sans py-20 px-6">
      <div className="max-w-3xl mx-auto">
        <Link to="/" className="text-indigo-400 hover:text-indigo-300 mb-8 inline-block">&larr; Back to Home</Link>
        <h1 className="text-4xl font-bold mb-4">Support & FAQ</h1>
        <p className="text-neutral-400 text-lg mb-12">How can we help you get the most out of LifeOS?</p>
        
        <div className="grid md:grid-cols-2 gap-6 mb-16">
          <div className="bg-white/5 border border-white/10 rounded-2xl p-6 hover:bg-white/10 transition-colors cursor-pointer">
            <Mail className="w-8 h-8 text-indigo-400 mb-4" />
            <h3 className="text-xl font-semibold mb-2">Email Support</h3>
            <p className="text-neutral-400 text-sm">Get help from our team within 24 hours at support@lifeos.app</p>
          </div>
          <div className="bg-white/5 border border-white/10 rounded-2xl p-6 hover:bg-white/10 transition-colors cursor-pointer">
            <MessageCircle className="w-8 h-8 text-emerald-400 mb-4" />
            <h3 className="text-xl font-semibold mb-2">Community Discord</h3>
            <p className="text-neutral-400 text-sm">Join other high performers in our private Discord server.</p>
          </div>
        </div>

        <h2 className="text-2xl font-semibold text-white mb-6">Frequently Asked Questions</h2>
        <div className="space-y-4">
          <div className="bg-white/5 border border-white/10 rounded-xl p-5">
            <h4 className="font-medium text-lg flex items-center gap-2 mb-2"><HelpCircle className="w-5 h-5 text-indigo-400"/> Is there an Android version?</h4>
            <p className="text-neutral-400 text-sm">Currently, LifeOS is iOS-first (iOS 17+) to take full advantage of Apple's ecosystem including Dynamic Island and WidgetKit. An Android version is on our long-term roadmap.</p>
          </div>
          <div className="bg-white/5 border border-white/10 rounded-xl p-5">
            <h4 className="font-medium text-lg flex items-center gap-2 mb-2"><HelpCircle className="w-5 h-5 text-indigo-400"/> Is my financial data safe?</h4>
            <p className="text-neutral-400 text-sm">Yes. We use read-only APIs via Plaid and Salt Edge. Your tokens are securely stored in the iOS Keychain, never on our servers.</p>
          </div>
          <div className="bg-white/5 border border-white/10 rounded-xl p-5">
            <h4 className="font-medium text-lg flex items-center gap-2 mb-2"><HelpCircle className="w-5 h-5 text-indigo-400"/> How does the AI rescheduling work?</h4>
            <p className="text-neutral-400 text-sm">LifeOS monitors your calendar blocks in real-time. If a meeting runs late, it automatically pushes all subsequent tasks forward, respecting your hard deadlines.</p>
          </div>
        </div>
      </div>
    </div>
  );
}
