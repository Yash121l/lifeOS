import { useState } from 'react';
import { Target, TrendingUp, CheckCircle, Clock } from 'lucide-react';
import './Dashboard.css';

export default function Dashboard() {
  const [greeting] = useState('Good evening, Yash');

  return (
    <div className="dashboard animate-fade-in">
      <header className="dashboard-header mb-8">
        <h1 className="text-2xl font-bold">{greeting}</h1>
        <p className="text-secondary mt-1">Here is a quick overview of your LifeOS.</p>
      </header>

      {/* Stats Grid */}
      <div className="stats-grid mb-8">
        <div className="glass-card stat-card">
          <div className="stat-header">
            <span className="stat-label">Tasks</span>
            <CheckCircle className="stat-icon text-success" size={20} />
          </div>
          <div className="stat-value">12 / 16</div>
          <div className="stat-footer text-success">75% Completion</div>
        </div>
        
        <div className="glass-card stat-card">
          <div className="stat-header">
            <span className="stat-label">Productivity</span>
            <TrendingUp className="stat-icon text-accent" size={20} />
          </div>
          <div className="stat-value">84%</div>
          <div className="stat-footer">↑ 12% vs last week</div>
        </div>

        <div className="glass-card stat-card">
          <div className="stat-header">
            <span className="stat-label">Focus Time</span>
            <Clock className="stat-icon text-warning" size={20} />
          </div>
          <div className="stat-value">4h 20m</div>
          <div className="stat-footer">On track for today</div>
        </div>
      </div>

      {/* Main Content Area */}
      <div className="dashboard-content grid grid-cols-2 gap-6">
        <div className="glass-card panel">
          <div className="panel-header mb-4">
            <h2 className="text-lg font-semibold flex items-center gap-2">
              <Target size={18} />
              Current Objectives
            </h2>
          </div>
          <div className="panel-body">
            <div className="empty-state">
              <p className="text-tertiary text-sm">No active objectives found.</p>
              <button className="btn btn-primary mt-4 text-sm">Create Objective</button>
            </div>
          </div>
        </div>

        <div className="glass-card panel">
          <div className="panel-header mb-4">
            <h2 className="text-lg font-semibold">Recent Activity</h2>
          </div>
          <div className="panel-body">
            <div className="empty-state">
              <p className="text-tertiary text-sm">All caught up.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
