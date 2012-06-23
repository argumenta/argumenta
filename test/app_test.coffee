app     = require '../app'
agent   = require 'superagent'
request = require 'request'
should  = require 'should'

base = 'http://localhost:3000'

# Url helper prepends `base` to a relative `path`.
abs_url = (path) ->
  if ~path.search /https?:\/\// then path else base + path

# Superagent helpers.
get = (path, cb) ->
  agent.get( abs_url path ).end( cb )

post = (path, data, cb) ->
  agent.post( abs_url path ).send( data ).end( cb )

# Request helpers.
req_get = (path, cb) ->
  request abs_url(path), cb

req_post = (path, data, cb) ->
  options =
    uri: abs_url(path)
    form: data
  request.post options, cb

describe 'App', () ->

  before (done) ->
    unless app.config.appMode is 'testing'
      return console.log "Won't drop non-testing database"

    app.argumenta.storage.clearAll (err) ->
      should.not.exist err
      done()

  describe '/index', () ->
    it 'should respond successfully', (done) ->
      get '/', (res) ->
        res.status.should.equal 200
        res.text.should.match /Argumenta/
        done()

  # TODO: Users (GET /users, GET /user/:name.json)
  describe '/users', () ->

    describe 'POST /users', ->
      it 'should create a new user', (done) ->
        user =
          username: 'tester'
          password: 'tester12'
          email:    'tester@xyz.com'
        post '/users', user, (res) ->
          res.status.should.equal 200
          res.text.should.match /tester/
          done()

      it 'should refuse to create an invalid user', (done) ->
        badUser =
          username: ''
          password: ''
          email:    'tester@xyz.com'
        post '/users', badUser, (res) ->
          res.status.should.equal 400
          res.text.should.match /error.*password.*blank/i
          done()

      it 'should refuse to overwrite an already existing user', (done) ->
        existingUser =
          username: 'tester'
          password: 'tester12'
          email:    'tester@xyz.com'
        post '/users', existingUser, (res) ->
          res.status.should.equal 409
          res.text.should.match /User already exists./
          done()

    describe 'GET /users', ->
      it 'should show a list of users', ->
        get '/users', (res) ->
          res.status.should.equal 200
          res.text.should.match /Users/
          res.text.should.match /tester/

    describe 'GET /users/:name', ->
      it 'should show the user', (done) ->
        get '/users/' + 'tester', (res) ->
          res.status.should.equal 200
          res.text.should.match /tester/
          res.text.should.not.match /Error getting/
          done()

    describe 'GET /users/:name.json', ->
      it 'should show the user as json', (done) ->
        get '/users/' + 'tester.json', (res) ->
          res.status.should.equal 200
          res.type.should.equal 'application/json'
          res.text.should.match /tester/
          done()

      it 'should show an error when user not found', (done) ->
        get '/users/' + 'nobody.json', (res) ->
          res.status.should.equal 404
          res.type.should.equal 'application/json'
          res.text.should.match /error.*user.*nobody.*not found/i
          done()

  describe '/login', ->

    describe 'GET /login', ->
      it 'should show the login page', (done) ->
        get '/login', (res) ->
          res.status.should.equal 200
          res.text.should.match /Username/
          res.text.should.match /Password/
          res.text.should.match /Login!/
          done()

    describe 'POST /login', ->

      it 'should accept a correct login', (done) ->
        data =
          username: 'tester'
          password: 'tester12'

        req_post '/login', data, (err, res, body) ->
          should.not.exist err
          res.statusCode.should.equal 302
          res.headers.location.should.match /^http.*tester$/
          url = res.headers.location

          req_get url, (err, res, body) ->
            should.not.exist err
            res.statusCode.should.equal 200
            body.should.match /Welcome back/
            done()

      it 'should deny an incorrect login', (done) ->
        data =
          username: 'tester'
          password: 'wrong!'
        req_post '/login', data, (err, res, body) ->
          should.not.exist err
          res.statusCode.should.equal 302
          res.headers.location.should.match /^http.*login$/
          url = res.headers.location

          req_get url, (err, res, body) ->
            res.statusCode.should.equal 200
            res.body.should.match /Invalid username and password combination./
            done()
