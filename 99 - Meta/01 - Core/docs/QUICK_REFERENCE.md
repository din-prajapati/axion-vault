# Quick Reference Guide

## Essential Commands

### Creating Objects
- `Ctrl/Cmd + P` → "Templater: Create new note from template"
- Choose template: Base-Object, Project, or Person

### Layout Switching
- Click buttons in object header: 📄 👤 🗃️ 📚
- Or modify `pageLayout` in frontmatter

### Customization
- Settings → Style Settings → Obsidian Inheritance sections
- Enable/disable CSS snippets in Appearance settings

## Template Syntax

### Basic Templater Tags
```markdown
<% tp.file.title %>           # Current file title
<% tp.date.now("YYYY-MM-DD") %> # Current date
<% tp.user.name %>            # User name
```

### Conditional Logic
```markdown
<%* if (layout === 'profile') { -%>
Profile content here
<%* } else { -%>
Default content here
<%* } -%>
```

### Loops
```markdown
<%* teamMembers.forEach(member => { -%>
- [[<% member %>]]
<%* }); -%>
```

## Schema Properties

### BaseObject Fields
- `title`: Object name
- `description`: Object description
- `status`: Draft/In Progress/Review/Published/Archived
- `pageLayout`: default/profile/index-card/encyclopedia
- `cssclasses`: CSS classes array

### Project Fields (inherits BaseObject)
- `project_manager`: Link to person
- `team_members`: Array of person links
- `budget`: Number
- `priority`: Low/Medium/High/Critical
- `progress`: Number (0-100)
- `deliverables`: Array of deliverables
- `risks`: Array of risks

### Person Fields (inherits BaseObject)
- `full_name`: Full name
- `email`: Email address
- `role`: Job role
- `department`: Department
- `skills`: Array of skills
- `projects`: Array of project links

## CSS Classes

### Layout Classes
- `.layout-default`
- `.layout-profile`
- `.layout-index-card`
- `.layout-encyclopedia`

### Object Type Classes
- `.base-object`
- `.project`
- `.person`

### Status Classes
- `.status-draft`
- `.status-in-progress`
- `.status-review`
- `.status-published`
- `.status-active`
- `.status-completed`

## Hotkeys (Suggested)

Set up in Settings → Hotkeys:
- `Ctrl/Cmd + Shift + P` → Project Template
- `Ctrl/Cmd + Shift + O` → Person Template
- `Ctrl/Cmd + Shift + B` → Base Object Template

## File Naming Conventions

### Templates
- `*-Template.md` - Templater templates
- Place in `_templates/` folder

### Schemas
- `*.base` - Schema definitions
- Place in `_bases/` folder

### CSS
- `*.css` - CSS snippets
- Place in vault's snippets folder

## Common Issues & Solutions

### Template not found
- Check template folder path in Templater settings
- Verify file exists in `_templates/`

### CSS not loading
- Enable snippet in Settings → Appearance → CSS snippets
- Check file is in correct snippets folder

### Layout buttons not working
- Check browser console for errors
- Verify `_scripts/layout-switcher.js` exists
- Ensure Templater script folder is set correctly

### Properties not inheriting
- Check schema file exists in `_bases/`
- Verify `__inherits__` field is correct
- Check for circular inheritance

## Validation Rules

### Required Fields
- `title` - Always required
- `status` - Always required

### Field Types
- `string` - Text fields
- `number` - Numeric fields
- `date` - Date fields (YYYY-MM-DD format)
- `multiselect` - Arrays
- `select` - Single choice from options
- `link` - Obsidian links

### Options Validation
Fields with `__options__` must use specified values only.

## Performance Tips

### Caching
- Schemas are cached after first load
- Clear cache by reloading Obsidian

### Large Vaults
- Use specific templates for better performance
- Avoid deeply nested inheritance (max 5 levels)

### Mobile
- Profile and card layouts work best on mobile
- Encyclopedia layout may be too wide

## Debugging

### Console Errors
- Open Developer Tools (Ctrl/Cmd + Shift + I)
- Check Console tab for JavaScript errors
- Look for Templater or schema validation errors

### Validation Issues
- Check schema syntax in `_bases/` files
- Verify YAML frontmatter is valid
- Use online YAML validators if needed

### Template Issues
- Check Templater syntax
- Verify all variables are defined
- Use `<%* console.log(variable) %>` for debugging
