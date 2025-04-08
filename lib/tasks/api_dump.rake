require './lib/modules/BulkDownloads.rb'

namespace :api do
  desc "Writes dump files of all taxons in CITES, uploads them to S3"
  task :dump => :environment do
    BulkDownloads.new.refresh_all

    puts "Done!"
  end
end