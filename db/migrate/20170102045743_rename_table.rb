class RenameTable < ActiveRecord::Migration[5.0]
  def change
    rename_table :statedetails, :state_details
  end
end
