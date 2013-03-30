class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :subject, polymorphic: true

  default_scope order('created_at ASC')

  def self.create!(user, params)
    meme = Meme.find(params[:id])
    unless user.likes_meme?(meme)
      like = user.likes.build
      like.subject = meme
      like.save
      meme.update_column(:likes, meme.likes.count)
    end
  end

  def self.destroy!(user, params)
    meme = Meme.find(params[:id])
    like = user.likes_meme?(meme)
    like.destroy unless like.nil?
    meme.update_column(:likes, meme.likes.count)
  end
end