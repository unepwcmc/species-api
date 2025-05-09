class RefreshDownloadsJob < ActiveJob::Base
  queue_as :admin

  def perform(*args)
    Appsignal::CheckIn.cron(self.class.name.underscore) do
      BulkDownloadService.new.refresh_all
    end
  end
end
