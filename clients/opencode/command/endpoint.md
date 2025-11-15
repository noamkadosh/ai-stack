---
description: Create API endpoint with controller, service, DTOs, and tests
agent: backend
temperature: 0.2
---

# Create Endpoint: $RESOURCE_NAME

$ARGUMENTS

## Generate

1. **Controller**: `$RESOURCE_NAME.controller.ts` - CRUD routes with guards
2. **Service**: `$RESOURCE_NAME.service.ts` - Business logic
3. **Create DTO**: `dto/create-$RESOURCE_NAME.dto.ts` - DTO with validation
4. **Update DTO**: `dto/update-$RESOURCE_NAME.dto.ts` - Update DTO (PartialType)
5. **Module**: `$RESOURCE_NAME.module.ts` - Module registration
6. **Tests**: Controller and service tests

## Module Structure

```
src/
├── modules/
│   ├── $RESOURCE_NAME/
│   │   ├── dto/
│   │   │   ├── create-$RESOURCE_NAME.dto.ts
│   │   │   └── update-$RESOURCE_NAME.dto.ts
│   │   ├── entities/
│   │   │   └── $RESOURCE_NAME.entity.ts
│   │   ├── $RESOURCE_NAME.controller.ts
│   │   ├── $RESOURCE_NAME.service.ts
│   │   ├── $RESOURCE_NAME.repository.ts
│   │   ├── $RESOURCE_NAME.module.ts
│   │   └── __tests__/
│   │       ├── $RESOURCE_NAME.controller.spec.ts
│   │       └── $RESOURCE_NAME.service.spec.ts
```

## RESTful Routes

```
GET    /api/v1/$RESOURCE_NAME       # List
GET    /api/v1/$RESOURCE_NAME/:id   # Get one
POST   /api/v1/$RESOURCE_NAME       # Create
PUT    /api/v1/$RESOURCE_NAME/:id   # Update
DELETE /api/v1/$RESOURCE_NAME/:id   # Delete
```

## Import/Export Standards

**Import Order:**
```typescript
// 1. External dependencies
import { Controller, Get, Post, Body } from '@nestjs/common';

// 2. Internal (absolute paths from tsconfig)
import { JwtAuthGuard } from '@/auth/guards/jwt-auth.guard';

// 3. Relative
import { CreateUserDto } from './dto/create-user.dto';
import { UserService } from './user.service';
```

**Named Exports Only:**
```typescript
// ✅ Named export
export class UserController { ... }

// ❌ NO default exports
export default UserController; // BAD
```

## Check Existing Patterns

```bash
ls src/**/*.controller.ts | head -3
```

## Requirements

- **Named exports only** (no default exports)
- DTOs with class-validator decorators
- JwtAuthGuard on all routes except public ones
- Proper error handling (NotFoundException, ConflictException, etc.)
- Service layer for business logic (controllers stay thin)
- Repository pattern for data access
- Tests with mocked dependencies
- **Import paths**: Update tsconfig.json if paths get too nested
