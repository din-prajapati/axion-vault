# Obsidian Inheritance System 🚀

A powerful, modular system for creating structured, inheritable templates and layouts in Obsidian, bringing Capacities-style object management to your knowledge base.

## ✨ Features

- **🧬 Schema Inheritance**: Hierarchical schemas with property inheritance
- **🎨 Dynamic Layouts**: Multiple visual representations (Profile, Card, Encyclopedia)
- **⚡ Real-time Switching**: Change layouts without page reload
- **🎭 Advanced Templates**: Templater integration with conditional logic
- **🎨 Customizable Styling**: Style Settings integration with multiple themes
- **✅ Validation System**: Automatic schema and property validation
- **📱 Responsive Design**: Works on desktop and mobile

## 🚀 Quick Start

### Prerequisites
- Obsidian v1.0.0+
- **Templater** plugin
- **Style Settings** plugin
- **Dataview** plugin (optional)

### Installation

1. **Download** the `Obsidian-Inheritance-System` folder
2. **Copy** it to your Obsidian vault root
3. **Install** required plugins from Community Plugins
4. **Configure** Templater:
   - Template folder: `_templates`
   - Script folder: `_scripts`
5. **Enable** CSS snippets in Settings → Appearance
6. **Customize** via Style Settings

## 📁 Structure

```
Obsidian-Inheritance-System/
├── _layouts/          # Layout configurations
├── _bases/           # Schema definitions
├── _templates/       # Templater templates
├── _styles/          # CSS snippets
├── _scripts/         # JavaScript modules
└── docs/            # Documentation
```

## 🎯 Usage Examples

### Creating a Project

1. Use Templater command: "Create new note from template"
2. Select `Project-Template.md`
3. Fill in the project details
4. Switch between layouts using the header buttons

### Layout Switching

Click the layout buttons in any object header:
- **📄** Default layout
- **👤** Profile layout  
- **🗃️** Index card layout
- **📚** Encyclopedia layout

### Custom Schemas

Create new base types by:
1. Adding a new `.base` file in `_bases/`
2. Creating a corresponding template in `_templates/`
3. Defining inheritance relationships

## 🎨 Customization

### Color Schemes
- Indigo (Default)
- Blue, Teal, Purple
- Magenta, Red, White

### Intensity Modes
- **Nebula**: Light backgrounds
- **Standard**: Balanced contrast
- **Void**: Dark mode

### Effects
- Glass effect (glassmorphism)
- Smooth transitions
- Floating elements
- Hover animations

## 📋 Schema Types

### BaseObject
Core properties all objects inherit:
- Title, description, status
- Created/modified dates
- Author, tags, links
- Layout and view settings

### Project (inherits BaseObject)
Project-specific properties:
- Team members, budget
- Progress, milestones
- Deliverables, risks
- Timeline management

### Person (inherits BaseObject)
Person-specific properties:
- Contact information
- Role, department, company
- Skills, projects
- Reporting relationships

## 🔧 Advanced Features

### Property Inheritance
- Automatic property merging from parent schemas
- Override capabilities for child schemas
- Computed properties (reading time, completion %, etc.)
- Real-time validation

### Schema Validation
- Type checking (string, number, date, etc.)
- Required field validation
- Options validation (dropdown values)
- Circular reference detection

### Performance
- Schema caching for fast resolution
- Lazy loading of inheritance chains
- Optimized DOM updates
- Memory management

## 🐛 Troubleshooting

### Templates Not Loading
- Verify Templater plugin is enabled
- Check template folder path (`_templates`)
- Ensure script folder path (`_scripts`)

### CSS Not Applying
- Enable CSS snippets in Settings → Appearance
- Check files are in snippets folder
- Try reloading Obsidian (Ctrl/Cmd + R)

### Layout Switching Issues
- Check browser console for errors
- Verify JavaScript files are in `_scripts/`
- Ensure Templater can execute scripts

## 📚 Documentation

- [Setup Guide](docs/SETUP_GUIDE.md) - Detailed installation instructions
- [Features](docs/FEATURES.md) - Complete feature overview
- [API Reference](docs/API.md) - Developer documentation (coming soon)

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- Inspired by [Capacities](https://capacities.io/) object management
- Built on [Obsidian](https://obsidian.md/) extensibility
- Styled with [Vauxhall theme](https://github.com/your-link) influences
- Powered by [Templater](https://github.com/SilentVoid13/Templater) plugin

## 🔗 Links

- [Obsidian Community](https://obsidian.md/community)
- [Templater Documentation](https://silentvoid13.github.io/Templater/)
- [Style Settings Plugin](https://github.com/mgmeyers/obsidian-style-settings)

---

**Version**: 1.0  
**Compatibility**: Obsidian 1.0.0+  
**Last Updated**: January 2024
