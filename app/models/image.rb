class Image < ActiveRecord::Base
  attr_accessor :file
  attr_accessible :name, :description, :file

  validates :name, presence: true
  validates :file, presence: true

  before_save :set_picture

  def created_at_human
    self.created_at.strftime("%y-%m-%d %H:%M")
  end

  private

  def set_picture
    self.picture ||= self.file.tempfile.read
    image_data     = Magick::Image.from_blob(self.picture).first.inspect
    self.width   ||= image_data.strip.split[1].split('x')[0]
    self.height  ||= image_data.strip.split[1].split('x')[1]
    rescue Magick::ImageMagickError
      self.errors.add :file, I18n.t('image.errors.invalid_format')
  end
end