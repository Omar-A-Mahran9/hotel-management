# Hotel Group Management Platform

Laravel API backend for a multi-hotel group management platform. Built as a
modular monolith (`app/Domain/{Context}`) with Repository + Service layers,
policy-based authorization, and a hotel-scoped RBAC foundation.

See `md/hotel_platform_phase0_approved_baseline.md` for the approved
architecture and requirements baseline. **Phase 1 (Foundation / RBAC)** is
implemented; later phases (rooms, reservations, payments, verification,
access, services, checkout, loyalty, reviews) are not yet built.

## Phase 1 scope

- Laravel API foundation under `/api/v1`, standard JSON response envelope,
  Sanctum token authentication.
- Identity & Access domain: Users, Roles, Permissions, `user_hotel_access`.
- Hotel Group / Hotels domain.
- RBAC with four seeded roles — Group Owner, Hotel Manager, Reception, Guest
  — enforced via Policies/Gates, never the UI.
- Hotel scope isolation: a user's accessible hotels are always resolved from
  their own stored `user_hotel_access` records (or an explicit Group Owner
  all-hotels bypass), never from a client-supplied `hotel_id`.
- Audit log foundation (`audit_logs`) for identity/hotel-group/hotel writes.
- English/Arabic localization foundation (`lang/en`, `lang/ar`, `X-Locale`
  header or `?lang=` query param).

## Setup

```bash
composer install
cp .env.example .env
php artisan key:generate
```

Create the MySQL databases referenced in `.env` (defaults:
`hotel_platform` for the app, `hotel_platform_testing` for `phpunit.xml`),
then:

```bash
php artisan migrate --seed
```

In `local` environment, seeding also creates a Group Owner account from
`GROUP_OWNER_EMAIL` / `GROUP_OWNER_PASSWORD` (defaults to
`owner@example.com` / `password`) so you have a way in.

## Testing

```bash
php artisan test
```

Runs against the `hotel_platform_testing` MySQL database configured in
`phpunit.xml` (matches the production driver rather than SQLite, so
MySQL-specific constraint/migration behavior is exercised too).

## Code style

```bash
./vendor/bin/pint
```
