module Scope
  def self.included(base)
    base.class_eval do
      scope :in_scope, ->(scope) {
        if scope == :current
          where(is_current: true)
        elsif scope == :historic
          where(is_current: false)
        else
          where(nil)
        end
      }
    end
  end
end