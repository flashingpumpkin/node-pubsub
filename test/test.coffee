pubsub = require '../lib/pubsub'
assert = require 'assert'

conn = pubsub.createConnection host: 'localhost'
conn.on 'ready', ->
    
    publisher1 = conn.createPublisher('test-publisher')
    publisher2 = conn.createPublisher('test-publisher-2')

    subscriber1 = conn.createSubscriber('test-publisher')
    subscriber2 = conn.createSubscriber('test-publisher')

    subscriber3 = conn.createSubscriber('test-publisher-2')
    subscriber4 = conn.createSubscriber('test-publisher-2')

    subscriberMessageCount1 = 0
    subscriberMessageCount2 = 0

    subscriber1.on 'message', ->
        subscriberMessageCount1++

    subscriber2.on 'message', ->
        subscriberMessageCount1++

    subscriber3.on 'message', ->
        subscriberMessageCount2++

    subscriber4.on 'message', ->
        subscriberMessageCount2++

    setTimeout (->
        publisher1.publish('test')
        publisher1.publish('test')
        publisher1.publish('test')

        publisher2.publish('test')
        publisher2.publish('test')
        publisher2.publish('test')
    ),200

    setTimeout (->
        assert.equal subscriberMessageCount1, 6
        assert.equal subscriberMessageCount2, 6
        console.log 'Test passed'
    ),1000
