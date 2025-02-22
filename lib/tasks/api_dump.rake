require './lib/modules/BulkDownloads.rb'

namespace :api do
  desc "Writes dump files of all taxons in CITES and CMS"
  task :dump => :environment do
    BulkDownloads.new.generate_all_files do |results|
      puts({
        lang: results[:lang],
        taxonomy: results[:taxonomy],
        filename: results[:filename],
        stats: results[:stats]
      }.to_json)
    end

    puts "Done!"
  end
end