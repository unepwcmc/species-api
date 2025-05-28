attributes :id, :filters, :format, :started_at, :success_message

node(:download_url) do |row|
  if row.download.attached?
    row.download.url expires_in: 1.hour
  end
end
