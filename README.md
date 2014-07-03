hue
===

Service for flashing Philips Hue lights when interesting things happen on Booodl.


## Getting Started

Make sure you create a `locals.json` file and specify `eventBusUrl` and `eventBusExchange`. It should probably look something like:

```
{
    "eventBusUrl": "amqp://booodl:booodlit@10.11.1.66",
    "eventBusExchange": "BooodlBus"
}
```

and then run with `coffee app.coffee`