fs = require('fs')
process.env.MONGOSKIN_URL ||= 'mongodb://localhost/rails_casts'
db = require('mongoskin').db(process.env.MONGOSKIN_URL)

data = fs.readFileSync 'data.json'
episodes = JSON.parse(data)

db.ensureIndex 'episodes', { slug: 1 }, (err, replies) ->
  throw err if err

  db.createCollection 'episodes', (err, collection) ->
    collection.insert episodes, {safe: true}, (err, result) ->
      throw err if err
      process.exit()
