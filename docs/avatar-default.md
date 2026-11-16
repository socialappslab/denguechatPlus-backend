# Avatar 1 initial assignment (PM note 3)

## Cause and scope

The avatar catalog introduced in commit `f2c5516` creates four base avatars and
their skin variants. `CreateAvatars` adds a nullable `user_profiles.avatar_id`
without a default or backfill. The `create_avatars` seed only creates images;
registration creates a profile without assigning an avatar. Profile serializers
expose the stored avatar ID and its image URL; mobile renders initials when that
URL is absent. There was no initial assignment in any of these paths.

"Avatar: setear avatar 1 a todos" is implemented as an initial default. Existing
non-null selections are preserved, including selections of avatars 2–4 made via
`users/change_avatar`. Literally resetting every selection would overwrite that
supported user choice and requires a separate product decision.

## Behavior

- New profiles receive the active, non-discarded base catalog entry with
  `base_code = 'avatar-1'` and no reward level. IDs, positions and skin variants
  do not determine the default.
- Before the catalog exists, profile creation can still proceed without an
  avatar. The backfill runs after catalog seeding, including on subsequent seed
  runs where the `create_avatars` seed marker already exists.
- The backfill updates only null avatar IDs, including profiles belonging to
  inactive/discarded accounts. It preserves skin settings and timestamps. Its
  SQL null predicate also protects selections made concurrently with the update.
- A missing, inactive or discarded default causes the explicit backfill to fail
  before updating profiles. Repair/seed the catalog before retrying.
- No schema, reward records, mobile code or dashboard columns change.

## Local rollout

Review the target connection before running commands. No staging/production
backfill or deployment has been performed. No schema migration is added: a data
task avoids running before the avatar catalog is seeded.

For an existing local database with the avatar migrations and catalog installed:

```sh
cd /Users/olrtg/d/denguechat/api
RAILS_ENV=development bundle exec rails data_migration:backfill_default_avatar
```

The task prints the number assigned. Run it again to verify zero additional
assignments. For a fresh local installation, the normal `db:migrate` then
`db:seed` sequence creates the catalog before the backfill. Do not rerun all seeds
solely to backfill a database whose catalog already exists.
