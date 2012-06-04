envVars = require './vars'

Env = {}

for envKey, confKey of envVars
  value = process.env[envKey]
  Env[confKey] = value if value?

module.exports = Env
