#### pubsub

Simple pubsub for node.js using rabbitmq.

### Synopsis

    pubsub = require('pubsub')
    
    conn = pubsub.createConnection({ host: 'localhost'})
    
    conn.on('ready', function(){
        publisher = conn.createPublisher('channel')
        
        sub1 = conn.createSubscriber('channel')
        sub2 = conn.createSubscriber('channel')
        
        react = function(sub){
            messages = 0
            return function(message){
                messages++
                doFancyThingsWith(sub, message)
                if (messages == 2){
                    sub.destroy()
                }
            }
        }
        
        sub1.on('message', react(sub1))
        sub2.on('message', react(sub2))
        
        publisher.publish({ javaScript: '++' })
        publisher.publish({ coffeeScript: '++' })
                
        publisher.destroy()
    })
    
### Installation

    npm install pubsub

### Documentation

...can be found (here)[http://flashingpumpkin.github.com/pubsub/docs/pubsub.html]

(<3 (docco)[http://jashkenas.github.com/docco/])

### Note

Requires a slightly modified version of node-amqp which is included 
in the `npm` installation. 

To make it work from git, use the following installation:

    git clone http://github.com/flashingpumpkin/node-pubsub.git
    cd node-pubsub/lib
    git clone http://github.com/flashingpumpkin/node-amqp.git
    

