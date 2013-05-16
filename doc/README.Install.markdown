
## Argumenta Setup


### 1. Install Node (0.8+)

Download Node.js from [the official site][Nodejs], or using your OS package manager.  
[Current versions][Downloads] of Node.js include the excellent [npm][Npm] package manager.

[Nodejs]: http://nodejs.org/
[Npm]: https://npmjs.org/
[Downloads]: http://nodejs.org/download/


### 2. Install Postgres (9.2+)

Download PostgreSQL from [postgresql.org][Postgres], or using your package manager.

[Postgres]: http://www.postgresql.org/


### 3. Install Argumenta

Install Argumenta with npm:

```bash
$ npm install -g argumenta
```

This provides the `argumenta` command, which starts the app:

```bash
$ argumenta
Argumenta 0.0.1 (development mode) | http://localhost:3000
```

It also provides `argumenta-setup`, which sets up a server install of Argumenta.

```bash
$ sudo argumenta-setup
```

This installs the app in `/usr/local/argumenta`, configuration files in `/etc/argumenta`, and creates an `argumenta` Upstart service and user account. It also creates an `argumenta-backup` user, and cron job in `/etc/cron.d` for [nightly backups][Admin].


### 4. Argumenta Config

Edit the configuration file for each mode in `/etc/argumenta`. In particular, uncomment the `postgresUrl` setting and change its `PASSWORD` placeholder to a password of your choice for each mode. The other settings can be safely left commented out, and Argumenta will use each mode's defaults.


### 5. Argumenta Database and Roles

#### Quick Setup

Argumenta provides `argumenta-setup-postgres` for database setup.  
Run these commands with your chosen password to configure each mode:

```bash
$ # Note the space before each command.
$ # It will omit the command from your bash history if `HISTCONTROL` includes `ignorespace`.
$  sudo argumenta-setup-postgres --user 'argumenta_development' --pass '<PASSWORD>' 'argumenta_development'
$  sudo argumenta-setup-postgres --user 'argumenta_testing'     --pass '<PASSWORD>' 'argumenta_testing'
$  sudo argumenta-setup-postgres --user 'argumenta_staging'     --pass '<PASSWORD>' 'argumenta_staging'
$  sudo argumenta-setup-postgres --user 'argumenta'             --pass '<PASSWORD>' 'argumenta'
```

#### Setup Details

See [postgres setup][Postgres-setup] for details on automatic and manual setup.


### 6. Run the App!

The `CONFIG_DIR` and `NODE_ENV` environment variables set the configuration directory and mode when running Argumenta:

```bash
$ CONFIG_DIR='/etc/argumenta' NODE_ENV='production' argumenta
```

The Argumenta Upstart service uses `/etc/argumenta` and `production` by default, so you can simply run:

```bash
$ sudo start argumenta
```


## Further Resources

See [Developer notes][Developers] for details on running, building, and testing Argumenta from source.  
See [Postgres setup][Postgres-setup] for details on setting up Postgres databases.  
See [Admin notes][Admin] for details on creating and restoring backups.  
See [Web API][API] for details on using Argumenta's Web API.

[Admin]: ./README.Admin.markdown
[Developers]: ./README.Developers.markdown
[Postgres-setup]: ./README.Postgres.markdown
[API]: ./README.API.markdown
