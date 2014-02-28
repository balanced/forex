require 'net/http'

class CoinbaseProxy
  def convert(currency)
    uri = URI('https://coinbase.com/api/v1/prices/spot_rate')
    params = { :currency => currency }
    uri.query = URI.encode_www_form(params)

    Net::HTTP.get(uri)
  end
end
