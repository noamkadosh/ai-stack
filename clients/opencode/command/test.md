---
description: Generate comprehensive unit tests (Jest/Vitest)
agent: test
temperature: 0.1
---

# Generate Tests: @$FILE_PATH

$ARGUMENTS

## Requirements

- Test all exported functions/classes
- Arrange-Act-Assert pattern
- Happy path + edge cases + error scenarios
- Mock external dependencies (use jest.spyOn)
- Descriptive test names ("should X when Y")
- 80%+ coverage

## Check Test Framework

```bash
grep -l "jest\|vitest" package.json
```

## Test Structure

```typescript
describe('ServiceName', () => {
  let service: ServiceName;
  let mockDependency: jest.Mocked<Dependency>;

  beforeEach(() => {
    mockDependency = { method: jest.fn() } as any;
    service = new ServiceName(mockDependency);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('methodName', () => {
    it('should return expected result when conditions met', () => {
      // Arrange
      mockDependency.method.mockReturnValue('value');

      // Act
      const result = service.methodName();

      // Assert
      expect(result).toBe('expected');
      expect(mockDependency.method).toHaveBeenCalledWith('args');
    });

    it('should throw error when invalid input', () => {
      expect(() => service.methodName(null)).toThrow('Error message');
    });
  });
});
```

## Coverage Focus

- All public methods
- Edge cases (null, undefined, empty, large inputs)
- Error paths
- Boundary conditions
