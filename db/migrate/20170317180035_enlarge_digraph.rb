class EnlargeDigraph < ActiveRecord::Migration[5.0]
  def change
    change_column :state_details, :digraph, :text, :limit => 966367641
  end
end
