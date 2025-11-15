---
description: Generate custom React hook with TypeScript and tests
agent: frontend
temperature: 0.2
---

# Create Hook: $HOOK_NAME

$ARGUMENTS

## Generate

1. **Hook**: `hooks/$HOOK_NAME.ts` - Hook with TypeScript, JSDoc, generics if needed
2. **Tests**: `hooks/$HOOK_NAME.test.ts` - Tests with @testing-library/react

## Placement

### Directory Structure
```
src/
├── modules/
│   ├── user/
│   │   └── hooks/           # Feature-specific hooks
│   │       └── useUserProfile.ts
├── common/
│   └── hooks/               # Shared hooks (used in 2+ modules)
│       ├── useDebounce.ts
│       ├── useLocalStorage.ts
│       └── useWindowSize.ts
```

### Placement Rules
- **Feature-specific hooks**: `src/modules/[feature]/hooks/`
- **Shared hooks** (used in 2+ places): `src/common/hooks/`
- Don't reuse feature-specific code across features (move to common/)

## Import/Export Standards

**Import Order:**
```typescript
// 1. External dependencies
import { useState, useEffect } from 'react';

// 2. Internal (absolute paths)
import { api } from '@/lib/api';

// 3. Relative
import type { User } from '../types';
```

**Named Exports Only:**
```typescript
// ✅ Named export
export function useDebounce<T>(value: T, delay: number): T { ... }

// ❌ NO default exports
export default useDebounce; // BAD
```

## Requirements

- Hook name must start with `use`
- **Named exports only** (no default exports)
- TypeScript with explicit types
- JSDoc documentation
- Complete dependency arrays (no missing dependencies)
- Cleanup in useEffect returns
- Generic types where appropriate

## Check Existing Patterns

```bash
grep "^export function use" src/hooks/*.ts | head -3
```

## Example

```typescript
/**
 * Debounces a value for the specified delay.
 *
 * @param value - The value to debounce
 * @param delay - Delay in milliseconds
 * @returns Debounced value
 */
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);
  
  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(handler);
  }, [value, delay]);
  
  return debouncedValue;
}
```
