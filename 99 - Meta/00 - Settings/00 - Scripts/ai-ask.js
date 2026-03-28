<%*
// ============================================================
// ai-ask.js  (Templater user script / QuickAdd macro)
// Sends current note or selected text to Claude or Gemini,
// appends the response inline at cursor position.
//
// Install: save to 99 - Meta/00 - Settings/00 - Scripts/
// Trigger: QuickAdd macro → "Ask AI" command palette entry
// ============================================================

// ── 1. Choose tool ───────────────────────────────────────────
const TOOL = await tp.system.suggester(
  ["🤖 Claude (Sonnet)", "✨ Gemini (Flash)"],
  ["claude", "gemini"]
);
if (!TOOL) { tR = ""; return; }

// ── 2. Choose context ────────────────────────────────────────
const CONTEXT_MODE = await tp.system.suggester(
  ["📄 Entire current note", "✏️  Type a prompt only"],
  ["note", "prompt"]
);
if (!CONTEXT_MODE) { tR = ""; return; }

// ── 3. Get prompt ────────────────────────────────────────────
const userPrompt = await tp.system.prompt(
  CONTEXT_MODE === "note"
    ? "What do you want to know about this note?"
    : "Enter your prompt"
);
if (!userPrompt) { tR = ""; return; }

// ── 4. Build request body ─────────────────────────────────────
const file = tp.file.find_tfile(tp.file.path(true));
let contextText = "";

if (CONTEXT_MODE === "note") {
  contextText = await app.vault.cachedRead(file);
}

const SYSTEM = "You are an assistant integrated into Axion, a personal knowledge vault (Obsidian). " +
  "Be concise. Format output in Markdown. " +
  "If given a vault note, refer to it by its title. " +
  "End with a --- divider then one-line: *AI response via [Tool] · [date]*";

const userMessage = contextText
  ? `## Vault Note\n\n\`\`\`markdown\n${contextText}\n\`\`\`\n\n${userPrompt}`
  : userPrompt;

// ── 5. Call API ───────────────────────────────────────────────
let responseText = "";

try {
  if (TOOL === "claude") {
    const apiKey = process.env.ANTHROPIC_API_KEY ?? "";
    if (!apiKey) throw new Error("ANTHROPIC_API_KEY not set in environment.");

    const res = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01"
      },
      body: JSON.stringify({
        model: "claude-sonnet-4-20250514",
        max_tokens: 1024,
        system: SYSTEM,
        messages: [{ role: "user", content: userMessage }]
      })
    });
    const data = await res.json();
    if (data.error) throw new Error(data.error.message);
    responseText = data.content?.[0]?.text ?? "(empty response)";

  } else {
    // Gemini
    const apiKey = process.env.GEMINI_API_KEY ?? "";
    if (!apiKey) throw new Error("GEMINI_API_KEY not set in environment.");

    const model = "gemini-2.0-flash";
    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

    const res = await fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: `${SYSTEM}\n\n${userMessage}` }] }]
      })
    });
    const data = await res.json();
    if (data.error) throw new Error(data.error.message);
    responseText = data.candidates?.[0]?.content?.parts?.[0]?.text ?? "(empty response)";
  }
} catch (err) {
  new Notice(`❌ AI error: ${err.message}`, 6000);
  tR = "";
  return;
}

// ── 6. Append to note ─────────────────────────────────────────
const today = new Date().toISOString().split("T")[0];
const toolLabel = TOOL === "claude" ? "Claude Sonnet" : "Gemini Flash";
const divider = `\n\n---\n\n## 🤖 AI Response · ${today}\n\n> **Prompt:** ${userPrompt}\n\n${responseText}\n`;

const currentContent = await app.vault.cachedRead(file);
await app.vault.modify(file, currentContent + divider);

new Notice(`✅ ${toolLabel} response appended to note.`);
tR = "";
%>
