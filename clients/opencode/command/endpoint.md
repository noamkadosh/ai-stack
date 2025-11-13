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

## RESTful Routes

```
GET    /api/v1/$RESOURCE_NAME       # List
GET    /api/v1/$RESOURCE_NAME/:id   # Get one
POST   /api/v1/$RESOURCE_NAME       # Create
PUT    /api/v1/$RESOURCE_NAME/:id   # Update
DELETE /api/v1/$RESOURCE_NAME/:id   # Delete
```

## Check Existing Patterns

```bash
ls src/**/*.controller.ts | head -3
```

## Requirements

- DTOs with class-validator decorators
- JwtAuthGuard on all routes except public ones
- Proper error handling (NotFoundException, etc.)
- Service layer for business logic
- Tests with mocked dependencies
