(function() {
  var assert, conn, pubsub;
  pubsub = require('../lib/pubsub');
  assert = require('assert');
  conn = pubsub.createConnection({
    host: 'localhost'
  });
  conn.on('ready', function() {
    var publisher, subscriber1, subscriber2, subscriberMessageCount;
    publisher = conn.createPublisher('test-publisher');
    subscriber1 = conn.createSubscriber('test-publisher');
    subscriber2 = conn.createSubscriber('test-publisher');
    subscriberMessageCount = 0;
    subscriber1.on('message', function() {
      return subscriberMessageCount++;
    });
    subscriber2.on('message', function() {
      return subscriberMessageCount++;
    });
    setTimeout((function() {
      publisher.publish('test');
      publisher.publish('test');
      return publisher.publish('test');
    }), 200);
    return setTimeout((function() {
      assert.equal(subscriberMessageCount, 6);
      console.log('Test passed');
      return process.exit(0);
    }), 1000);
  });
}).call(this);
