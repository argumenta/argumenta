
## Argumenta Setup

### 1. Install Node (0.8+)

Download node.js from [the official site][Nodejs], or using your OS package manager.  
[Current versions][Downloads] of node.js include the excellent [npm][Npm] package manager.

[Nodejs]: http://nodejs.org/
[Npm]: https://npmjs.org/
[Downloads]: http://nodejs.org/download/ 

### 2. Install Postgres (9.2+)

Download PostgreSQL from [postgresql.org][Postgres], or using your package manager (recommended).

[Postgres]: http://www.postgresql.org/

### 3. Install Argumenta

Download Argumenta from [the github repo][Argumenta-repo].

You may checkout the source with git (recommended):

```shell
$ git checkout git://github.com/qualiabyte/argumenta.git
```

Or download the latest zip archive:

```shell
$ wget https://github.com/qualiabyte/argumenta/archive/master.zip
```

[Argumenta-repo]: https://github.com/qualiabyte/argumenta
[master.zip]: https://github.com/qualiabyte/argumenta/archive/master.zip

### 4. Install Argumenta Modules

With npm installed (it's bundled with node), install Argumenta's dependencies:

```shell
$ cd argumenta
$ npm install
```

### 5. Argumenta Database and Roles

#### Quick Setup

Argumenta includes the script `bin/setup-postgres.sh` for convenience.  
Run these commands to setup databases for each mode automatically:

```shell
$ # Note the space before each command.
$ # It will omit the command from your bash history if `HISTCONTROL` includes `ignorespace`.
$  sudo ./bin/setup-postgres.sh --user 'argumenta_development' --pass '<PASSWORD>' 'argumenta_development'
$  sudo ./bin/setup-postgres.sh --user 'argumenta_testing' --pass '<PASSWORD>' 'argumenta_testing'
$  sudo ./bin/setup-postgres.sh --user 'argumenta_staging' --pass '<PASSWORD>' 'argumenta_staging'
$  sudo ./bin/setup-postgres.sh --user 'argumenta' --pass '<PASSWORD>' 'argumenta'
```

#### Setup Details

See [postgres setup][Postgres-setup] for details on automatic and manual setup.

### 6. Argumenta Config

Next, we'll customize Argumenta's configuration for this deploy.  
Run the script `bin/setup-config.sh`:

```shell
$ ./bin/setup-config.sh
Initializing config/deploy
Creating './config/deploy/development.coffee'
Creating './config/deploy/testing.coffee'
Creating './config/deploy/staging.coffee'
Creating './config/deploy/production.coffee'
Done!
```

In addition to copying the defaults for each mode from `config/modes/*`, this generates a random `appSecret` for each mode. It won't overwrite any existing config files, for example if run previously.

You should now edit these files. In particular, uncomment the `postgresUrl` setting and change its `PASSWORD` placeholder to match the database password for each mode. The other settings can be safely left commented out, and Argumenta will simply use each mode's defaults.

### 7. Run the App!

Run the `build` make target to compile the client and server:

```shell
$ make build
```

Run the test suite to make sure everything is ok:

```shell
$ make test
```

Argumenta should now be ready to run!

```shell
$ node app
Argumenta 0.0.1 (development mode) | http://localhost:3000
```

## Further Resources

See [Developer notes][Developers] for details on running, building, and testing Argumenta.  
See [Postgres setup][Postgres-setup] for details on setting up Postgres databases.  
See [Web API][API] for details on using Argumenta's Web API.

[Developers]: ./README.Developers.markdown
[Postgres-setup]: ./README.Postgres.markdown
[API]: ./README.API.markdown
