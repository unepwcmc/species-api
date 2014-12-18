class UpdateApiDistributionsView < ActiveRecord::Migration
  def change
    drop_view :api_distributions_view, if_exists: true
    create_view :api_distributions_view, view_sql('20141215114029', 'api_distributions_view')
  end
end
