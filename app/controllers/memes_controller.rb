class MemesController < ApplicationController
  before_filter :authenticate_user!, except: ['index', 'show']

  def index
    @memes = Meme.order('created_at DESC').paginate(page: params[:page])
    @memes_groups = @memes.in_groups_of(3)
  end

  def show
    @meme = Meme.where(uid: params[:id]).first!
    respond_to do |format|
      format.html
      format.jpg {send_data @meme.picture, type:'image/jpg', disposition: 'inline'}
    end
  end

  def new
    @meme = Meme.new
  end
  
  def create
    @meme = current_user.memes.build(params[:meme])
    #@meme = Meme.new(params[:meme])
    if @meme.save
      redirect_to meme_path(@meme.uid), notice: t('notice.meme.created')
    else
      redirect_to memes_path, alert: t('alert.meme.not_created')
    end
  end
end