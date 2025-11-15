# Code Standards

Comprehensive coding standards for TypeScript, React, NestJS, and database code.

## General Principles

**SOLID Principles:**
- **S**ingle Responsibility: One class/function, one purpose
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Subtypes must be substitutable for base types
- **I**nterface Segregation: Many specific interfaces > one general
- **D**ependency Injection: Don't hardcode dependencies

**Other:**
- **DRY**: Extract repeated code into functions/utilities
- **KISS**: Simplest solution that works wins
- **YAGNI**: Don't build for hypothetical future needs

## TypeScript/JavaScript

### Type Safety
```typescript
// ❌ AVOID
function process(data: any) { ... }

// ✅ PREFER
function process(data: User) { ... }
// Or use unknown with type guards
function process(data: unknown) {
  if (isUser(data)) { ... }
}
```

### Type vs Interface
```typescript
// ✅ Use type for unions, primitives, tuples (PREFER type over interface)
type Status = 'pending' | 'approved' | 'rejected';
type Coordinates = [number, number];

// ✅ Use interface only when you need extension
interface User {
  id: string;
  email: string;
}
```

### Type Annotations
```typescript
// ❌ BAD - Type assertion
const palette = {
  red: [255, 0, 0],
  green: "#00ff00",
} as Record<"red" | "green", string | RGB>;

// ✅ GOOD - satisfies (narrowing)
const palette = {
  red: [255, 0, 0],
  green: "#00ff00",
} satisfies Record<"red" | "green", string | RGB>;
```

### Enums
```typescript
// ❌ BAD
enum Environment {
  "development",
  "production",
}

// ✅ GOOD - String enums only
enum Environment {
  Development = "development",
  Production = "production",
}
```

### Naming Conventions
- **Types/Interfaces**: PascalCase (`User`, `StatusType`)
- **Enums**: PascalCase (`UserRole`)
- **Variables**: camelCase (`userName`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_RETRIES`)
- **Functions**: camelCase (`getUserById`)
- **Classes**: PascalCase (`UserService`)
- **Files (components)**: PascalCase (`HomePage.tsx`)
- **Files (non-components)**: camelCase (`useHomePageData.ts`)

### Code Quality
1. No eslint errors/warnings
2. No hardcoded values, use constants
3. Comments should describe reasoning, not what code does
4. No deprecated elements & attributes
5. Avoid raw text, use translations
6. Use lodash only if ES6+ APIs don't exist
7. Use Promises or async/await with rejection handling

### Functions
1. Max 3 arguments (use object if more needed)
2. Keep functions under 20 lines
3. Use destructuring for arrays/objects
4. All props must be sanitized

## React/NextJS

### Components
```typescript
// ✅ Props interface above component
interface ButtonProps {
  variant: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  children: React.ReactNode;
}

export function Button({ variant, size = 'md', disabled = false, children }: ButtonProps) {
  return (
    <button className={`btn btn-${variant} btn-${size}`} disabled={disabled}>
      {children}
    </button>
  );
}
```

### Rules
1. Use functional components (no `React.FC`)
2. No `React.createElement()` unless initializing app
3. Use fragments instead of extra divs
4. Keep components under 120 lines (body only)
5. Define Props interface for all components
6. Move side effects out of render methods
7. Don't edit props within components
8. Avoid multiple if/else blocks in render
9. Don't use index as key prop
10. Move reusable code to common space (if used in 2+ places)

### Server vs Client Components (NextJS)
```typescript
// ✅ Server Component (default in App Router)
export default async function Page() {
  const data = await fetchData();
  return <Display data={data} />;
}

// ✅ Client Component (explicit)
'use client';

export function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

### Hooks
```typescript
// ✅ Custom hooks start with 'use'
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);
  
  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(handler);
  }, [value, delay]);
  
  return debouncedValue;
}

// ✅ Complete dependency arrays
useEffect(() => {
  fetchData(userId, filter);
}, [userId, filter]);

// ✅ Cleanup side effects
useEffect(() => {
  const subscription = subscribe();
  return () => subscription.unsubscribe();
}, []);
```

### Performance
```typescript
// ✅ Memoize expensive computations
const expensiveValue = useMemo(() => computeExpensiveValue(a, b), [a, b]);

// ✅ Memoize callbacks
const handleClick = useCallback(() => doSomething(value), [value]);

// ✅ Memoize components (use sparingly)
export const MemoizedComponent = React.memo(Component);
```

### Event Handlers
- Props: prefix with `on` (e.g., `onClick`)
- Handlers: prefix with `handle` (e.g., `handleClick`)

### Props Naming
```typescript
// ❌ BAD - Avoid DOM prop names, use camelCase
<MyComponent style="fancy" UserName="hello" phone_number={12345678} />

// ✅ GOOD
<MyComponent variant="fancy" userName="hello" phoneNumber={12345678} />
```

## NestJS/Backend

### Module Organization
```typescript
@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UserController],
  providers: [UserService, UserRepository],
  exports: [UserService], // Export if used by other modules
})
export class UserModule {}
```

### Controller Pattern
```typescript
@Controller('api/v1/users')
@UseGuards(JwtAuthGuard)
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<UserDto> {
    return this.userService.findOne(id);
  }

  @Post()
  @UsePipes(new ValidationPipe())
  async create(@Body() dto: CreateUserDto): Promise<UserDto> {
    return this.userService.create(dto);
  }
}
```

### Service Pattern
```typescript
@Injectable()
export class UserService {
  constructor(
    private readonly userRepo: UserRepository,
    private readonly logger: Logger,
  ) {}

  async create(dto: CreateUserDto): Promise<User> {
    // Validation
    const exists = await this.userRepo.findByEmail(dto.email);
    if (exists) throw new ConflictException('Email already exists');

    // Business logic
    const user = await this.userRepo.create(dto);

    this.logger.log(`User created: ${user.id}`);
    return user;
  }
}
```

### DTO Validation
```typescript
export class CreateUserDto {
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsString()
  @MinLength(8)
  @MaxLength(128)
  @Matches(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]/)
  password: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  name?: string;
}
```

### Error Handling
```typescript
// ✅ Use specific exceptions
throw new NotFoundException('User not found');
throw new BadRequestException('Invalid input');
throw new ConflictException('Email exists');
throw new ForbiddenException('Access denied');
```

## Database

### Migration Naming
```
YYYYMMDDHHMMSS_descriptive_name.ts
20240115120000_create_users_table.ts
```

### Query Optimization
```typescript
// ❌ N+1 Query Problem
const users = await userRepo.find();
for (const user of users) {
  user.posts = await postRepo.findByUserId(user.id);
}

// ✅ Eager Loading
const users = await userRepo.find({ relations: ['posts'] });
```

### Index Strategy
- Index all foreign keys
- Composite indexes for common queries
- Partial indexes for filtered queries

## Project Structure

### Folder Organization
```
src/
├── modules/              # Feature modules
│   ├── user/
│   │   ├── components/   # Child components (keep simple ones here)
│   │   ├── hooks/        # useMySomething.ts
│   │   ├── utils/        # Utility functions
│   │   ├── User.tsx      # Main component
│   │   ├── User.types.ts # Types/interfaces (if >2)
│   │   ├── User.constants.ts # Constants (if >2)
│   │   └── __tests__/
├── common/               # Shared across modules
│   ├── hooks/
│   ├── utils/
│   ├── constants/
│   └── types/
```

### Rules
1. Feature components in separate PascalCase folder
2. Child components in `components/` subfolder (no nested folders if <100 lines)
3. Utils in `utils/` folder
4. Constants (>2) in `ComponentName.constants.ts`
5. Types (>2) in `ComponentName.types.ts`
6. Custom hooks in `hooks/` subfolder as `useSomething.ts`
7. Don't reuse feature-specific code across features (move to common/)

## Imports/Exports

```typescript
// ✅ Destructuring imports
import { Component } from './Component';

// ✅ Type imports
import type { User } from './types';

// ❌ NO default exports
export default MyComponent; // BAD

// ✅ Named exports
export const MyComponent = ...; // GOOD
```

### Component Naming
```typescript
// ✅ Use directory name as component name
import { Footer } from './Footer';           // GOOD
import { Footer } from './Footer/index';     // BAD
import { Footer } from './Footer/Footer';    // BAD
```

### Import Order
```typescript
// 1. External dependencies
import { Injectable } from '@nestjs/common';

// 2. Internal (absolute paths from tsconfig)
import { UserRepository } from '@/repositories/user.repository';

// 3. Relative
import { CreateUserDto } from './dto/create-user.dto';
```

**If import path has too many layers, update paths in `tsconfig.json`**

## Testing

### Tools
- **Storybook**: Component testing (design-focused)
- **Jest/Vitest + Testing Library**: Unit/integration tests
- **Playwright + Testing Library**: E2E tests
- **MSW**: Mock APIs (REST/GraphQL)

### F.I.R.S.T Principles
- **F**ast: Quick execution
- **I**ndependent: Tests don't depend on each other
- **R**epeatable: Same results every time
- **S**elf-validating: Pass/fail, no manual checking
- **T**imely: Written before or with code

### Structure
```typescript
describe('UserService', () => {
  let service: UserService;
  let mockRepo: jest.Mocked<UserRepository>;

  beforeEach(() => {
    mockRepo = { findById: jest.fn(), create: jest.fn() } as any;
    service = new UserService(mockRepo, mockLogger);
  });

  afterEach(() => jest.clearAllMocks());

  describe('create', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const dto = { email: 'test@example.com', password: 'pass123' };
      mockRepo.create.mockResolvedValue({ id: '1', ...dto });

      // Act
      const result = await service.create(dto);

      // Assert
      expect(result).toEqual({ id: '1', ...dto });
      expect(mockRepo.create).toHaveBeenCalledWith(dto);
    });
  });
});
```

### Rules
1. Unit tests in separate `__tests__/` folder
2. File naming: `myFunction.test.ts` for `myFunction.ts`
3. Mock with `jest.spyOn()` method
4. Write lightweight tests (fast, maintainable, isolated)
5. Descriptive test names: "should return user when id exists"

### Coverage Guidelines
- Critical business logic: 90%+
- Services: 80%+
- Controllers: 70%+
- Focus on edge cases and error paths

## Git Workflow

### GitHub Flow
1. **Create branch** from `main`
   ```sh
   git checkout -b feature/add-user-auth
   ```

2. **Add commits** with descriptive messages
   ```sh
   git commit -m "feat: add user authentication with JWT"
   ```

3. **Open Pull Request**

4. **Merge PR** after review

5. **Delete branch**

### Branch Naming
```
feature/add-user-authentication
fix/resolve-memory-leak
refactor/improve-error-handling
docs/update-api-documentation
chore/upgrade-dependencies
```

### Commit Messages
```
feat: add user authentication with JWT
fix: resolve memory leak in WebSocket handler
refactor: improve error handling in UserService
docs: update API documentation
test: add unit tests for UserService
chore: upgrade dependencies
```

**Format:** `type(scope): subject`
**Types:** feat, fix, docs, style, refactor, test, chore, perf

### Pull Request Guidelines
1. Mark as `Draft` if work in progress
2. Provide description of changes
3. Add testing preview link or images/videos
4. Describe how to test (what's expected, what was fixed)
5. Ensure all pipeline jobs pass
6. Squash to meaningful commits on merge
7. Request multiple reviewers

## Tooling

### Required Tools
1. **Prettier** - Code formatter (let it do its job)
2. **ESLint** - Linter (let it do its job)
3. **Stylelint** - CSS/SCSS linter
4. **browserslist** - Define target browsers
5. **Git Hooks** (husky + lint-staged):
   - Pre-commit hook
   - Format changed files
   - Lint changed files (with `--fix`)
   - Type-check codebase
6. **concurrently** - Parallelize npm scripts
7. **cross-env** - Cross-platform env vars

### Services
- GitHub (version control)
- Sentry.io (error tracking)
- New Relic/DataDog (monitoring)
- Snyk (DAST, SAST, SCA)
- Launch Darkly (feature flags)
- Strapi (CMS)
- AWS/Vercel (hosting)
- Figma (design)

## Accessibility

### Basic Rules
1. Use appropriate DOM elements (`<a>` for links, `<button>` for buttons)
2. Maintain logical tab-order, use `tabindex` if needed
3. Add `<label>` to all form fields with unique IDs
4. Wrap form controls in `<form>` tags
5. Use `<h1>`-`<h4>` in logical hierarchy
6. Add unique IDs to headings for direct linking
7. All `<img>` tags need meaningful `alt` attribute
8. All `<a>` tags need meaningful text or `title` attribute
9. Buttons opening popups need `aria-haspopup` attribute
10. Popups should gain focus on open
11. Auto-updating content needs manual update method
12. All focusable elements need distinguishable `:focus` style
13. Don't use `div`/`span` if appropriate semantic tag exists

**Reference:** [Web Content Accessibility Guidelines (WCAG)](https://www.w3.org/WAI/WCAG21/quickref/)

## Code Review Checklist

- [ ] Follows naming conventions
- [ ] Types are explicit, no `any`
- [ ] No code duplication
- [ ] Functions are single-purpose (<20 lines, <3 args)
- [ ] Components under 120 lines
- [ ] Error handling is comprehensive
- [ ] Tests are included
- [ ] Security best practices followed
- [ ] No hardcoded values
- [ ] Environment variables used correctly
- [ ] No eslint/prettier errors
- [ ] Accessibility requirements met
