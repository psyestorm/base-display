class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.string :salt
      t.string :token
      t.timestamps
    end
  end
end
