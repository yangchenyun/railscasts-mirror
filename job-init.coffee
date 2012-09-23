redis = require('redis')
kue = require('kue')

# initialize kue redis connection
if process.env.REDISTOGO_URL
  rtg   = require('url').parse process.env.REDISTOGO_URL
  kue.redis.createClient = ->
    redis.createClient rtg.port, rtg.hostname
    client.auth rtg.auth.split(':')[1]
    client.select(process.env.REDIS_DB || '2')
    client
# Localhost
else
  kue.redis.createClient = ->
    client = redis.createClient()
    client.select(process.env.REDIS_DB || '2')
    client

module.exports =
  jobs: kue.createQueue()
  kue: kue
