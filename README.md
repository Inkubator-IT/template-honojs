## Inkubator IT — Hono + Bun API Template

Minimal Hono API template for projects in the Inkubator IT GitHub organization. The template standardizes the runtime, quality gates, local PostgreSQL infrastructure, container image, and CI/CD conventions without adding an ORM, authentication, OpenAPI, or application architecture.

### Tech stack

- **Runtime**: Bun 1.4.2
- **Framework**: Hono
- **Language**: TypeScript
- **Quality**: Biome, TypeScript, and Bun test
- **Containerization**: Docker
- **Database (local)**: PostgreSQL 16 via Docker Compose

### Project structure

```text
.
├─ src/
│  ├─ app.ts              # Hono app declaration and routes
│  ├─ app.test.ts         # Hono app smoke test
│  ├─ configs/             # Configuration helpers
│  ├─ controllers/         # Request handlers
│  ├─ db/                  # Database placeholders
│  ├─ lib/                 # Shared libraries
│  ├─ middlewares/         # Hono middleware placeholders
│  ├─ repositories/        # Data access placeholders
│  ├─ routes/              # Route registration placeholders
│  ├─ services/            # Business logic placeholders
│  ├─ types/               # Type definition placeholders
│  ├─ utils/               # Utility placeholders
│  └─ index.ts             # Bun server entrypoint
├─ Dockerfile             # Production application image
├─ docker-compose.yaml    # Local PostgreSQL service
├─ .dockerignore          # Docker build context exclusions
├─ .env.example           # Example environment variables
├─ biome.json             # Biome config
├─ tsconfig.json          # TypeScript config
├─ package.json           # Scripts and dependencies
└─ .github/workflows/
   └─ deploy.yaml         # CI, GHCR publishing, and commented Dokploy job
```

### Prerequisites

- **Bun 1.4.2** (`bun --version`)
- **Docker** and **Docker Compose**

The required Bun version is also pinned in `package.json` through `packageManager` and in the Docker image.

### Getting started

1. Create a new repository using this template in the Inkubator IT organization.
2. Clone your new repository.
3. Create a local environment file:

```sh
cp .env.example .env
```

4. Install the locked dependencies:

```sh
bun install --frozen-lockfile
```

5. Start the local database when PostgreSQL is needed:

```sh
docker compose up -d db
docker compose ps db
```

6. Start the API in dev mode:

```sh
bun run dev
```

7. Open `http://localhost:3000` or the port configured by `APP_PORT`.

### Environment variables

Duplicate `.env.example` to `.env` and update the values. Do not commit `.env`.

- **APP_PORT**: Application port; defaults to `3000`.
- **NODE_ENV**: `development` or `production`.
- **DB_HOST**, **DB_PORT**, **POSTGRES_USER**, **POSTGRES_PASSWORD**, **POSTGRES_DB**: Local PostgreSQL settings.
- **DATABASE_URL**: Full PostgreSQL URL for a future client; this template does not include a database driver or ORM.

### Database (local)

The Compose file keeps PostgreSQL at version 16 Alpine and exposes it through the project-scoped `db` service. It has a `pg_isready` healthcheck and does not set a global `container_name`, so multiple projects can run without container-name collisions.

Start PostgreSQL:

```sh
docker compose up -d db
docker compose ps db
```

Validate the Compose configuration after creating `.env`:

```sh
docker compose --env-file .env.example config
```

Connect, for example:

```sh
psql "postgresql://myuser:mypassword@localhost:5432/mydb"
```

### Run with Docker

Build the production image. The image installs production dependencies only and runs the application as the non-root `bun` user:

```sh
docker build -t inkubatorit/hono-template .
```

Run the default-port container without relying on host-shell expansion of `APP_PORT`:

```sh
docker run --rm --env-file .env -p 3000:3000 inkubatorit/hono-template
```

If `.env` sets a custom `APP_PORT`, replace both `3000` values in the mapping with that explicit port.

### Bun scripts

- **dev**: `bun run --hot src/index.ts`
- **start**: `bun run src/index.ts`
- **format**: `biome format --write .`
- **format:check**: `biome format .` without writing files
- **lint**: `biome lint .`
- **lint:fix**: `biome lint --write .`
- **typecheck**: `tsc --noEmit`
- **test**: `bun test`
- **test:watch**: `bun test --watch`
- **check**: format check, lint, typecheck, then test

Run the complete local quality gate:

```sh
bun run check
bun audit
```

The smoke test calls `app.request("/")` and checks both the `200` status and `Hello Hono!` response body.

### CI/CD

`.github/workflows/deploy.yaml` runs on every pull request and on pushes to `main`.

- The `quality` job uses Bun 1.4.2, performs a frozen install, runs `bun run check`, and runs `bun audit`.
- Pull requests run only the quality job; they do not build or publish a Docker image.
- After quality passes on a push to `main`, the `publish` job logs in to GHCR with `GITHUB_TOKEN` and `packages: write` permission, then publishes using a lowercased repository path:
  - `ghcr.io/<lowercase-github-repository>:latest`
  - `ghcr.io/<lowercase-github-repository>:sha-<short-sha>`
- Publishing remains disabled for repositories named `Inkubator-IT/template-*`, preserving the template-repository condition.
- Jobs use concurrency cancellation and explicit timeouts.

### Dokploy

The Dokploy job is fully commented in the workflow. To enable it for a project:

1. Create or select the GitHub environment named `production`.
2. Add `DOKPLOY_WEBHOOK_URL` as a secret in that environment.
3. Uncomment the `dokploy` job in `.github/workflows/deploy.yaml`.
4. Keep the job dependent on `publish`; it runs only after a successful `main` publish and triggers the webhook with `curl --fail-with-body`.

If the GHCR package is private, configure GHCR read credentials in Dokploy so the deployment can pull the published image.

### Deployment notes

- Provide application environment variables through the deployment platform or an environment file.
- Set `APP_PORT` to the port used by the runtime and reverse proxy.
- Set `NODE_ENV=production` in production environments.

### Contributing

This template is maintained by the **Inkubator IT DevOps** team. Contributions and improvements are welcome via pull requests. For significant changes, open an issue for discussion first.

### Support

For questions or support, contact the Inkubator IT DevOps team.

### License

Copyright (c) Inkubator IT. All rights reserved.
