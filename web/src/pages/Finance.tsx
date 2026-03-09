import { AreaChart, Area, Tooltip, ResponsiveContainer } from 'recharts';
import { ArrowUpRight, Wallet, CreditCard, Landmark } from 'lucide-react';

const data = [
  { name: 'Jan', value: 12000 },
  { name: 'Feb', value: 15000 },
  { name: 'Mar', value: 14000 },
  { name: 'Apr', value: 18000 },
  { name: 'May', value: 17500 },
  { name: 'Jun', value: 22000 },
];

const transactions = [
  { id: 1, name: 'Apple Setup', category: 'Tech', amount: -299.00, date: 'Today, 2:40 PM', type: 'expense' },
  { id: 2, name: 'Salary', category: 'Income', amount: 4500.00, date: 'Yesterday', type: 'income' },
  { id: 3, name: 'Whole Foods', category: 'Groceries', amount: -84.50, date: 'Yesterday', type: 'expense' },
  { id: 4, name: 'Uber Server', category: 'Transport', amount: -24.00, date: 'Mon, 12:00 PM', type: 'expense' },
];

export default function Finance() {
  return (
    <div className="finance-view flex flex-col h-full animate-fade-in no-scrollbar">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold mb-1 text-primary">Finance</h1>
          <p className="text-sm text-secondary">Track your net worth, budgets, and automated expenses.</p>
        </div>
        <button className="btn btn-primary h-[38px]">
          <Wallet size={16} /> Link Account (Plaid)
        </button>
      </div>

      <div className="grid grid-cols-3 gap-6 mb-8">
        <div className="glass-card p-6 col-span-2 flex flex-col">
          <div className="flex justify-between items-start mb-6">
            <div>
              <p className="text-sm text-secondary font-medium mb-1">Total Net Worth</p>
              <h2 className="text-3xl font-bold text-primary">$22,000.00</h2>
            </div>
            <div className="flex items-center gap-1 text-success text-sm font-semibold tracking-wide bg-[rgba(16,185,129,0.1)] px-3 py-1.5 rounded-full">
               <ArrowUpRight size={16} /> +14.2% (YTD)
            </div>
          </div>
          <div className="flex-1 min-h-[200px] -mx-2">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data}>
                <defs>
                  <linearGradient id="colorValue" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="var(--accent-primary)" stopOpacity={0.4}/>
                    <stop offset="95%" stopColor="var(--accent-primary)" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <Tooltip 
                  contentStyle={{ backgroundColor: 'var(--bg-tertiary)', borderColor: 'var(--border-strong)', borderRadius: '8px' }}
                  itemStyle={{ color: 'var(--text-primary)' }}
                />
                <Area type="monotone" dataKey="value" stroke="var(--accent-primary)" strokeWidth={3} fillOpacity={1} fill="url(#colorValue)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="flex flex-col gap-6">
          <div className="glass-card p-5 border-l-4 border-l-success flex items-center gap-4">
            <div className="bg-[rgba(16,185,129,0.1)] p-3 rounded-full text-success">
               <Landmark size={24} />
            </div>
            <div>
               <p className="text-sm text-secondary">Chase Checking</p>
               <p className="font-bold text-lg">$14,240.50</p>
            </div>
          </div>

          <div className="glass-card p-5 border-l-4 border-l-accent-primary flex items-center gap-4">
            <div className="bg-[rgba(59,130,246,0.1)] p-3 rounded-full text-accent-primary">
               <CreditCard size={24} />
            </div>
            <div>
               <p className="text-sm text-secondary">Amex Platinum</p>
               <p className="font-bold text-lg">-$2,400.00</p>
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-6 pb-8">
         <div className="glass-card p-6">
            <h3 className="font-semibold text-lg mb-4">Recent Transactions</h3>
            <div className="flex flex-col gap-4">
              {transactions.map(tx => (
                <div key={tx.id} className="flex items-center justify-between p-3 rounded-lg hover:bg-[rgba(255,255,255,0.03)] transition-colors cursor-pointer border border-transparent hover:border-[var(--border-subtle)]">
                   <div className="flex items-center gap-3">
                     <div className="w-10 h-10 rounded-full bg-secondary flex items-center justify-center text-primary font-medium">
                        {tx.name.charAt(0)}
                     </div>
                     <div>
                       <p className="font-medium text-sm text-primary">{tx.name}</p>
                       <p className="text-xs text-tertiary">{tx.category} • {tx.date}</p>
                     </div>
                   </div>
                   <div className={`font-semibold text-sm ${tx.type === 'income' ? 'text-success' : 'text-primary'}`}>
                      {tx.type === 'income' ? '+' : ''}{tx.amount.toLocaleString('en-US', { style: 'currency', currency: 'USD' })}
                   </div>
                </div>
              ))}
            </div>
         </div>

         <div className="glass-card p-6">
            <h3 className="font-semibold text-lg mb-4">Monthly Budgets</h3>
            <div className="flex flex-col gap-6">
               <div>
                 <div className="flex justify-between text-sm mb-2">
                    <span className="text-primary font-medium">Food & Dining</span>
                    <span className="text-secondary">$450 / $600</span>
                 </div>
                 <div className="w-full bg-secondary h-2 rounded-full overflow-hidden">
                    <div className="bg-warning h-full rounded-full" style={{ width: '75%' }} />
                 </div>
               </div>
               
               <div>
                 <div className="flex justify-between text-sm mb-2">
                    <span className="text-primary font-medium">Shopping</span>
                    <span className="text-secondary">$820 / $800</span>
                 </div>
                 <div className="w-full bg-secondary h-2 rounded-full overflow-hidden">
                    <div className="bg-error h-full rounded-full" style={{ width: '100%' }} />
                 </div>
                 <p className="text-xs text-error mt-2">Over budget by $20</p>
               </div>
            </div>
         </div>
      </div>
    </div>
  );
}
