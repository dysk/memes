class CreateImages < ActiveRecord::Migration
  def up
    create_table :images do |t|
      t.string :name
      t.text :description
      t.integer :width
      t.integer :height
      t.binary :picture, limit: 10.megabyte

      t.timestamps
    end
  end

  def down
    drop_table :images
  end
end
