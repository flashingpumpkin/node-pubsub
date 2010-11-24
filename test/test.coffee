pubsub = require '../lib/pubsub'
assert = require 'assert'

conn = pubsub.createConnection host: 'localhost'
conn.on 'ready', ->
    
    publisher = conn.createPublisher('test-publisher')

    subscriber1 = conn.createSubscriber('test-publisher')
    subscriber2 = conn.createSubscriber('test-publisher')

    subscriberMessageCount = 0

    subscriber1.on 'message', ->
        subscriberMessageCount++

    subscriber2.on 'message', ->
        subscriberMessageCount++

    setTimeout (->
        publisher.publish('test')
        publisher.publish('test')
        publisher.publish('test')
    ),200

    setTimeout (->
        assert.equal subscriberMessageCount, 6
        console.log 'Test passed'
        process.exit 0
    ),1000
