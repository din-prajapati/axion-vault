---
title: <% tp.file.title %>
description: ""
status: Active
created_date: <% tp.date.now("YYYY-MM-DD") %>
modified_date: <% tp.date.now("YYYY-MM-DD") %>
author: <% tp.user.name || 'Unknown' %>
tags:
  - person
full_name: ""
email: ""
phone: ""
role: ""
department: ""
company: ""
location: ""
bio: ""
skills: []
projects: []
reports_to: ""
direct_reports: []
pageLayout: standard index-card
viewMode: preview
cssclasses:
  - person
  - base-object
---

<%*
// Person-specific layout logic
const fm = tp.frontmatter || {};
const layout = fm.pageLayout || 'profile';
const layoutClass = `layout-${layout}`;
const title = fm.title || tp.file.title || 'New Person';
const status = fm.status || 'Active';
const fullName = fm.full_name || '';
const email = fm.email || '';
const role = fm.role || '';
const department = fm.department || '';
const company = fm.company || '';
const bio = fm.bio || '';
const skills = fm.skills || [];
const projects = fm.projects || [];

// Generate safe CSS classes
const statusClass = status.toLowerCase().replace(/\s+/g, '-');
-%>

<div class="<% layoutClass %> person-container" data-layout="<% layout %>">

# <% title %> 👤

<div class="person-header">
  <div class="person-status">
    <span class="status-badge status-<% statusClass %>">
      <% status %>
    </span>
    <%* if (role) { -%>
    <span class="role-badge">
      <% role %>
    </span>
    <%* } -%>
  </div>
  <div class="layout-switcher">
    <button onclick="switchLayout('profile')" class="layout-btn active" data-layout="profile" title="Profile Layout">👤</button>
    <button onclick="switchLayout('index-card')" class="layout-btn" data-layout="index-card" title="Card Layout">🗃️</button>
    <button onclick="switchLayout('encyclopedia')" class="layout-btn" data-layout="encyclopedia" title="Encyclopedia Layout">📚</button>
  </div>
</div>

<%* if (layout === 'profile') { -%>
## Person Profile
<div class="person-profile">
  <div class="profile-main">
    <div class="person-avatar">
      <% title.charAt(0).toUpperCase() %>
    </div>
    <div class="person-details">
      <h3><% fullName || title %></h3>
      <%* if (role && company) { -%>
      <p class="person-title"><% role %> at <% company %></p>
      <%* } else if (role) { -%>
      <p class="person-title"><% role %></p>
      <%* } -%>
      <p class="person-bio"><% bio || "*No bio provided*" %></p>
    </div>
  </div>
  
  <div class="profile-sidebar">
    <div class="contact-info">
      <h4>Contact Information</h4>
      <%* if (email) { -%>
      <div class="contact-item">
        <strong>Email:</strong> <a href="mailto:<% email %>"><% email %></a>
      </div>
      <%* } -%>
      <%* if (fm.phone) { -%>
      <div class="contact-item">
        <strong>Phone:</strong> <% fm.phone %>
      </div>
      <%* } -%>
      <%* if (fm.location) { -%>
      <div class="contact-item">
        <strong>Location:</strong> <% fm.location %>
      </div>
      <%* } -%>
    </div>
    
    <%* if (department) { -%>
    <div class="org-info">
      <h4>Organization</h4>
      <div class="org-item">
        <strong>Department:</strong> <% department %>
      </div>
      <%* if (fm.reports_to) { -%>
      <div class="org-item">
        <strong>Reports To:</strong> [[<% fm.reports_to %>]]
      </div>
      <%* } -%>
    </div>
    <%* } -%>
  </div>
</div>
<%* } else if (layout === 'index-card') { -%>
## Person Card
<div class="person-card">
  <div class="card-header">
    <h3>👤 <% title %></h3>
    <div class="card-badges">
      <span class="status-mini"><% status %></span>
      <%* if (role) { -%>
      <span class="role-mini"><% role %></span>
      <%* } -%>
    </div>
  </div>
  <div class="card-content">
    <p><% bio ? bio.substring(0, 120) + '...' : "*No bio available*" %></p>
    <%* if (email) { -%>
    <p class="contact-mini">📧 <% email %></p>
    <%* } -%>
  </div>
  <div class="card-footer">
    <span class="card-company"><% company || "No company" %></span>
    <span class="card-department"><% department || "No department" %></span>
  </div>
</div>
<%* } -%>

## Skills & Expertise
<div class="skills-section">
<%* if (skills && skills.length > 0) { -%>
<div class="skills-grid">
<%* skills.forEach(skill => { -%>
<span class="skill-tag"><% skill %></span>
<%* }); -%>
</div>
<%* } else { -%>
*No skills listed*
<%* } -%>
</div>

## Projects & Involvement
<div class="projects-section">
<%* if (projects && projects.length > 0) { -%>
**Current Projects:**
<div class="projects-grid">
<%* projects.forEach(project => { -%>
- [[<% project %>]]
<%* }); -%>
</div>
<%* } else { -%>
*No projects assigned*
<%* } -%>
</div>

## Team Structure
<div class="team-structure-section">
<%* if (fm.direct_reports && fm.direct_reports.length > 0) { -%>
**Direct Reports:**
<div class="reports-grid">
<%* fm.direct_reports.forEach(report => { -%>
- [[<% report %>]]
<%* }); -%>
</div>
<%* } else { -%>
*No direct reports*
<%* } -%>
</div>

</div>

---
*Layout: <% layout %> | Template: Person | Version: 1.0*
