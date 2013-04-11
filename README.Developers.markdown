
# Developer Notes

These developer notes show how to install, configure, build, run, and test Argumenta from source.

## Install

### 1. Get the Source

To get started with Argumenta development, clone the git repo:

```shell
$ git clone https://github.com/argumenta/argumenta.git
```

Even better, fork our repo on GitHub and clone that. This way you can push your changes, and send us a pull request!

### 2. Install Dependencies

Change into the source directory, and install Argumenta's dependencies with npm:

```shell
$ cd argumenta
$ npm install
```
### 4. Database Setup

Setup databases in the same way you would for a normal install, but using `./bin/setup-postgres.sh`.  
See the [Install instructions][Install].

[Install]: ./README.Install.markdown

### 3. Configure

Run the command `./bin/setup-config.sh` to generate local config files:

```bash
$ argumenta-setup-config
Initializing config/deploy
Creating './config/deploy/development.coffee'
Creating './config/deploy/testing.coffee'
Creating './config/deploy/staging.coffee'
Creating './config/deploy/production.coffee'
Done!
```

This copies defaults for each mode, and generates a random app secret. It won't overwrite existing config files.

You should now edit these files. In particular, uncomment the `postgresUrl` setting and change its `PASSWORD` placeholder to match the database password for each mode. The other settings can be safely left commented out, and Argumenta will simply use each mode's defaults.

### 4. Run

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

## Building

Make all (build + docs)

```shell
$ make all
```

Make build (server + client)

```shell
$ make build
```

Make coffee

```shell
$ make coffee
```

Make coffee automatically

```shell
$ make coffee_forever
```

## Testing

Run tests once

```shell
$ make test
```

Run tests automatically

```shell
$ make test_forever
```

Run tests matching `pattern` in a given `file`

```shell
$ NODE_ENV='testing' mocha -g '<pattern>' test/<file>.js
```

## Test Options

### NODE_ENV

The node env determines the application mode.  
Current modes include 'production', 'staging', 'development', and 'testing'.  
Settings for each mode reside in `config/deploy/<mode>.coffee`.  
These extend the mode defaults in `config/modes/<mode>.coffee`.

### LOG_LEVEL

The default log level for tests hides errors to reduce output noise.  
Change the log level from 'testing' to 'debug' to see more error output.

```shell
$ LOG_LEVEL='debug' make test
```

### REPORTER

The default reporter shows the name of each test as it is run.  
Change the reporter from 'spec' to 'dot' for quieter automatic testing.

```shell
$ REPORTER='dot' make test_forever
```

### BCRYPT_COST

The bcrypt cost determines how many times passwords will be hashed.  
The default cost of '10' increases the cost of reversing password hashes, but slows down account creation and login.  
When testing, the value is lowered to '1' for faster tests.  
Raise the bcrypt cost above '10' to experiment with higher values.

```shell
$ BCRYPT_COST='12' make test
```
