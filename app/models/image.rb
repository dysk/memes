class Image < ActiveRecord::Base
  has_many :memes

  attr_accessor :file
  attr_accessible :name, :description, :file

  validates :name, presence: true
  validates :file, presence: true

  before_save :set_picture

  def created_at_human
    self.created_at.strftime("%y-%m-%d %H:%M")
  end

  def save
    begin
      set_picture
    rescue Magick::ImageMagickError
      self.errors.add :file, I18n.t('image.errors.invalid_format')
      return false
    end
    super
  end

  private

  def set_picture
    self.picture ||= self.file.tempfile.try(:read) unless self.file.nil?
    raise Magick::ImageMagickError if self.picture.nil?
    image_data     = Magick::Image.from_blob(self.picture).first.inspect
    self.width   ||= image_data.strip.split[1].split('x')[0]
    self.height  ||= image_data.strip.split[1].split('x')[1]
  end
end