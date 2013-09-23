class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :Code
      t.string :Email
      t.boolean :Active

      t.timestamps
    end
  end
end
