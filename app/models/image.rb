class Image < ActiveRecord::Base
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
      self.errors.add :file, I18n.t('image.errors.invalid_format')
      return false
    end
    super
  end

  private

  def set_picture
    self.picture ||= self.file.tempfile.try(:read) unless self.file.nil?
    raise Magick::ImageMagickError if self.picture.nil?
    image = Magick::Image.from_blob(self.picture).first.resize_to_fit(500,500)
    self.width   = image.inspect.strip.split('=>')[1].split(' ')[0].split('x')[0]
    self.height  = image.inspect.strip.split('=>')[1].split(' ')[0].split('x')[1]
    self.picture = image.to_blob
  end
end