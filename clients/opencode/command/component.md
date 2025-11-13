---
description: Generate React component with TypeScript, tests, and Storybook story
agent: frontend
temperature: 0.2
---

# Create Component: $COMPONENT_NAME

$ARGUMENTS

## Generate

1. **Component**: `$COMPONENT_NAME.tsx` - TypeScript component with props interface
2. **Styles**: `$COMPONENT_NAME.module.css` - CSS modules
3. **Story**: `$COMPONENT_NAME.stories.tsx` - Storybook with variants
4. **Tests**: `$COMPONENT_NAME.test.tsx` - Unit tests with React Testing Library

## Check Existing Patterns

```bash
ls src/components/*/index.tsx | head -3
```

## Placement

Place in appropriate directory:
- **UI components**: `src/components/ui/`
- **Feature components**: `src/components/features/`
- **Layout components**: `src/components/layouts/`

## Requirements

- Props interface above component
- TypeScript strict mode
- Server component by default (add `'use client'` if needed)
- Accessibility considered (ARIA attributes)
- Responsive design
- Component <250 lines
