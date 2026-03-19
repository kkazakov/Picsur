# Picsur - Agent Guidelines

## Project Overview

Picsur is an image hosting platform (Imgur clone) with a NestJS backend, Angular frontend, and shared TypeScript library. Uses pnpm workspaces.

## Commands

### Root Level
```bash
pnpm format          # Format all files with Prettier
pnpm lint            # Lint with ESLint (--fix included)
pnpm build           # Build all (via ./support/build.sh)
pnpm devdb:start     # Start dev PostgreSQL via Docker
pnpm devdb:stop      # Stop dev database
```

### Backend (`/backend`)
```bash
pnpm start:dev       # Nest dev server with watch
pnpm build           # Build for production
pnpm migrate         # Generate TypeORM migration
```

### Frontend (`/frontend`)
```bash
pnpm start           # Angular dev server (ng serve)
pnpm build           # Production build
pnpm watch           # Development watch mode
```

### Shared (`/shared`)
```bash
pnpm build          # Compile TypeScript
pnpm start          # Watch mode for development
```

## Architecture

### Backend (NestJS + Fastify)
- **Entry**: `backend/src/main.ts`
- **Module**: `backend/src/app.module.ts`
- **Routes**: `backend/src/routes/routes.module.ts` (imports API and Image modules)
- **Database**: TypeORM with PostgreSQL
- **Auth**: JWT + Passport (local, API key strategies)

### Frontend (Angular 18)
- **Entry**: `frontend/src/main.ts`
- **Module**: `frontend/src/app/app.module.ts`
- **Routing**: `frontend/src/app/app.routing.module.ts`
- **API Client**: `frontend/src/app/services/api/api.service.ts`

### Shared Library
- **Purpose**: DTOs, entities, validators, error handling types
- **Exports**: All via `shared/src/index.ts` (currently empty, use barrel imports)

## Code Style

### Imports
- Use absolute imports from package roots (e.g., `picsur-shared/dist/dto/api/user.dto`)
- Backend uses ES modules with `.js` extensions in imports
- Angular uses standard relative imports

### TypeScript
- **Target**: ES2022
- **Module**: NodeNext (backend/shared), ES2022 (frontend)
- **Strict mode**: Enabled in `tsconfig.base.json`
- **Decorators**: Experimental decorators enabled

### Formatting (Prettier)
```yaml
singleQuote: true
tabWidth: 2
trailingComma: all
arrowParens: always
endOfLine: lf
```

### Naming Conventions
- **Files**: kebab-case (e.g., `user.service.ts`, `auth.guard.ts`)
- **Classes**: PascalCase (e.g., `UserController`, `UserService`)
- **Enums**: Prefixed with `E` for entities (e.g., `EUser`), bare for permissions (e.g., `Permission`)
- **Constants**: PascalCase for DTOs, UPPERCASE for constants

## Error Handling

### Failable Pattern
All operations that can fail use the `Failable<T>` type from `shared/src/types/failable.ts`:

```typescript
import { Fail, FT, HasFailed, ThrowIfFailed } from 'picsur-shared/dist/types/failable';

// Return failure
return Fail(FT.NotFound, 'User not found');

// Check and handle
if (HasFailed(result)) {
  // handle error
}

// Throw if failed
const user = ThrowIfFailed(await userService.findById(id));
```

### Failure Types (FT enum)
- `Unknown`, `Database`, `SysValidation`, `UsrValidation`
- `BadRequest`, `Permission`, `RateLimit`, `NotFound`
- `RouteNotFound`, `Conflict`, `Internal`, `Authentication`, `Impossible`, `Network`

### API Response Format
All JSON responses wrapped in `ApiResponseSchema`:
```typescript
{
  success: boolean,
  statusCode: number,
  timestamp: string,
  timeMs: number,
  data: T // or { type: string, message: string } on error
}
```

## Backend Patterns

### Controllers
- Use `@Controller()` with route prefix
- Mark return types with `@Returns(ZodDtoClass)`
- Use permission decorators: `@RequiredPermissions()`, `@NoPermissions()`, `@UseLocalAuth()`
- Add rate limiting with `@EasyThrottle(attempts, ttl?)`

### Services
- Inject via constructor
- Return `Failable<T>` or `AsyncFailable<T>`
- Use `ThrowIfFailed()` for required operations

### DTOs
- Use Zod schemas via `createZodDto()` from `shared/src/util/create-zod-dto.ts`
- Example: `createZodDto(z.object({ username: z.string().min(3) }))`

## Frontend Patterns

### API Calls
```typescript
const result = apiService.get(UserDto, 'api/user/me');
const progress = result.uploadProgress; // Observable<number>
const data = await result.result;       // AsyncFailable<T>
```

### Components
- Use standalone modules pattern (e.g., `HeaderModule`, `FooterModule`)
- Lazy load route modules via `loadChildren()`

### Forms
- Use custom validators from `shared/src/validators/`
- Form DTOs in `frontend/src/app/models/forms-dto/`

## Database

### Migrations
```bash
cd backend
pnpm migrate          # Generate migration
# Edit migration file if needed
pnpm typeorm migration:run
```

### Entities
- Shared entities in `shared/src/entities/`
- Backend-specific in `backend/src/database/entities/`

## Testing

No test suite exists. Nest CLI configured with `"spec": false` in `nest-cli.json`.

## Dependencies

- **Backend**: NestJS 10, Fastify, TypeORM, PostgreSQL, Sharp (image processing)
- **Frontend**: Angular 18, Angular Material, RxJS, Axios
- **Shared**: Zod (validation), MS (duration parsing)

## Important Files

| Path | Purpose |
|------|---------|
| `backend/src/app.module.ts` | Backend module composition |
| `backend/src/routes/routes.module.ts` | Route module aggregation |
| `frontend/src/app/app.module.ts` | Frontend module composition |
| `frontend/src/app/services/api/api.service.ts` | HTTP client |
| `shared/src/types/failable.ts` | Error handling |
| `shared/src/util/create-zod-dto.ts` | DTO factory |
| `tsconfig.base.json` | Base TypeScript config |
| `.eslintrc.cjs` | ESLint config |
| `.prettierrc.yaml` | Prettier config |
