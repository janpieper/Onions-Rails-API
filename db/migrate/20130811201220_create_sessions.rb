class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :Key
      t.string :HashedUser

      t.timestamps
    end
  end
end
