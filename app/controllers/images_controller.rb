class ImagesController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]

  def create
    authorize! :create, @image, :message => I18n.t('cancan.access_denied')
    @image = Image.new(params[:image])
    if @image.save
      redirect_to image_path(@image), notice: t('notice.image.created')
    else
      render :new, alert: t('alert.image.not_created')
    end
  end

  def destroy
    authorize! :destroy, @image, :message => I18n.t('cancan.access_denied')
    @image = Image.find(params[:id])
    notice = if @image.destroy
      t('notice.image.destroyed')
    else
      t('notice.image.not_destroyed')
    end
    redirect_to images_path, notice: notice
  end

  def index
    @images = Image.order('name ASC').paginate(page: params[:page])
    @images_groups = @images.in_groups_of(6)
  end

  def new
    authorize! :new, @image, :message => I18n.t('cancan.access_denied')
    @image = Image.new
  end

  def show
    @image = Image.find(params[:id])
    if stale?(:last_modified => @image.updated_at.utc, :etag => @image)
      respond_to do |format|
        format.html {expires_in 10.minutes}
        format.jpg {
          expires_in 5.years
          send_data @image.picture, type:'image/jpg', disposition: 'inline'
        }
      end
    end
  end 
end