---
description: Generate comprehensive unit tests (Jest/Vitest)
agent: test
temperature: 0.1
---

# Generate Tests: @$FILE_PATH

$ARGUMENTS

## Requirements

- Test all exported functions/classes
- **F.I.R.S.T Principles**:
  - **F**ast: Quick execution
  - **I**ndependent: Tests don't depend on each other
  - **R**epeatable: Same results every time
  - **S**elf-validating: Pass/fail, no manual checking
  - **T**imely: Written with or before code
- Arrange-Act-Assert pattern
- Happy path + edge cases + error scenarios
- Mock external dependencies (use jest.spyOn)
- Descriptive test names ("should X when Y")
- 80%+ coverage

## Check Test Framework

```bash
grep -l "jest\|vitest" package.json
```

## Testing Best Practices

**File Naming:**
```
src/users/user.service.ts
src/users/__tests__/user.service.test.ts  ← Unit tests in __tests__/
```

**Mock with jest.spyOn:**
```typescript
// ✅ GOOD - Spy on actual method
const spy = jest.spyOn(userRepo, 'findById').mockResolvedValue(mockUser);

// ❌ AVOID - Full object mocks (brittle)
const mockRepo = { findById: jest.fn(), save: jest.fn(), ... };
```

**One Concept Per Test:**
```typescript
// ❌ BAD - Testing multiple things
it('should create user and send email', async () => {
  const user = await service.create(dto);
  expect(user).toBeDefined();
  expect(emailService.send).toHaveBeenCalled(); // Different concern
});

// ✅ GOOD - One concept
it('should create user with valid data', async () => {
  const user = await service.create(dto);
  expect(user.email).toBe(dto.email);
});

it('should send welcome email after user creation', async () => {
  await service.create(dto);
  expect(emailService.send).toHaveBeenCalledWith(dto.email, 'welcome');
});
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
