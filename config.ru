class Forex
  def call(env)
    status = 200
    headers = {"Content-Type" => "application/vnd.balanced.forex+json"}
    body = %Q/{"hello" => "world"}/

    [status, headers, [body]]
  end
end

run Forex.new
