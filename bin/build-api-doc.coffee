#! /usr/bin/env coffee

async         = require 'async'
child_process = require 'child_process'
fs            = require 'fs'
path          = require 'path'
{exec}        = child_process

# The pattern of commands to match in our API template.
CMD_PATTERN = /(curl (?:.+[\s\S])+[\s\S])/g

# The main script.
main = ->
  templateFile = path.join __dirname, '../doc/templates/api.template.md'
  outFile      = path.join __dirname, '../doc/README.API.markdown'

  console.log "Creating API doc: '#{outFile}'."

  createDoc templateFile, outFile, (err) ->
    if err
      console.log "Error creating API docs: ", err
      process.exit 1
    else
      console.log "Done!"
      process.exit 0

# Creates the API document, given template and output filenames.
createDoc = (templateFile, outFile, callback) ->
  template = readTemplate templateFile
  commands = loadCommands template

  startApp (err, app) ->
    return callback err if err

    runCommands commands, (err, results) ->
      return callback err if err

      resultsByCmd = {}
      for i, c of commands
        unless resultsByCmd[c]?
          resultsByCmd[c] = results[i]

      doc = template.replace CMD_PATTERN, (match, p1, offset, string) ->
        command = match
        result = resultsByCmd[command]
          .replace(/\r\n/g        , '\n')
          .replace(/^(HTTP.*)$/m  , '$1\n')
          .replace(/^/gm          , '    ')
          .replace(/$/            , '\n\n')
          .replace(/^ +$/gm       , '')
        example = command + result
        return example

      outputDoc outFile, doc
      return callback null

# Reads the API template.
readTemplate = (filename) ->
  template = fs.readFileSync(filename, 'utf8').toString('utf8')
  return template

# Loads commands from template text.
loadCommands = (template) ->
  commands = template.match CMD_PATTERN
  return commands

# Starts the Argumenta app asynchronously.
startApp = (callback) ->
  process.env.NODE_ENV = 'testing'
  module = path.join __dirname, '../app'
  app = require module
  app.argumenta.storage.clearAll null, (err) ->
    return callback err, app

# Runs commands in series, and returns results by callback.
runCommands = (commands, callback) ->
  runCmd = (c, cb) ->
    exec c, (err, stdout, stderr) ->
      cb err, stdout

  async.mapSeries commands, runCmd, (err, results) ->
    return callback err, results

# Writes the document text to the named file.
outputDoc = (filename, text) ->
  fs.writeFileSync filename, text, 'utf8'

# Let's do this!
main()
