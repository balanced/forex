require 'json'
require 'coinbase_proxy'

class Forex
  attr_accessor :coinbase

  def initialize
    @coinbase = CoinbaseProxy.new
  end
  
  def call(env)
    headers = {"Content-Type" => "text/plain"}
    status = 404
    body = 'Not found.'

    if env["REQUEST_PATH"] == "/"
      headers = {"Content-Type" => "application/collection+json"}
      status = 200
      body = root_cj_document
      body = JSON.generate(body)
    elsif env["REQUEST_PATH"].start_with?("/convert")
      headers = {"Content-Type" => "application/collection+json"}
      status = 200
      body = convert_cj_document(Rack::Utils.parse_query(env["QUERY_STRING"]))
      body = JSON.generate(body)
    end

    [status, headers, [body]]
  rescue UnsupportedCurrency
    [400, {"Content-Type" => "text/plain"}, ["Currency not supported."]]
  end

  private

  SUPPORTED_CURRENCIES = ["USD", "BTC"]
  UnsupportedCurrency = Class.new(StandardError)

  def convert_cj_document(query)
    to = query["to"]
    from = query["from"]
    amount = query.fetch("amount") { 1 }

    unless SUPPORTED_CURRENCIES.include?(to) && SUPPORTED_CURRENCIES.include?(from)
      raise UnsupportedCurrency
    end

    value = coinbase.convert(from) * amount

    root_cj_document.tap do |doc|
      doc["collection"]["items"] = [{
        "data" => [
          "name" => "#{amount} #{from} in #{to}",
          "value" => "#{value}",
        ],
      }]
    end
  end

  def root_cj_document
    Hash.new.tap do |doc|
      doc["collection"] = {}
      doc["collection"]["queries"] = []
      doc["collection"]["queries"] << queries_hash
    end
  end

  def queries_hash
    {
      "href" => "/convert",
      "rel" => "convert",
      "data" => [
        {
          "name" => "from",
          "value" => "",
        },
        {
          "name" => "to",
          "value" => "",
        },
        {
          "name" => "amount",
          "value" => "1",
        },
      ],
    }
  end
end
