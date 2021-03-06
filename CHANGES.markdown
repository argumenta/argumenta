
# Changes

## 0.1.5 / 2014-04-16

+ Add feature for argument editing.
+ Add collection for repos.
+ Add collections directory.
+ Add robots.txt file.
+ Add link to widgets shim.
+ Add metadata option for Storage accessors.
+ Show argument repos on homepage.
+ Show latest publications on profile pages.
+ Change tag icon to ribbon.
+ Change `Argument#slugify()` to replace periods.
+ Disable httpOnly for session cookies.
+ Update modules `pg`, `pg-nest`.

## 0.1.4 / 2014-01-26

+ Trust proxy headers.
+ Add config option for `proxy`.
+ Show propositions on index page.
+ Show discussions for argument repos.

## 0.1.3 / 2013-12-25

+ Add discussions and comments.
+ Add migration for discussions.
+ Add API routes for discussions and comments.

## 0.1.2 / 2013-10-23

+ Add proposition publishing.
+ Add proposition search results.
+ Show publications on public user page.

## 0.1.1 / 2013-09-27

+ Add intro ribbon, panel.
+ Add join, login modals.
+ Add procedural audience widget.

## 0.1.0 / 2013-09-16

+ Search for users, arguments, propositions.
+ Use widgets for search, sidebar, users.
+ Show latest users, arguments.
+ Document API resources.
+ Add search API route.

## 0.0.10 / 2013-08-02

+ Add config option for `host`.
+ Add `commit.host` property.
+ Fix data attribute escaping in Jade.

## 0.0.9 / 2013-07-03

+ Add config option for `baseUrl`.
+ Add CORS middleware.
+ Add watchCSS helper.
+ Add widget config to layout.

## 0.0.8 / 2013-05-23

+ Automate API doc generation.
+ Add script `build-api-doc.coffee`.
+ Add makefile target `api_doc`.
+ Replace coffee config files with json.
+ Modularize stylesheets.
+ Show avatars on profile page.

## 0.0.7 / 2013-05-16

+ Use migrations for Postgres setup.
+ Remove compiled JS from system config.
+ Update install docs.

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

+ Add config options: gzip, port.
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
