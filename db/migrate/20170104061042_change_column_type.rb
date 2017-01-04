class ChangeColumnType < ActiveRecord::Migration[5.0]
  def change
    change_column :state_details, :terraform_version, :decimal
  end
end
