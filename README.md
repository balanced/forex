## Forex

[Balanced](http://balancedpayments.com)'s foreign currency exchange service.

To try it out:

```bash
$ bundle
$ rackup &
$ curl http://localhost:9292/
```

Forex uses [Collection+JSON](http://amundsen.com/media-types/collection/) as a
media type. This means that you can use any generic CJ client with Forex. If
you don't have one handy, it's easy!

### Using Forex

If you're not familliar with Collection+JSON, here's how it works, at least
for Forex: make a request to the API:

```
$ curl http://localhost:9292/
{
  "collection": {
    "queries": [
      // ...
    ]
  }
}
```

You'll get one top-level item: a `collection` object. The `collection` has a
`queries` array which represents queries you can make.

Here's a full response, with the details filled in:

```
$ curl http://localhost:9292/
{
  "collection": {
    "queries": [
      {
        "rel": "convert",
        "href": "/convert",
        "data": [
          {
            "name": "from",
            "value": ""
          },
          {
            "name": "to",
            "value": ""
          },
          {
            "name": "amount",
            "value": "1"
          }
        ]
      }
    ]
  }
}
```

Our `collection` is empty, because we haven't requested any particular currency
conversion rate. The `queries` array has one object inside. This object has
three keys: `rel`, `href`, and `data`.

`rel` is the most important: it's the 'link relation' name of the query. In
this case, we have a `convert` relation. We'll use the `rel` in a moment.

`href` and `data` are used to construct the query itself. What you do is
this: you take the URL located in `href`, and you append a query string made
by joining the `name` elements of all of the objects in `data` as keys, and the
values you want as values. You may notice that `amount` already has a value
above; this is a default value. If you leave out `amount`, you'll get a result
where the `amount` is `1`. In this example, you wished to convert 1 USD into
BTC, the query URL would be `/convert?from=USD&to=BTC&amount=1`. You can then
make an HTTP `GET` request to that URL, and you'll get another response back.

## Reading the value

Let's make that request:

```
$ curl "http://localhost:9292/convert?from=usd&to=btc"
{
  "collection": {
    "items": [
      {
        "data": [
          {
            "name": "1 USD in BTC",
            "value": "0.001696"
          }
        ]
      }
    ],
    "queries": [
      // ...
    ]
  }
}
```

You'll note we've omitted the `queries` body: it's the same as on the root
URL, so no need to repeat ourselves here. What's new is that we now have an
`items` array. This `items` array contains an object, with a `data` array
inside of it. This `data` array has a `name` and a `value`. The `name` is
a descriptive explanation, in this case, that we're fetching one USD in BTC.
The value is the actual converted amount of currency.

That's how Forex works!
