express  = require 'express'
flash    = require 'connect-flash'
http     = require 'http'
_        = require 'underscore'
reply    = require '../app/middleware/reply'
success  = require '../app/middleware/success'
created  = require '../app/middleware/created'
failed   = require '../app/middleware/failed'
notFound = require '../app/middleware/not_found'
routes   = require '../routes'
config   = require '../config'
Objects  = require '../lib/argumenta/objects'

# Express Instance
app = module.exports = express()

# Globals middleware: Extends locals with given properties
globals = ( extensions, processor ) ->
  globalsFunc = (req, res, next) ->
    res.locals( extensions )
    processor( extensions, req, res ) if processor
    next()

# Config
configure = () ->
  app.configure ->
    app.set 'views', __dirname + '/../views'
    app.set 'view engine', 'jade'
    app.set 'view options', {layout: false}
    app.use express.favicon()
    app.use require('stylus').middleware({ src: __dirname + '/../public' })
    app.use express.static(__dirname + '/../public')
    app.use express.bodyParser()
    app.use express.cookieParser( config.appSecret )
    app.use express.methodOverride()
    app.use express.cookieSession()
    app.use flash()
    app.use globals {siteName: config.siteName, title: ''}, (ext, req, res) ->
      errors = req.flash 'errors'
      messages = req.flash 'messages'
      res.locals
        errors: errors
        messages: messages
        username: req.session.username or ''
    app.locals.pretty = true
    app.use reply
      processor: (opts, req) ->
        format = req.param 'format'
        # Send argumenta objects with data() methods as plain object data
        if format is 'json' or format is 'jsonp'
          for key, val of opts
            if _.isObject(val) and typeof val.data is 'function'
              opts[key] = val.data()
            else if _.isArray(val) and typeof val[0]?.data is 'function'
              opts[key] = val.map (obj) -> obj.data()
        return opts
    app.use success()
    app.use failed()
    app.use created()
    app.use notFound view: 'index'
    app.use app.router

app.configure 'production', ->
  app.use express.logger()
  configure()

app.configure 'testing', ->
  configure()

app.configure 'development', ->
  app.use express.logger('dev')
  configure()
  app.use express.errorHandler()

# Fallback config
unless config.appMode.match /production|testing|development/
  console.log "Using generic configure for app mode: '#{config.appMode}'"
  configure()

# Routes
app.get  '/',                         routes.main.index

app.get  '/users',                    routes.users.index
app.post '/users.:format?',           routes.users.create
app.get  '/users/:name.:format?',     routes.users.show

app.get  '/join',                     routes.join.index

app.get  '/login',                    routes.login.index
app.post '/login',                    routes.login.verify
app.get  '/logout',                   routes.logout.index

app.get  '/arguments/new',            routes.arguments.new
app.post '/arguments',                routes.arguments.create
app.get  '/arguments/:hash.:format?', routes.arguments.show
app.get  '/arguments/:hash/propositions.:format?', routes.arguments.propositions

app.get  '/:name.:format?',           routes.users.public
app.get  '/:name/:repo.:format?',     routes.repos.show

# Http
http.createServer(app).listen(3000)

console.log "Express server listening on port 3000"
