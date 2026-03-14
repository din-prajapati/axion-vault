// Layout Switcher Script for Templater
// This script provides layout switching functionality

function createLayoutSwitcher() {
  return `
<script>
async function switchLayout(newLayout) {
  try {
    // Get current file
    const activeView = app.workspace.getActiveViewOfType(MarkdownView);
    if (!activeView) {
      console.warn('No active markdown view found');
      return;
    }
    
    const file = activeView.file;
    const fileContent = await app.vault.read(file);
    
    // Parse frontmatter (CRLF/LF safe)
    const frontmatterRegex = /^---\r?\n([\s\S]*?)\r?\n---/;
    const match = fileContent.match(frontmatterRegex);
    
    if (match) {
      // Update pageLayout in frontmatter
      let frontmatter = match[1];
      
      // Replace or add pageLayout
      if (frontmatter.includes('pageLayout:')) {
        frontmatter = frontmatter.replace(/pageLayout:.*$/m, \`pageLayout: \${newLayout}\`);
      } else {
        frontmatter += \`\\npageLayout: \${newLayout}\`;
      }
      
      // Update file content
      const newContent = fileContent.replace(frontmatterRegex, (m, _fm) => {
        const eol = m.includes("\r\n") ? "\r\n" : "\n";
        return `---${eol}${frontmatter}${eol}---`;
      });
      await app.vault.modify(file, newContent);
      
      // Update UI immediately
      updateLayoutUI(newLayout);
      
      // Show success message
      new Notice(\`Layout switched to \${newLayout}\`);
      
    } else {
      console.warn('No frontmatter found in file');
      new Notice('Could not find frontmatter to update layout');
    }
  } catch (error) {
    console.error('Layout switch failed:', error);
    new Notice('Layout switch failed. See console for details.');
  }
}

function updateLayoutUI(layout) {
  // Update active button
  document.querySelectorAll('.layout-btn').forEach(btn => {
    btn.classList.remove('active');
    if (btn.dataset.layout === layout) {
      btn.classList.add('active');
    }
  });
  
  // Update container class
  const containers = document.querySelectorAll('[data-layout]');
  containers.forEach(container => {
    // Remove old layout classes
    container.className = container.className.replace(/layout-\\w+/g, '');
    // Add new layout class
    container.classList.add(\`layout-\${layout}\`);
    container.dataset.layout = layout;
  });
  
  // Add smooth transition effect
  if (document.body.classList.contains('enable-smooth-transitions')) {
    document.body.style.transition = 'all 0.3s ease';
    setTimeout(() => {
      document.body.style.transition = '';
    }, 300);
  }
}

// Initialize layout switcher on page load
document.addEventListener('DOMContentLoaded', function() {
  const currentLayout = document.querySelector('[data-layout]')?.dataset.layout || 'default';
  updateLayoutUI(currentLayout);
});

// Also run immediately if DOM is already loaded
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeLayoutSwitcher);
} else {
  initializeLayoutSwitcher();
}

function initializeLayoutSwitcher() {
  const currentLayout = document.querySelector('[data-layout]')?.dataset.layout || 'default';
  updateLayoutUI(currentLayout);
}
</script>
`;
}

// Export for use in templates
module.exports = createLayoutSwitcher;
