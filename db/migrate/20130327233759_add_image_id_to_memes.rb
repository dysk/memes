class AddImageIdToMemes < ActiveRecord::Migration
  def change
    add_column :memes, :image_id, :integer, after: :user_id
  end
end
