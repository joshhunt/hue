_     = require 'underscore'
hue   = require 'node-hue-api'
request = require 'request'
Q     = require 'Q'
async = require 'async'
require 'colors'

hueConnect = require './hue-connect'
config     = require './config'

NICE_WARM = 350
TRANSITION_DURATION = .1
ITERATION_DELAY = .1
lights = {}
hueURL = null

states =
    on:    hue.lightState.create().transition(0).on().white(NICE_WARM, 100)
    flash: hue.lightState.create().transition(0).alert()
    cold:  hue.lightState.create().transition(0).on().white(155, 100)
    mango: hue.lightState.create().transition(0).rgb(253, 167, 69).brightness(100)
    blue:  hue.lightState.create().transition(0).rgb(0, 0, 255).brightness(100)
    red:   hue.lightState.create().transition(0).rgb(255, 0, 0).brightness(100)
    pink:   hue.lightState.create().transition(0).rgb(180, 15, 15).brightness(100)

module.exports =
    connect: hueConnect.connect
    api: hue
    quiet: true
    NICE_WARM: NICE_WARM
    TRANSITION_DURATION: TRANSITION_DURATION
    lights: lights
    states: states

hueConnect.promise.then (api) -> hueURL = "http://#{api.host}/api/#{api.username}"

allLightsToState = (state) ->
    # node-hue-api doesnt cope well when you do multiple quick
    # transitions, so we create our own API call to change lights
    dfd = Q.defer()

    request
        url: "#{hueURL}/groups/0/action"
        json: state
        method: 'PUT'
    , -> dfd.resolve()

    return dfd.promise

transitionAll = (thisStates, _duration, _delay) ->
    module.exports.currentlyFlashing = true
    duration = _duration or TRANSITION_DURATION
    delay = _delay or ITERATION_DELAY
    timeout = duration + delay
    dfd = Q.defer()

    _performState = (stateName, callback) ->
        stateToPerform = states[stateName].transition(duration)
        allLightsToState stateToPerform
            .then ->
                stateToPerform.transition(0)
                setTimeout callback, timeout * 1000

    async.eachSeries thisStates, _performState, (->
        module.exports.currentlyFlashing = false
        dfd.resolve()
    )
    return dfd.promise


###
# Public Methods
###
module.exports.lights           = transitionAll
module.exports.allLightsToState = allLightsToState
module.exports.resetLights      = -> allLightsToState states.on
module.exports.flashOnce        = -> allLightsToState states.flash


module.exports.printLightStatus = ->
    promise = hueConnect.api.getFullState()
    promise.then (state) ->
        _.each state.lights, (light, index) ->
            log "\n##{index}: #{light.name.cyan}"
            log "  On: #{utils.prettyBool(light.state.on)}"
            log "  Reachable: #{utils.prettyBool(light.state.reachable)}"
        .done()
    return promise


module.exports.toRGB = (red, green, blue) ->
    state = hue.lightState.create().transition(TRANSITION_DURATION).rgb(red, green, blue).brightness(100)
    allLightsToState state
