import { useState, useEffect, useCallback } from "react";

const STEPS = [
  {
    id: 1, name: "Scaffold", tasks: [
      "1.1 Root CLAUDE.md", "1.2 Root README.md", "1.3 setup.sh", "1.4 settings.json",
      "1.5.1 cmd/idea.md", "1.5.2 cmd/plan.md", "1.5.3 cmd/architect.md", "1.5.4 cmd/build.md",
      "1.5.5 cmd/test.md", "1.5.6 cmd/ship.md", "1.5.7 cmd/full-pipeline.md",
      "1.6.1 agent/interviewer", "1.6.2 agent/planner", "1.6.3 agent/architect",
      "1.6.4 agent/executor", "1.6.5 agent/reviewer", "1.6.6 agent/tester",
      "1.6.7 agent/release-mgr", "1.6.8 agent/critic",
      "1.7.1 skill/deep-interview", "1.7.2 skill/prd-gen", "1.7.3 skill/sys-design",
      "1.7.4 skill/parallel-build", "1.7.5 skill/tdd", "1.7.6 skill/verification",
      "1.7.7 skill/git-workflow", "1.7.8 skill/release",
      "1.8.1 hook/session-start", "1.8.2 hook/pre-tool", "1.8.3 hook/stop", "1.8.4 hook/post-tool",
      "1.9 knowledge/ dirs", "1.10 pipeline/ dirs", "1.11 templates/ dirs",
      "1.12 .omc/ dirs", "1.13 .gitignore"
    ]
  },
  {
    id: 2, name: "CLAUDE.md", tasks: [
      "2.1 Phase detection routing", "2.2 Knowledge loading rules", "2.3 Gate enforcement",
      "2.4 State tracking rules", "2.5 Delegation rules", "2.6 Context mgmt rules",
      "2.7 Artifact path conventions", "2.8 Model selection guidance",
      "2.9 Routing table references", "2.10 Compaction recovery", "2.11 Validate in CC"
    ]
  },
  {
    id: 3, name: "Output Specs", tasks: [
      "3.1 Idea output-spec", "3.2 Plan output-spec", "3.3 Architect output-spec",
      "3.4 Build output-spec", "3.5 Test output-spec", "3.6 Ship output-spec",
      "3.7 Cross-validate chain"
    ]
  },
  {
    id: 4, name: "Commands", tasks: [
      "4.1 /idea command", "4.2 /plan command", "4.3 /architect command",
      "4.4 /build command", "4.5 /test command", "4.6 /ship command",
      "4.7 /full-pipeline command", "4.8 Test all commands"
    ]
  },
  {
    id: 5, name: "Agents", tasks: [
      "5.1 interviewer.md", "5.2 planner.md", "5.3 architect.md",
      "5.4 executor.md", "5.5 reviewer.md", "5.6 tester.md",
      "5.7 release-manager.md", "5.8 critic.md", "5.9 Validate frontmatter"
    ]
  },
  {
    id: 6, name: "Skills", tasks: [
      "6.1 deep-interview SKILL", "6.2 prd-generator SKILL", "6.3 system-design SKILL",
      "6.4 parallel-build SKILL", "6.5 tdd SKILL", "6.6 verification SKILL",
      "6.7 git-workflow SKILL", "6.8 release SKILL", "6.9 Validate pipelines"
    ]
  },
  {
    id: 7, name: "Knowledge Base", tasks: [
      "7.1 Clone interview-univ", "7.2 data-structures.md", "7.3 algorithms.md",
      "7.4 system-design.md", "7.5 design-patterns.md",
      "7.6 Clone best-practice", "7.7 Clone claude-howto",
      "7.8 agent-design.md", "7.9 skill-design.md", "7.10 hook-patterns.md",
      "7.11 context-mgmt.md", "7.12 team-coord.md", "7.13 prompt-patterns.md",
      "7.14 Clone claw-code", "7.15 tool-orchestration.md",
      "7.16 context-window.md", "7.17 runtime-behavior.md", "7.18 Validate <2k tokens"
    ]
  },
  {
    id: 8, name: "Templates", tasks: [
      "8.1 web-app template", "8.2 api-service template", "8.3 cli-tool template",
      "8.4 full-stack template", "8.5 agent-system template", "8.6 Template CLAUDE.md overlays"
    ]
  },
  {
    id: 9, name: "Hooks", tasks: [
      "9.1 session-start.js", "9.2 pre-tool-use.js", "9.3 stop.js",
      "9.4 post-tool-use.js", "9.5 Register in settings", "9.6 Test hooks"
    ]
  },
  {
    id: 10, name: "E2E Testing", tasks: [
      "10.1 Test /idea", "10.2 Test /plan", "10.3 Test /architect",
      "10.4 Test /build", "10.5 Test /test", "10.6 Test /ship",
      "10.7 Test /full-pipeline", "10.8 Test gate enforcement",
      "10.9 Test phase resumption", "10.10 Test compaction recovery",
      "10.11 Test web-app e2e", "10.12 Test api-service e2e",
      "10.13 Test agent-system e2e", "10.14 Write README", "10.15 PROJECT COMPLETE 🚀"
    ]
  }
];

const TOTAL_TASKS = STEPS.reduce((sum, s) => sum + s.tasks.length, 0);

const STORAGE_KEY = "super-repo-checklist";

export default function SuperRepoTracker() {
  const [completed, setCompleted] = useState({});
  const [expandedStep, setExpandedStep] = useState(1);
  const [compactions, setCompactions] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      try {
        const result = await window.storage.get(STORAGE_KEY);
        if (result?.value) {
          const data = JSON.parse(result.value);
          setCompleted(data.completed || {});
          setCompactions(data.compactions || []);
        }
      } catch (e) { /* first load */ }
      setLoading(false);
    })();
  }, []);

  const save = useCallback(async (newCompleted, newCompactions) => {
    try {
      await window.storage.set(STORAGE_KEY, JSON.stringify({
        completed: newCompleted,
        compactions: newCompactions,
        lastUpdated: new Date().toISOString()
      }));
    } catch (e) { console.error("Storage error:", e); }
  }, []);

  const toggleTask = (taskKey) => {
    const next = { ...completed, [taskKey]: !completed[taskKey] };
    setCompleted(next);
    save(next, compactions);
  };

  const logCompaction = () => {
    const completedCount = Object.values(completed).filter(Boolean).length;
    const entry = {
      time: new Date().toISOString(),
      tasksComplete: completedCount,
      currentStep: expandedStep
    };
    const next = [...compactions, entry];
    setCompactions(next);
    save(completed, next);
  };

  const resetAll = () => {
    if (confirm("Reset all progress? This cannot be undone.")) {
      setCompleted({});
      setCompactions([]);
      save({}, []);
    }
  };

  const completedCount = Object.values(completed).filter(Boolean).length;
  const pct = Math.round((completedCount / TOTAL_TASKS) * 100);

  const getStepProgress = (step) => {
    const done = step.tasks.filter((_, i) => completed[`${step.id}-${i}`]).length;
    return { done, total: step.tasks.length, pct: Math.round((done / step.tasks.length) * 100) };
  };

  const getStepStatus = (step) => {
    const p = getStepProgress(step);
    if (p.done === p.total) return "complete";
    if (p.done > 0) return "active";
    return "pending";
  };

  if (loading) return <div style={{ padding: 40, color: "var(--text-secondary, #888)", fontFamily: "monospace" }}>Loading state...</div>;

  return (
    <div style={{ fontFamily: "'IBM Plex Mono', monospace", maxWidth: 780, margin: "0 auto", padding: "20px 16px" }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600;700&display=swap');
        * { box-sizing: border-box; }
      `}</style>

      {/* Header */}
      <div style={{ marginBottom: 28 }}>
        <div style={{ fontSize: 11, letterSpacing: 3, color: "var(--text-secondary, #888)", textTransform: "uppercase", marginBottom: 4 }}>Super Repo Build Tracker</div>
        <div style={{ fontSize: 28, fontWeight: 700, color: "var(--text-primary, #111)", lineHeight: 1.1 }}>Idea → Ship Pipeline</div>
      </div>

      {/* Overall progress bar */}
      <div style={{ marginBottom: 24 }}>
        <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 6 }}>
          <span style={{ fontSize: 12, color: "var(--text-secondary, #888)" }}>{completedCount}/{TOTAL_TASKS} tasks</span>
          <span style={{ fontSize: 12, fontWeight: 600, color: pct === 100 ? "#16a34a" : "var(--text-primary, #111)" }}>{pct}%</span>
        </div>
        <div style={{ height: 8, background: "var(--bg-secondary, #f0f0f0)", borderRadius: 4, overflow: "hidden" }}>
          <div style={{
            height: "100%", borderRadius: 4, transition: "width 0.4s ease",
            width: `${pct}%`,
            background: pct === 100 ? "#16a34a" : pct > 50 ? "#2563eb" : "#f59e0b"
          }} />
        </div>
      </div>

      {/* Pipeline phase indicators */}
      <div style={{ display: "flex", gap: 2, marginBottom: 24 }}>
        {STEPS.map((step) => {
          const status = getStepStatus(step);
          const p = getStepProgress(step);
          return (
            <div
              key={step.id}
              onClick={() => setExpandedStep(step.id)}
              style={{
                flex: 1, height: 32, borderRadius: 4, cursor: "pointer",
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: 10, fontWeight: 600, letterSpacing: 0.5, transition: "all 0.2s",
                border: expandedStep === step.id ? "2px solid var(--text-primary, #111)" : "2px solid transparent",
                background: status === "complete" ? "#16a34a" : status === "active" ? "#2563eb" : "var(--bg-secondary, #e5e5e5)",
                color: status === "pending" ? "var(--text-secondary, #888)" : "#fff"
              }}
              title={`Step ${step.id}: ${step.name} (${p.done}/${p.total})`}
            >
              {step.id}
            </div>
          );
        })}
      </div>

      {/* Steps */}
      {STEPS.map((step) => {
        const p = getStepProgress(step);
        const status = getStepStatus(step);
        const isExpanded = expandedStep === step.id;

        return (
          <div key={step.id} style={{
            marginBottom: 2,
            border: `1px solid ${isExpanded ? "var(--text-primary, #333)" : "var(--bg-secondary, #e5e5e5)"}`,
            borderRadius: 6, overflow: "hidden", transition: "all 0.2s"
          }}>
            {/* Step header */}
            <div
              onClick={() => setExpandedStep(isExpanded ? null : step.id)}
              style={{
                display: "flex", alignItems: "center", gap: 10, padding: "10px 14px",
                cursor: "pointer", userSelect: "none",
                background: isExpanded ? "var(--bg-secondary, #f8f8f8)" : "transparent"
              }}
            >
              <span style={{
                width: 22, height: 22, borderRadius: 12, display: "flex", alignItems: "center",
                justifyContent: "center", fontSize: 11, fontWeight: 700, flexShrink: 0,
                background: status === "complete" ? "#16a34a" : status === "active" ? "#2563eb" : "var(--bg-secondary, #e5e5e5)",
                color: status === "pending" ? "var(--text-secondary, #888)" : "#fff"
              }}>
                {status === "complete" ? "✓" : step.id}
              </span>
              <span style={{ fontSize: 13, fontWeight: 600, color: "var(--text-primary, #111)", flex: 1 }}>
                {step.name}
              </span>
              <span style={{ fontSize: 11, color: "var(--text-secondary, #888)" }}>
                {p.done}/{p.total}
              </span>
              <div style={{ width: 60, height: 4, background: "var(--bg-secondary, #e5e5e5)", borderRadius: 2, overflow: "hidden" }}>
                <div style={{
                  height: "100%", borderRadius: 2, transition: "width 0.3s",
                  width: `${p.pct}%`,
                  background: status === "complete" ? "#16a34a" : "#2563eb"
                }} />
              </div>
            </div>

            {/* Tasks */}
            {isExpanded && (
              <div style={{ padding: "4px 14px 12px", borderTop: "1px solid var(--bg-secondary, #eee)" }}>
                {step.tasks.map((task, i) => {
                  const key = `${step.id}-${i}`;
                  const done = !!completed[key];
                  return (
                    <div
                      key={key}
                      onClick={() => toggleTask(key)}
                      style={{
                        display: "flex", alignItems: "center", gap: 8, padding: "5px 0",
                        cursor: "pointer", userSelect: "none",
                        opacity: done ? 0.5 : 1, transition: "opacity 0.2s"
                      }}
                    >
                      <span style={{
                        width: 16, height: 16, borderRadius: 3, flexShrink: 0,
                        border: done ? "none" : "1.5px solid var(--text-secondary, #ccc)",
                        background: done ? "#16a34a" : "transparent",
                        display: "flex", alignItems: "center", justifyContent: "center",
                        fontSize: 10, color: "#fff", fontWeight: 700
                      }}>
                        {done && "✓"}
                      </span>
                      <span style={{
                        fontSize: 12, color: "var(--text-primary, #333)",
                        textDecoration: done ? "line-through" : "none"
                      }}>
                        {task}
                      </span>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        );
      })}

      {/* Compaction log + controls */}
      <div style={{ marginTop: 24, padding: 14, border: "1px solid var(--bg-secondary, #e5e5e5)", borderRadius: 6 }}>
        <div style={{ fontSize: 12, fontWeight: 600, color: "var(--text-primary, #111)", marginBottom: 10 }}>
          Compaction Log
        </div>
        {compactions.length === 0 ? (
          <div style={{ fontSize: 11, color: "var(--text-secondary, #888)", marginBottom: 10 }}>No compactions recorded yet.</div>
        ) : (
          <div style={{ marginBottom: 10 }}>
            {compactions.map((c, i) => (
              <div key={i} style={{ fontSize: 11, color: "var(--text-secondary, #666)", padding: "2px 0", display: "flex", gap: 12 }}>
                <span style={{ color: "var(--text-secondary, #aaa)", minWidth: 20 }}>#{i + 1}</span>
                <span style={{ minWidth: 140 }}>{new Date(c.time).toLocaleString()}</span>
                <span>{c.tasksComplete}/{TOTAL_TASKS} done</span>
                <span>@ Step {c.currentStep}</span>
              </div>
            ))}
          </div>
        )}
        <div style={{ display: "flex", gap: 8 }}>
          <button
            onClick={logCompaction}
            style={{
              padding: "6px 14px", fontSize: 11, fontWeight: 600, fontFamily: "inherit",
              background: "#2563eb", color: "#fff", border: "none", borderRadius: 4,
              cursor: "pointer"
            }}
          >
            Log Compaction
          </button>
          <button
            onClick={resetAll}
            style={{
              padding: "6px 14px", fontSize: 11, fontWeight: 600, fontFamily: "inherit",
              background: "transparent", color: "#dc2626", border: "1px solid #dc2626",
              borderRadius: 4, cursor: "pointer"
            }}
          >
            Reset All
          </button>
        </div>
      </div>

      <div style={{ marginTop: 16, fontSize: 10, color: "var(--text-secondary, #aaa)", textAlign: "center" }}>
        State persists across sessions · Click tasks to toggle · Click step numbers to navigate
      </div>
    </div>
  );
}
