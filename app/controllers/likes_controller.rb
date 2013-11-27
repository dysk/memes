class LikesController < ApplicationController
  def create
    meme = Meme.find(params[:id])
    Like.create!(current_user, meme)
    redirect_to :back
  end

  def destroy
    meme = Meme.find(params[:id])
    Like.destroy!(current_user, meme)
    redirect_to :back
  end
end
