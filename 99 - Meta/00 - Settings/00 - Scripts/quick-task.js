<%*
// ============================================================
// quick-task.js — Cloud KMS fast task capture
// Creates a standalone task note OR appends to a project note.
// Trigger: QuickAdd macro → "New Task" (Cmd+T recommended)
// ============================================================

// ── 1. Task title ────────────────────────────────────────────
const title = await tp.system.prompt("Task title");
if (!title) { tR = ""; return; }

// ── 2. Mode: standalone note or append to project ────────────
const MODE = await tp.system.suggester(
  ["📝 Quick task (append to today's daily)", "📁 Project task (append to project note)", "🗒️ Standalone task note"],
  ["daily", "project", "standalone"]
);
if (!MODE) { tR = ""; return; }

const today = new Date().toISOString().split("T")[0];

// ── 3a. Quick task → append to today's daily note ────────────
if (MODE === "daily") {
  const dailyPath = `06 - Daily/Daily/${today}.md`;
  const dailyFile = app.vault.getAbstractFileByPath(dailyPath);

  const taskLine = `- [ ] ${title}`;

  if (dailyFile) {
    const content = await app.vault.cachedRead(dailyFile);
    await app.vault.modify(dailyFile, content + "\n" + taskLine);
    new Notice(`✅ Task added to today's daily note`);
  } else {
    new Notice(`⚠️ No daily note for today (${today}). Create it first with Cmd+D.`, 6000);
  }
  tR = "";
  return;
}

// ── 3b. Project task → pick project, append ─────────────────
if (MODE === "project") {
  const priority = await tp.system.suggester(
    ["🔴 High", "🟡 Medium", "🟢 Low"],
    ["High", "Medium", "Low"]
  );

  // Find all project files
  const projectFiles = app.vault.getMarkdownFiles()
    .filter(f => {
      const fm = app.metadataCache.getFileCache(f)?.frontmatter;
      return fm?.type === "project";
    })
    .map(f => f.basename);

  if (projectFiles.length === 0) {
    new Notice("No project notes found.", 4000);
    tR = ""; return;
  }

  const chosenProject = await tp.system.suggester(projectFiles, projectFiles);
  if (!chosenProject) { tR = ""; return; }

  const projectFile = app.vault.getMarkdownFiles()
    .find(f => f.basename === chosenProject);

  const taskLine = `- [ ] ${title}`;
  const content = await app.vault.cachedRead(projectFile);

  // Insert after "## ✅ Tasks" header if present, else append
  let newContent;
  if (content.includes("## ✅ Tasks")) {
    newContent = content.replace(
      /## ✅ Tasks\n/,
      `## ✅ Tasks\n${taskLine}\n`
    );
  } else {
    newContent = content + `\n${taskLine}`;
  }

  await app.vault.modify(projectFile, newContent);
  new Notice(`✅ Task added to ${chosenProject}`);
  tR = "";
  return;
}

// ── 3c. Standalone task note ─────────────────────────────────
if (MODE === "standalone") {
  const priority = await tp.system.suggester(
    ["🔴 High", "🟡 Medium", "🟢 Low"],
    ["High", "Medium", "Low"]
  );
  const area = await tp.system.suggester(
    ["Work", "Health", "Finance", "Creative", "Personal"],
    ["Work", "Health", "Finance", "Creative", "Personal"]
  );
  const due = await tp.system.prompt("Due date (YYYY-MM-DD or blank)") ?? "";

  const fm = `---
type: task
title: ${title}
status: Open
priority: ${priority ?? "Medium"}
area: ${area ?? "Work"}
due: "${due}"
created: ${today}
project: ""
tags: [task]
---

# ${title}

## Context
> Why does this matter?

## Steps
- [ ] 

## Notes
`;

  const safeName = title.replace(/[/\\:*?"<>|]/g, "-");
  const outputPath = `01 - Inbox/${today} — ${safeName}.md`;
  await app.vault.create(outputPath, fm);
  const newFile = app.vault.getAbstractFileByPath(outputPath);
  app.workspace.getLeaf().openFile(newFile);
  new Notice(`🗒️ Task note created`);
  tR = "";
}
%>
