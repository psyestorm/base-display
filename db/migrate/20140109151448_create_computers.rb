class CreateComputers < ActiveRecord::Migration
  def change
    create_table :computers do |t|
      t.string :name
      t.string :computer_uuid
      t.string :shared_secret

      t.timestamps
    end
  end
end
