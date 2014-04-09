## Foreign Currency Support

This document contains an overview of all of the changes that will be need to
made for Balanced to support foreign currency.

### What is Foreign Currency Support?

Currently, as a seller on a Balanced-powered marketplace, all of my prices are
set in USD. If someone from Europe with an account denominated in EUR purchases
something from me, their bank will charge them a foreign exchange fee.

Forex support in Balanced will allow sellers to sell things in other currencies,
such as EUR. This way, the buyer will not pay their bank the exchange fee, and
will see the full, round number on their account statement.

Even though the seller charges in EUR, it will hit their account in USD.
Everything else stays the same. Eventually, we hope to offer 'multicurrency'
support, which would allow sellers to have different escrow accounts in different
currencies. Because we can not yet pay out sellers outside the US, this feature
is not yet necessary.

Balanced will charge a 2% fee for providing this service. This is consistent
with Stripe.

If a charge that was initiated in EUR gets refunded, the buyer will be refunded
in EUR, at the same amount. The seller may end up taking a small hit if the
exchange rate has changed in the period between the charge and the refund. This
is consistent with Stripe, and our decision to place risk on the seller rather
than the buyer whenever it's unclear who should take it on.

We should decide how many currencies we want to expose. Stripe pulled out 139 at
launch. We may want to just start with GBP and EUR, or we may want to do all of
the ones Litle supports. This is primarily a marketing decision, and doesn't
affect development much.

### Docs

Most importantly, we need overall documentation. While this documentation is
mostly team-facing and high-level, we will also need to modify our charge,
capture, and refund API documentation, and should probably create a separate
guide for foreign currency support.

In addition, all of the services will need to have their individual
documentation updated, since the interfaces will be getting additions.

Client libraries could probably use examples added of how to use the
already-existing forex support.

### Dashboard

The dashboard already shows the full details of the responses, so there doesn't
_need_ to be any specific changes. However, we can do better than that: it'd
probably be good to expose which charges were in a different currency, and allow
you to search/sort by currency type.

These changes will be largely cosmetic, because 1.1 already has the currency
field.

### balanced

As just mentioned, balanced needs few changes, as it already accepts a currency
type as well as an amount.

However, it currently does not pass this information along to precog, which
just understands integer cents. So the changes to balanced will simply be
around relaxing the restriction on that field to non-USD.

The other change in balanced will be exposing more details about how we collect
fees. Right now, we expose nothing, but we should show our fee and the forex
fee separately. This change will be entirely additive.

### precog

precog is where reporting is done, and so it needs to be able to understand
exactly what is charged and where.

It will need to be modified to record the differences between our fee and
the forex fee.

It will need to be able to query forex to find out what that fee is.

It will need to be modified to use a unit of currency and an amount, rather
than be solely USD cents, and it will need to pass that information upstream
to knox.

### knox

Knox currently only operates in USD cents, and so will need to be modified to
handle a currency type and amount.

Currently, marketplaces are 1-1 with MIDs, mostly. There are also some that
share a MID. So we'll need to fix that, and make marketplaces 1-N with MIDs.
This is because that's how Litle handles charging in different currencies.

Noah brought up a small concern regarding 'backflow' from Knox. Basically, Knox
cannot directly connect to precog, and instead publishes to a queue that precog
subscribes to, and he's not sure why that decision was made. But, this
connection becomes more important after this change, since knox needs to confirm
with precog that the rate Litle actually gave us is the one that they said they'd
give us. We should make sure that's reliable.

### forex

forex is a new service that is the definitive source of information about foreign
currency services. This functionality could have just been placed inside of
precog, but SOA is about making services that control different parts of your
application, and given that precog is about determining fraud, it felt right
to move it. This is consistent with the precog/balanced/knox split, as well as
Billy being a separate service.

forex's primary job is to understand and communicate the rate at which we
exchange currencies for one another.

In practice, this boils down to proxying to two services and doing some math.
This demonstrates exactly why it's a good idea to make this a separate service,
as we can still provide forex services if our upstream conversion providers
experience downtime, as well as swap out different providers without changing
anything else in the system.

Coinbase will be our provider for BTC conversions. The 'spike' branch of the
forex repository contains a simple implementation of proxying out to Coinbase.
Their API for this is very straightforward.

Litle will be for other currencies. Litle says they use the Visa daily rate,
which I do not have a definitive answer as to where to get it yet. I remember
vaguely having a conversation which suggests they give it to us through FTP
every day, but I am not 100% sure. Regardless, we will source it from
somewhere.

Keeping with our hypermedia theme, forex will use Collection+JSON to expose the
rates. CJ is a media type very specific to lists, and also contains forms.
Therefore, it is perfect for this 'query and give me a list of results' kind of
service.

Steve will need to develop a profile for the CJ to follow. The spike
demonstrated that it will be very simple, with less than five link relations
and data types.

### Client libraries

Our client libraries already have support for multi-currency, because 1.1 has
the field in the API already. As mentioned in the documentation section,
some examples would be nice to add.
