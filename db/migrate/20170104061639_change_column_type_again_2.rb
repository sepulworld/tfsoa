class ChangeColumnTypeAgain2 < ActiveRecord::Migration[5.0]
  def change
    change_column :state_details, :terraform_version, :string
  end
end
