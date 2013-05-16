
# Argumenta Admin

These notes on server administration show how to backup, restore, and migrate the database.

## Backup

### Automatic

After running `argumenta-setup` to configure your server, nightly backups of the
production database are created in `/home/argumenta-backup/backups`.
This is controlled by the cron file `/etc/cron.d/argumenta-backup`.

Backups are created daily (Mon-Sun), weekly (on Sunday), and monthly (1st of each
month). If an old backup for the current day, week, or month exists, it's
removed to make room for the new one.

### Manual

You can also generate a backup manually with `argumenta-backup`:
```bash
$ sudo argumenta-backup
Creating backup dir: '/home/argumenta-backup/backups/argumenta'.
Creating backup: '/home/argumenta-backup/backups/argumenta/argumenta_2013.05.16.sql'.
Creating daily backup: '/home/argumenta-backup/backups/argumenta/daily/argumenta_2013.05.16.sql.Thu'.
```

## Restore

Before restoring a database, prepare a role and remove any existing database with the same name.

```bash
# If you haven't setup a database role, do so now:
$  sudo argumenta-setup-postgres --user argumenta --pass 'PASSWORD' argumenta

# If a database with the name you wish to restore already exists, you must drop it first:
$ sudo -u postgres psql -c 'DROP DATABASE "argumenta";'
```

You may now load a database backup file with `argumenta-restore`:
```bash
# Restores the production database from a daily backup.
$ sudo argumenta-restore 'argumenta' /home/argumenta-backup/backups/daily/argumenta_2013.05.03.sql.Fri
```

## Migrate

The `argumenta-migrate` command provides a way to update the database schema between releases.

It's a light wrapper for the [db-migrate][Db-Migrate] executable.
Here's the most useful options:

```bash
$ argumenta-migrate -h

Usage: db-migrate [up|down|create] migrationName [options]

Options:
  --count, -c           Max number of migrations to run.
  --dry-run             Prints the SQL but doesn't run it.
  --verbose, -v         Verbose mode.
  --version, -i         Print version info.
```

To migrate the production database up after installing a new release, run:

```bash
$ NODE_ENV=production argumenta-migrate up
[INFO] Processed migration 20130507094551-initial
[INFO] Done
```
The wrapper will load the database url for the application mode from your config files.

[Db-Migrate]: https://github.com/nearinfinity/node-db-migrate
