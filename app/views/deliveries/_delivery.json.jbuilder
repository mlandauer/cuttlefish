json.id delivery.id
json.from delivery.email.from_address.text
json.to delivery.address.text
json.subject delivery.email.subject
json.sent delivery.sent
json.status delivery.status
json.message_id delivery.email.message_id
json.email_id delivery.email.id
json.data_hash delivery.email.data_hash
json.created_at delivery.created_at
json.updated_at delivery.updated_at
json.app do
  json.id delivery.email.app.id
  json.name delivery.email.app.name
  json.url delivery.email.app.url
  json.custom_tracking_domain delivery.email.app.custom_tracking_domain
  json.from_domain delivery.email.app.from_domain
end
json.tracking do
  json.open_tracked delivery.open_tracked
  json.open_events delivery.open_events do |open_event|
    json.user_agent open_event.user_agent
    json.referer open_event.referer
    json.ip open_event.ip
    json.created_at open_event.created_at
  end
  json.links delivery.delivery_links do |delivery_link|
    json.id delivery_link.link.id
    json.url delivery_link.link.url
    json.click_events delivery_link.click_events do |click_event|
      json.user_agent click_event.user_agent
      json.referer click_event.referer
      json.ip click_event.ip
      json.created_at click_event.created_at
    end
  end
  json.postfix_queue_id delivery.postfix_queue_id
  json.postfix_log_lines delivery.postfix_log_lines do |postfix_log_line|
    json.time postfix_log_line.time
    json.relay postfix_log_line.relay
    json.delay postfix_log_line.delay
    json.delays postfix_log_line.delays
    json.dsn postfix_log_line.dsn
    json.extended_status postfix_log_line.extended_status
  end
end
