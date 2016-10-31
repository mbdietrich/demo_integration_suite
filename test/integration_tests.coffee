bb = require 'bluebird'

describe 'Player Score Calculation', ->

  before ->
    post_player( {name: 'Bob'} )
    post_player( {name: 'Steve'} )
    post_player( {name: 'Jane'} )


  context 'simple integration testing', ->
    it 'should return all scores correctly', ->
      post_score( {name: 'Bob', score: 2} )
      .then( ->
        post_score( {name: 'Bob', score: 3} )
      )
      .then( ->
        get_player( 'Bob' )
      )
      .spread( (status, body) ->
        player = JSON.parse(body)
        expect(status).to.eq 200
        expect(player.name).to.eq 'Bob'
        expect(player.scores).to.deep.equal [2,3]
      )

  context 'concurrency testing', ->
    it 'should return all scores correctly', ->
      bb.all([
        post_score( {name: 'Jane', score: 2} ),
        post_score( {name: 'Jane', score: 3} ),
        post_score( {name: 'Jane', score: 4} ),
        post_score( {name: 'Jane', score: 5} )
      ])
      .then( ->
        get_player( 'Jane' )
      )
      .spread( (status, body) ->
        player = JSON.parse(body)
        expect(status).to.eq 200
        expect(player.name).to.eq 'Jane'
        expect(player.scores).to.deep.equal [2,3,4,5]
      )

  context 'error case testing', ->
    it 'returns the correct error when the player does not exist', ->
      post_score( {name: 'Alice', score: 2} )
      .spread( (status, body) ->
        message = JSON.parse(body)
        expect(status).to.eq 400
        expect(message.error).to.eq "Bad Request"
      )

  context 'performance testing', ->
    it 'should post 100 scores in under 5000ms', ->
      @timeout(5000)
      requests = []
      for i in [1..100]
        requests.push post_score( {name: 'Steve', score: 1} )
      bb.all( requests )
      .then( ->
        assert.ok(true)
      )