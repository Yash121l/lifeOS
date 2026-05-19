import { Link } from 'react-router-dom';

export default function TermsOfService() {
  return (
    <div className="min-h-screen bg-neutral-950 text-neutral-50 font-sans py-20 px-6">
      <div className="max-w-3xl mx-auto">
        <Link to="/" className="text-indigo-400 hover:text-indigo-300 mb-8 inline-block">&larr; Back to Home</Link>
        <h1 className="text-4xl font-bold mb-8">Terms of Service</h1>
        
        <div className="space-y-6 text-neutral-300 leading-relaxed">
          <p>Last updated: May 20, 2026</p>
          
          <h2 className="text-2xl font-semibold text-white mt-8">1. Acceptance of Terms</h2>
          <p>By accessing or using the LifeOS app and website, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, then you may not access the service.</p>
          
          <h2 className="text-2xl font-semibold text-white mt-8">2. Subscriptions</h2>
          <p>Some parts of the Service are billed on a subscription basis ("Pro", "Family", "Student"). You will be billed in advance on a recurring and periodic basis depending on the type of subscription plan you select.</p>
          
          <h2 className="text-2xl font-semibold text-white mt-8">3. Accounts</h2>
          <p>When you create an account with us, you must provide information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service.</p>
          
          <h2 className="text-2xl font-semibold text-white mt-8">4. Changes</h2>
          <p>We reserve the right, at our sole discretion, to modify or replace these Terms at any time. We will provide notice of any significant changes.</p>
        </div>
      </div>
    </div>
  );
}
