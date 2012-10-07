fs = require('fs')
mongo = require('mongoskin')
db = mongo.db('localhost:27017/rails_casts')

data = fs.readFileSync 'data.json'
episodes = JSON.parse(data)

db.createCollection "episodes", (err, collection) ->
  for episode in episodes
    collection.insert episode
