config     = require '../config'
fixtures   = require '../test/fixtures'
superagent = require 'superagent'
request    = require 'request'
should     = require 'should'
Objects    = require '../lib/argumenta/objects'
{Argument} = Objects

base = 'http://localhost:3000'

class HttpHelper

  constructor: (@agent, @basepath) ->

  absUrl: (path) ->
    if ~path.search /https?:\/\// then path else @basepath + path

  get: (path, cb) ->
    @agent.get( @absUrl path ).end( cb )

  post: (path, data, cb) ->
    @agent.post( @absUrl path ).send( data ).end( cb )

  put: (path, data, cb) ->
    @agent.put( @absUrl path ).send( data ).end( cb )

  del: (path, cb) ->
    @agent.del( @absUrl path ).end( cb )

# Http helper - provides http methods with agent & base url.
httpHelper = (callback) ->
  agent = superagent.agent()
  callback new HttpHelper( agent, base )

# Temp agent helper - provides callback with get, post, put, delete.
tempAgent = (callback) ->
  httpHelper (http) ->
    post = http.post.bind http
    get  = http.get.bind http
    put  = http.put.bind http
    del  = http.del.bind http
    callback get, post, put, del

# Session helper - provides logged in user with new account, get, post.
session = (callback) ->
  tempAgent (get, post, put, del) ->
    user = fixtures.uniqueUserData()
    post '/users', user, (err, res) ->
      should.not.exist err
      res.status.should.equal 200
      res.text.should.match new RegExp 'Logged in as <a href="/'+user.username+'">'+user.username+'</a>'
      callback user, get, post, put, del

# Logged out session helper - provides a user session just after logout, get, post.
loggedOutSession = (callback) ->
  session (user, get, post, put, del) ->
    get '/logout', (err, res) ->
      should.not.exist err
      res.status.should.equal 200
      callback user, get, post, put, del

# No session helper - provides user without account, get, post.
noSession = (callback) ->
  user = fixtures.uniqueUser()
  tempAgent (get, post, put, del) ->
    callback user, get, post, put, del

# Assertion helper - checks if text matches argument
matchesArgument = (text, arg) ->
  for s in arg.premises.concat [arg.title, arg.conclusion]
    text.should.match new RegExp s

# Session with argument helper - provides user, argument data, get, post
sessionWithArgument = (callback) ->
  session (user, get, post, put, del) ->
    data = fixtures.uniqueArgumentData()
    post '/arguments', data, (err, res) ->
      should.not.exist err
      res.status.should.equal 200
      callback user, data, get, post, put, del

# Session with tag helper - provides user, argument, tag, get, post
sessionWithTag = (callback) ->
  sessionWithArgument (user, argumentData, get, post, put, del) ->
    argument = new Argument argumentData
    tag = fixtures.validSupportTag()
    tag.targetType = 'proposition'
    tag.targetSha1 = argument.propositions[0].sha1()
    tag.sourceType = 'proposition'
    tag.sourceSha1 = argument.propositions[1].sha1()
    tagData = tag.data()
    post '/tags.json', tagData, (res) ->
      res.status.should.equal 201
      callback user, argumentData, tagData, get, post, put, del

# Verify JSONP Helper - Given a JSONP response, invokes callback with json.
verifyJSONP = (res, callback) ->
  res.type.should.equal 'text/javascript'
  res.text.should.exist
  jsonp = res.text
  jsonpCallback = (json) ->
    callback(json)
  eval jsonp

# Http helpers.
http = new HttpHelper( superagent.agent(), base )
get = http.get.bind http
post = http.post.bind http

# Request helpers.
req_get = (path, cb) ->
  request abs_url(path), cb

req_post = (path, data, cb) ->
  options =
    uri: abs_url(path)
    form: data
  request.post options, cb

describeTests = () ->
  app = require '../app'
  describeAppTests config.storageType, app

# Describes app tests for the given storage type and app.
describeAppTests = (type, app) ->

  describe "App with #{type} store", ->

    before (done) ->
      app.argumenta.storage.clearAll null, (err) ->
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

    describe '/stylesheets', ->
      describe 'GET /stylesheets/style.css', ->
        it 'should serve gzipped css', (done) ->
          get '/stylesheets/style.css', (res) ->
            res.status.should.equal 200
            res.header['content-encoding'].should.equal('gzip')
            res.header['content-type'].should.equal('text/css')
            done()

    describe '/users', () ->

      describe 'POST /users', () ->
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
            res.redirects.should.eql [ base + '/join' ]
            res.status.should.equal 200
            res.text.should.match /error.*password.*blank/i
            done()

        it 'should refuse to overwrite an already existing user', (done) ->
          existingUser =
            username: 'tester'
            password: 'tester12'
            email:    'tester@xyz.com'
          post '/users', existingUser, (res) ->
            res.redirects.should.eql [ base + '/join' ]
            res.status.should.equal 200
            res.text.should.match /User already exists./
            done()

      describe 'POST /users.json', ->
        it 'should create a user and return json confirmation', (done) ->
          data = fixtures.uniqueUserData()
          post '/users.json', data, (res) ->
            res.status.should.equal 201
            res.body.message.should.match new RegExp "Welcome.*#{data.username}"
            done()

        it 'should fail with 400 status if user is invalid', (done) ->
          data = fixtures.invalidUserData()
          post '/users.json', data, (res) ->
            res.status.should.equal 400
            should.exist res.body.error
            done()

        it 'should fail with 409 status if user exists', (done) ->
          session (user, get, post) ->
            data = user
            post '/users.json', data, (res) ->
              res.status.should.equal 409
              should.exist res.body.error
              done()

      describe 'GET /users', ->
        it 'should show a list of users', (done) ->
          get '/users', (res) ->
            res.status.should.equal 200
            res.text.should.match /Users/
            res.text.should.match /tester/
            done()

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
            json = res.body
            json.user.username.should.equal 'tester'
            json.user.join_date.should.match /^\d{4}-\d{2}-\d{2}.\d{2}:\d{2}:\d{2}.\d{3}Z$/
            json.user.gravatar_id.should.match /^[0-9,a-f]{32}$/
            should.not.exist json.error
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
          loggedOutSession (user, get, post) ->
            post '/login', user, (res) ->
              res.status.should.equal 200
              res.redirects.should.eql [ "#{base}/#{user.username}" ]
              res.text.should.match /Welcome back/
              res.text.should.match new RegExp "Logged in as .*#{user.username}"
              done()

        it 'should deny an incorrect login', (done) ->
          loggedOutSession (user, get, post) ->
            data = user
            data.password = 'wrong'
            post '/login', data, (res) ->
              res.status.should.equal 200
              res.redirects.should.eql [ base + '/login' ]
              res.text.should.match /Invalid username and password combination./
              done()

      describe 'POST /login.json', ->
        it 'should accept a correct login and return json confirmation', (done) ->
          loggedOutSession (user, get, post) ->
            post '/login.json', user, (res) ->
              res.status.should.equal 200
              res.redirects.should.eql []
              json = res.body
              should.not.exist json.error
              json.message.should.match /Welcome back/
              done()

        it 'should deny an incorrect login and return json error', (done) ->
          loggedOutSession (user, get, post) ->
            data = username: user.username, password: 'wrong!'
            post '/login.json', data, (res) ->
              res.status.should.equal 401
              res.body.error.should.match /Invalid username and password combination./
              done()

    describe '/arguments', ->

      describe 'GET /arguments/new', ->
        it 'should show a form to create a new argument', (done) ->
          session (user, get, post) ->
            get '/arguments/new', (err, res) ->
              should.not.exist err
              res.status.should.equal 200
              res.text.should.match /Create a new argument!/
              done()

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

      describe 'POST /arguments.json', ->
        it 'should create an argument and return json confirmation', (done) ->
          session (user, get, post) ->
            data = fixtures.uniqueArgumentData()
            post '/arguments.json', data, (res) ->
              res.status.should.equal 201
              json = res.body
              json.message.should.match new RegExp "Created a new argument!"
              done()

        it 'should fail with 400 status if argument is invalid', (done) ->
          session (user, get, post) ->
            data = fixtures.invalidArgumentData()
            post '/arguments.json', data, (res) ->
              res.status.should.equal 400
              json = res.body
              json.error.should.exist
              done()

        it 'should fail with 401 status if not logged in', (done) ->
          noSession (user, get, post) ->
            data = fixtures.invalidArgumentData()
            post '/arguments.json', data, (res) ->
              res.status.should.equal 401
              json = res.body
              json.error.should.exist
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
              json.commit.committer.should.equal user.username
              json.commit.target_sha1.should.equal argument.sha1
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
              metadata = json.propositions[0].metadata
              should.exist metadata
              should.exist metadata.tag_sha1s
              should.exist metadata.tag_counts
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

    describe '/propositions', ->

      describe 'GET /propositions/:hash.:format?', ->
        it 'should return a proposition as json', (done) ->
          sessionWithArgument (user, argumentData, get, post) ->
            argument = new Argument argumentData
            prop = argument.propositions[0]
            hash = prop.sha1()
            get '/propositions/' + hash + '.json', (res) ->
              res.status.should.equal 200
              res.redirects.should.eql []
              json = res.body
              json.proposition.should.include prop.data()
              metadata = json.proposition.metadata
              should.exist metadata
              should.exist metadata.tag_sha1s
              should.exist metadata.tag_counts
              done()

        it "should fail with 404 status if the proposition doesn't exist", (done) ->
          session (user, get, post) ->
            prop = fixtures.uniqueProposition()
            hash = prop.sha1()
            get '/propositions/' + hash + '.json', (res) ->
              res.status.should.equal 404
              res.redirects.should.eql []
              json = res.body
              json.error.should.exist
              done()

      describe 'GET /propositions/:hash/tags.:format?', ->
        it 'should return proposition tags as json', (done) ->
          sessionWithTag (user, argumentData, tag, get, post) ->
            argument = new Argument argumentData
            prop = argument.propositions[0]
            hash = prop.sha1()
            get '/propositions/' + hash + '/tags.json', (res) ->
              res.status.should.equal 200
              res.redirects.should.eql []
              json = res.body
              json.tags[0].should.eql tag
              done()

        it "should return empty array if proposition has no tags", (done) ->
          noSession (user, get, post) ->
            argument = fixtures.uniqueArgument()
            prop = argument.propositions[0]
            hash = prop.sha1()
            get '/propositions/' + hash + '/tags.json', (res) ->
              res.status.should.equal 200
              res.redirects.should.eql []
              json = res.body
              json.tags.length.should.equal 0
              should.not.exist json.error
              done()

      describe 'GET /propositions/:hash/tags-plus-sources.:format?', ->
        it 'should return proposition tags plus sources as json', (done) ->
          sessionWithTag (user, argumentData, tag, get, post) ->
            argument = new Argument argumentData
            prop = argument.propositions[0]
            hash = prop.sha1()
            get '/propositions/' + hash + '/tags-plus-sources.json', (res) ->
              res.status.should.equal 200
              res.redirects.should.eql []
              json = res.body
              json.tags.length.should.equal 1
              json.sources.length.should.equal 1
              json.commits.length.should.equal 1
              json.tags[0].should.eql tag
              done()

        it "should return empty array if proposition has no tags", (done) ->
          noSession (user, get, post) ->
            argument = fixtures.uniqueArgument()
            prop = argument.propositions[0]
            hash = prop.sha1()
            get '/propositions/' + hash + '/tags-plus-sources.json', (res) ->
              res.status.should.equal 200
              res.redirects.should.eql []
              json = res.body
              json.tags.length.should.equal 0
              json.sources.length.should.equal 0
              json.commits.length.should.equal 0
              should.not.exist json.error
              done()

    describe '/tags', ->
      describe 'GET /tags/:hash.:format?', ->
        it 'should return a tag as json', (done) ->
          sessionWithTag (user, argument, tag, get, post) ->
            get '/tags/' + tag.sha1 + '.json', (res) ->
              res.status.should.equal 200
              res.redirects.should.eql []
              json = res.body
              should.not.exist json.error
              json.tag.should.eql tag
              done()

      describe 'POST /tags.json', ->
        it 'should create a tag and return json confirmation', (done) ->
          sessionWithArgument (user, argumentData, get, post) ->
            argument = new Argument argumentData
            tag = fixtures.validSupportTag()
            tag.targetType = 'proposition'
            tag.targetSha1 = argument.propositions[0].sha1()
            tag.sourceType = 'proposition'
            tag.sourceSha1 = argument.propositions[1].sha1()
            data = tag.data()
            post '/tags.json', data, (res) ->
              res.status.should.equal 201
              json = res.body
              json.message.should.match new RegExp "Created a new tag!"
              json.tag.should.eql data
              done()

        it 'should fail with 400 status if tag is invalid', (done) ->
          sessionWithArgument (user, argumentData, get, post) ->
            tag = fixtures.validSupportTag()
            tag.targetType = ''
            data = tag.data()
            post '/tags.json', data, (res) ->
              res.status.should.equal 400
              json = res.body
              json.error.should.exist
              done()

        it 'should fail with 401 status if not logged in', (done) ->
          noSession (user, get, post) ->
            data = fixtures.validSupportTag().data()
            post '/tags.json', data, (res) ->
              res.status.should.equal 401
              json = res.body
              json.error.should.exist
              done()

    describe '/search', ->

      describe 'GET /search/:query.json', ->
        it 'should find an argument by title', (done) ->
          sessionWithArgument (user, argData, get, post) ->
            query = encodeURIComponent(argData.title)
            get '/search/' + query + '.json', (err, res) ->
              should.not.exist err
              res.status.should.equal 200
              json = res.body
              json.arguments.should.be.an.instanceOf Array
              json.arguments.length.should.equal 1
              json.arguments[0].should.eql argData
              done()

        it 'should find a user by username', (done) ->
          session (user, get, post) ->
            query = encodeURIComponent(user.username)
            get '/search/' + query + '.json', (err, res) ->
              should.not.exist err
              res.status.should.equal 200
              json = res.body
              json.users.should.be.an.instanceOf Array
              json.users.length.should.equal 1
              json.users[0].username.should.equal user.username
              done()

    describe '/logout', ->
      describe 'GET /logout', ->
        it 'should clear session cookie and redirect to index', (done) ->
          get '/logout', (err, res) ->
            res.status.should.equal 200
            res.redirects.should.eql(['http://localhost:3000/'])
            res.text.should.match /Sign in.*or.*Join now!/
            done()

      describe 'GET /logout.json', ->
        it 'should clear session cookie', (done) ->
          session (user, get, post) ->
            get '/logout.json', (res) ->
              get '/logout.json', (res) ->
                res.status.should.equal 200
                res.redirects.should.eql []
                should.not.exist res.body.error
                post '/arguments.json', {}, (res) ->
                  res.status.should.equal 401
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
        it "should show the user's public info as json", (done) ->
          sessionWithArgument (user, argument, get, post) ->
            get "/#{user.username}.json", (err, res) ->
              should.not.exist err
              res.type.should.equal 'application/json'
              json = res.body
              json.user.username.should.equal user.username
              json.user.join_date.should.match /^\d{4}-\d{2}-\d{2}.\d{2}:\d{2}:\d{2}.\d{3}Z$/
              json.user.gravatar_id.should.match /^[0-9,a-f]{32}$/
              json.repos[0].username.should.equal user.username
              json.repos[0].target.should.eql argument
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
              res.body.repo.target.should.eql argument
              done()

        it 'should show a repo as jsonp', (done) ->
          sessionWithArgument (user, argument, get, post) ->
            get "/#{user.username}/#{argument.repo}.jsonp", (err, res) ->
              res.status.should.equal 200
              res.redirects.should.eql []
              verifyJSONP res, (json) ->
                should.not.exist json.error
                json.repo.user.should.include {username: user.username}
                json.repo.reponame.should.eql argument.repo
                json.repo.commit.should.include
                  target_type: 'argument'
                  target_sha1: argument.sha1
                json.repo.target.should.eql argument
                done()

      describe 'GET /:name/:repo.:format?callback=:cbName', ->
        it 'should show a repo as jsonp with custom callback', (done) ->
          sessionWithArgument (user, argument, get, post) ->
            get "/#{user.username}/#{argument.repo}.jsonp?callback=myCb", (err, res) ->
              res.status.should.equal 200
              res.redirects.should.eql []
              res.type.should.equal 'text/javascript'
              jsonp = res.text
              myCb = (json) ->
                should.not.exist json.error
                json.repo.user.should.include {username: user.username}
                json.repo.reponame.should.eql argument.repo
                json.repo.commit.should.include
                  target_type: 'argument'
                  target_sha1: argument.sha1
                json.repo.target.should.eql argument
                done()
              eval jsonp

      describe 'DELETE /:name/:repo.:format', ->
        it 'should delete a given repo', (done) ->
          sessionWithArgument (user, argument, get, post, put, del) ->
            del "/#{user.username}/#{argument.repo}.json", (err, res) ->
              res.status.should.equal 200
              res.redirects.should.eql []
              res.body.message.should.match /Deleted repo '.*'./
              done()

        it 'should not exist after deletion', (done) ->
          sessionWithArgument (user, argument, get, post, put, del) ->
            username = user.username
            reponame = argument.repo
            path = "/#{username}/#{reponame}.json"
            del path, (err, res) ->
              get path, (err, res) ->
                res.status.should.equal 404
                res.redirects.should.eql []
                res.body.error.should.match /Repo '.*' not found./
                done()

        it 'should fail with 401 status if not logged in', (done) ->
          sessionWithArgument (user, argument, get, post, put, del) ->
            get '/logout', (err, res) ->
              del "/#{user.username}/#{argument.repo}.json", (err, res) ->
                res.status.should.equal 401
                res.redirects.should.eql []
                res.body.error.should.match /Login to delete repos./
                done()

        it 'should fail with 403 status if not repo owner', (done) ->
          sessionWithArgument (user1, argument) ->
            session (user2, get, post, put, del) ->
              del "/#{user1.username}/#{argument.repo}.json", (err, res) ->
                res.status.should.equal 403
                res.redirects.should.eql []
                res.body.error.should.match /Only the repo owner may delete a repo./
                done()

describeTests()
