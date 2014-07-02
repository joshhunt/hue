rabbit = require 'rabbit.js'
require 'colors'

config = require './config'
EVENT_BUS_URL = config.get('eventBusUrl')
EVENT_BUS_EXCHANGE = config.get('eventBusExchange')

context = rabbit.createContext EVENT_BUS_URL

wildSocket = context.socket 'SUB', {routing: 'topic', persistent: true}

EVENTS =
    followUser: 'user.follow.user'
    likeCard: 'user.like.card'
    collectCard: 'user.collect.card'
    newCard: 'user.add.card'
    newUser: 'system.add.user'

console.log "Connecting to #{EVENT_BUS_URL.cyan}"
wildSocket.connect EVENT_BUS_EXCHANGE, '#', -> console.log 'wildSocket connected\n'

parse = (buf) ->
    msg = JSON.parse buf.toString 'utf-8'
    eventName = "#{msg.actor_type}.#{msg.verb}.#{msg.objects[0][0]}"
    return [msg, eventName]

wildSocket.on 'error', (err) -> console.log err

wildSocket.on 'data', (data) ->
    [msg, eventName] = parse data

    switch eventName
        when EVENTS.newUser     then hue.lights ['mango', 'on', 'mango', 'on', 'mango', 'on']
        when EVENTS.newCard     then hue.lights ['blue', 'cold', 'blue', 'cold', 'blue', 'on']
        when EVENTS.collectCard then hue.lights ['blue', 'on']
        when EVENTS.likeCard    then hue.lights ['red', 'on']
        when EVENTS.followUser  then hue.lights ['mango', 'on']
        else                         hue.flashOnce
