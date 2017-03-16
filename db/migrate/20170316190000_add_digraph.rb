class AddDigraph < ActiveRecord::Migration[5.0]
  def change
    add_column :state_details, :digraph, :text
  end
end
