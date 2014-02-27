## Forex

[Balanced](http://balancedpayments.com)'s foreign currency exchange service.

To try it out:

```bash
$ bundle
$ rackup &
$ curl http://localhost:9292/
```

Forex uses [Collection+JSON]() as a media type. This means that you can use
any generic CJ client with Forex. If you don't have one handy, it's easy!

### Using Forex

If you're not familliar with Collection+JSON, here's how it works, at least
for Forex: make a request to the API:

```
$ curl http://localhost:9292/
{
  "collection": {
    // ... 
  },
  "queries": [
    // ...
  ]
}
```

You'll get two top-level items: a `collection` object, and a `queries`
array. `collection` has a list of items in it, and `queries` represents
queries you can make.

Here's a full response, with the details filled in:

```
$ curl http://localhost:9292/
{
  "collection": {
    
  },
  "queries": [
    {
      "rel": "convert",
      "href": "/convert",
      "data": [
        {
          "name": "from",
          "value": ""
        }
        {
          "name": "to",
          "value": ""
        }
        {
          "name": "amount",
          "value": ""
        }
      ]
    }
  ]
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
values you want as values. In this example, the query URL would be
`/convert?from=USD&to=BTC&amount=1`.
