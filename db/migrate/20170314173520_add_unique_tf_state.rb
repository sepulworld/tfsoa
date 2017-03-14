class AddUniqueTfState < ActiveRecord::Migration[5.0]
  def change
    add_column :tfstates, :unique_tf_state, :string
    remove_column :tfstates, :s3_bucket_uri
    remove_column :tfstates, :s3_bucket_key
    remove_column :tfstates, :role_arn
  end
end
