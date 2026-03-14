---
type: moc
area: Health
---
# 🏃 Health

## Protocols
- **Sleep:** 
- **Exercise:** 
- **Nutrition:** 

## 7-Day Metrics
```dataview
TABLE sleep, mood, energy, deep_work_hrs AS "Deep Work"
FROM "06 - Daily/Daily"
WHERE type = "daily"
SORT file.name DESC
LIMIT 7
```
