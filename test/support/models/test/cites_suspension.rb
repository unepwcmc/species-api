class Test::CitesSuspension < Test::TradeRestriction
  belongs_to :start_notification, class_name: 'Test::CitesSuspensionNotification'
  belongs_to :end_notification, class_name: 'Test::CitesSuspensionNotification'
end
