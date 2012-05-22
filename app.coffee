express = require 'express'
routes  = require './routes'
http    = require 'http'

# App Instance
app = module.exports = express()

# Config
app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use require('stylus').middleware({ src: __dirname + '/public' })
  app.use express.static(__dirname + '/public')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router

app.configure 'development', ->
  app.use express.errorHandler()

# Routes
app.get '/', routes.main.index
app.get '/users', routes.users.index
app.get '/users/:name', routes.users.show

# Http
http.createServer(app).listen(3000)

console.log "Express server listening on port 3000"
