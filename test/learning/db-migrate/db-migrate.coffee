
should        = require 'should'
child_process = require 'child_process'
path          = require 'path'
config        = require '../../../config'
exec          = child_process.exec

appDir = path.join __dirname, '../../../'
dbDir  = path.join appDir, 'db'
process.env.DATABASE_URL = config.postgresUrl
process.env.PATH = path.join(appDir, 'node_modules/.bin:') + process.env.PATH

describe 'db-migrate', ->

  before (done) ->
    process.chdir dbDir
    exec 'db-migrate down -c 9001', (err, stdout, stderr) ->
      should.not.exist err
      stdout.should.match /\[INFO\] Done/
      done()

  after (done) ->
    process.chdir dbDir
    exec 'db-migrate up', (err, stdout, stderr) ->
      should.not.exist err
      stdout.should.match /\[INFO\] Done/
      done()

  reset = (done) ->
    process.chdir __dirname
    done()

  cleanup = (done) ->
    exec 'rm -fr migrations; mkdir migrations', (err) ->
      should.not.exist err
      done()

  beforeEach reset
  afterEach cleanup

  describe 'create <title>', ->

    it 'should create a new migration with title', (done) ->
      exec 'db-migrate create first', (err, stdout, stderr) ->
        should.not.exist err
        exec 'ls -1 migrations/*first.js | wc -l', (err, stdout, stderr) ->
          should.not.exist err
          stdout.should.match /^1\n$/
          done()

  describe 'up', ->

    it 'should run a migration up', (done) ->
      copyCommand = 'cp ./fixtures/first.js ./migrations/20130507051756-first.js'
      exec copyCommand, (err, stdout, stderr) ->
        should.not.exist err
        exec 'db-migrate up', (err, stdout, stderr) ->
          should.not.exist err
          stdout.should.match /\[INFO\] Processed migration .*first/
          done()

  describe 'down', ->

    it 'should run a migration down', (done) ->
      copyCommand = 'cp ./fixtures/first.js ./migrations/20130507051756-first.js'
      exec copyCommand, (err, stdout, stderr) ->
        should.not.exist err
        exec 'db-migrate down', (err, stdout, stderr) ->
          should.not.exist err
          stdout.should.match /\[INFO\] Processed migration .*first/
          done()
