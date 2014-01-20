class CreateComputers < ActiveRecord::Migration
  def change
    create_table :computers do |t|
      t.string :name
      t.string :computer_id
      t.string :token
      t.references :player

      t.timestamps
    end
    add_index :computers, :player_id
  end
end
