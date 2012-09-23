app        = require '../app'
fixtures   = require '../test/fixtures'
superagent = require 'superagent'
request    = require 'request'
should     = require 'should'
Objects    = require '../lib/argumenta/objects'
{Argument} = Objects

base = 'http://localhost:3000'

# Url helper prepends `base` to a relative `path`.
abs_url = (path) ->
  if ~path.search /https?:\/\// then path else base + path

# Creates custom get helper.
getFor = (agent) ->
  return (path, cb) ->
    agent.get( abs_url path ).end( cb )

# Creates custom post helper.
postFor = (agent) ->
  return (path, data, cb) ->
    agent.post( abs_url path ).send( data ).end( cb )

# Temp agent helper - provides callback with get, post.
tempAgent = (callback) ->
  temp = superagent.agent()
  post = postFor temp
  get  = getFor temp
  callback get, post

# Session helper - provides logged in user with new account, get, post.
session = (callback) ->
  tempAgent (get, post) ->
    user = fixtures.uniqueUserData()
    post '/users', user, (err, res) ->
      should.not.exist err
      res.status.should.equal 200
      res.text.should.match new RegExp 'Logged in as <a href="/'+user.username+'">'+user.username+'</a>'
      callback user, get, post

# No session helper - provides user without account, get, post.
noSession = (callback) ->
  user = fixtures.uniqueUser()
  tempAgent (get, post) ->
    callback user, get, post

# Assertion helper - checks if text matches argument
matchesArgument = (text, arg) ->
  for s in arg.premises.concat [arg.title, arg.conclusion]
    text.should.match new RegExp s

# Session with argument helper - provides user, argument data, get, post
sessionWithArgument = (callback) ->
  session (user, get, post) ->
    data = fixtures.uniqueArgumentData()
    post '/arguments', data, (err, res) ->
      should.not.exist err
      res.status.should.equal 200
      callback user, data, get, post

# Superagent helpers.
agent = superagent.agent()
get = getFor agent
post = postFor agent

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

  describe '/', () ->
    describe 'GET /', ->
      it 'should respond with index and links to log in', (done) ->
        get '/', (res) ->
          res.status.should.equal 200
          res.text.should.match /Argumenta/
          res.text.should.match /Sign in.*or.*Join now!/
          done()

  describe '/users', () ->

    describe 'POST /users', (done) ->
      it 'should create a new user and sign in', (done) ->
        user =
          username: 'tester'
          password: 'tester12'
          email:    'tester@xyz.com'
        post '/users', user, (err, res) ->
          res.status.should.equal 200
          res.text.should.match /tester/
          res.text.should.match new RegExp 'Logged in as <a href="/tester">tester</a>'
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
          res.body.should.be.an.instanceof Object
          res.body.user.should.eql { username: 'tester', repos: [] }
          should.not.exist res.body.error
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
            body.should.match new RegExp 'Logged in as <a href="/tester">tester</a>'
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

  describe '/arguments', ->

    describe 'POST /arguments', ->
      it 'should create an argument given a session and valid argument', (done) ->
        session (user, get, post) ->
          data = fixtures.validArgumentData()
          post '/arguments', data, (err, res) ->
            should.not.exist err
            res.status.should.equal 200
            res.redirects.should.eql ["#{base}/#{user.username}/#{data.repo}"]
            res.text.should.match new RegExp "#{user.username}.*/.*#{data.repo}"
            matchesArgument res.text, data
            get '/arguments/' + data.sha1, (res) ->
              res.status.should.equal 200
              matchesArgument res.text, data
              done()

      it 'should redirect to /login if user not logged in', (done) ->
        noSession (user, get, post) ->
          data = fixtures.uniqueArgumentData()
          post '/arguments', data, (err, res) ->
            should.not.exist err
            res.status.should.equal 200
            res.redirects.should.eql [base + "/login"]
            get '/arguments/' + data.sha1, (res) ->
              res.status.should.equal 404
              done()

      it 'should redisplay creation page if object is invalid', (done) ->
        session (user, get, post) ->
          data = fixtures.invalidArgumentData()
          post '/arguments', data, (err, res) ->
            should.not.exist err
            res.redirects.should.eql [base + "/arguments/new"]
            res.status.should.equal 200
            res.text.should.match /Create a new argument/
            res.text.should.match /Error: /
            matchesArgument res.text, data
            done()

    describe 'GET /arguments/:sha1.:format?', ->
      it 'should return an argument page', (done) ->
        sessionWithArgument (user, argument, get, post) ->
          get '/arguments/' + argument.sha1, (res) ->
            res.status.should.equal 200
            res.redirects.should.eql []
            matchesArgument res.text, argument
            done()

      it 'should return an argument as json', (done) ->
        sessionWithArgument (user, argument, get, post) ->
          get '/arguments/' + argument.sha1 + '.json', (res) ->
            res.status.should.equal 200
            res.redirects.should.eql []
            res.body.should.exist
            json = res.body
            should.not.exist json.error
            json.argument.should.eql argument
            done()

      it 'should return an argument as jsonp', (done) ->
        sessionWithArgument (user, argument, get, post) ->
          get '/arguments/' + argument.sha1 + '.jsonp', (res) ->
            res.status.should.equal 200
            res.redirects.should.eql []
            res.type.should.equal 'text/javascript'
            res.text.should.exist
            jsonp = res.text
            jsonpCallback = (json) ->
              should.not.exist json.error
              json.argument.should.eql argument
              done()
            eval jsonp

    # Matches Propositions Data Helper - Checks array of proposition data.
    matchesPropositionsData = (actual, expected) ->
      actual.length.should.equal expected.length
      for prop, index in expected
        actual[index].should.include
          sha1: prop.sha1
          text: prop.text

    # Verify JSONP Helper - Given a JSONP response, invokes callback with json.
    verifyJSONP = (res, callback) ->
      res.type.should.equal 'text/javascript'
      res.text.should.exist
      jsonp = res.text
      jsonpCallback = (json) ->
        callback(json)
      eval jsonp

    describe 'GET /arguments/:sha1/propositions.:format?', ->
      it "should return argument propositions as json", (done) ->
        sessionWithArgument (user, argument, get, post) ->
          get '/arguments/' + argument.sha1 + '/propositions.json', (res) ->
            res.status.should.equal 200
            res.redirects.should.eql []
            json = res.body
            arg = new Argument(argument)
            expectedData = arg.propositions.map (p) -> p.data()
            matchesPropositionsData json.propositions, expectedData
            done()

      it "should return argument propositions as jsonp", (done) ->
        sessionWithArgument (user, argument, get, post) ->
          get '/arguments/' + argument.sha1 + '/propositions.jsonp', (res) ->
            res.status.should.equal 200
            res.redirects.should.eql []
            verifyJSONP res, (json) ->
              should.not.exist json.error
              arg = new Argument argument
              expectedData = arg.propositions.map (p) -> p.data()
              matchesPropositionsData json.propositions, expectedData
              done()

  describe '/logout', ->
    describe 'GET logout', ->
      it 'should clear session cookie and redirect to index', (done) ->
        get '/logout', (err, res) ->
          res.status.should.equal 200
          res.redirects.should.eql(['http://localhost:3000/'])
          res.text.should.match /Sign in.*or.*Join now!/
          done()

  describe '/:name.:format?', ->

    describe 'GET /:name', ->
      it "should show the user's public page", (done) ->
        sessionWithArgument (user, argument, get, post) ->
          get '/' + user.username, (err, res) ->
            should.not.exist err
            res.status.should.equal 200
            res.redirects.should.eql []
            res.text.should.not.match /error/i
            res.text.should.match new RegExp user.username
            res.text.should.match new RegExp argument.title
            done()

    describe 'GET /:name.json', ->
      it 'should be an alias for /users/:name.json', (done) ->
        get '/tester.json', (err, res) ->
          res.status.should.equal 200
          res.type.should.equal 'application/json'
          res.body.should.be.an.instanceof Object
          res.body.user.should.eql { username: 'tester', repos: [] }
          should.not.exist res.body.error
          done()

  describe '/:name/:repo.:format?', ->
    describe 'GET /:name/:repo.:format?', ->
      it 'should show a repo page', (done) ->
        sessionWithArgument (user, argument, get, post) ->
          get "/#{user.username}/#{argument.repo}", (err, res) ->
            res.status.should.equal 200
            res.redirects.should.eql []
            matchesArgument res.text, argument
            done()

      it 'should show a repo as json', (done) ->
        sessionWithArgument (user, argument, get, post) ->
          get "/#{user.username}/#{argument.repo}.json", (err, res) ->
            res.status.should.equal 200
            res.redirects.should.eql []
            res.type.should.equal 'application/json'
            res.body.should.be.an.instanceof Object
            res.body.argument.should.eql argument
            done()

      it 'should show a repo as jsonp', (done) ->
        sessionWithArgument (user, argument, get, post) ->
          get "/#{user.username}/#{argument.repo}.jsonp", (err, res) ->
            res.status.should.equal 200
            res.redirects.should.eql []
            res.type.should.equal 'text/javascript'
            jsonp = res.text
            jsonpCallback = (json) ->
              should.not.exist json.error
              json.user.should.include {username: user.username}
              json.repo.should.eql argument.repo
              json.commit.should.include
                targetType: 'argument'
                targetSha1: argument.sha1
              json.argument.should.eql argument
              done()
            eval jsonp
