envVars = require './vars'

Env = {}

# Parses value of an environment variable.
parseValue = (value) ->
  if value is 'true'
    return true

  else if value is 'false'
    return false

  else if /^\d+$/.test value
    return parseInt(value, 10)

  else if /^\d+\.\d+$/.test value
    return parseFloat(value)

  else
    return value

for envKey, confKey of envVars
  value = process.env[envKey]
  if value?
    Env[confKey] = parseValue(value)

module.exports = Env
