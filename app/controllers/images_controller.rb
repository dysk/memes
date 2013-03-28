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

  def index
    @images = Image.order('created_at DESC').paginate(page: params[:page])
    @images_groups = @images.in_groups_of(3)
  end

  def new
    authorize! :new, @image, :message => I18n.t('cancan.access_denied')
    @image = Image.new
  end

  def show
    @image = Image.find(params[:id])
    respond_to do |format|
      format.html
      format.jpg {send_data @image.picture, type:'image/jpg', disposition: 'inline'}
    end
  end
end