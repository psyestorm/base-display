class CreatePeripherals < ActiveRecord::Migration
  def change
    create_table :peripherals do |t|
      t.string :description
      t.string :peripheral_type
      t.string :side
      t.references :computer

      t.timestamps
    end
    add_index :peripherals, :computer_id
  end
end
