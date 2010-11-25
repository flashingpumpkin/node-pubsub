(function() {
  var assert, conn, pubsub;
  pubsub = require('../lib/pubsub');
  assert = require('assert');
  conn = pubsub.createConnection({
    host: 'localhost'
  });
  conn.on('ready', function() {
    var publisher1, publisher2, subscriber1, subscriber2, subscriber3, subscriber4, subscriberMessageCount1, subscriberMessageCount2;
    publisher1 = conn.createPublisher('test-publisher');
    publisher2 = conn.createPublisher('test-publisher-2');
    subscriber1 = conn.createSubscriber('test-publisher');
    subscriber2 = conn.createSubscriber('test-publisher');
    subscriber3 = conn.createSubscriber('test-publisher-2');
    subscriber4 = conn.createSubscriber('test-publisher-2');
    subscriberMessageCount1 = 0;
    subscriberMessageCount2 = 0;
    subscriber1.on('message', function() {
      return subscriberMessageCount1++;
    });
    subscriber2.on('message', function() {
      return subscriberMessageCount1++;
    });
    subscriber3.on('message', function() {
      return subscriberMessageCount2++;
    });
    subscriber4.on('message', function() {
      return subscriberMessageCount2++;
    });
    setTimeout((function() {
      publisher1.publish('test');
      publisher1.publish('test');
      publisher1.publish('test');
      publisher2.publish('test');
      publisher2.publish('test');
      return publisher2.publish('test');
    }), 200);
    return setTimeout((function() {
      assert.equal(subscriberMessageCount1, 6);
      assert.equal(subscriberMessageCount2, 6);
      return console.log('Test passed');
    }), 1000);
  });
}).call(this);
