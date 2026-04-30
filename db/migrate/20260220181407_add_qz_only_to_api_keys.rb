class AddQZOnlyToAPIKeys < ActiveRecord::Migration[8.0]
  def change
    add_column :api_keys, :qz_only, :boolean
  end
end
