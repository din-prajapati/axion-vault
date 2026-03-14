// Property Inheritance System for Templater
// Handles real-time property inheritance and computed properties

class PropertyInheritance {
    constructor() {
        this.propertyCache = new Map();
        this.inheritanceGraph = new Map();
        this.observers = new Map();
    }

    // Build inheritance graph from base files
    async buildInheritanceGraph() {
        try {
            const baseFiles = app.vault.getFiles()
                .filter(file => file.path.includes('_bases/') && file.extension === 'md');

            for (const file of baseFiles) {
                const content = await app.vault.read(file);
                const schema = this.parseSchema(content);
                
                if (schema) {
                    const baseName = file.basename.replace('.base', '');
                    this.inheritanceGraph.set(baseName, {
                        schema,
                        parent: schema.__inherits__ || null,
                        children: new Set()
                    });
                }
            }

            // Build parent-child relationships
            this.inheritanceGraph.forEach((node, name) => {
                if (node.parent) {
                    const parentName = node.parent.replace(/\[\[|\]\]/g, '').split('/').pop();
                    const parentNode = this.inheritanceGraph.get(parentName);
                    if (parentNode) {
                        parentNode.children.add(name);
                    }
                }
            });
        } catch (error) {
            console.error('Failed to build inheritance graph:', error);
        }
    }

    // Get inherited properties for a given base type
    async getInheritedProperties(baseName) {
        if (this.propertyCache.has(baseName)) {
            return this.propertyCache.get(baseName);
        }

        await this.buildInheritanceGraph();
        
        const properties = {};
        const visited = new Set();
        
        await this.collectPropertiesRecursive(baseName, properties, visited);
        
        this.propertyCache.set(baseName, properties);
        return properties;
    }

    async collectPropertiesRecursive(baseName, properties, visited) {
        if (visited.has(baseName)) return;
        visited.add(baseName);

        const node = this.inheritanceGraph.get(baseName);
        if (!node) return;

        // Collect parent properties first (for proper override order)
        if (node.parent) {
            const parentName = node.parent.replace(/\[\[|\]\]/g, '').split('/').pop();
            await this.collectPropertiesRecursive(parentName, properties, visited);
        }

        // Add/override with current node's properties
        const schema = node.schema;
        Object.keys(schema).forEach(key => {
            if (!key.startsWith('__')) {
                properties[key] = schema[key];
            }
        });

        // Merge type definitions
        if (schema.__types__) {
            properties.__types__ = { ...(properties.__types__ || {}), ...schema.__types__ };
        }

        // Merge options
        if (schema.__options__) {
            properties.__options__ = { ...(properties.__options__ || {}), ...schema.__options__ };
        }

        // Merge validation rules
        if (schema.__validation__) {
            properties.__validation__ = { ...(properties.__validation__ || {}), ...schema.__validation__ };
        }
    }

    // Apply inherited properties to frontmatter
    async applyInheritance(frontmatter, baseName) {
        try {
            const inheritedProperties = await this.getInheritedProperties(baseName);
            const result = { ...inheritedProperties };

            // Override with provided frontmatter
            Object.keys(frontmatter).forEach(key => {
                if (!key.startsWith('__')) {
                    result[key] = frontmatter[key];
                }
            });

            return result;
        } catch (error) {
            console.error('Failed to apply inheritance:', error);
            return frontmatter;
        }
    }

    // Generate computed properties
    computeProperties(properties) {
        const computed = { ...properties };

        try {
            // Example: Auto-calculate reading time from description
            if (computed.description && typeof computed.description === 'string') {
                const wordCount = computed.description.split(/\s+/).length;
                computed.reading_time = Math.ceil(wordCount / 200);
            }

            // Example: Auto-generate slug from title
            if (computed.title && typeof computed.title === 'string') {
                computed.slug = computed.title
                    .toLowerCase()
                    .replace(/[^a-z0-9]+/g, '-')
                    .replace(/^-|-$/g, '');
            }

            // Example: Calculate completion percentage for projects
            if (computed.deliverables && Array.isArray(computed.deliverables)) {
                const total = computed.deliverables.length;
                const completed = computed.deliverables.filter(d => 
                    typeof d === 'string' && d.includes('✅')
                ).length;
                computed.completion_percentage = total ? Math.round((completed / total) * 100) : 0;
            }

            // Example: Format display name for persons
            if (computed.full_name || computed.title) {
                computed.display_name = computed.full_name || computed.title;
            }
        } catch (error) {
            console.error('Error computing properties:', error);
        }

        return computed;
    }

    parseSchema(content) {
        // Extract YAML frontmatter
        const match = content.match(/^---\n([\s\S]*?)\n---/);
        if (!match) return null;
        
        try {
            return this.parseYAML(match[1]);
        } catch (error) {
            console.error('Schema parsing error:', error);
            return null;
        }
    }

    parseYAML(yamlText) {
        // Simplified YAML parser (same as in SchemaValidator)
        const lines = yamlText.split('\n');
        const result = {};
        let currentSection = result;
        const sectionStack = [result];

        lines.forEach(line => {
            const trimmed = line.trim();
            if (!trimmed || trimmed.startsWith('#')) return;

            const indentLevel = (line.match(/^ */)[0] || '').length / 2;
            
            while (sectionStack.length > indentLevel + 1) {
                sectionStack.pop();
            }
            currentSection = sectionStack[sectionStack.length - 1];

            if (line.includes(':')) {
                const [key, ...valueParts] = line.split(':');
                const cleanKey = key.trim();
                const value = valueParts.join(':').trim();

                if (value === '') {
                    currentSection[cleanKey] = {};
                    sectionStack.push(currentSection[cleanKey]);
                } else if (value.startsWith('-')) {
                    if (!currentSection[cleanKey]) {
                        currentSection[cleanKey] = [];
                    }
                    currentSection[cleanKey].push(value.substring(1).trim());
                } else {
                    currentSection[cleanKey] = this.parseValue(value);
                }
            } else if (trimmed.startsWith('-')) {
                const lastKey = Object.keys(currentSection).pop();
                if (Array.isArray(currentSection[lastKey])) {
                    currentSection[lastKey].push(trimmed.substring(1).trim());
                }
            }
        });

        return result;
    }

    parseValue(value) {
        if (value === 'true') return true;
        if (value === 'false') return false;
        if (value === 'null' || value === '') return null;
        if (/^\d+$/.test(value)) return parseInt(value);
        if (/^\d+\.\d+$/.test(value)) return parseFloat(value);
        return value.replace(/^["']|["']$/g, '');
    }

    // Watch for property changes and propagate
    observePropertyChanges(filePath, callback) {
        if (!this.observers.has(filePath)) {
            this.observers.set(filePath, new Set());
        }
        this.observers.get(filePath).add(callback);

        // Set up file watcher
        const eventRef = app.vault.on('modify', (file) => {
            if (file.path === filePath) {
                this.handlePropertyChange(filePath);
            }
        });

        return () => {
            this.observers.get(filePath)?.delete(callback);
            app.vault.offref(eventRef);
        };
    }

    async handlePropertyChange(filePath) {
        const observers = this.observers.get(filePath);
        if (!observers) return;

        try {
            const file = app.vault.getAbstractFileByPath(filePath);
            const content = await app.vault.read(file);
            const frontmatter = this.extractFrontmatter(content);

            observers.forEach(callback => {
                try {
                    callback(frontmatter, filePath);
                } catch (error) {
                    console.error('Property change observer error:', error);
                }
            });
        } catch (error) {
            console.error('Property change handling error:', error);
        }
    }

    extractFrontmatter(content) {
        const match = content.match(/^---\n([\s\S]*?)\n---/);
        if (!match) return {};
        
        try {
            return this.parseYAML(match[1]);
        } catch (error) {
            console.error('Frontmatter parsing error:', error);
            return {};
        }
    }
}

// Global property inheritance instance
if (typeof window !== 'undefined') {
    window.propertyInheritance = new PropertyInheritance();
}

// Export for Templater
module.exports = PropertyInheritance;
