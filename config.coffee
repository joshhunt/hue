path = require 'path'
fs = require 'fs'

CONFIG_PATH = './locals.json'

writeToJsonFile = (obj, filename) ->
    filename = filename or CONFIG_PATH
    data = JSON.stringify obj
    fs.writeFile filename, data, (err) ->
        console.log err if err

module.exports.get = (key) ->
    config = require CONFIG_PATH
    return config[key]

module.exports.set = (key, value) ->
    config = require CONFIG_PATH
    config[key] = value
    writeToJsonFile config
    return module.exports.get key
