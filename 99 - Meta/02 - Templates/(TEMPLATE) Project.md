---
type: project
title: <% tp.file.title %>
status: Planning
intensity: on
rank: 5
priority: Medium
area: Work
created: <% tp.date.now("YYYY-MM-DD") %>
deadline: ""
goal: ""
tags: [project]
cssclasses: [project, base-object]
---
<%* await tp.user.generate_claude_md(tp, app) -%>

# <% tp.file.title %> 🚀

> **Goal:** What does success look like?

**Area:** `= this.area` · **Priority:** `= this.priority` · **Intensity:** `= this.intensity` · **Due:** `= this.deadline`

---

## ✅ Tasks

- [ ] 
- [ ] 

## 🧠 Notes Log

### <% tp.date.now("YYYY-MM-DD") %>
- 

## 👥 People

```dataview
TABLE role FROM "03 - Areas/Relationships"
WHERE contains(projects, this.file.name)
```

## 📅 Meetings

```dataview
LIST FROM "03 - Areas/Meetings"
WHERE contains(projects, this.file.name)
SORT file.name DESC
```

## ⚠️ Risks

- [ ] 
