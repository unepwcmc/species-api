require 'exception_notification/rails'
require 'yaml'

ExceptionNotification.configure do |config|
  secrets = YAML.load(File.open('config/secrets.yml'))
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

  # Adds a condition to decide when an exception must be ignored or not.
  # The ignore_if method can be invoked multiple times to add extra conditions.
  config.ignore_if do |exception, options|
    not (Rails.env.production? || Rails.env.staging?)
  end

  # Notifiers =================================================================

  # Email notifier sends notifications by email.
  config.add_notifier :email, {
    :email_prefix         => "[ERROR] ",
    :sender_address       => %{"Exception Notification" <notifier@speciesplus.net>},
    :exception_recipients => %w{SpeciesPlusDevs@wcmc.org.uk}
  }

  # Campfire notifier sends notifications to your Campfire room. Requires 'tinder' gem.
  # config.add_notifier :campfire, {
  #   :subdomain => 'my_subdomain',
  #   :token => 'my_token',
  #   :room_name => 'my_room'
  # }

  # HipChat notifier sends notifications to your HipChat room. Requires 'hipchat' gem.
  # config.add_notifier :hipchat, {
  #   :api_token => 'my_token',
  #   :room_name => 'my_room'
  # }

  config.add_notifier :slack, {
    :team => "wcmc",
    :token => secrets["slack_exception_notification_token"],
    :channel => "#speciesplus"
  }

end