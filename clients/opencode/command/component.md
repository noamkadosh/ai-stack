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

### Directory Structure
```
src/
├── modules/              # Feature modules
│   ├── user/
│   │   ├── components/   # Child components
│   │   ├── hooks/        # useSomething.ts
│   │   ├── utils/        # Utility functions
│   │   ├── User.tsx      # Main component
│   │   ├── User.types.ts # Types (if >2)
│   │   └── __tests__/
├── common/               # Shared across modules
│   ├── components/       # Reusable UI components
│   │   ├── Button/
│   │   ├── Modal/
│   │   └── Input/
```

### Placement Rules
- **Feature components**: `src/modules/[feature]/` (PascalCase folder)
- **Shared UI components**: `src/common/components/`
- **Child components**: `components/` subfolder (if <100 lines, keep simple)
- **Types** (>2): `ComponentName.types.ts` in same directory
- **Constants** (>2): `ComponentName.constants.ts` in same directory

## File Structure

**Main Component:**
```typescript
// ✅ Named export (NO default exports)
export const Button = ({ variant, children }: ButtonProps) => {
  return <button className={`btn-${variant}`}>{children}</button>;
};
```

**Import/Export:**
```typescript
// ✅ Named imports
import { Button } from './Button';
import type { ButtonProps } from './Button.types';

// ❌ NO default exports
export default Button; // BAD

// ✅ Named exports
export const Button = ...; // GOOD
```

**Import Order:**
```typescript
// 1. External dependencies
import { useState, useEffect } from 'react';

// 2. Internal (absolute paths from tsconfig)
import { useAuth } from '@/hooks/useAuth';

// 3. Relative
import { ButtonProps } from './Button.types';
import styles from './Button.module.css';
```

## Requirements

- Props interface above component
- TypeScript strict mode
- **Named exports only** (no default exports)
- Server component by default (add `'use client'` if needed)
- Accessibility considered (ARIA attributes, keyboard navigation)
- Responsive design
- Component <120 lines (body only, excluding imports/types)
