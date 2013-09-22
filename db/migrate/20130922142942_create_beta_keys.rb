class CreateBetaKeys < ActiveRecord::Migration
  def change
    create_table :beta_keys do |t|
      t.string :Code
      t.boolean :Active

      t.timestamps
    end
  end
end
