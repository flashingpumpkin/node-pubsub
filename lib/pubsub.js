(function() {
  var Connection, amqp, bison, createConnection, destroy, events, publisher, receive, send, subscriber, sys, u;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  amqp = require('../lib/node-amqp/amqp');
  events = require('events');
  bison = require('../lib/bison');
  util = require('util');
  u = require('underscore')._;
  receive = function(emitter) {
    return function(message) {
      message.data = bison.decode(message.data.toString());
      return emitter.emit('message', message);
    };
  };
  send = function(exchange) {
    return function(message) {
      return exchange.publish('', bison.encode({
        message: message
      }));
    };
  };
  destroy = function(emitter, channel, channels, collection) {
    channel.on('close', function() {
      delete channels[channel.channel];
      delete collection[channel.name];
      return emitter.emit('close');
    });
    return function() {
      channel.destroy();
      return channel.close();
    };
  };
  publisher = function(connection) {
    return function(id, options) {
      var emitter, exchange;
      options || (options = {
        type: 'fanout'
      });
      emitter = new events.EventEmitter;
      exchange = connection.exchange(id, options);
      return u.extend(emitter, {
        destroy: destroy(emitter, exchange, connection.channels, connection.exchanges),
        publish: send(exchange)
      });
    };
  };
  subscriber = function(connection) {
    return function(id, options) {
      var emitter, queue;
      options || (options = {});
      emitter = new events.EventEmitter;
      queue = connection.queue('', options);
      queue.subscribe(receive(emitter));
      queue.bind(id, '');
      return u.extend(emitter, {
        destroy: destroy(emitter, queue, connection.channels, connection.queues)
      });
    };
  };
  Connection = function() {
    function Connection(connection) {
      this.connection = connection;
      this.connection.on('ready', __bind(function() {
        return this.emit('ready');
      }, this));
      this.createPublisher = publisher(this.connection);
      this.createSubscriber = subscriber(this.connection);
    }
    __extends(Connection, events.EventEmitter);
    return Connection;
  }();
  createConnection = function(options) {
    var amqpConnection, connection;
    amqpConnection = amqp.createConnection(options);
    connection = new Connection(amqpConnection);
    return connection;
  };
  exports.createConnection = createConnection;
}).call(this);
