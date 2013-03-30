class CreateLikes < ActiveRecord::Migration
  def up
    create_table :likes do |t|
      t.integer :user_id
      t.integer :subject_id
      t.string :subject_type

      t.timestamps
    end

    add_index :likes, :user_id
    add_index :likes, [:subject_type, :subject_id]
  end

  def down
    drop_table :likes
  end
end
