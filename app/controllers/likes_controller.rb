class LikesController < ApplicationController
  before_filter :authenticate_user!

  def create
    Like.create!(current_user, params)
    redirect_to :back
  end

  def destroy
    Like.destroy!(current_user, params)
    redirect_to :back
  end
end
