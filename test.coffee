require 'colors'
hue = require './hue'
hue.quiet = false

main = ->
    hue.lights ['mango', 'on', 'mango', 'on', 'mango', 'on'], 1, 0

hue.connect()
    .then (api) ->
        console.log 'Cool, connected to Hue'.green
        main()
        # hue.resetLights()
        # setTimeout main, 3000
    .catch (err) ->
        console.log 'Fuck, an error happened'
        console.log err
    .done()
