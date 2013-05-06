
# Argumenta Admin

These notes on server administration show how to create and restore database backups.

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
Creating backup dir: '/home/argumenta-backup/backups'.
Creating backup: '/home/argumenta-backup/backups/argumenta_2013.05.03.sql'.
Creating daily backup: '/home/argumenta-backup/backups/daily/argumenta_2013.05.03.sql.Fri'.
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
```shell
# Restores the production database from a daily backup.
$ sudo argumenta-restore 'argumenta' /home/argumenta-backup/backups/daily/argumenta_2013.05.03.sql.Fri
```
