class EnlargeStateJson < ActiveRecord::Migration[5.0]
  def change
    change_column :state_details, :state_json, :text, :limit => 4294967295
  end
end
