process.env.MONGOSKIN_URL ||= 'mongodb://localhost/rails_casts'
db = require('mongoskin').db(process.env.MONGOSKIN_URL)
express = require('express')
fs = require('fs')

app = express()
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.set 'view engine', 'jade'
app.enable 'view cache'
app.set 'views', "#{__dirname}/views"

# serve static files
# FIXME need to write streaming server for video now
app.use '/video', express.static "#{__dirname}/video"
app.use '/source-code', express.static "#{__dirname}/source-code"
app.use '/screenshot', express.static "#{__dirname}/screenshot"
app.use '/public', express.static "#{__dirname}/public"

# prepare the data
data = fs.readFileSync 'data.json'
episodes = JSON.parse(data)

mongo = require('mongoskin')
db = mongo.db('localhost:27017/rails_casts')

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
  db.collection('episodes').distinct 'tags', (err, tags) ->
    tags = tags.filter (item)-> return true if item
    db.collection('episodes').find().toArray (err, items) ->
      res.render 'index', { episodes: items, tags: tags }

app.get '/episodes', auth, (req, res) ->
  words = req.query['search'].split(' ').join('|')

  # match each word against title and description
  matchTitle = { title : { $regex : words, $options: 'i' } }
  matchDesc = { description : { $regex : words, $options: 'i' } }

  query = { $or: [ matchTitle, matchDesc ] }

  db.collection('episodes').distinct 'tags', (err, tags) ->
    tags = tags.filter (item)-> return true if item
    db.collection('episodes').find(query)
      .toArray (err, items) ->
        res.render 'index', { episodes: items }

app.get '/episodes/:slug', auth, (req, res) ->

  db.collection('episodes').findOne { slug: req.params['slug'] }, (err, episode) ->
    if episode
      res.render 'episode', { episode: episode }
    else
      res.render '404'

app.get '/tag/:tag', (req, res) ->

  db.collection('episodes').distinct 'tags', (err, tags) ->
    tags = tags.filter (item)-> return true if item
    db.collection('episodes').find( { tags: req.params['tag'] } )
      .toArray (err, episodes) ->
        if episodes
          res.render 'index', { episodes: episodes, tags: tags }
        else
          res.render '404'

app.listen 2734, ->
  console.log "mirror server listening at 2734"
