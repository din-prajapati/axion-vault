---
type: book
title: <% tp.file.title %>
author: ""
status: Want to Read
rating: ""
started: ""
finished: ""
genre: ""
tags: [book]
---

# <% tp.file.title %>
**`= this.author`** · Status: `= this.status` · Rating: `= this.rating`

## Central Thesis
> One paragraph: what is the core argument?

## Key Ideas
1. 
2. 
3. 

## Highlights
> 

## My Takeaways
- 

## Applied To
```dataview
LIST FROM ""
WHERE contains(file.outlinks, this.file.link)
```
