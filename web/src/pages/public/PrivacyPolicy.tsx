import { Link } from 'react-router-dom';

export default function PrivacyPolicy() {
  return (
    <div className="min-h-screen bg-neutral-950 text-neutral-50 font-sans py-20 px-6">
      <div className="max-w-3xl mx-auto">
        <Link to="/" className="text-indigo-400 hover:text-indigo-300 mb-8 inline-block">&larr; Back to Home</Link>
        <h1 className="text-4xl font-bold mb-8">Privacy Policy</h1>
        
        <div className="space-y-6 text-neutral-300 leading-relaxed">
          <p>Last updated: May 20, 2026</p>
          
          <h2 className="text-2xl font-semibold text-white mt-8">1. Introduction</h2>
          <p>Welcome to LifeOS. We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we look after your personal data when you visit our website or use our iOS application.</p>
          
          <h2 className="text-2xl font-semibold text-white mt-8">2. Data We Collect</h2>
          <ul className="list-disc pl-5 space-y-2">
            <li><strong>Identity Data:</strong> First name, last name, email address.</li>
            <li><strong>Task & Schedule Data:</strong> Stored securely using Firebase Firestore with strict security rules.</li>
            <li><strong>Location Data:</strong> Processed entirely on-device via CoreLocation. No GPS coordinates are ever sent to our servers.</li>
            <li><strong>Financial Data:</strong> Bank integration tokens are stored securely in your iOS Keychain. We do not transmit or store your bank credentials on our servers.</li>
          </ul>
          
          <h2 className="text-2xl font-semibold text-white mt-8">3. How We Use Your Data</h2>
          <p>We use your data solely to provide and improve the LifeOS service. We do not sell your data to third parties, nor do we use it for advertising purposes.</p>
          
          <h2 className="text-2xl font-semibold text-white mt-8">4. Data Security</h2>
          <p>We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used, or accessed in an unauthorized way. Data sync is secured via Firebase Firestore.</p>
          
          <h2 className="text-2xl font-semibold text-white mt-8">5. Contact Us</h2>
          <p>If you have any questions about this privacy policy, please contact us at privacy@lifeos.app.</p>
        </div>
      </div>
    </div>
  );
}
