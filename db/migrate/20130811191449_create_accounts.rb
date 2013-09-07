class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :HashedUser
      t.string :HashedPass
      t.string :Salt
    end
  end
end
