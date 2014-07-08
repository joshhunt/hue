hue
===

Service for flashing Philips Hue lights when interesting things happen on Booodl. The [Philips Hue API Documentation](http://developers.meethue.com/) is recommended reading.

If you want to add a new event to react to, you'll need to make some changes to `app.coffee`:
 1. Add a key/value pair to `EVENTS`.
 2. Create a function that will be the reaction. Usually this will just call `hue.lights([...])`
 3. Add the function and `EVENT` key to the switch statement for on new data.

In this project, 'state' refers to a state of a light (e.g. what colour, brightness, etc). For more info, see [node-hue-api lightStates](https://github.com/peter-murray/node-hue-api#using-lightstate-to-build-states).

`hue.lights(states)` will transition the lights to the states, as specified as a list of strings in `states`. These strings should be keys of `states` in `hue.coffee`


## Getting Started

Make sure you create a `locals.json` file and specify `eventBusUrl` and `eventBusExchange`. It should probably look something like:

```
{
    "eventBusUrl": "amqp://booodl:booodlit@10.11.1.66",
    "eventBusExchange": "BooodlBus"
}
```

and then run with `coffee app.coffee`
