amqp = require '../lib/node-amqp/amqp'
uuid = require 'uuid'
events = require 'events'
bison = require '../lib/bison'
sys = require 'sys'
u = require('underscore')._


receive = (emitter)->
    (message)->
        message.data = bison.decode(message.data.toString())
        emitter.emit 'message', message

send = (exchange)->
    (message)->
        exchange.publish '', bison.encode({ message: message })

destroy = (emitter, channel, channels, collection)->
    channel.on 'close', ->
        delete channels[channel.channel]
        delete collection[channel.name]
        emitter.emit 'close'
    ->
        channel.destroy()
        channel.close()

publisher = (connection)->
    (id, options) ->
        options or= type: 'fanout'
        emitter = new events.EventEmitter
        exchange = connection.exchange(id, options)
        u.extend emitter, {
            destroy: destroy(emitter, exchange, connection.channels, connection.exchanges)
            publish: send(exchange)
        }

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

