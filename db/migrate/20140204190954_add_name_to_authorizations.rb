class AddNameToAuthorizations < ActiveRecord::Migration
  def change
    add_column :authorizations, :name, :string
  end
end
