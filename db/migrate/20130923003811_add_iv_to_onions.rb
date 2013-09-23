class AddIvToOnions < ActiveRecord::Migration
  def change
    add_column :onions, :Title_Iv, :string
    add_column :onions, :Info_Iv, :string
    add_column :onions, :Title_AuthTag, :string
    add_column :onions, :Info_AuthTag, :string
  end
end
