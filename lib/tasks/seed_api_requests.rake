namespace :db do
  desc "Seeds 30 days worth of fake api requests for the last 5 users,"
  task :seed_api_requests => :environment do
    puts "Clearing all existing api requests..."
    ApiRequest.delete_all

    User.last(5).each do |user|
      for n in (29).downto(0)
        rand(1..8).times do
          ApiRequest.create(
            user_id: user.id, 
            response_status: [200, 200, 200, 500].sample,
            created_at: DateTime.now - n+1,
            controller: ['api/v1/taxon_concepts', 'api/v1/taxon_concepts/1/common_names', 'api/v1/taxon_concepts/1/distributions', 'api/v1/taxon_concepts/1/eu_legislation'].sample
          )
        end
      end
    end

    puts "Done!"
  end
end