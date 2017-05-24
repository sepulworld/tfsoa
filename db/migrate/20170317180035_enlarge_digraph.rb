class EnlargeDigraph < ActiveRecord::Migration[5.0]
  def change
    change_column :state_details, :digraph, :text, :limit => 1073741824
  end
end
