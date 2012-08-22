express = require 'express'
flash   = require 'connect-flash'
http    = require 'http'
routes  = require '../routes'
config  = require '../config'

# Express Instance
app = module.exports = express()

# Globals middleware: Extends locals with given properties
globals = ( extensions, processor ) ->
  globalsFunc = (req, res, next) ->
    res.locals( extensions )
    processor( extensions, req, res ) if processor
    next()

# Reply middleware: Adds a res.reply helper
respond = require '../routes/helpers/respond'
reply = ( processor ) ->
  replyFunc = (req, res, next) ->
    res.reply = ( view, opts ) ->
      opts = processor( opts ) if processor
      respond( view, opts, req, res )
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
    app.use reply()
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
app.get  '/',                     routes.main.index
app.get  '/users',                routes.users.index
app.post '/users',                routes.users.create
app.get  '/users/:name.:format?', routes.users.show

app.get  '/join',                 routes.join.index

app.get  '/login',                routes.login.index
app.post '/login',                routes.login.verify

app.get  '/logout',               routes.logout.index

# Http
http.createServer(app).listen(3000)

console.log "Express server listening on port 3000"
