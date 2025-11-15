---
description: Generate Playwright E2E tests for complete user flows
agent: test
temperature: 0.1
---

# Generate E2E Tests: $FEATURE_NAME

$ARGUMENTS

## Requirements

- Complete user flow (happy path + error cases)
- Page object pattern for reusable selectors
- Setup/teardown with test data
- Assertions at each step
- Screenshots on failure (automatic with Playwright)

## Test Structure

```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature Name', () => {
  test.beforeEach(async ({ page }) => {
    // Setup: Navigate, login, create test data
    await page.goto('/feature');
  });

  test.afterEach(async ({ page }) => {
    // Cleanup: Delete test data
  });

  test('happy path: user completes flow successfully', async ({ page }) => {
    // Step 1: Fill form
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'password123');
    
    // Step 2: Submit
    await page.click('button[type="submit"]');
    
    // Step 3: Verify success
    await expect(page).toHaveURL('/success');
    await expect(page.getByText('Success message')).toBeVisible();
  });

  test('error: shows validation error for invalid email', async ({ page }) => {
    await page.fill('input[name="email"]', 'invalid');
    await page.click('button[type="submit"]');
    
    await expect(page.getByText('Invalid email')).toBeVisible();
  });
});
```

## Page Object Pattern (Optional)

```typescript
class FeaturePage {
  constructor(private page: Page) {}

  async navigate() {
    await this.page.goto('/feature');
  }

  async fillForm(data: FormData) {
    await this.page.fill('input[name="email"]', data.email);
    await this.page.fill('input[name="password"]', data.password);
  }

  async submit() {
    await this.page.click('button[type="submit"]');
  }

  async expectSuccess() {
    await expect(this.page).toHaveURL('/success');
  }
}
```

## Coverage

- ✅ Happy path (success scenario)
- ✅ Validation errors
- ✅ Authentication failures
- ✅ Network errors (mock failed requests)
- ✅ Loading states
- ✅ Empty states

## Best Practices

**Selectors:**
```typescript
// ❌ BRITTLE - CSS classes may change
await page.click('.submit-btn');

// ✅ ROBUST - Data attributes for testing
await page.click('[data-testid="submit-button"]');

// ✅ SEMANTIC - ARIA roles
await page.click('button[role="submit"]');
```

**Wait for Elements:**
```typescript
// ❌ BAD - Fixed delays (flaky)
await page.click('button');
await page.waitForTimeout(2000);

// ✅ GOOD - Wait for conditions
await page.click('button');
await expect(page.getByText('Success')).toBeVisible();
```

**Data Isolation:**
```typescript
test.describe('User Registration', () => {
  let testEmail: string;

  test.beforeEach(() => {
    // Generate unique test data
    testEmail = `test-${Date.now()}@example.com`;
  });

  test.afterEach(async ({ request }) => {
    // Cleanup: Delete test user
    await request.delete(`/api/users?email=${testEmail}`);
  });
});
```

**Network Mocking:**
```typescript
// Mock API responses
await page.route('/api/users', route => {
  route.fulfill({
    status: 200,
    body: JSON.stringify([{ id: 1, name: 'Test User' }])
  });
});
```

## Placement

Place in `tests/e2e/` or `e2e/` directory

**File naming:**
```
tests/e2e/auth/login.spec.ts
tests/e2e/checkout/cart-to-payment.spec.ts
```
