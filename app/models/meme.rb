class Meme < ActiveRecord::Base
  include GenerateId
  self.per_page = 6

  belongs_to :user
  belongs_to :image

  after_initialize :default_values

  attr_accessor :image_ref
  attr_accessible :text_upper, :text_lower, :image_ref

  validates :text_upper, presence: true, length: { in: 1..30 }
  validates :text_lower, presence: true, length: { in: 1..30 }
  validates :image_ref, inclusion: { in: Proc.new {Image.all.map{|i| i.id.to_s}}, message: I18n.t('image.not_included') }


  def save
    self.image = Image.find(self.image_ref)
    generate_image if valid?
    super
  end

  def generate_image
    image = Magick::Image.from_blob(self.image.picture).first

    upper = Magick::Draw.new
    upper.stroke('#000000')
    upper.fill('#ffffff')
    Rails.logger.info "\n\nSIZE: #{font_size}\n"
    upper.pointsize(font_size)
    upper.stroke_width(stroke_width)
    upper.stroke('#000000')
    upper.font_weight = Magick::BoldWeight
    upper.font_style  = Magick::NormalStyle
    upper.text(x = upper_text_x_position, y = upper_text_y_position, text = self.text_upper)
    upper.draw(image)

    lower = Magick::Draw.new
    lower.stroke('#000000')
    lower.fill('#ffffff')
    lower.pointsize(font_size)
    lower.stroke_width(stroke_width)
    lower.stroke('#000000')
    lower.font_weight = Magick::BoldWeight
    lower.font_style  = Magick::NormalStyle
    lower.text(x = lower_text_x_position, y = lower_text_y_position, text = self.text_lower)
    lower.draw(image)
    self.picture = image.to_blob
  end

  def created_at_human
    self.created_at.strftime("%y-%m-%d %H:%M")
  end

  def user_name
    return self.user.name if self.user
    I18n.t('unavailable')
  end

  def user_id
    return self.user.id if self.user
    0
  end

  private

  def lower_text_y_position
    (self.image.height*0.95).to_i
  end

  def upper_text_y_position
    (self.image.height*0.08).to_i+(font_size/10.0).to_i
  end

  def lower_text_x_position
    center_text_position(self.text_lower)
  end

  def upper_text_x_position
    center_text_position(self.text_upper)
  end

  def center_text_position(text)
    ((3.03*(33-text.length)/200)*self.image.width).to_i
  end

  def font_size
    Rails.logger.info "\n\nFONT SIZE: #{((self.image.width/600.0)*38.0).to_i}\n"
    ((self.image.width/600.0)*38.0).to_i
  end

  def stroke_width
    Rails.logger.info "\n\nSTROKE SIZE: #{font_size > 30 ? 2 : 1}\n"
    font_size > 30 ? 2 : 1
  end

  def default_values
    self.uid ||= provide_unique_id(:uid)
  end
end