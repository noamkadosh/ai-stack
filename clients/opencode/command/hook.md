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

## Requirements

- Hook name must start with `use`
- TypeScript with explicit types
- JSDoc documentation
- Complete dependency arrays
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
