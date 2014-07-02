require 'colors'
hue = require './hue'
hue.quiet = false

hue.connect()
    .then (api) ->
        console.log 'Cool, connected to Hue'.green
        # hue.resetLights()
        # hue.flashOnce()
        hue.newUser().done -> setTimeout hue.newCard, 3000
    .catch (err) ->
        console.log 'Fuck, an error happened'
        console.log err
    .done()