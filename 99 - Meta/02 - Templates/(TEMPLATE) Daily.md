---
type: daily
date: <% tp.date.now("YYYY-MM-DD") %>
day: <% tp.date.now("dddd") %>
tags: [Daily]
cssclasses: [daily, <% tp.date.now("dddd").toLowerCase() %>]
sleep: 
mood: 
energy: 
deep_work_hrs: 
---

# <% tp.date.now("dddd, MMMM Do YYYY") %>

## 🎯 Top 3
- [ ] 
- [ ] 
- [ ] 

> [!abstract]- 🔥 Open On-Tasks (pull from projects)
> ```dataview
> TASK
> FROM "02 - Projects/_on"
> WHERE !completed
> LIMIT 12
> ```

---

## ⏰ Time Blocks

| Time | Block | Task | ✓ |
|------|-------|------|---|
| 09:00–11:00 | 🧠 Deep Work 1 | | ⏳ |
| 11:00–11:15 | ☕ Break | | ⏳ |
| 11:15–13:00 | 🧠 Deep Work 2 | | ⏳ |
| 13:00–14:00 | 🍽️ Lunch | | ⏳ |
| 14:00–15:30 | ⚡ Execution | | ⏳ |
| 15:30–17:00 | 🎨 Creative / Learning | | ⏳ |
| 21:00–22:00 | 📋 Admin + Inbox | | ⏳ |
| 22:00–22:20 | 🌙 Daily Review | | ⏳ |

---

## 📝 Notes
> 

## ✅ Tasks Added Today
- [ ] 

---

## 🌙 End-of-Day Review

- **Deep Work hrs:** ___ / target
- **Top 3 done:** ___ / 3
- **Energy (1–10):** 
- **Focus (1–10):** 

### Wins
- 

### Improve
- 

### Tomorrow's Top 3
1. [ ] 
2. [ ] 
3. [ ] 

---
← [[<% tp.date.now("YYYY-MM-DD", -1) %>|Yesterday]] · [[<% tp.date.now("YYYY-MM-DD", 1) %>|Tomorrow]] →
