---
type: moc
area: Creative
---
# 🎨 Creative

## Content Pipeline
```dataview
TABLE status, platform, publish_date AS "Publish"
FROM "03 - Areas/Creative"
WHERE type = "content"
SORT publish_date ASC
```
