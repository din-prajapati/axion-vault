---
type: moc
cssclasses: [moc]
---
# 🎯 Projects

> All efforts, sorted by cognitive intensity. Move projects between folders to signal attention level.

---

## 🔥 On — Full Attention
```dataview
TABLE WITHOUT ID
  file.link AS "Project",
  area AS "Area",
  deadline AS "Due",
  rank AS "↑"
FROM "02 - Projects/_on"
WHERE type = "project"
SORT rank DESC
```

## ♻️ Ongoing — Active, Not Daily
```dataview
TABLE WITHOUT ID
  file.link AS "Project",
  area AS "Area",
  rank AS "↑"
FROM "02 - Projects/_ongoing"
WHERE type = "project"
SORT rank DESC
```

## 〰️ Simmering — Background
```dataview
TABLE WITHOUT ID
  file.link AS "Project",
  area AS "Area",
  deadline AS "Due"
FROM "02 - Projects/_simmering"
WHERE type = "project"
SORT file.mtime DESC
```

## 💤 Sleeping — Paused
```dataview
TABLE WITHOUT ID
  file.link AS "Project",
  area AS "Area"
FROM "02 - Projects/_sleeping"
WHERE type = "project"
SORT file.mtime DESC
```

---

## ✅ All Open Tasks — On + Ongoing

```dataview
TASK
FROM "02 - Projects/_on" OR "02 - Projects/_ongoing"
WHERE !completed
GROUP BY file.link
```

---

*New project → use template `(TEMPLATE) Project.md` · Change intensity → run `move-effort.js` macro*
