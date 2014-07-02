module.exports.generateUsername = (prefix) ->
    prefix = prefix or 'eventBus'
    random = Math.random().toString(36).substr(2, 15)
    return "#{prefix}-#{random}"

module.exports.prettyBool = (data) ->
    if data.lower == 'false' or not data
        return 'false'.red
    else
        return 'true'.green

module.exports.log = (msg...) ->
    console.log msg.join(' ') unless module.exports.quiet