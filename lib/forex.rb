require 'json'

class Forex
  def call(env)
    status = 200
    headers = {"Content-Type" => "application/collection+json"}
    body = JSON.generate(root_cj_document)

    [status, headers, [body]]
  end

  private

  def root_cj_document
    Hash.new.tap do |doc|
      doc["collection"] = {}
      doc["queries"] = []
      doc["queries"] << {
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
            "value" => "",
          },
        ],
      }
    end
  end
end

