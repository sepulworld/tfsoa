class CreateTfstates < ActiveRecord::Migration[5.0]
  def change
    create_table :tfstates do |t|
      t.string :s3_bucket_uri
      t.string :s3_bucket_key
      t.string :role_arn
      t.text   :state_json
      t.timestamps
    end
  end
end
