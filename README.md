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

### Note

Requires a slightly modified version of node-amqp which is included 
in the `lib/` folder & in the installation.
