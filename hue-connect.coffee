_     = require 'underscore'
hue   = require 'node-hue-api'
Q     = require 'Q'

utils  = require './utils'
config = require './config'

fallbackTimeout = 0
api = new hue.HueApi()
deferred = Q.defer()
promise = deferred.promise
lights = {}
module.exports.lights = lights
module.exports.api = api
module.exports.promise = promise

module.exports.connect = ->
    hue.locateBridges()
        .then (bridges) ->
            postLocateBridges(bridges)
        .catch (err) ->
            utils.log 'Error using bridge autodiscovery.'.red
            utils.log err
        .done()

    return promise


postLocateBridges = (bridges) ->

    if not bridges.length
        utils.log 'Couldn\'t autodiscover bridges. Using fallback method'.cyan
        searchBridgeFallback()
        return

    if bridges.length > 1
        utils.log 'Found multiple bridges, using first bridge'.cyan

    connectToBridge(bridges[0].ipaddress)


searchBridgeFallback = (iter) ->
    fallbackTimeout += 5

    if fallbackTimeout > 25
        utils.log 'Giving up searching for bridge...'.red
        err = new Error 'Fallback search timeout'
        deferred.reject err
        return

    utils.log "Using fallback method for bridge search. May take #{fallbackTimeout} seconds..."

    hue.searchForBridges(fallbackTimeout * 1000)
        .then postLocateBridges
        .catch -> utils.log 'searchBridgeFallback error'.red
        .done()


connectToBridge = (bridge) ->
    utils.log 'Connecting to bridge at'.blue, bridge.cyan + '...'.blue

    if config.get('username')
        loginToBridge bridge, config.get('username')
    else
        registerToBridge bridge


registerToBridge = (bridge) ->
    username = utils.generateUsername()
    deviceType = 'booodlEventBus'

    utils.log 'Registering to bridge with username'.blue, username.cyan

    reg = ->
        api.registerUser(bridge, username, deviceType)
            .then (newUsername) ->
                utils.log 'Registered successfully'.green
                config.set 'username', newUsername
                loginToBridge bridge, newUsername
            .catch (err) ->
                # 101 is error code for link button on pressed
                if err.type == 101
                    console.log 'Plz press button on bridge. Trying again in 5 seconds'.cyan
                    setTimeout reg, 5 * 1000
                else
                    utils.log 'Failed to register'.red
                    utils.log err
                    deferred.reject(err)
            .done()
    reg()


loginToBridge = (bridge, username) ->
    utils.log 'Logging into bridge'.blue, bridge.cyan, 'with username'.blue, username.cyan
    api = new hue.HueApi bridge, username

    api.connect()
        .then onceConnected
        .catch (err) ->
            utils.log 'Error logging into bridge!'.red
            utils.log err
            deferred.reject(err)
        .done()


onceConnected = (data) ->
    utils.log 'Successfully connected to bridge'.green, data.name.cyan

    api.lights()
        .then (resp) ->
            _.each resp.lights, (obj) -> lights[obj.id] = obj
            module.exports.api = api
            deferred.resolve api
        .done()