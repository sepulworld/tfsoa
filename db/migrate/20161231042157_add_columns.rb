class AddColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :tfstates, :terraform_version, :decimal
    add_column :tfstates, :state_version, :integer
  end
end
