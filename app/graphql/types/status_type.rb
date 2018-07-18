class Types::StatusType < Types::BaseEnum
  value "not_sent", "Not sent because it's on the blacklist"
  value "sent", "Sent but not yet definitely delivered"
  value "delivered", "Delivered to its destination"
  value "soft_bounce", "A temporary delivery problem"
  value "hard_bounce", "A permanent delivery problem"
end
