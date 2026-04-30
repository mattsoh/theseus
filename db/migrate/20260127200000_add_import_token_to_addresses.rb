class AddImportTokenToAddresses < ActiveRecord::Migration[8.0]
  def change
    add_column :addresses, :import_token, :uuid
    add_index :addresses, :import_token, where: "import_token IS NOT NULL"
  end
end
