class EnlargeStateJson < ActiveRecord::Migration[5.0]
  def change
    change_column :state_details, :state_json, :text, :limit => 1073741824
  end
end
