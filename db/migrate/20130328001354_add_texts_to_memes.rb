class AddTextsToMemes < ActiveRecord::Migration
  def change
    add_column :memes, :text_lower, :string, after: :uid
    add_column :memes, :text_upper, :string, after: :uid
  end
end
