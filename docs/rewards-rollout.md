# Rewards rollout on an existing database

After deploying, confirm the reward and avatar migrations are up, including
`20261108000000` (`AddNotifiableToUserRewards`). From the deployed release directory,
with the application's database environment loaded, run each command separately:

```sh
bin/rails data_migration:seed_reward_catalog
bin/rails data_migration:backfill_user_rewards
bin/rails data_migration:backfill_default_avatar
```

Stop if any command fails. On an empty catalog, the first command creates two
reward types, eight levels, and sixteen avatars, including images. It runs only
reward/avatar initialization using the definitions and images already used by
`db:seed`. It can repair partially seeded catalogs even when their seed markers
exist. Existing definitions, images,
user selections, and awards are preserved; missing images must exist in the release.

The reward backfill grants missing historical awards marked as seen, without
notifications. The default-avatar backfill assigns avatar 1 only to profiles
without an avatar. These two backfills can run in either order after the catalog
exists. All three commands can be rerun.

New catalogs use the current names. Databases with older definitions can also run
`bin/rails data_migration:update_reward_design_names` after initializing the catalog.
Do not run all of `db:seed` just to initialize this feature: it includes unrelated
legacy data operations.
