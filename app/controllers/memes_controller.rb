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
    session[:image_id] = params[:id]
    @image = Image.find(session[:image_id]) unless session[:image_id].nil?
    @meme = Meme.new
  end
  
  def create
    @meme = current_user.memes.build(params[:meme])
    if @meme.save
      session[:image_id] = nil
      redirect_to meme_path(@meme.uid), notice: t('notice.meme.created')
    else
      render :new, alert: t('alert.meme.not_created')
    end
  end

  def destroy
    authorize! :destroy, @meme, :message => I18n.t('cancan.access_denied')
    @meme = Meme.find(params[:id])
    notice = if @meme.destroy
      t('notice.meme.destroyed')
    else
      t('notice.meme.not_destroyed')
    end
    redirect_to memes_path, notice: notice
  end
end