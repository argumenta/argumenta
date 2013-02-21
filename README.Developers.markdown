
# Developer Notes

## Running

Run the app!

```shell
$ cd argumenta
$ make all
$ node app
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
