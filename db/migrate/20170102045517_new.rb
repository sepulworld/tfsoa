class New < ActiveRecord::Migration[5.0]
  def change
    create_table :tfstates do |t|
      t.string :s3_bucket_uri
      t.string :s3_bucket_key
      t.string :role_arn
      t.timestamps
    end
    create_table :statedetails do |t|
      t.belongs_to :tfstate, index: true
      t.integer :terraform_version
      t.text :state_json
      t.integer :json_version
      t.integer :serial
      t.timestamps
    end
  end
end
