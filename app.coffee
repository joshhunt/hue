rabbit = require 'rabbit.js'
hue = require './hue'
require 'colors'

config = require './config'
EVENT_BUS_URL = config.get('eventBusUrl')
EVENT_BUS_EXCHANGE = config.get('eventBusExchange')

api = null

context = rabbit.createContext EVENT_BUS_URL
wildSocket = context.socket 'SUB', {routing: 'topic', persistent: true}

hue.quiet = false
hue.connect()
    .then (apiInstance) ->
        api = apiInstance
        hue.flashOnce()

EVENTS =
    followUser: 'user.follow.user'
    likeCard: 'user.like.card'
    collectCard: 'user.collect.card'
    newCard: 'user.add.card'
    newUser: 'system.add.user'

console.log "Connecting to #{EVENT_BUS_URL.cyan}"
wildSocket.connect EVENT_BUS_EXCHANGE, '#', -> console.log 'Connected to event bus'.green

parse = (buf) ->
    msg = JSON.parse buf.toString 'utf-8'
    eventName = "#{msg.actor_type}.#{msg.verb}.#{msg.objects[0][0]}"
    return [msg, eventName]

wildSocket.on 'error', (err) -> console.log err

wildSocket.on 'data', (data) ->
    [msg, eventName] = parse data

    switch eventName
        when EVENTS.newUser     then performNewUser()
        when EVENTS.newCard     then performNewCard()
        when EVENTS.collectCard then performCollectCard()
        when EVENTS.likeCard    then performLikeCard()
        when EVENTS.followUser  then performFollowUser()
        else                         hue.flashOnce()

# Sometimes the lights get stuck, so make sure
# we reset them back to white every 5 seconds
setInterval (->
    hue.resetLights() unless hue.currentlyFlashing
), 10 * 1000

performNewUser = ->
    console.log 'New User'.blue
    hue.lights ['mango', 'on', 'mango', 'on', 'mango', 'on'], .1, .5

performNewCard = ->
    console.log 'New Card'.blue
    hue.lights ['blue', 'cold', 'blue', 'cold', 'blue', 'on'], .1, .5

performCollectCard = ->
    console.log 'Collect Card'.blue
    hue.lights ['blue', 'on']

performLikeCard = ->
    console.log 'Like Card'.blue
    hue.lights ['pink', 'on']

performFollowUser = ->
    console.log 'Follow User'.blue
    hue.lights ['mango', 'on']