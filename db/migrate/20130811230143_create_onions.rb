class CreateOnions < ActiveRecord::Migration
  def change
    create_table :onions do |t|
      t.string :HashedUser
      t.string :HashedTitle
      t.text :HashedInfo
    end
  end
end
