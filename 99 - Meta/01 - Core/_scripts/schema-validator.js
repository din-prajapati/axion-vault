// Schema Validation Engine for Templater
// Validates inheritance chains and schema structures

class SchemaValidator {
    constructor() {
        this.schemas = new Map();
        this.validationCache = new Map();
    }

    // Load schema from base file
    async loadSchema(baseName) {
        if (this.schemas.has(baseName)) {
            return this.schemas.get(baseName);
        }

        try {
            const basePath = `_bases/${baseName}.base`;
            const baseFile = app.vault.getAbstractFileByPath(basePath);
            
            if (!baseFile) {
                console.warn(`Schema file not found: ${basePath}`);
                return null;
            }

            const content = await app.vault.read(baseFile);
            const schema = this.parseSchema(content);
            
            if (schema) {
                this.schemas.set(baseName, schema);
            }
            
            return schema;
        } catch (error) {
            console.error(`Failed to load schema ${baseName}:`, error);
            return null;
        }
    }

    parseSchema(content) {
        // Extract YAML frontmatter (CRLF/LF safe)
        const frontmatterMatch = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
        if (!frontmatterMatch) {
            console.warn('Invalid schema format: missing frontmatter');
            return null;
        }

        try {
            // Parse YAML (simplified parser)
            const yamlText = frontmatterMatch[1];
            const schema = this.parseYAML(yamlText);
            
            // Validate schema structure
            this.validateSchemaStructure(schema);
            
            return schema;
        } catch (error) {
            console.error(`Schema parsing failed: ${error.message}`);
            return null;
        }
    }

    // Simplified, indentation-tolerant YAML parser for schemas
    parseYAML(yamlText) {
        const lines = yamlText.replace(/\r/g, '').split('\n');
        const root = {};
        const stack = [{ indent: -1, node: root }];

        for (const rawLine of lines) {
            if (!rawLine) continue;
            const line = rawLine; // keep leading spaces
            const trimmed = line.trim();
            if (!trimmed || trimmed.startsWith('#')) continue;

            const indentMatch = line.match(/^[ \t]*/);
            const indent = indentMatch ? indentMatch[0].replace(/\t/g, '    ').length : 0;

            // Find parent by indentation
            while (stack.length && indent <= stack[stack.length - 1].indent) {
                stack.pop();
            }
            const parent = stack[stack.length - 1].node;

            // List item line starting with '-'
            if (trimmed.startsWith('- ')) {
                const afterDash = trimmed.slice(2);
                if (afterDash.includes(':')) {
                    // Object item in array
                    const [k, ...vparts] = afterDash.split(':');
                    const ktrim = k.trim();
                    const v = vparts.join(':').trim();
                    const obj = {};
                    obj[ktrim] = v === '' ? {} : this.parseValue(v);
                    // Ensure last key of parent is an array
                    const lastKey = Object.keys(parent).pop();
                    if (!lastKey || !Array.isArray(parent[lastKey])) {
                        // create anonymous array placeholder
                        parent.items = parent.items && Array.isArray(parent.items) ? parent.items : [];
                        parent.items.push(obj);
                        stack.push({ indent, node: obj[ktrim] === {} ? obj : obj });
                    } else {
                        parent[lastKey].push(obj);
                        stack.push({ indent, node: obj[ktrim] === {} ? obj : obj });
                    }
                } else {
                    // Simple value in array
                    const lastKey = Object.keys(parent).pop();
                    if (!lastKey || !Array.isArray(parent[lastKey])) {
                        // If parent doesn't have an array yet, create a generic one named 'items'
                        parent.items = parent.items && Array.isArray(parent.items) ? parent.items : [];
                        parent.items.push(this.parseValue(afterDash));
                    } else {
                        parent[lastKey].push(this.parseValue(afterDash));
                    }
                }
                continue;
            }

            // Key: value or Key:
            const colonIdx = line.indexOf(':');
            if (colonIdx === -1) continue;
            const key = line.slice(0, colonIdx).trim();
            const valueRaw = line.slice(colonIdx + 1).trim();

            if (valueRaw === '') {
                // New nested section
                const obj = {};
                parent[key] = obj;
                stack.push({ indent, node: obj });
            } else if (valueRaw === '-' || valueRaw.startsWith('- ')) {
                // New array
                const arr = [];
                parent[key] = arr;
                // Push array container to stack for children
                stack.push({ indent, node: { [key]: arr } });
                if (valueRaw.startsWith('- ')) {
                    arr.push(this.parseValue(valueRaw.slice(2)));
                }
            } else {
                parent[key] = this.parseValue(valueRaw);
            }
        }

        return root;
    }

    parseValue(value) {
        // Convert string values to appropriate types
        if (value === 'true') return true;
        if (value === 'false') return false;
        if (value === 'null' || value === '') return null;
        if (/^\d+$/.test(value)) return parseInt(value);
        if (/^\d+\.\d+$/.test(value)) return parseFloat(value);
        return value.replace(/^["']|["']$/g, ''); // Remove quotes
    }

    validateSchemaStructure(schema) {
        if (!schema.__meta__ || !schema.__meta__.id) {
            console.warn('Schema missing required __meta__.id field');
        }
        return true;
    }

    // Validate inheritance chain for circular references
    async validateInheritanceChain(baseName, visited = new Set()) {
        if (visited.has(baseName)) {
            const chain = [...visited, baseName].join(' → ');
            console.error(`Circular inheritance detected: ${chain}`);
            return false;
        }

        const schema = await this.loadSchema(baseName);
        if (!schema) return false;

        visited.add(baseName);

        if (schema.__inherits__) {
            const parentName = schema.__inherits__.replace(/\[\[|\]\]/g, '').split('/').pop();
            return await this.validateInheritanceChain(parentName, new Set(visited));
        }

        return true;
    }

    // Resolve complete schema with inheritance
    async resolveSchema(baseName) {
        const cacheKey = baseName;
        if (this.validationCache.has(cacheKey)) {
            return this.validationCache.get(cacheKey);
        }

        const isValid = await this.validateInheritanceChain(baseName);
        if (!isValid) {
            console.error(`Invalid inheritance chain for ${baseName}`);
            return null;
        }
        
        const schema = await this.loadSchema(baseName);
        if (!schema) return null;

        let resolvedSchema = { ...schema };

        // Resolve parent schemas
        if (schema.__inherits__) {
            const parentName = schema.__inherits__.replace(/\[\[|\]\]/g, '').split('/').pop();
            const parentSchema = await this.resolveSchema(parentName);
            
            if (parentSchema) {
                resolvedSchema = this.mergeSchemas(parentSchema, schema);
            }
        }

        this.validationCache.set(cacheKey, resolvedSchema);
        return resolvedSchema;
    }

    mergeSchemas(parent, child) {
        const merged = JSON.parse(JSON.stringify(parent)); // Deep clone

        // Merge each section
        Object.keys(child).forEach(key => {
            if (key.startsWith('__')) {
                // Merge metadata sections
                if (typeof child[key] === 'object' && !Array.isArray(child[key])) {
                    merged[key] = { ...merged[key], ...child[key] };
                } else {
                    merged[key] = child[key];
                }
            } else {
                // Override field values
                merged[key] = child[key];
            }
        });

        return merged;
    }

    // Validate frontmatter against resolved schema
    async validateFrontmatter(frontmatter, baseName) {
        const schema = await this.resolveSchema(baseName);
        if (!schema) return { valid: false, errors: ['Schema not found'] };

        const errors = [];
        const types = schema.__types__ || {};
        const options = schema.__options__ || {};
        const validation = schema.__validation__ || {};

        // Type validation
        Object.keys(types).forEach(field => {
            const value = frontmatter[field];
            const expectedType = types[field];
            
            if (value !== undefined && value !== null) {
                if (!this.validateFieldType(value, expectedType)) {
                    errors.push(`Field '${field}' should be type '${expectedType}', got '${typeof value}'`);
                }
            }
        });

        // Options validation
        Object.keys(options).forEach(field => {
            const value = frontmatter[field];
            const allowedOptions = options[field];
            
            if (value && Array.isArray(allowedOptions) && !allowedOptions.includes(value)) {
                errors.push(`Field '${field}' value '${value}' not in allowed options: ${allowedOptions.join(', ')}`);
            }
        });

        // Custom validation rules
        Object.keys(validation).forEach(field => {
            const value = frontmatter[field];
            const rules = validation[field];
            
            if (rules.required && (value === undefined || value === null || value === '')) {
                errors.push(`Field '${field}' is required`);
            }
        });

        return { valid: errors.length === 0, errors };
    }

    validateFieldType(value, expectedType) {
        switch (expectedType) {
            case 'string': return typeof value === 'string';
            case 'number': return typeof value === 'number';
            case 'boolean': return typeof value === 'boolean';
            case 'date': return /^\d{4}-\d{2}-\d{2}$/.test(value);
            case 'multiselect': return Array.isArray(value);
            case 'select': return typeof value === 'string';
            case 'text': return typeof value === 'string';
            case 'link': return typeof value === 'string';
            default: return true; // Unknown type, allow anything
        }
    }
}

// Global validator instance
if (typeof window !== 'undefined') {
    window.schemaValidator = new SchemaValidator();
}

// Export for Templater
module.exports = SchemaValidator;
