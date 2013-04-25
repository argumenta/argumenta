module.exports = Staging =

  # Mode
  appMode:      'staging'

  # Port
  port:         8080

  # Security
  appSecret:    'SECRET'

  # Logging (levels: debug, info, warn, error, fatal)
  logLevel:     'info'

  # Site
  siteName:     'Argumenta'

  # Storage
  storageType:  'postgres'

  # Postgres
  postgresUrl: 'postgres://argumenta_staging:PASSWORD@localhost:5432/argumenta_staging'

  # Gzip
  gzip:         true
