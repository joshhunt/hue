_     = require 'underscore'
hue   = require 'node-hue-api'
Q     = require 'Q'
async = require 'async'
require 'colors'

hueConnect = require './hue-connect'
config     = require './config'

NICE_WARM = 350
TRANSITION_DURATION = .4
ITERNATION_DELAY = .15
lights = {}

states =
    on:    hue.lightState.create().on().transition(TRANSITION_DURATION).white(NICE_WARM, 100)
    flash: hue.lightState.create().alert()
    cold:  hue.lightState.create().on().transition(TRANSITION_DURATION).white(155, 100)
    mango: hue.lightState.create().transition(TRANSITION_DURATION).rgb(253, 167, 69).brightness(100)
    blue:  hue.lightState.create().transition(TRANSITION_DURATION).rgb(0, 0, 255).brightness(100)
    red:  hue.lightState.create().transition(TRANSITION_DURATION).rgb(255, 0, 0).brightness(100)

module.exports =
    connect: hueConnect.connect
    api: null,
    quiet: true
    NICE_WARM: NICE_WARM
    TRANSITION_DURATION: TRANSITION_DURATION
    lights: lights
    states: states

globalLightState = (state) -> hueConnect.api.setGroupLightState 0, state

transitions = (thisStates) ->
    timeout = TRANSITION_DURATION + ITERNATION_DELAY
    dfd = Q.defer()

    _performState = (_state, callback) ->
        hueConnect.api.setGroupLightState 0, states[_state]
            .then ->
                timeout = TRANSITION_DURATION
                timeout += ITERNATION_DELAY if _state is 'on' or _state is 'cold'
                setTimeout callback, timeout * 1000

    async.eachSeries thisStates, _performState, (-> dfd.resolve())
    return dfd.promise


###
# Public Methods
###
module.exports.lights           = transitions
module.exports.globalLightState = globalLightState
module.exports.resetLights      = -> globalLightState states.on
module.exports.flashOnce        = -> globalLightState states.flash


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
    globalLightState state


module.exports.newUser = ->
    transitions [
        'mango'
        'on'
        'mango'
        'on'
        'mango'
        'on'
    ]

module.exports.newCard = ->
    transitions [
        'blue'
        'cold'
        'blue'
        'cold'
        'blue'
        'on'
    ]