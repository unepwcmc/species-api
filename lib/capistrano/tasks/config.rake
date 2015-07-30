namespace :config do
  task :setup do
   ask(:db_user, 'db_user')
   ask(:db_pass, 'db_pass')
   ask(:db_name, 'db_name')
   ask(:db_host, 'db_host')
setup_config = <<-EOF
#{fetch(:rails_env)}:
adapter: postgresql
database: #{fetch(:db_name)}
username: #{fetch(:db_user)}
password: #{fetch(:db_pass)}
host: #{fetch(:db_host)}
EOF
  on roles(:app) do
     execute "mkdir -p #{shared_path}/config"
     upload! StringIO.new(setup_config), "#{shared_path}/config/database.yml"
    end
  end
end


namespace :config do
  task :setup do
   ask(:SECRET_KEY_BASE, 'SECRET_KEY_BASE')
   ask(:DEVISE_SECRET_KEY, 'DEVISE_SECRET_KEY')
   ask(:SLACK_EXCEPTION_NOTIFICATION_TOKEN, 'SLACK_EXCEPTION_NOTIFICATION_TOKEN')
   ask(:SLACK_EXCEPTION_NOTIFICATION_WEBHOOK_URL, 'SLACK_EXCEPTION_NOTIFICATION_WEBHOOK_URL')
   ask(:MAILER_ADDRESS_KEY, 'MAILER_ADDRESS_KEY')
   ask(:MAILER_DOMAIN_KEY, 'MAILER_DOMAIN_KEY')
   ask(:MAILER_USERNAME_KEY, 'MAILER_USERNAME_KEY')
   ask(:MAILER_PASSWORD_KEY, 'MAILER_PASSWORD_KEY')
   ask(:MAILER_ASSET_HOST_KEY, 'MAILER_ASSET_HOST_KEY')
   ask(:MAILER_HOST_KEY, 'MAILER_HOST_KEY')
env_config = <<-EOF
SECRET_KEY_BASE:	#{fetch(:SECRET_KEY_BASE)}
DEVISE_SECRET_KEY:	#{fetch(:DEVISE_SECRET_KEY)}
SLACK_EXCEPTION_NOTIFICATION_TOKEN:	#{fetch(:SLACK_EXCEPTION_NOTIFICATION_TOKEN)}
SLACK_EXCEPTION_NOTIFICATION_WEBHOOK_URL:	#{fetch(:SLACK_EXCEPTION_NOTIFICATION_WEBHOOK_URL)}
MAILER_ADDRESS_KEY:	#{fetch(:MAILER_ADDRESS_KEY)}
MAILER_DOMAIN_KEY:	#{fetch(:MAILER_DOMAIN_KEY)}
MAILER_USERNAME_KEY:	#{fetch(:MAILER_USERNAME_KEY)}
MAILER_PASSWORD_KEY:	#{fetch(:MAILER_PASSWORD_KEY)}
MAILER_ASSET_HOST_KEY:	#{fetch(:MAILER_ASSET_HOST_KEY)}
MAILER_HOST_KEY:	#{fetch(:MAILER_HOST_KEY)}
EOF
  on roles(:app) do
     execute "mkdir -p #{shared_path}"
     upload! StringIO.new(env_config), "#{shared_path}/.env"
    end
  end
end



namespace :config do
task :setup do
vhost_config =<<-EOF
server {
  listen 80;
      client_max_body_size 200M;
      server_name #{fetch(:server_name)};
      keepalive_timeout 5;
      root #{deploy_to}/current/public;
      passenger_enabled on;
      passenger_ruby /home/#{fetch(:deploy_user)}/.rvm/#{fetch(:rvm_ruby_version)}/wrappers/ruby;
      rails_env #{fetch(:rails_env)};
      gzip on;
      location ^~ /assets/ {
        expires max;
        add_header Cache-Control public;
      }

error_page 503 @503;
# Return a 503 error if the maintenance page exists.
if (-f #{deploy_to}shared/public/system/maintenance.html) {
  return 503;
}
location @503 {
  # Serve static assets if found.
  if (-f $request_filename) {
    break;
  }
  # Set root to the shared directory.
  root #{deploy_to}/shared/public;
  rewrite ^(.*)$ /system/maintenance.html break;
}

    }

EOF

  on roles(:app) do
     execute "sudo mkdir -p /etc/nginx/sites-available"
     upload! StringIO.new(vhost_config), "/tmp/vhost_config"
     execute "sudo mv /tmp/vhost_config /etc/nginx/sites-available/#{fetch(:application)}"
     execute "sudo ln -s /etc/nginx/sites-available/#{fetch(:application)} /etc/nginx/sites-enabled/#{fetch(:application)}"
    end
  end
end

