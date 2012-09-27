express = require('express')
fs = require('fs')
app = express()
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.set 'view engine', 'jade'
app.set 'views', "#{__dirname}/views"

# serve static files
app.use '/video', express.static "#{__dirname}/video"
app.use '/source-code', express.static "#{__dirname}/source-code"
app.use '/screenshot', express.static "#{__dirname}/screenshot"
app.use '/public', express.static "#{__dirname}/public"

# prepare the data
data = fs.readFileSync 'data.json'
episodes = JSON.parse(data)

accounts = process.env.RC_ACCOUNT

auth = (req, res, next) ->
  if req.headers.authorization && req.headers.authorization.search('Basic ') is 0
    authString = new Buffer(req.headers.authorization.split(' ')[1], 'base64').toString()
    # account:passwd exists in the auth header
    # allow access to resources
    if accounts.indexOf(authString) isnt -1
      next()
      return

  res.header 'WWW-Authenticate', 'Basic realm=Auth'

  timeout = 0
  if req.headers.authorization
    # cache for  60 mins
    timeout = 60 * 60 * 1000

  setTimeout ->
    res.send 'Authentication required', 401
  , timeout

app.get '/', auth, (req, res) ->
  res.render 'index', { episodes: episodes }

app.get '/episodes/:seq', auth, (req, res) ->

  episode = null
  for this_epi in episodes
    if this_epi.sequence is parseInt(req.params['seq'], 10)
      episode = this_epi

  if episode
    res.render 'episode', { episode: episode }
  else
    res.render '404'

app.get '/tag/:tag', (req, res) ->

app.listen 2734, ->
  console.log "mirror server listening at 2734"
