import { useMemo, useState } from 'react';
import { formatCurrency } from '../../lib/formatters';
import { createTransactionItem } from '../../lib/models';
import { useData } from '../data/DataProvider';

export default function FinancePage() {
  const { deleteTransaction, saveTransaction, transactions } = useData();
  const [draft, setDraft] = useState({
    title: '',
    amount: '',
    category: 'General',
    date: new Date().toISOString().slice(0, 10),
    isExpense: 'true',
    isRecurring: 'false',
  });

  const summary = useMemo(
    () =>
      transactions.reduce(
        (totals, transaction) => {
          if (transaction.isExpense) {
            totals.expenses += transaction.amount;
          } else {
            totals.income += transaction.amount;
          }
          return totals;
        },
        { income: 0, expenses: 0 },
      ),
    [transactions],
  );

  const net = summary.income - summary.expenses;

  const categorySpend = useMemo(() => {
    const totals = new Map<string, number>();

    transactions.forEach((transaction) => {
      if (!transaction.isExpense) return;
      totals.set(
        transaction.category,
        (totals.get(transaction.category) ?? 0) + transaction.amount,
      );
    });

    return [...totals.entries()]
      .sort((left, right) => right[1] - left[1])
      .slice(0, 5);
  }, [transactions]);

  async function handleCreateTransaction(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    await saveTransaction(
      createTransactionItem({
        title: draft.title.trim(),
        amount: Math.abs(Number(draft.amount) || 0),
        category: draft.category,
        date: new Date(draft.date),
        isExpense: draft.isExpense === 'true',
        isRecurring: draft.isRecurring === 'true',
      }),
    );
    setDraft({
      title: '',
      amount: '',
      category: 'General',
      date: new Date().toISOString().slice(0, 10),
      isExpense: 'true',
      isRecurring: 'false',
    });
  }

  return (
    <div className="page-stack">
      <section className="page-header">
        <div>
          <p className="eyebrow">Finance</p>
          <h2>Cash flow tracker</h2>
          <p className="text-subtle">
            Use the same Firebase-backed transaction model as mobile, with
            simple budget visibility.
          </p>
        </div>
      </section>

      <section className="metrics-grid">
        <article className="metric-card panel">
          <div>
            <p>Income</p>
            <strong>{formatCurrency(summary.income)}</strong>
          </div>
        </article>
        <article className="metric-card panel">
          <div>
            <p>Expenses</p>
            <strong>{formatCurrency(summary.expenses)}</strong>
          </div>
        </article>
        <article className="metric-card panel">
          <div>
            <p>Net flow</p>
            <strong>{formatCurrency(net)}</strong>
          </div>
        </article>
      </section>

      <div className="content-grid content-grid--wide">
        <section className="panel">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Transactions</p>
              <h3>Recent activity</h3>
            </div>
          </div>
          <div className="list-stack">
            {transactions.length ? (
              transactions.map((transaction) => (
                <div key={transaction.id} className="list-row">
                  <div>
                    <strong>{transaction.title}</strong>
                    <small>
                      {transaction.category} ·{' '}
                      {transaction.date.toLocaleDateString()}
                    </small>
                  </div>
                  <div className="inline-actions">
                    <span
                      className={`status-pill ${
                        transaction.isExpense
                          ? 'status-pill--offline'
                          : 'status-pill--online'
                      }`}
                    >
                      {transaction.isExpense ? '-' : '+'}
                      {formatCurrency(transaction.amount)}
                    </span>
                    <button
                      className="button button--ghost"
                      type="button"
                      onClick={() => void deleteTransaction(transaction.id)}
                    >
                      Delete
                    </button>
                  </div>
                </div>
              ))
            ) : (
              <p className="empty-copy">No transactions yet.</p>
            )}
          </div>
        </section>

        <aside className="stack">
          <section className="panel">
            <div className="section-heading">
              <div>
                <p className="eyebrow">Capture</p>
                <h3>Add transaction</h3>
              </div>
            </div>
            <form
              className="form-grid"
              onSubmit={(event) => void handleCreateTransaction(event)}
            >
              <label className="field">
                <span>Title</span>
                <input
                  value={draft.title}
                  onChange={(event) =>
                    setDraft((current) => ({ ...current, title: event.target.value }))
                  }
                  placeholder="Salary, rent, coffee, subscription..."
                  required
                />
              </label>

              <div className="form-grid form-grid--split">
                <label className="field">
                  <span>Amount</span>
                  <input
                    type="number"
                    min="0"
                    step="0.01"
                    value={draft.amount}
                    onChange={(event) =>
                      setDraft((current) => ({ ...current, amount: event.target.value }))
                    }
                    required
                  />
                </label>

                <label className="field">
                  <span>Date</span>
                  <input
                    type="date"
                    value={draft.date}
                    onChange={(event) =>
                      setDraft((current) => ({ ...current, date: event.target.value }))
                    }
                  />
                </label>
              </div>

              <div className="form-grid form-grid--split">
                <label className="field">
                  <span>Type</span>
                  <select
                    value={draft.isExpense}
                    onChange={(event) =>
                      setDraft((current) => ({
                        ...current,
                        isExpense: event.target.value,
                      }))
                    }
                  >
                    <option value="true">Expense</option>
                    <option value="false">Income</option>
                  </select>
                </label>

                <label className="field">
                  <span>Recurring</span>
                  <select
                    value={draft.isRecurring}
                    onChange={(event) =>
                      setDraft((current) => ({
                        ...current,
                        isRecurring: event.target.value,
                      }))
                    }
                  >
                    <option value="false">One time</option>
                    <option value="true">Recurring</option>
                  </select>
                </label>
              </div>

              <label className="field">
                <span>Category</span>
                <input
                  value={draft.category}
                  onChange={(event) =>
                    setDraft((current) => ({ ...current, category: event.target.value }))
                  }
                  placeholder="General, Food, Salary, Travel..."
                />
              </label>

              <button className="button button--primary" type="submit">
                Save transaction
              </button>
            </form>
          </section>

          <section className="panel">
            <div className="section-heading">
              <div>
                <p className="eyebrow">Budgets</p>
                <h3>Top categories</h3>
              </div>
            </div>
            <div className="stack">
              {categorySpend.length ? (
                categorySpend.map(([category, amount]) => {
                  const width = summary.expenses
                    ? `${(amount / summary.expenses) * 100}%`
                    : '0%';
                  return (
                    <div key={category} className="budget-bar">
                      <div className="budget-bar__meta">
                        <strong>{category}</strong>
                        <span>{formatCurrency(amount)}</span>
                      </div>
                      <div className="budget-bar__track">
                        <div className="budget-bar__fill" style={{ width }} />
                      </div>
                    </div>
                  );
                })
              ) : (
                <p className="empty-copy">Log expenses to see category split.</p>
              )}
            </div>
          </section>
        </aside>
      </div>
    </div>
  );
}
