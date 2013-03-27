class CreateMemes < ActiveRecord::Migration
  def up
    create_table :memes do |t|
      t.integer :user_id
      t.string :uid
      t.binary :picture, limit: 10.megabyte

      t.timestamps
    end

    add_index :memes, :uid, unique: true
  end

  def down
    drop_table :memes
  end
end
