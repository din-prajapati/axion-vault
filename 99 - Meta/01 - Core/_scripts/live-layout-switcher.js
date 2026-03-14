<%*
// Live Layout Switcher - No page reload required
class LiveLayoutSwitcher {
    constructor() {
        this.currentLayout = null;
        this.initializeEventListeners();
    }

    async switchLayout(newLayout) {
        try {
            // Get current active view
            const activeView = app.workspace.getActiveViewOfType(MarkdownView);
            if (!activeView) return;

            // Update frontmatter without file modification
            this.updateFrontmatterInMemory(activeView, newLayout);
            
            // Update DOM classes immediately
            this.updateLayoutClasses(newLayout);
            
            // Animate transition
            this.animateLayoutTransition(newLayout);
            
            // Update URL hash for persistence
            location.hash = `layout=${newLayout}`;
            
        } catch (error) {
            console.error('Layout switch failed:', error);
            new Notice('Layout switch failed. See console for details.');
        }
    }

    updateFrontmatterInMemory(view, newLayout) {
        // Create virtual frontmatter update
        const frontmatterEl = view.containerEl.querySelector('.frontmatter');
        if (frontmatterEl) {
            // Update the rendered frontmatter display
            frontmatterEl.dataset.pageLayout = newLayout;
        }
        
        // Update internal state
        this.currentLayout = newLayout;
    }

    updateLayoutClasses(newLayout) {
        const container = document.querySelector('.base-object-container, .project-container');
        if (container) {
            // Remove old layout classes
            container.className = container.className.replace(/layout-\w+/g, '');
            // Add new layout class
            container.classList.add(`layout-${newLayout}`);
            container.dataset.layout = newLayout;
        }

        // Update button states
        document.querySelectorAll('.layout-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.layout === newLayout);
        });
    }

    animateLayoutTransition(newLayout) {
        const container = document.querySelector('[data-layout]');
        if (!container) return;

        // Add transition class
        container.classList.add('layout-transitioning');
        
        // Smooth transition effect
        container.style.opacity = '0.7';
        container.style.transform = 'scale(0.98)';
        
        setTimeout(() => {
            container.style.opacity = '1';
            container.style.transform = 'scale(1)';
            container.classList.remove('layout-transitioning');
        }, 150);
    }

    initializeEventListeners() {
        // Listen for hash changes to restore layout
        window.addEventListener('hashchange', () => {
            const hash = location.hash.substring(1);
            const layoutMatch = hash.match(/layout=(\w+)/);
            if (layoutMatch) {
                this.switchLayout(layoutMatch[1]);
            }
        });

        // Initialize from hash on load
        document.addEventListener('DOMContentLoaded', () => {
            const hash = location.hash.substring(1);
            const layoutMatch = hash.match(/layout=(\w+)/);
            if (layoutMatch) {
                this.currentLayout = layoutMatch[1];
            }
        });
    }

    // Persistent layout switching with actual file updates
    async persistLayoutChange(newLayout) {
        const activeView = app.workspace.getActiveViewOfType(MarkdownView);
        if (!activeView) return;

        const file = activeView.file;
        const content = await app.vault.read(file);
        
        // Parse and update frontmatter
        const frontmatterMatch = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
        if (frontmatterMatch) {
            let frontmatter = frontmatterMatch[1];
            
            if (frontmatter.includes('pageLayout:')) {
                frontmatter = frontmatter.replace(/pageLayout:.*$/m, `pageLayout: ${newLayout}`);
            } else {
                frontmatter += `\npageLayout: ${newLayout}`;
            }
            
            const newContent = content.replace(/^---\r?\n[\s\S]*?\r?\n---/, (m) => {
                const eol = m.includes("\r\n") ? "\r\n" : "\n";
                return `---${eol}${frontmatter}${eol}---`;
            });
            await app.vault.modify(file, newContent);
        }
    }
}

// Initialize global layout switcher
if (typeof window !== 'undefined') {
    window.layoutSwitcher = new LiveLayoutSwitcher();
    
    // Global function for template use
    window.switchLayout = function(layout, persist = false) {
        if (persist) {
            window.layoutSwitcher.persistLayoutChange(layout);
        } else {
            window.layoutSwitcher.switchLayout(layout);
        }
    };
}

// Export for Templater
module.exports = { LiveLayoutSwitcher };
%>