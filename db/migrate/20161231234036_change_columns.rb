class ChangeColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :tfstates, :serial, :integer
    add_column :tfstates, :json_version, :integer
    remove_column :tfstates, :state_version
  end
end
