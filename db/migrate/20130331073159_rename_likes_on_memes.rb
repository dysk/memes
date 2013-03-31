class RenameLikesOnMemes < ActiveRecord::Migration
  def up
    rename_column :memes, :likes, :likes_count
  end

  def down
    rename_column :memes, :likes_count, :likes
  end
end
