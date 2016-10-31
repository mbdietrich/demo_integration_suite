chai = require 'chai'
should = chai.should()
bb = require 'bluebird'

http = require 'q-io/http'

global.expect = chai.expect;
global.assert = chai.assert;

#call these methods as post_player(foo).spread( (status, body) -> ... )

global.post_player = (player) ->
  http.request({
    url: "http://localhost:8042/player",
    body: [JSON.stringify(player)],
    method: 'POST'
  })
  .then( (resp) ->
    bb.all( [
      bb.try( -> resp.status),
      resp.body.read()
    ] )
  )

global.post_score = (score) ->
  http.request({
    url: "http://localhost:8043/score",
    body: [JSON.stringify(score)],
    method: 'POST'
  })
  .then( (resp) ->
    bb.all( [
      bb.try( -> resp.status),
      resp.body.read()
    ] )
  )

global.get_player = (playername) ->
  http.request("http://localhost:8042/player/#{playername}")
  .then( (resp) ->
    bb.all( [
      bb.try( -> resp.status),
      resp.body.read()
    ] )
  )