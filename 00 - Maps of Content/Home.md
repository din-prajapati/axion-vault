---
type: home
cssclasses: [home, dashboard]
obsidianUIMode: preview
---

# ⚡ Command Center

> *What needs your attention right now?*

---

## 🔥 Today

> [!tip]+ ### Top 3 Priorities
> - [ ] 
> - [ ] 
> - [ ] 

> [!warning]+ ### Overdue
> ```dataview
> TABLE deadline AS "Due", area AS "Area"
> FROM "02 - Projects"
> WHERE type = "project"
>   AND deadline != ""
>   AND date(deadline) < date(today)
>   AND intensity != "sleeping"
> SORT deadline ASC
> LIMIT 5
> ```

> [!note]+ ### 📬 Inbox — Unprocessed
> ```dataview
> TABLE source AS "From", captured AS "Date"
> FROM "01 - Inbox"
> WHERE status = "unprocessed"
> SORT file.ctime DESC
> LIMIT 6
> ```

---

## 🎯 Efforts

> [!abstract]+ ### 🔥 On — Full Attention
> *Daily-driver projects. Max 3.*
> ```dataview
> TABLE WITHOUT ID
>   file.link AS "Project",
>   area AS "Area",
>   deadline AS "Due",
>   rank AS "↑"
> FROM "02 - Projects/_on"
> WHERE type = "project"
> SORT rank DESC
> ```

> [!example]+ ### ♻️ Ongoing — Active but Not Daily
> *Recurring responsibilities. No deadline pressure.*
> ```dataview
> TABLE WITHOUT ID
>   file.link AS "Project",
>   area AS "Area",
>   rank AS "↑"
> FROM "02 - Projects/_ongoing"
> WHERE type = "project"
> SORT rank DESC
> ```

> [!info]- ### 〰️ Simmering — Background
> *Not now but alive. Revisit weekly.*
> ```dataview
> TABLE WITHOUT ID
>   file.link AS "Project",
>   area AS "Area"
> FROM "02 - Projects/_simmering"
> WHERE type = "project"
> SORT file.mtime DESC
> ```

> [!done]- ### 💤 Sleeping — Paused
> *Intentionally parked. No guilt.*
> ```dataview
> TABLE WITHOUT ID
>   file.link AS "Project",
>   area AS "Area"
> FROM "02 - Projects/_sleeping"
> WHERE type = "project"
> SORT file.mtime DESC
> ```

---

## ✅ Open Tasks

> [!todo]+ ### 🔥 On — Open Tasks
> ```dataview
> TASK
> FROM "02 - Projects/_on"
> WHERE !completed
> GROUP BY file.link
> LIMIT 20
> ```

> [!todo]- ### ♻️ Ongoing — Open Tasks
> ```dataview
> TASK
> FROM "02 - Projects/_ongoing"
> WHERE !completed
> GROUP BY file.link
> LIMIT 15
> ```

> [!todo]- ### Today's Daily Tasks
> ```dataview
> TASK
> FROM "06 - Daily/Daily"
> WHERE !completed AND file.day = date(today)
> ```

---

## 📡 Radar

> [!tip]- ### People — Recent Contact
> ```dataview
> TABLE role AS "Role", company AS "Company", last_contact AS "Last Seen"
> FROM "03 - Areas/Relationships"
> WHERE type = "person"
> SORT last_contact DESC
> LIMIT 5
> ```

> [!note]- ### Upcoming Meetings
> ```dataview
> TABLE date AS "Date", people AS "With"
> FROM "03 - Areas/Meetings"
> WHERE type = "meeting"
>   AND date >= date(today)
> SORT date ASC
> LIMIT 5
> ```

> [!info]- ### Recently Modified
> ```dataview
> TABLE file.mtime AS "Modified"
> FROM "02 - Projects" OR "05 - Permanent"
> WHERE type != "moc"
> SORT file.mtime DESC
> LIMIT 8
> ```

---

## 🗺️ Navigate

| 📥 Capture | ⚡ Execute | 🧠 Knowledge |
|------------|-----------|--------------|
| [[01 - Inbox/PROCESS\|📬 Inbox]] | [[02 - Projects/MOC - Projects\|🎯 All Projects]] | [[05 - Permanent/\|🧠 Permanent]] |
| [[06 - Daily/Daily/\|📅 Daily Note]] | [[08 - Integration/_bases/tasks\|✅ Task Base]] | [[04 - Resources/MOC - Resources\|📚 Resources]] |
| [[08 - Integration/_scripts/README\|🤖 AI Scripts]] | [[08 - Integration/_bases/Bases Hub\|🗂️ All Bases]] | [[03 - Areas/MOC - Areas\|🗂️ Areas]] |
