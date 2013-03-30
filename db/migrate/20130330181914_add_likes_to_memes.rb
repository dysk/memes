class AddLikesToMemes < ActiveRecord::Migration
  def change
    add_column :memes, :likes, :integer, after: :text_lower, default: 0
    add_index :memes, :likes
  end
end
