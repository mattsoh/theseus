class AddMapOptoutToPublicUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :public_users, :opted_out_of_map, :boolean, default: false
  end
end
