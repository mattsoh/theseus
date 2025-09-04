class AddSlackIdToPublicUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :public_users, :slack_id, :string
  end
end
