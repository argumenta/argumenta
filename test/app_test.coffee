app    = require '../app'
agent  = require 'superagent'
should = require 'should'

base = 'http://localhost:3000'

get = (path, cb) ->
  agent.get( base + path ).end( cb )

post = (path, data, cb) ->
  agent.post( base + path ).send( data ).end( cb )

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
          res.text.should.match /error.*creating.*username.*blank/i
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
