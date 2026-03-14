---
title: <% tp.file.title %>
description: ""
status: Planning
created_date: <% tp.date.now("YYYY-MM-DD") %>
modified_date: <% tp.date.now("YYYY-MM-DD") %>
author: "<% tp.user.name || 'Unknown' %>"
tags:
  - project
project_manager: ""
team_members: []
budget: 0
priority: Medium
progress: 0
start_date: ""
deadline: ""
end_date: ""
deliverables: []
risks: []
milestones: []
pageLayout: profile
viewMode: preview
cssclasses:
  - project
  - base-object
---

<%*
// Project-specific layout logic
const fm = tp.frontmatter || {};
const layout = fm.pageLayout || 'profile';
const layoutClass = `layout-${layout}`;
const progress = fm.progress || 0;
const title = fm.title || tp.file.title || 'New Project';
const status = fm.status || 'Planning';
const priority = fm.priority || 'Medium';
const description = fm.description || '';
const budget = fm.budget || 0;
const projectManager = fm.project_manager || '';
const deadline = fm.deadline || '';
const teamMembers = fm.team_members || [];
const deliverables = fm.deliverables || [];
const risks = fm.risks || [];

// Generate safe CSS classes
const statusClass = status.toLowerCase().replace(/\s+/g, '-');
const priorityClass = priority.toLowerCase();
-%>

<div class="<% layoutClass %> project-container" data-layout="<% layout %>">

# <% title %> 🚀

<div class="project-header">
  <div class="project-status">
    <span class="status-badge status-<% statusClass %>">
      <% status %>
    </span>
    <span class="priority-badge priority-<% priorityClass %>">
      <% priority %>
    </span>
  </div>
  <div class="layout-switcher">
    <button onclick="switchLayout('profile')" class="layout-btn active" data-layout="profile" title="Profile Layout">👤</button>
    <button onclick="switchLayout('index-card')" class="layout-btn" data-layout="index-card" title="Card Layout">🗃️</button>
    <button onclick="switchLayout('encyclopedia')" class="layout-btn" data-layout="encyclopedia" title="Encyclopedia Layout">📚</button>
  </div>
</div>

<%* if (layout === 'profile') { -%>
## Project Profile
<div class="project-profile">
  <div class="profile-main">
    <div class="project-avatar">
      🚀
    </div>
    <div class="project-details">
      <h3><% title %></h3>
      <p class="project-description"><% description || "*No description*" %></p>
      <div class="progress-bar">
        <div class="progress-fill" style="width: <% progress %>%"></div>
        <span class="progress-text"><% progress %>% Complete</span>
      </div>
    </div>
  </div>
  
  <div class="profile-sidebar">
    <div class="quick-stats">
      <div class="stat-item">
        <strong>Budget:</strong> $<% budget %>
      </div>
      <div class="stat-item">
        <strong>Manager:</strong> <% projectManager ? `[[${projectManager}]]` : "*Not assigned*" %>
      </div>
      <div class="stat-item">
        <strong>Deadline:</strong> <% deadline || "*Not set*" %>
      </div>
    </div>
  </div>
</div>
<%* } else if (layout === 'index-card') { -%>
## Project Card
<div class="project-card">
  <div class="card-header">
    <h3>🚀 <% title %></h3>
    <div class="card-badges">
      <span class="status-mini"><% status %></span>
      <span class="priority-mini"><% priority %></span>
    </div>
  </div>
  <div class="card-progress">
    <div class="mini-progress-bar">
      <div class="mini-progress-fill" style="width: <% progress %>%"></div>
    </div>
    <span class="mini-progress-text"><% progress %>%</span>
  </div>
  <div class="card-content">
    <p><% description ? description.substring(0, 120) + '...' : "*No description*" %></p>
  </div>
  <div class="card-footer">
    <span class="card-budget">$<% budget %></span>
    <span class="card-deadline"><% deadline || "No deadline" %></span>
  </div>
</div>
<%* } -%>

## Team & Stakeholders
<div class="team-section">
<%* if (teamMembers && teamMembers.length > 0) { -%>
**Team Members:**
<div class="team-grid">
<%* teamMembers.forEach(member => { -%>
- [[<% member %>]]
<%* }); -%>
</div>
<%* } else { -%>
*No team members assigned*
<%* } -%>
</div>

## Project Timeline
<div class="timeline-section">
- **Start Date:** <% fm.start_date || "*Not set*" %>
- **Deadline:** <% deadline || "*Not set*" %>
- **End Date:** <% fm.end_date || "*Not completed*" %>
</div>

## Deliverables & Milestones
<div class="deliverables-section">
<%* if (deliverables && deliverables.length > 0) { -%>
**Deliverables:**
<%* deliverables.forEach(deliverable => { -%>
- [ ] <% deliverable %>
<%* }); -%>
<%* } else { -%>
*No deliverables defined*
<%* } -%>
</div>

## Risk Management
<div class="risks-section">
<%* if (risks && risks.length > 0) { -%>
**Identified Risks:**
<%* risks.forEach(risk => { -%>
- ⚠️ <% risk %>
<%* }); -%>
<%* } else { -%>
*No risks identified*
<%* } -%>
</div>

</div>

---
*Layout: <% layout %> | Progress: <% progress %>% | Template: Project | Version: 1.0*
