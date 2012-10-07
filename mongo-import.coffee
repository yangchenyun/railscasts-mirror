fs = require('fs')
mongo = require('mongoskin')
db = mongo.db('localhost:27017/rails_casts')

data = fs.readFileSync 'data.json'
episodes = JSON.parse(data)

db.ensureIndex 'episodes', { slug: 1 }, (err, replies) ->
  throw err if err

  db.createCollection 'episodes', (err, collection) ->
    collection.insert episodes, {safe: true}, (err, result) ->
      throw err if err
      process.exit()
