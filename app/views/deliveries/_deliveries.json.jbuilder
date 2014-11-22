#json.partial! partial: "deliveries/delivery", collection: deliveries, as: :delivery

json.deliveries do
  json.array! deliveries, partial: "deliveries/delivery", as: :delivery
end
