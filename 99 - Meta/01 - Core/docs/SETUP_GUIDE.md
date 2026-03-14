# Obsidian Inheritance System - Setup Guide

## Overview
The Obsidian Inheritance System provides a powerful way to create structured, inheritable templates and layouts within Obsidian, similar to Capacities or Notion databases.

## Prerequisites
- Obsidian v1.0.0 or later
- Required community plugins:
  - **Templater** (for dynamic templates)
  - **Style Settings** (for customization)
  - **Dataview** (optional, for advanced queries)

## Installation Steps

### 1. Install Required Plugins

1. Open Obsidian Settings (Ctrl/Cmd + ,)
2. Go to **Community Plugins**
3. Click **Browse** and install:
   - **Templater**
   - **Style Settings**
   - **Dataview** (optional)
4. Enable all installed plugins

### 2. Copy Files to Your Vault

Copy the entire `Obsidian-Inheritance-System` folder structure to your Obsidian vault root:

```
YourVault/
├── _layouts/
│   └── Global.layout
├── _bases/
│   ├── BaseObject.base
│   ├── Project.base
│   └── Person.base
├── _templates/
│   ├── Base-Object-Template.md
│   ├── Project-Template.md
│   └── Person-Template.md
├── _styles/
│   ├── obsidian-inheritance.css
│   └── style-settings.css
└── _scripts/
    ├── layout-switcher.js
    ├── schema-validator.js
    └── property-inheritance.js
```

### 3. Configure Templater

1. Open **Settings** → **Templater**
2. Set the following:
   - **Template folder location**: `_templates`
   - **Script files folder location**: `_scripts`
   - **Enable System Commands**: ✅
   - **Enable Folder Templates**: ✅ (optional)

### 4. Enable CSS Snippets

1. Open **Settings** → **Appearance** → **CSS Snippets**
2. Click the **Folder** icon to open snippets folder
3. Copy the CSS files from `_styles/` to the snippets folder
4. Return to Obsidian and enable:
   - `obsidian-inheritance.css`
   - `style-settings.css`

### 5. Configure Style Settings

1. Open **Settings** → **Style Settings**
2. You should see two new sections:
   - **Obsidian Inheritance System**
   - **Obsidian Inheritance - Vauxhall Style**
3. Customize colors, layouts, and features as desired

## Usage

### Creating New Objects

#### Method 1: Using Templater Command
1. Press `Ctrl/Cmd + P` to open command palette
2. Type "Templater: Create new note from template"
3. Choose your template:
   - `Base-Object-Template.md` - For generic objects
   - `Project-Template.md` - For projects
   - `Person-Template.md` - For people/contacts

#### Method 2: Using Hotkeys (Optional)
Set up hotkeys in **Settings** → **Hotkeys** for quick access:
- Search for "Templater: Insert Template"
- Assign hotkeys for your most-used templates

### Switching Layouts

Each object supports multiple layout views:
- **📄 Default**: Standard markdown view
- **👤 Profile**: Card-based profile view
- **🗃️ Index Card**: Compact card view
- **📚 Encyclopedia**: Documentation-style view

Click the layout buttons in the header or modify the `pageLayout` property in frontmatter.

### Customizing Appearance

#### Using Style Settings
1. Go to **Settings** → **Style Settings**
2. Expand **Obsidian Inheritance - Vauxhall Style**
3. Choose from:
   - **Color Schemes**: White, Teal, Blue, Indigo, Purple, Magenta, Red
   - **Intensity Modes**: Nebula (Light), Standard, Void (Dark)
   - **Header Styles**: Various gradient options
   - **Effects**: Glass effect, smooth transitions, floating elements

#### Manual CSS Customization
Edit the CSS variables in your snippets:
```css
:root {
  --inheritance-accent: #your-color;
  --inheritance-bg-secondary: #your-bg-color;
  --inheritance-radius: 12px;
}
```

## Creating Custom Base Types

### 1. Create a New Base Schema

Create a new file in `_bases/` (e.g., `Task.base`):

```yaml
---
# Task Base Schema
__inherits__: BaseObject

__meta__:
  id: task_v1
  type: base
  parent_id: base_object_v1
  version: 1.0
  created: 2024-01-15
  inheritance_chain:
    - base_object_v1
    - task_v1

# Task-Specific Fields
title: New Task
status: Todo
priority: Medium
assignee: ""
due_date: ""
estimated_hours: 0
actual_hours: 0

# Extended Field Types
__types__:
  assignee: link
  due_date: date
  estimated_hours: number
  actual_hours: number

# Extended Options
__options__:
  status:
    - Todo
    - In Progress
    - Review
    - Done
    - Cancelled
  priority:
    - Low
    - Medium
    - High
    - Urgent

# Template Reference
__template_file__: Task-Template.md
---
```

### 2. Create a Corresponding Template

Create `_templates/Task-Template.md`:

```markdown
---
title: README
status: Todo
priority: Medium
assignee: ""
due_date: ""
estimated_hours: 0
actual_hours: 0
pageLayout: profile
cssclasses:
  - task
  - base-object
---


# README ✅

<!-- Your task template content -->
```

## Troubleshooting

### Templates Not Loading
1. Check that Templater is enabled and configured correctly
2. Verify template folder path is set to `_templates`
3. Ensure script folder path is set to `_scripts`

### CSS Not Applying
1. Verify CSS snippets are enabled in **Settings** → **Appearance**
2. Check that files are in the correct snippets folder
3. Try reloading Obsidian (Ctrl/Cmd + R)

### Layout Switching Not Working
1. Ensure the layout-switcher script is in `_scripts/`
2. Check browser console for JavaScript errors
3. Verify Templater has access to execute scripts

### Style Settings Not Appearing
1. Confirm Style Settings plugin is installed and enabled
2. Check that `style-settings.css` is enabled as a snippet
3. Restart Obsidian if settings don't appear

## Advanced Features

### Schema Validation
The system includes automatic schema validation:
- Inheritance chain validation
- Type checking
- Required field validation
- Options validation

### Property Inheritance
Properties are automatically inherited from parent schemas:
- Field definitions merge down the chain
- Child schemas can override parent properties
- Computed properties are generated automatically

### Real-time Updates
- Layout changes apply immediately
- Property changes propagate to related objects
- Validation occurs in real-time

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify all prerequisites are met
3. Check browser console for error messages
4. Ensure all files are in correct locations

## Version Information

- **System Version**: 1.0
- **Obsidian Compatibility**: 1.0.0+
- **Last Updated**: 2024-01-15
