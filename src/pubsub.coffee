#### Pubsub
# Pubsub is a simple library to create a pubsub system
# using [node.js](http://nodejs.org) and [RabbitMQ](http://rabbitmq.com)

amqp = require '../lib/node-amqp/amqp'
events = require 'events'
bison = require '../lib/bison'
sys = require 'sys'
u = require('underscore')._

# Receive messages from publishers and emit them via the event emitter
# object.
receive = (emitter)->
    (message)->
        message.data = bison.decode(message.data.toString())
        emitter.emit 'message', message

# Send messages via the exchange.
send = (exchange)->
    (message)->
        exchange.publish '', bison.encode({ message: message })

# Destroy a given channel and clean up the objects in 
# the connection. The channel is either a queue or an
# exchange.
destroy = (emitter, channel, channels, collection)->
    channel.on 'close', ->
        delete channels[channel.channel]
        delete collection[channel.name]
        emitter.emit 'close'
    ->
        channel.destroy()
        channel.close()

# Create a publisher object and return an event emitter with 
# some additional methods to publish messages and to destroy
# the exchange.
publisher = (connection)->
    (id, options) ->
        options or= type: 'fanout'
        emitter = new events.EventEmitter
        exchange = connection.exchange(id, options)
        u.extend emitter, {
            destroy: destroy(emitter, exchange, connection.channels, connection.exchanges)
            publish: send(exchange)
        }

# Create a subscriber object and return an event emitter with an
# additional method to destroy the queue.
subscriber = (connection)->
    (id, options)->
        options or= {}
        emitter = new events.EventEmitter
        queue = connection.queue('', options)
        queue.subscribe(receive(emitter))
        queue.bind id, ''
        u.extend emitter, {
            destroy: destroy(emitter, queue, connection.channels, connection.queues)
        }

# Connection class exposing publisher and subscriber methods.
class Connection extends events.EventEmitter
    constructor: (@connection)->
        @connection.on 'ready', =>
            @emit 'ready'

        @createPublisher = publisher(@connection)

        @createSubscriber = subscriber(@connection)

createConnection = (options)->
    amqpConnection = amqp.createConnection(options)
    connection = new Connection amqpConnection
    return connection

exports.createConnection = createConnection

