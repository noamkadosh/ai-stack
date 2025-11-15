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

**Core principles** (detailed patterns in @frontend agent):
- Server components default (App Router)
- `'use client'` for interactivity
- Props interface above component
- Components <120 lines (body only)
- Functional components only (no class components)

## NestJS/Backend

**Core patterns** (detailed patterns in @backend agent):
- Controllers: thin, HTTP only
- Services: business logic
- DTOs: validate with class-validator
- Always parameterized queries (never string concatenation)

## Database

**Core principles** (detailed patterns in @database agent):
- Normalized schemas (3NF)
- Parameterized queries only
- Index foreign keys and query columns
- Migrations for all schema changes

## Project Structure

**Detailed patterns in slash commands** (see `/component`, `/endpoint`, `/hook` for specifics):
- Feature modules in `src/modules/[feature]/`
- Shared code in `src/common/`
- Types (>2) in `ComponentName.types.ts`
- Custom hooks in `hooks/` subfolder

## Imports/Exports

**Named exports only** (detailed patterns in slash commands):
```typescript
// ❌ NO default exports
export default MyComponent; // BAD

// ✅ Named exports
export const MyComponent = ...; // GOOD
```

**Import Order:**
1. External dependencies
2. Internal (absolute paths from tsconfig)
3. Relative

**If import path has too many layers, update paths in `tsconfig.json`**

## Testing

**Core principles** (detailed patterns in @test agent):
- Jest/Vitest (unit), Playwright (e2e), Storybook (components)
- F.I.R.S.T: Fast, Independent, Repeatable, Self-validating, Timely
- Arrange-Act-Assert pattern
- Coverage: 80%+ critical paths
- Test behavior, not implementation

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

**Core principles** (detailed rules in @frontend agent):
- Use semantic HTML elements
- Keyboard navigation support
- ARIA attributes where needed
- All images need `alt` text
- Focus styles required
- **Reference:** [WCAG 2.1](https://www.w3.org/WAI/WCAG21/quickref/)

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
