
# Changes

## 0.0.6 / 2013-05-15

+ Add command `argumenta-migrate`.
+ Add initial migration.
+ Add migration for join date and ip.
+ Add migration for public users view and gravatar id.
+ Allow database argument for `argumenta-backup`.

## 0.0.5 / 2013-05-05

+ Add command `argumenta-backup`.
+ Add command `argumenta-restore`.
+ Automatic backups daily, weekly, monthly.

## 0.0.4 / 2013-04-26

+ Add options: gzip, port.
+ Add Upstart service for Nginx.
+ Configure Nginx and SSL on setup.
+ Handle uncaught exceptions.
+ Update `argumenta-widgets` to 0.0.5.

## 0.0.3 / 2013-04-18

+ Add favicon.
+ Fix CSS compilation bug.
+ Fix label alignment on signup form.
+ Use gzip for static assets.

## 0.0.2 / 2013-04-14

+ Fix source directory in commands.
+ Add makefile targets: production, development.
+ Update `argumenta-widgets` to 0.0.4.

## 0.0.1 / 2013-04-13

+ Install with npm.
+ Add readme file.
+ Add command `argumenta`.
+ Add command `argumenta-setup`.
+ Add command `argumenta-setup-postgres`.
+ Add stylus makefile target.
+ Support for Upstart, logging, server config.
+ Add MIT license.
