class LikesController < ApplicationController
  before_filter :authenticate_user!

  def create
    meme = Meme.find(params[:id])
    unless current_user.likes_meme?(meme)
      like = current_user.likes.build
      like.subject = meme
      like.save
      meme.update_column(:likes, meme.likes.count)
    end
    redirect_to :back
  end

  def destroy
    meme = Meme.find(params[:id])
    like = current_user.likes_meme?(meme)
    like.destroy unless like.nil?
    meme.update_column(:likes, meme.likes.count)
    redirect_to :back
  end
end
