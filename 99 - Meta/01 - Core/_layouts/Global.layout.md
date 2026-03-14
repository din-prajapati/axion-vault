---

## File 1: `_layouts/Global.layout`
```yaml
---
# Global Layout Configuration
__meta__:
  id: global_layout_v1
  type: layout
  version: 1.0
  created: 2024-01-15

# Available Layout Types
layout_types:
  - default
  - profile
  - encyclopedia
  - index-card
  - timeline
  - kanban

# Default Layout Settings
default_layout: default
responsive: true
animations: true

# Profile Layout Config
profile_layout:
  avatar_size: large
  show_tags: true
  show_connections: true
  layout_style: card

# Encyclopedia Layout Config
encyclopedia_layout:
  show_toc: true
  show_backlinks: true
  show_metadata: true
  layout_style: article

# Index Card Layout Config
index_card_layout:
  card_width: 320px
  card_height: 240px
  show_preview: true
  layout_style: grid

# CSS Classes
css_variables:
  --profile-bg: var(--background-secondary)
  --card-shadow: 0 4px 12px rgba(0,0,0,0.15)
  --accent-color: var(--interactive-accent)

# Style Settings Integration
style_settings:
  enable_custom_colors: true
  enable_layout_switching: true
  enable_animations: true
---