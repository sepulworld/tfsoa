class Addteam < ActiveRecord::Migration[5.0]
  def change
    add_column :tfstates, :team, :string
    Tfstate.all.each do |record|
      team = record.unique_tf_state.split('-').first
      record.update_attribute(:team, team)
    end
  end
end
