FactoryGirl.define do
  factory :postfix_log_line do
    delivery
    
    time Time.now
    relay "foo.com[1.2.3.4]:25"
    delay "2.1"
    delays "0.09/0.02/0.99/0.99"
    dsn "2.0.0"
    extended_status "sent (250 ok dirdel)"
  end
end
