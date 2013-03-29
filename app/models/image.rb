class Image < ActiveRecord::Base
  X_SIZE = 400
  Y_SIZE = 400

  self.per_page = 18
  has_many :memes

  attr_accessor :file
  attr_accessible :name, :description, :file

  validates :name, presence: true
  validates :file, presence: true

  def created_at_human
    self.created_at.strftime("%y-%m-%d %H:%M")
  end

  def save
    begin
      set_picture
    rescue Magick::ImageMagickError
      self.errors.add :image_ref, I18n.t('image.errors.invalid_format')
    end
    super
  end

  private

  def set_picture
    self.picture ||= self.file.tempfile.try(:read) unless self.file.nil?
    raise Magick::ImageMagickError if self.picture.nil?
    image = Magick::Image.from_blob(self.picture).first.resize_to_fit(X_SIZE,Y_SIZE)
    image.format = "JPG"
    self.width   = image.rows
    self.height  = image.columns
    self.picture = image.to_blob
  end
end