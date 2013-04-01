json.array!(@emails) do |email|
  json.extract! email, 
  json.url email_url(email, format: :json)
end