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

app.get '/', (req, res) ->
  res.render 'index', { episodes: episodes }

app.get '/:seq', (req, res) ->

app.get '/tag/:tag', (req, res) ->

app.listen 2734, ->
  console.log "mirror server listening at 2734"
