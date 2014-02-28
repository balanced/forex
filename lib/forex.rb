require 'json'

class Forex
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
      body = convert_cj_document(env["QUERY_STRING"])
      body = JSON.generate(body)
    end

    [status, headers, [body]]
  end

  private

  def convert_cj_document(query)
    root_cj_document.tap do |doc|
      doc["collection"]["items"] = [{
        "data" => [
          "name" => "1 USD in BTC",
          "value" => "0.001696",
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

