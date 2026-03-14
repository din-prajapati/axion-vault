---
type: weekly
week: <% tp.date.now("YYYY-[W]WW") %>
created: <% tp.date.now("YYYY-MM-DD") %>
tags: [Weekly]
---

# Week <% tp.date.now("WW") %> · <% tp.date.now("MMM YYYY") %>

## ⚡ Effort Intensity Check

> [!abstract]+ 🔥 On — Still the right focus?
> ```dataview
> TABLE deadline AS "Due", area AS "Area", rank AS "↑"
> FROM "02 - Projects/_on"
> WHERE type = "project"
> SORT rank DESC
> ```

> [!example]- ♻️ Ongoing
> ```dataview
> TABLE area AS "Area", rank AS "↑"
> FROM "02 - Projects/_ongoing"
> WHERE type = "project"
> SORT rank DESC
> ```

> [!info]- 〰️ Simmering — Anything ready to promote?
> ```dataview
> TABLE area AS "Area"
> FROM "02 - Projects/_simmering"
> WHERE type = "project"
> SORT file.mtime DESC
> ```

---

## ✅ Task Completion Check

```dataview
TASK
FROM "02 - Projects/_on"
WHERE completed
AND file.mtime >= date(today) - dur(7 days)
GROUP BY file.link
```

---

## 📊 Week Metrics

| Metric | Value |
|--------|-------|
| Tasks completed | |
| Deep work hrs | |
| Projects advanced | |
| Inbox processed | |

---

## 🪞 Review

**What went well**
- 

**What to improve**
- 

**Effort moves this week** *(any project change intensity?)*
- 

---

## 🎯 Next Week Focus

**Top 3 priorities**
1. 
2. 
3. 

**Effort adjustments**
- [ ] Move to On: 
- [ ] Move to Simmering: 

← [[<% tp.date.now("YYYY-[W]WW", -7) %>|Last Week]] · [[<% tp.date.now("YYYY-[W]WW", 7) %>|Next Week]] →
