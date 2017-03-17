class EnlargeDigraph < ActiveRecord::Migration[5.0]
  def change
    change_column :state_details, :digraph, :text, :limit => 4294967295
  end
end
