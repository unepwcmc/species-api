class CreateApiDistributionsView < ActiveRecord::Migration
  def change
    create_view :api_distributions_view, view_sql('20141209133037', 'api_distributions_view')
  end
end
