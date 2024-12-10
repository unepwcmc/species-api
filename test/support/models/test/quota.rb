class Test::Quota < Test::TradeRestriction
  belongs_to :unit, class_name: 'Test::Unit', optional: true
end
