# Iconize — Fix "Icon pack not installed" and locate missing icons

## Icons showing as text (e.g. `RiFontSizeLine Fonts`)

This means the icon is not in your pack. **How to locate the correct icon:**

1. **Check what’s installed**  
   Open `.obsidian/icons/remix-icons/` and list the SVGs. Iconize expects PascalCase names (e.g. `FontSize.svg`).

2. **Match Remix Icon to Iconize**  
   - Browse [remixicon.com](https://remixicon.com) and note the icon’s kebab-case name (e.g. `font-size`, `code-view`).
   - Convert to Iconize format: `Ri` + PascalCase (`FontSize` → `RiFontSize`, `CodeView` → `RiCodeView`).
   - Use a variant that exists in the pack, e.g. `RiCodeSLine` instead of `RiCodeViewLine` if only `code-s-line.svg` is present.

3. **If the icon is missing from Remix**  
   Remix may not have a `*-line` variant. Use the base name, e.g. `RiFontSize` (from `font-size.svg`), or pick an existing icon.

4. **Update config**  
   Edit `99 - Meta/00 - Settings/02 - Plugin Configs/icon-folders.json`, change `iconName` to an icon that exists, then run `SETUP.ps1` or copy the file to `.obsidian/plugins/obsidian-icon-folder/data.json`.

---

## Quick fix (recommended)

Use Iconize's built-in download:

1. Open **Obsidian** → **Settings** (gear icon)
2. **Community plugins** → **Iconize**
3. Under **Icon packs folder path**, ensure it shows: `.obsidian/icons`
4. Click **Save** if you changed it
5. Scroll to **Icon packs** → click **Browse icon packs**
6. Find **Remix Icons** → click **Download**
7. Wait for the download to finish
8. **Restart Obsidian** (close the app fully and reopen)

## If it still fails

1. **Path format**: The path must be exactly `.obsidian/icons` (forward slash)
   - Wrong: `\.obsidian\icons` or `remix-icc` or `.obsidian/icons/remix-icons`
   - Correct: `.obsidian/icons`

2. **Enable Icons background check**: In Iconize settings, turn ON "Icons background check" — this can help the plugin discover packs.

3. **Enable Debug Mode**: Turn ON "Toggle Debug Mode" in Iconize, then check the console (Ctrl+Shift+I → Console tab) for errors when loading.

## Manual reinstall

If the built-in download fails, run from vault root (in PowerShell):

```powershell
.\"99 - Meta\00 - Settings\install-remix-icons.ps1"
.\"99 - Meta\00 - Settings\fix-remix-icons-structure.ps1"
.\"99 - Meta\00 - Settings\rename-remix-icons-for-iconize.ps1"
```

Then restart Obsidian.
