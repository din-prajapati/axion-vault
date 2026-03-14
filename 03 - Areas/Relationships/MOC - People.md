---
type: moc
---
# 👥 People

```dataview
TABLE role, company, last_contact AS "Last Contact"
FROM "03 - Areas/Relationships"
WHERE type = "person"
SORT last_contact DESC
```
