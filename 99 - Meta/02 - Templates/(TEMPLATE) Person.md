---
type: person
title: <% tp.file.title %>
status: Active
role: ""
company: ""
email: ""
phone: ""
location: ""
met_on: <% tp.date.now("YYYY-MM-DD") %>
met_via: ""
last_contact: <% tp.date.now("YYYY-MM-DD") %>
projects: []
tags: [person]
cssclasses: [person, base-object]
---

# <% tp.file.title %> 👤

**`= this.role`** at **`= this.company`**
📧 `= this.email` · 📍 `= this.location` · Last contact: `= this.last_contact`

---

## Context
> Who are they and why do they matter to you?

## Key Notes
- 

## Meetings
```dataview
LIST FROM "03 - Areas/Meetings"
WHERE contains(people, this.file.name)
SORT file.name DESC
```

## All Mentions
```dataview
LIST FROM ""
WHERE contains(file.outlinks, this.file.link)
SORT file.mtime DESC
LIMIT 10
```

## Follow-up
- [ ] 
