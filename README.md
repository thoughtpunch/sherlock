# Sherlock

Sherlock is the world's best (URI) inspector.

It will get all available data about a given URI and even fetch and scrape the content if needed.

## Installation

Add this line to your application's Gemfile:

    gem 'sherlock'

Or install it yourself as:

    $ gem install sherlock

## Usage

Inspect a URI like so...

```Sherlock.inspect("http://www.awesome.com")```

This will return a Sherlock::Inspector object that will give you basic info about the URI

Sherlock will attempt to use the lightest methods possible for extracting data first. If all you need is basic data on wether the endpoint exists, how the server responds, it will only make a TRACE request. Only if you need content from the URI will it use a GET, etc.

## Examples

```inspector = Sherlock.inspect("http:www.contently.com")```

inspector.server = 'Apache 2.1'
inspector.exists? = true
inspector.headers = '{HEADERS}'

**Scraping URI Content**
inspector.author = "Dan Barrett"
inspector.title = "How to be Awesome without really trying"
inspector.images = ['http://www.awesome.com/bears.jpg']
inspector.links = ['http://www.google.com','http://www.amazon.com']

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
