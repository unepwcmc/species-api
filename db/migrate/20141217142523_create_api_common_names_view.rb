class CreateApiCommonNamesView < ActiveRecord::Migration
  def change
    create_view :api_common_names_view, view_sql('20141217142523', 'api_common_names_view')
  end
end
