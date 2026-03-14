---
title: <% tp.file.title %>
description: ""
status: Draft
created_date: <% tp.date.now("YYYY-MM-DD") %>
modified_date: <% tp.date.now("YYYY-MM-DD") %>
author: "<% tp.user.name || 'Unknown' %>"
tags: []
links: []
attachments: []
pageLayout: default
viewMode: edit
cssclasses:
  - base-object
---

<%*
// Get frontmatter values safely
const fm = tp.frontmatter || {};
const layout = fm.pageLayout || 'default';
const title = fm.title || tp.file.title || 'Untitled';
const status = fm.status || 'Draft';
const description = fm.description || '';
const author = fm.author || 'Unknown';
const createdDate = fm.created_date || tp.date.now("YYYY-MM-DD");
const tags = fm.tags || [];
const links = fm.links || [];

// Generate safe CSS class
const statusClass = status.toLowerCase().replace(/\s+/g, '-');
const layoutClass = `layout-${layout}`;
-%>

<div class="<% layoutClass %> base-object-container" data-layout="<% layout %>">

# <% title %>

<div class="object-header">
  <div class="status-badge status-<% statusClass %>">
    <% status %>
  </div>
  <div class="layout-switcher">
    <button onclick="switchLayout('default')" class="layout-btn" data-layout="default" title="Default Layout">📄</button>
    <button onclick="switchLayout('profile')" class="layout-btn" data-layout="profile" title="Profile Layout">👤</button>
    <button onclick="switchLayout('index-card')" class="layout-btn" data-layout="index-card" title="Card Layout">🗃️</button>
    <button onclick="switchLayout('encyclopedia')" class="layout-btn" data-layout="encyclopedia" title="Encyclopedia Layout">📚</button>
  </div>
</div>

<%* if (layout === 'profile') { -%>
## Profile View
<div class="profile-container">
  <div class="profile-avatar">
    <% title.charAt(0).toUpperCase() %>
  </div>
  <div class="profile-details">
    <h3><% title %></h3>
    <p class="profile-description"><% description || "*No description*" %></p>
  </div>
</div>
<%* } else if (layout === 'index-card') { -%>
## Card View
<div class="index-card">
  <div class="card-header">
    <h3><% title %></h3>
    <span class="card-status"><% status %></span>
  </div>
  <div class="card-content">
    <p><% description ? (description.length > 100 ? description.substring(0, 100) + '...' : description) : "*No description*" %></p>
  </div>
</div>
<%* } else if (layout === 'encyclopedia') { -%>
## Encyclopedia View
<div class="encyclopedia-container">
  <div class="toc-sidebar">
    <h4>Contents</h4>
    <ul>
      <li><a href="#description">Description</a></li>
      <li><a href="#metadata">Metadata</a></li>
      <li><a href="#links">Links</a></li>
      <li><a href="#tags">Tags</a></li>
    </ul>
  </div>
  <div class="main-content">
<%* } -%>

## Description {#description}
<% description || "*No description provided*" %>

## Metadata {#metadata}
<div class="metadata-grid">
  <div class="meta-item">
    <strong>Status:</strong> <% status %>
  </div>
  <div class="meta-item">
    <strong>Created:</strong> <% createdDate %>
  </div>
  <div class="meta-item">
    <strong>Author:</strong> <% author %>
  </div>
</div>

## Links & Connections {#links}
<%* if (links.length > 0) { -%>
<div class="links-container">
<%* links.forEach(link => { -%>
- <% link %>
<%* }); -%>
</div>
<%* } else { -%>
*No links added*
<%* } -%>

## Tags {#tags}
<div class="tags-container">
<%* if (tags.length > 0) { -%>
<%* tags.forEach(tag => { -%>
<span class="tag">#<% tag %></span> 
<%* }); -%>
<%* } else { -%>
<span class="no-tags">*No tags*</span>
<%* } -%>
</div>

<%* if (layout === 'encyclopedia') { -%>
  </div>
</div>
<%* } -%>

</div>

---
*Layout: <% layout %> | Template: Base-Object | Version: 1.0*
