import React, { useMemo, useState } from 'react';
import {
  TrendingUp,
  TrendingDown,
  Plus,
  ArrowUpRight,
  ArrowDownRight,
  Wallet,
  CreditCard,
  DollarSign,
  Calendar,
  Filter,
  Search,
  MoreHorizontal,
  Trash2,
  PieChart as PieChartIcon
} from 'lucide-react';
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
} from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Progress } from '@/components/ui/progress';
import {
  Area,
  AreaChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
  Cell,
  Pie,
  PieChart,
} from 'recharts';
import { formatCurrency } from '../../core/utils/formatters';
import { type TransactionItem, createTransactionItem } from '../../core/models/index';
import { useData } from '../data/DataProvider';

const CATEGORIES = [
  'Housing',
  'Food',
  'Transport',
  'Utilities',
  'Entertainment',
  'Health',
  'Shopping',
  'Other',
];

export default function FinancePage() {
  const { deleteTransaction, saveTransaction, transactions } = useData();
  const [amount, setAmount] = useState('');
  const [category, setCategory] = useState(CATEGORIES[0]);
  const [description, setDescription] = useState('');
  const [isExpense, setIsExpense] = useState(true);

  const balance = transactions.reduce((total, tx) => {
    return total + (tx.isExpense ? -tx.amount : tx.amount);
  }, 0);

  const totalIncome = transactions
    .filter((tx) => !tx.isExpense)
    .reduce((total, tx) => total + tx.amount, 0);

  const totalExpenses = transactions
    .filter((tx) => tx.isExpense)
    .reduce((total, tx) => total + tx.amount, 0);

  const chartData = useMemo(() => {
    // Group transactions by day for the last 7 days
    const last7Days = Array.from({ length: 7 }, (_, i) => {
      const date = new Date();
      date.setDate(date.getDate() - (6 - i));
      return date.toLocaleDateString([], { weekday: 'short' });
    });

    return last7Days.map((day) => ({
      name: day,
      amount: Math.floor(Math.random() * 5000) + 1000, // Placeholder data for visualization
    }));
  }, [transactions]);

  const categoryData = useMemo(() => {
    return CATEGORIES.map(cat => ({
      name: cat,
      value: transactions
        .filter(tx => tx.category === cat && tx.isExpense)
        .reduce((sum, tx) => sum + tx.amount, 0) || Math.floor(Math.random() * 500) // Placeholder
    })).filter(d => d.value > 0);
  }, [transactions]);

  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8', '#82ca9d', '#ffc658', '#8dd1e1'];

  async function handleAddTransaction(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!amount || isNaN(Number(amount))) return;

    const transaction = createTransactionItem({
      amount: Number(amount),
      category,
      title: description.trim() || category,
      isExpense,
      date: new Date(),
    });

    await saveTransaction(transaction);
    setAmount('');
    setDescription('');
  }

  return (
    <div className="flex flex-col gap-8 pb-12 animate-in fade-in duration-700">
      {/* Header Section */}
      <section className="flex flex-col gap-6 md:flex-row md:items-end md:justify-between">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <span className="flex h-2 w-2 rounded-full bg-blue-500" />
            <p className="text-xs font-bold uppercase tracking-[0.2em] text-blue-400/90">Treasury</p>
          </div>
          <h2 className="font-display text-2xl font-bold tracking-tight sm:text-3xl text-gradient-apple">Financial Ledger</h2>
          <p className="text-muted-foreground text-sm max-w-xl leading-relaxed">
            Monitor liquidity, track expenditures, and optimize your personal capital flow.
          </p>
        </div>
        <div className="flex items-center gap-3">
           <Badge variant="outline" className="glass px-3 py-1 text-[10px] uppercase tracking-wider font-semibold">
            Status: Stable
          </Badge>
          <Badge variant="outline" className="glass px-3 py-1 text-[10px] uppercase tracking-wider font-semibold">
            <TrendingUp size={12} className="mr-2 text-emerald-400" />
            +12.4% MoM
          </Badge>
        </div>
      </section>

      {/* Main Stats Grid */}
      <section className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <Card className="glass relative overflow-hidden group border-white/[0.05]">
          <div className="absolute top-0 right-0 w-32 h-32 bg-blue-500/10 rounded-full blur-3xl -mr-16 -mt-16 group-hover:bg-blue-500/20 transition-colors" />
          <CardHeader className="pb-2">
            <CardTitle className="text-xs font-bold uppercase tracking-widest text-muted-foreground/70">Total Liquidity</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-4xl font-display font-bold text-gradient-blue">{formatCurrency(balance)}</div>
            <p className="text-xs text-muted-foreground mt-2 flex items-center gap-1.5 font-medium">
              <TrendingUp size={12} className="text-emerald-400" />
              <span className="text-emerald-400">+2.1%</span> from yesterday
            </p>
          </CardContent>
        </Card>

        <Card className="glass relative overflow-hidden group border-white/[0.05]">
          <CardHeader className="pb-2">
            <CardTitle className="text-xs font-bold uppercase tracking-widest text-muted-foreground/70">Monthly Inflow</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-display font-bold text-emerald-400">{formatCurrency(totalIncome)}</div>
            <div className="mt-4 space-y-2">
              <div className="flex items-center justify-between text-[10px] uppercase font-bold tracking-tighter opacity-60">
                <span>Target</span>
                <span>84%</span>
              </div>
              <Progress value={84} className="h-1 bg-white/5" />
            </div>
          </CardContent>
        </Card>

        <Card className="glass relative overflow-hidden group border-white/[0.05]">
          <CardHeader className="pb-2">
            <CardTitle className="text-xs font-bold uppercase tracking-widest text-muted-foreground/70">Expenditure Burn</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-display font-bold text-rose-400">{formatCurrency(totalExpenses)}</div>
            <div className="mt-4 space-y-2">
              <div className="flex items-center justify-between text-[10px] uppercase font-bold tracking-tighter opacity-60">
                <span>Limit</span>
                <span>$4,000.00</span>
              </div>
              <Progress value={Math.min((totalExpenses / 4000) * 100, 100)} className="h-1 bg-white/5" />
            </div>
          </CardContent>
        </Card>
      </section>

      {/* Charts and Entry Section */}
      <section className="grid gap-8 lg:grid-cols-2">
        {/* Trend Visualization */}
        <Card className="glass border-white/[0.05] overflow-hidden flex flex-col">
          <CardHeader className="bg-white/[0.02] border-b border-white/[0.05]">
            <div className="flex items-center justify-between">
               <CardTitle className="text-xl font-display">Capital Velocity</CardTitle>
               <div className="flex items-center gap-2">
                 <Badge variant="secondary" className="bg-white/5 text-[10px] uppercase font-bold">7D</Badge>
                 <Badge variant="ghost" className="text-muted-foreground text-[10px] uppercase font-bold">30D</Badge>
               </div>
            </div>
          </CardHeader>
          <CardContent className="pt-8 flex-1">
            <div className="h-[240px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={chartData}>
                  <defs>
                    <linearGradient id="colorAmt" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#007AFF" stopOpacity={0.3} />
                      <stop offset="95%" stopColor="#007AFF" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <XAxis 
                    dataKey="name" 
                    axisLine={false} 
                    tickLine={false} 
                    tick={{ fill: 'hsl(var(--muted-foreground))', fontSize: 10, fontWeight: 600 }}
                  />
                  <Tooltip 
                    contentStyle={{ backgroundColor: 'hsl(var(--card))', borderRadius: '12px', border: '1px solid hsla(var(--border), 0.1)', fontSize: '12px' }}
                    itemStyle={{ color: '#007AFF', fontWeight: 'bold' }}
                  />
                  <Area
                    type="monotone"
                    dataKey="amount"
                    stroke="#007AFF"
                    strokeWidth={2}
                    fillOpacity={1}
                    fill="url(#colorAmt)"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        {/* Transaction Entry */}
        <Card className="glass border-white/[0.05] overflow-hidden">
          <CardHeader className="bg-white/[0.02] border-b border-white/[0.05]">
            <CardTitle className="text-xl font-display">New Entry</CardTitle>
            <CardDescription className="text-xs">Log financial movements manually.</CardDescription>
          </CardHeader>
          <CardContent className="pt-6">
            <form onSubmit={handleAddTransaction} className="space-y-6">
              <div className="grid grid-cols-2 gap-2 p-1 bg-black/40 rounded-xl border border-white/5">
                <Button
                  type="button"
                  variant={isExpense ? 'default' : 'ghost'}
                  className={`h-9 rounded-lg text-xs font-bold uppercase tracking-wider transition-all ${isExpense ? 'bg-rose-500/20 text-rose-400 hover:bg-rose-500/30' : 'text-muted-foreground'}`}
                  onClick={() => setIsExpense(true)}
                >
                  Expense
                </Button>
                <Button
                  type="button"
                  variant={!isExpense ? 'default' : 'ghost'}
                  className={`h-9 rounded-lg text-xs font-bold uppercase tracking-wider transition-all ${!isExpense ? 'bg-emerald-500/20 text-emerald-400 hover:bg-emerald-500/30' : 'text-muted-foreground'}`}
                  onClick={() => setIsExpense(false)}
                >
                  Income
                </Button>
              </div>

              <div className="grid gap-6 sm:grid-cols-2">
                <div className="space-y-2">
                   <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Capital Amount</label>
                   <div className="relative">
                     <DollarSign size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
                     <Input
                        className="pl-9 h-11 border-white/5 bg-black/40 text-sm font-bold placeholder:text-muted-foreground/30 focus-visible:ring-blue-500/50"
                        placeholder="0.00"
                        value={amount}
                        onChange={(e) => setAmount(e.target.value)}
                        required
                      />
                   </div>
                </div>

                <div className="space-y-2">
                  <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Classification</label>
                  <select
                    className="flex h-11 w-full rounded-xl border border-white/5 bg-black/40 px-3 py-2 text-xs font-bold appearance-none outline-none focus:ring-1 focus:ring-blue-500/50 transition-all cursor-pointer"
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                  >
                    {CATEGORIES.map((cat) => (
                      <option key={cat} value={cat}>{cat}</option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Description</label>
                <Input
                  className="h-11 border-white/5 bg-black/40 text-sm font-medium placeholder:text-muted-foreground/30 focus-visible:ring-blue-500/50"
                  placeholder="E.g. Monthly infrastructure hosting"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                />
              </div>

              <Button type="submit" className="h-12 w-full rounded-2xl bg-[#007AFF] hover:bg-[#007AFF]/90 text-white font-bold uppercase tracking-widest text-xs transition-all hover:shadow-[0_0_20px_rgba(0,122,255,0.3)]">
                Record Transaction
              </Button>
            </form>
          </CardContent>
        </Card>
      </section>

      {/* Transaction History */}
      <section className="space-y-6">
        <div className="flex items-center justify-between">
          <div className="space-y-1">
             <h3 className="text-xl font-display font-medium">Recent Activity</h3>
             <p className="text-xs text-muted-foreground font-medium uppercase tracking-[0.1em]">Verified transaction history</p>
          </div>
          <div className="flex items-center gap-2">
            <Button variant="outline" size="sm" className="glass h-8 px-3 text-[10px] uppercase font-bold tracking-widest">
              <Filter size={12} className="mr-2" /> Filter
            </Button>
            <Button variant="outline" size="sm" className="glass h-8 px-3 text-[10px] uppercase font-bold tracking-widest">
              Export CSV
            </Button>
          </div>
        </div>

        <Card className="glass border-white/[0.05] overflow-hidden">
          <div className="flex flex-col divide-y divide-white/5">
            {transactions.length > 0 ? (
              [...transactions].reverse().slice(0, 10).map((tx) => (
                <div key={tx.id} className="group relative flex items-center justify-between gap-4 p-4 hover:bg-white/[0.02] transition-colors">
                  <div className="flex items-center gap-4">
                    <div className={`h-11 w-11 rounded-2xl flex items-center justify-center transition-transform group-hover:scale-110 ${tx.isExpense ? 'bg-rose-500/10 text-rose-500' : 'bg-emerald-500/10 text-emerald-500'}`}>
                      {tx.isExpense ? <ArrowDownRight size={20} /> : <ArrowUpRight size={20} />}
                    </div>
                    <div className="min-w-0">
                      <strong className="block truncate text-sm font-semibold tracking-tight leading-tight">{tx.description}</strong>
                      <div className="flex items-center gap-2 mt-1">
                        <span className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">{tx.category}</span>
                        <span className="h-0.5 w-0.5 rounded-full bg-white/20" />
                        <span className="text-[10px] font-bold text-muted-foreground/60">{tx.date.toLocaleDateString()}</span>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-6">
                    <div className="text-right">
                       <strong className={`block text-sm font-bold tracking-tight ${tx.isExpense ? 'text-white' : 'text-emerald-400'}`}>
                         {tx.isExpense ? '-' : '+'}{formatCurrency(tx.amount)}
                       </strong>
                       <span className="block text-[9px] font-bold uppercase tracking-tighter text-muted-foreground/40 leading-none mt-1">Confirmed</span>
                    </div>
                    <Button 
                      variant="ghost" 
                      size="icon" 
                      className="h-8 w-8 text-muted-foreground/30 hover:text-rose-400 hover:bg-rose-400/10 transition-colors opacity-0 group-hover:opacity-100"
                      onClick={() => void deleteTransaction(tx.id)}
                    >
                      <Trash2 size={14} />
                    </Button>
                  </div>
                </div>
              ))
            ) : (
              <div className="py-20 text-center opacity-30">
                 <Wallet size={40} className="mx-auto mb-4" />
                 <p className="text-sm font-bold uppercase tracking-widest">No entries recorded</p>
              </div>
            )}
          </div>
        </Card>
      </section>
    </div>
  );
}
