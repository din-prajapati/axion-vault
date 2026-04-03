<%*
// ============================================================
// move-effort.js — Axion effort intensity mover
// Moves current project note to the right _on/_ongoing/_simmering/_sleeping folder.
// Trigger: QuickAdd → "Change Effort" or run from any project note
// ============================================================

const file = tp.file.find_tfile(tp.file.path(true));
const fm = app.metadataCache.getFileCache(file)?.frontmatter ?? {};

if (fm.type !== "project") {
  new Notice("⚠️ This note is not a project (type ≠ project)", 4000);
  tR = ""; return;
}

const INTENSITIES = [
  { label: "🔥 On — Full daily attention (max 3)", value: "on",        folder: "02 - Projects/_on" },
  { label: "♻️ Ongoing — Active, not daily",       value: "ongoing",   folder: "02 - Projects/_ongoing" },
  { label: "〰️ Simmering — Background, revisit weekly", value: "simmering", folder: "02 - Projects/_simmering" },
  { label: "💤 Sleeping — Paused, no guilt",        value: "sleeping",  folder: "02 - Projects/_sleeping" },
];

const chosen = await tp.system.suggester(
  INTENSITIES.map(i => i.label),
  INTENSITIES
);
if (!chosen) { tR = ""; return; }

// Update frontmatter intensity field
let content = await app.vault.cachedRead(file);
if (content.includes("intensity:")) {
  content = content.replace(/intensity:.*/, `intensity: ${chosen.value}`);
} else {
  content = content.replace(/^---/, `---\nintensity: ${chosen.value}`);
}
await app.vault.modify(file, content);

// Move file to correct folder
const newPath = `${chosen.folder}/${file.name}`;
await app.fileManager.renameFile(file, newPath);

new Notice(`✅ Moved to ${chosen.value.toUpperCase()}: ${file.basename}`);
tR = "";
%>
