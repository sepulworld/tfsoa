class AddHashToDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :state_details, :sha, :string
    
    StateDetail.all.each do |record|
      sha = Digest::SHA1.hexdigest(record.state_json.to_json)
      record.update_attribute(:sha, sha)
    end
  end
end
