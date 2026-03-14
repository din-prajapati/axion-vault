---
title: Capacities Layout Scaffold
description: DataviewJS-powered Capacities-style layouts (Profile, Encyclopedia, Index Card)
tags: [scaffold, capacities, layouts]
---

> Use this scaffold inside notes that have frontmatter `pageLayout: profile | encyclopedia | index-card`.
> Requires CSS snippets: `obsidian-inheritance.css` and/or `capacities-layouts.css` enabled in Obsidian.

```dataviewjs
// Capacities-style Layout Scaffold (Profile, Encyclopedia, Index Card)
const fm = dv.current();
const file = fm?.file;
const layout = String((fm?.pageLayout ?? 'default')).toLowerCase();

// Derive object type heuristically
const cssClasses = (fm?.cssclasses ?? []).map(c => String(c).toLowerCase());
const isPerson = cssClasses.includes('person') || 'full_name' in fm || 'email' in fm;
const isProject = cssClasses.includes('project') || 'project_manager' in fm || 'progress' in fm;
const objectType = isPerson ? 'person' : isProject ? 'project' : 'base-object';

// Basic fields
const title = fm?.title || file?.name || 'Untitled';
const description = fm?.description || '';

// Utility
const root = dv.el('div', null, { cls: `${objectType}-container layout-${layout}`, attr: { 'data-layout': layout }});
const fmt = {
  date: v => v || '',
  list: arr => Array.isArray(arr) ? arr.filter(Boolean) : [],
  text: v => v ?? ''
};

function renderLayoutSwitcher(container, current) {
  const switcher = dv.el('div', null, { cls: 'layout-switcher' });
  const layouts = [
    { key: 'profile', label: 'Profile' },
    { key: 'encyclopedia', label: 'Encyclopedia' },
    { key: 'index-card', label: 'Index Card' }
  ];
  layouts.forEach(l => {
    const btn = dv.el('button', l.label, { cls: `layout-btn${l.key === current ? ' active' : ''}` });
    btn.dataset.layout = l.key;
    btn.addEventListener('click', () => {
      if (window.switchLayout) window.switchLayout(l.key, true);
    });
    switcher.appendChild(btn);
  });
  container.appendChild(switcher);
}

function renderProfile(container) {
  // Uses classes from obsidian-inheritance.css and capacities-layouts.css
  const wrapper = dv.el('div', null, { cls: `${objectType}-profile profile-container capacities-profile` });

  // Sidebar
  const aside = dv.el('aside', null, { cls: 'profile-sidebar profile-sidebar-capacities' }, wrapper);
  const header = dv.el('div', null, { cls: 'profile-header-capacities' }, aside);
  dv.el('div', (title?.[0] || title?.slice(0,1) || '•').toUpperCase(), { cls: 'profile-avatar profile-avatar-capacities' }, header);
  dv.el('div', title, { cls: 'profile-name-capacities' }, header);
  if (isPerson && fm?.role) dv.el('div', String(fm.role), { cls: 'profile-role-capacities' }, header);

  const stats = dv.el('div', null, { cls: 'profile-stats-capacities' }, aside);
  const stat = (label, value) => {
    const row = dv.el('div', null, { cls: 'stat-row-capacities' }, stats);
    dv.el('span', label, { cls: 'stat-label-capacities' }, row);
    dv.el('span', value ?? '—', { cls: 'stat-value-capacities' }, row);
  };
  if (isProject) {
    stat('Status', fm?.status);
    stat('Priority', fm?.priority);
    stat('Progress', typeof fm?.progress === 'number' ? `${fm.progress}%` : '—');
  } else if (isPerson) {
    stat('Department', fm?.department);
    stat('Location', fm?.location);
    stat('Company', fm?.company);
  } else {
    stat('Status', fm?.status);
  }

  const actions = dv.el('div', null, { cls: 'profile-actions-capacities' }, aside);
  const primary = dv.el('button', 'Open', { cls: 'action-btn-capacities' }, actions);
  primary.addEventListener('click', () => app?.commands?.executeCommandById?.('app:open') );
  const secondary = dv.el('button', 'Copy Link', { cls: 'action-btn-capacities action-btn-secondary' }, actions);
  secondary.addEventListener('click', () => navigator.clipboard?.writeText?.(app?.vault?.getResourcePath?.(file?.path) || '') );

  // Main Content
  const main = dv.el('section', null, { cls: 'profile-content-capacities' }, wrapper);
  const tabs = dv.el('div', null, { cls: 'content-tabs-capacities' }, main);
  const tabAbout = dv.el('button', 'About', { cls: 'tab-capacities active' }, tabs);
  const tabDetails = dv.el('button', 'Details', { cls: 'tab-capacities' }, tabs);

  const tabContent = dv.el('div', null, { cls: 'tab-content-capacities' }, main);
  const about = dv.el('div', null, {}, tabContent);
  if (description) dv.el('p', String(description), { cls: isPerson ? 'person-bio' : isProject ? 'project-description' : 'profile-description' }, about);

  const metaGrid = dv.el('div', null, { cls: 'metadata-grid' }, about);
  const addMeta = (k, v) => {
    if (v === undefined || v === null || v === '') return;
    const item = dv.el('div', null, { cls: 'meta-item' }, metaGrid);
    dv.el('div', k, { cls: 'meta-label' }, item);
    dv.el('div', Array.isArray(v) ? v.join(', ') : String(v), { cls: 'meta-value' }, item);
  };
  if (isPerson) {
    addMeta('Email', fm?.email);
    addMeta('Phone', fm?.phone);
    addMeta('Skills', fmt.list(fm?.skills));
    addMeta('Reports To', fm?.reports_to);
  }
  if (isProject) {
    addMeta('Project Manager', fm?.project_manager);
    addMeta('Team', fmt.list(fm?.team_members));
    addMeta('Budget', fm?.budget);
    addMeta('Deadline', fm?.deadline);
  }

  // Tabs behavior (client-only)
  tabDetails.addEventListener('click', () => {
    tabAbout.classList.remove('active');
    tabDetails.classList.add('active');
    tabContent.innerHTML = '';
    const details = dv.el('div', null, {}, tabContent);
    const tagsWrap = dv.el('div', null, { cls: 'tags-container' }, details);
    const tags = fmt.list(fm?.tags);
    if (tags.length) tags.forEach(t => dv.el('span', `#${t}`, { cls: 'tag' }, tagsWrap));
    else dv.el('span', 'No tags', { cls: 'no-tags' }, details);
  });

  tabAbout.addEventListener('click', () => {
    tabDetails.classList.remove('active');
    tabAbout.classList.add('active');
    tabContent.innerHTML = '';
    const about2 = dv.el('div', null, {}, tabContent);
    if (description) dv.el('p', String(description), { cls: 'profile-description' }, about2);
  });

  container.appendChild(wrapper);
}

function renderIndexCard(container) {
  const card = dv.el('div', null, { cls: `${objectType}-card index-card capacities-card` });
  const header = dv.el('div', null, { cls: 'card-header card-header-capacities' }, card);
  dv.el('h3', title, {}, header);
  const badges = dv.el('div', null, { cls: 'card-badges' }, header);
  if (fm?.status) dv.el('span', String(fm.status), { cls: 'status-mini' }, badges);
  if (isProject && fm?.priority) dv.el('span', String(fm.priority), { cls: 'priority-mini' }, badges);
  if (isPerson && fm?.role) dv.el('span', String(fm.role), { cls: 'role-mini' }, badges);

  if (isProject && typeof fm?.progress === 'number') {
    const prog = dv.el('div', null, { cls: 'card-progress' }, card);
    const bar = dv.el('div', null, { cls: 'mini-progress-bar' }, prog);
    const fill = dv.el('div', null, { cls: 'mini-progress-fill' }, bar);
    fill.style.width = `${Math.min(Math.max(fm.progress, 0), 100)}%`;
    dv.el('div', `${fm.progress}%`, { cls: 'mini-progress-text' }, prog);
  }

  const content = dv.el('div', null, { cls: 'card-content card-content-capacities' }, card);
  if (description) dv.el('p', String(description), { cls: 'card-description-capacities' }, content);
  if (isPerson && (fm?.email || fm?.phone)) {
    dv.el('div', [fm?.email, fm?.phone].filter(Boolean).join(' · '), { cls: 'contact-mini' }, content);
  }

  const footer = dv.el('div', null, { cls: 'card-footer' }, card);
  dv.el('span', file?.ctime ? `Created ${window?.moment?.(file.ctime.ts).fromNow?.() ?? ''}` : '', {}, footer);
  dv.el('span', file?.mtime ? `Updated ${window?.moment?.(file.mtime.ts).fromNow?.() ?? ''}` : '', {}, footer);

  container.appendChild(card);
}

function renderEncyclopedia(container) {
  const wrapper = dv.el('div', null, { cls: 'encyclopedia-container capacities-encyclopedia' });
  const sidebar = dv.el('aside', null, { cls: 'toc-sidebar encyclopedia-sidebar-capacities' }, wrapper);
  dv.el('div', 'On this page', { cls: 'sidebar-header-capacities' }, sidebar);
  const nav = dv.el('div', null, { cls: 'sidebar-nav-capacities' }, sidebar);

  // Build TOC from markdown headings in the file (requires API available in preview)
  const headings = Array.from(document.querySelectorAll('.markdown-preview-section h1, .markdown-preview-section h2, .markdown-preview-section h3'));
  headings.forEach(h => {
    const a = dv.el('a', h.textContent, { cls: `nav-item-capacities level-${h.tagName.toLowerCase()}` }, nav);
    a.href = `#${h.id || ''}`;
  });

  const main = dv.el('section', null, { cls: 'encyclopedia-content-capacities' }, wrapper);
  const header = dv.el('div', null, { cls: 'content-header-capacities' }, main);
  dv.el('div', title, { cls: 'content-title-capacities' }, header);
  if (description) dv.el('div', String(description), { cls: 'content-subtitle-capacities' }, header);
  dv.el('div', null, { cls: 'content-body-capacities' }, main);

  container.appendChild(wrapper);
}

// Render
renderLayoutSwitcher(root, layout);
if (layout === 'profile') {
  renderProfile(root);
} else if (layout === 'index-card') {
  renderIndexCard(root);
} else if (layout === 'encyclopedia') {
  renderEncyclopedia(root);
} else {
  // Default fallback
  dv.el('div', `Select a layout with pageLayout frontmatter (current: ${layout})`, { cls: 'no-layout' }, root);
}

// Attach to page
dv.container.appendChild(root);
```


