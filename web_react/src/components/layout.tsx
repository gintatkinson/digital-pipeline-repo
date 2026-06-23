import React, { useState, useRef, useEffect } from 'react';
import './layout.css';

export interface LayoutProps {
  activeView?: string;
  ActiveView?: string;
  onViewChange?: (view: string) => void;
  children?: React.ReactNode;
}

export const Layout: React.FC<LayoutProps> = ({
  activeView,
  ActiveView,
  onViewChange,
  children
}) => {
  const currentView = activeView || ActiveView || 'Ingestion';
  const containerRef = useRef<HTMLDivElement>(null);
  const [splitterHeight, setSplitterHeight] = useState(350);
  const [isDragging, setIsDragging] = useState(false);
  const [workerResult, setWorkerResult] = useState<number | null>(null);
  const workerRef = useRef<Worker | null>(null);

  // Initialize Web Worker for off-thread calculations
  useEffect(() => {
    const code = `
      self.onmessage = function(e) {
        // Mock heavy calculations off-thread
        const val = e.data;
        let sum = 0;
        for (let i = 0; i < 1000000; i++) {
          sum += Math.sin(val + i);
        }
        self.postMessage(Math.round(sum));
      };
    `;
    const blob = new Blob([code], { type: 'application/javascript' });
    const worker = new Worker(URL.createObjectURL(blob));
    worker.onmessage = (e) => {
      setWorkerResult(e.data);
    };
    workerRef.current = worker;

    return () => {
      worker.terminate();
    };
  }, []);

  // Trigger web worker on view change or splitter drag
  const triggerWorker = (inputVal: number) => {
    if (workerRef.current) {
      workerRef.current.postMessage(inputVal);
    }
  };

  const handlePointerDown = (e: React.PointerEvent) => {
    // Event-Echo Guard: stop propagation of click/pointer interactions
    e.stopPropagation();
    setIsDragging(true);
    if (containerRef.current) {
      containerRef.current.classList.add('dragging');
    }
    (e.target as HTMLElement).setPointerCapture(e.pointerId);
  };

  const handlePointerMove = (e: React.PointerEvent) => {
    if (!isDragging || !containerRef.current) return;
    // Event-Echo Guard
    e.stopPropagation();
    const rect = containerRef.current.getBoundingClientRect();
    const relativeY = e.clientY - rect.top;
    
    // Boundary checks: Keep within 150px and container height - 150px
    const newHeight = Math.max(150, Math.min(relativeY, rect.height - 150));
    setSplitterHeight(newHeight);
    
    // Trigger worker calculation using the new height
    triggerWorker(newHeight);
  };

  const handlePointerUp = (e: React.PointerEvent) => {
    // Event-Echo Guard
    e.stopPropagation();
    setIsDragging(false);
    if (containerRef.current) {
      containerRef.current.classList.remove('dragging');
    }
    (e.target as HTMLElement).releasePointerCapture(e.pointerId);
  };

  const handleSidebarItemClick = (e: React.MouseEvent, view: string) => {
    // Event-Echo Guard: stop propagation on sidebar/tree interaction
    e.stopPropagation();
    if (onViewChange) {
      onViewChange(view);
    }
  };

  const views = ['Ingestion', 'Metrics', 'Location', 'Chassis', 'Epics', 'Traceability'];

  return (
    <div className="layout-container" ref={containerRef}>
      {/* Sidebar with flex navigation */}
      <aside className="sidebar-nav">
        <div className="sidebar-header">
          <svg className="outline-svg brand-icon" viewBox="0 0 24 24">
            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" />
          </svg>
          <h2>Antigravity Console</h2>
        </div>
        <nav className="nav-menu">
          {views.map((view) => {
            const isSelected = currentView === view;
            return (
              <button
                key={view}
                className={`nav-item ${isSelected ? 'active' : ''}`}
                onClick={(e) => handleSidebarItemClick(e, view)}
              >
                <svg className="outline-svg nav-icon" viewBox="0 0 24 24">
                  {view === 'Ingestion' && <rect x="3" y="3" width="18" height="18" rx="2" />}
                  {view === 'Metrics' && <path d="M18 20V10M12 20V4M6 20v-6" />}
                  {view === 'Location' && <path d="M12 2a8 8 0 00-8 8c0 5.25 8 12 8 12s8-6.75 8-12a8 8 0 00-8-8z" />}
                  {view === 'Chassis' && <path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z" />}
                  {view === 'Epics' && <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />}
                  {view === 'Traceability' && <path d="M22 11.08V12a10 10 0 11-5.93-9.14" />}
                </svg>
                <span>{view}</span>
              </button>
            );
          })}
        </nav>
        <div className="sidebar-footer">
          <div className="worker-status">
            <span className="status-dot pulsing"></span>
            <span>Worker: {workerResult !== null ? workerResult : 'Idle'}</span>
          </div>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="main-content">
        {/* Top Pane with Reflow Isolation */}
        <section 
          className="pane top-pane reflow-isolated" 
          style={{ height: `${splitterHeight}px`, contain: 'layout paint' }}
        >
          <div className="pane-header">
            <h3>Active View: {currentView}</h3>
          </div>
          <div className="pane-body">
            {children}
          </div>
        </section>

        {/* Resizable Splitter */}
        <div
          className="splitter-bar"
          onPointerDown={handlePointerDown}
          onPointerMove={handlePointerMove}
          onPointerUp={handlePointerUp}
        >
          <div className="splitter-handle"></div>
        </div>

        {/* Bottom Pane with Reflow Isolation */}
        <section 
          className="pane bottom-pane reflow-isolated" 
          style={{ contain: 'layout paint' }}
        >
          <div className="pane-header">
            <h3>System Status & Logs</h3>
          </div>
          <div className="pane-body terminal-output">
            <div className="log-line">
              <span className="log-timestamp">[15:39:33]</span> [SYSTEM] Console initialized.
            </div>
            <div className="log-line">
              <span className="log-timestamp">[15:39:33]</span> [WORKER] Registered off-thread background worker.
            </div>
            <div className="log-line">
              <span className="log-timestamp">[15:39:33]</span> [INFO] Selected panel reflow isolation scope active.
            </div>
          </div>
        </section>
      </main>
    </div>
  );
};
