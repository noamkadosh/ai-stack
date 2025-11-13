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

## Placement

Place in `tests/e2e/` or `e2e/` directory
