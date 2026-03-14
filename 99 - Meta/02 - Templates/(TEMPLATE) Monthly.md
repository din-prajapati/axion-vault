---
type: monthly
month: <% tp.date.now("YYYY-MM") %>
tags: [Monthly]
income: 0
expenses: 0
savings: 0
---

# <% tp.date.now("MMMM YYYY") %>

## 🏆 Month Wins
- 

## 📊 Project Status
```dataview
TABLE status, priority
FROM "02 - Projects/_active"
WHERE type = "project"
SORT priority DESC
```

## 💰 Finance Snapshot
| | Planned | Actual |
|--|---------|--------|
| Income | | |
| Expenses | | |
| Savings | | |

## 🎯 Next Month Focus
1. 
2. 
3. 
