# http://pivotallabs.com/rails-and-sql-views-part-2-migrations/
ActiveRecord::Migration.class_eval do
  def view_sql(timestamp,view)
    File.read(Rails.root.join("db/views/#{view}/#{timestamp}.sql"))
  end
end
