class MemesController < ApplicationController
  before_filter :authenticate_user!, except: ['index', 'show']

  def index
    order = params[:order] == 'likes' ? 'likes_count DESC' : 'created_at DESC'
    memes_scope = Meme.order(order).paginate(page: params[:page]).scoped
    @memes = memes_scope
    @memes_groups = @memes.in_groups_of(3)
  end

  def show
    @meme = Meme.where(uid: params[:id]).first!
    respond_to do |format|
      format.html
      format.jpg {
        if stale?(:last_modified => @meme.updated_at.utc, :etag => @meme)
          expires_in 5.years, :public => true
          send_data @meme.picture, type:'image/jpg', disposition: 'inline'
        end
      }
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