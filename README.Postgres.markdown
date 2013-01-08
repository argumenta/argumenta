
# Postgres Setup

## Option 1: Automatic Setup

Argumenta uses a Postgres database and role for each app mode (development, testing, staging, and production).  
The included script `bin/setup-postgres.sh` will setup a role, database, and schema.

```
$ ./bin/setup-postgres.sh --help

  Usage: setup-postgres.sh [options] [<db>]

    <db>          Name of database to create; defaults to 'argumenta'.

  Options:
    -h, --help:          Show this help info.
    -u, --user <user>:   Database user to create.
    -p, --pass <pass>:   Database user's password.
    -t, --test-only:     Do nothing; but print what would happen.
```

Run the script to setup a database, role, and password for each mode:

```shell
$ # Note the space before each command.
$ # It will omit the command from your bash history if `HISTCONTROL` includes `ignorespace`.
$  sudo ./bin/setup-postgres.sh --user 'argumenta_development' --pass '<PASSWORD>' 'argumenta_development'
$  sudo ./bin/setup-postgres.sh --user 'argumenta_testing' --pass '<PASSWORD>' 'argumenta_testing'
$  sudo ./bin/setup-postgres.sh --user 'argumenta_staging' --pass '<PASSWORD>' 'argumenta_staging'
$  sudo ./bin/setup-postgres.sh --user 'argumenta' --pass '<PASSWORD>' 'argumenta'
```

## Option 2: Manual Setup

You may alternatively setup the role, database, and schema manually.  
For example, using the utilities bundled with Postgres:  

1\. Create a role and password for testing with the `createuser` command:
```shell
$ sudo -u postgres createuser --login --encrypted --pwprompt 'argumenta_testing'
Enter password for new role: 
Enter it again: 
```

2\. Create a database for this role with `createdb`:
```shell
$ sudo -u postgres createdb --owner='argumenta_testing' 'argumenta_testing'
```

3\. Now initialize the schema for this database with `psql` and our schema file:
```shell
$ sudo -u postgres \
    PGOPTIONS='--client-min-messages=warning' \
    psql --file='./db/schema.sql' --host=localhost --port=5432 \
         --username='argumenta_testing' --dbname='argumenta_testing'
```

4\. Repeat the above steps to create an 'argumenta' role and database for production:
```shell
$ sudo -u postgres createuser --login --encrypted --pwprompt 'argumenta'
$ sudo -u postgres createdb --owner='argumenta' 'argumenta'
$ sudo -u postgres \
    PGOPTIONS='--client-min-messages=warning' \
    psql --file='./db/schema.sql' --host=localhost --port=5432 \
         --username='argumenta' --dbname='argumenta'
```

5\. For staging:
```shell
$ sudo -u postgres createuser --login --encrypted --pwprompt 'argumenta_staging'
$ sudo -u postgres createdb --owner='argumenta_staging' 'argumenta_staging'
$ sudo -u postgres \
    PGOPTIONS='--client-min-messages=warning' \
    psql --file='./db/schema.sql' --host=localhost --port=5432 \
         --username='argumenta_staging' --dbname='argumenta_staging'
```

6\. And for development:
```shell
$ sudo -u postgres createuser --login --encrypted --pwprompt 'argumenta_development'
$ sudo -u postgres createdb --owner='argumenta_development' 'argumenta_development'
$ sudo -u postgres \
    PGOPTIONS='--client-min-messages=warning' \
    psql --file='./db/schema.sql' --host=localhost --port=5432 \
         --username='argumenta_development' --dbname='argumenta_development'
```

