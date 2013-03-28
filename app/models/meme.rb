class Meme < ActiveRecord::Base
  include GenerateId
  self.per_page = 6

  belongs_to :user
  belongs_to :image

  after_initialize :default_values

  attr_accessor :image_ref, :background
  attr_accessible :text_upper, :text_lower, :image_ref

  validates :text_upper, presence: true, length: { in: 1..45 }
  validates :text_lower, presence: true, length: { in: 1..45 }
  validates :image_ref, inclusion: { in: Proc.new {Image.all.map{|i| i.id.to_s}}, message: I18n.t('image.not_included') }

  COLORS = ["tomato", "purple", "lime", "blue", "dark orange", "fuchsia", "firebrick", "indigo", "tomato", "teal", "khaki"]

  def save
    if self.image_ref.blank?
      self.errors.add :file, I18n.t('image.errors.invalid_format')
    else
      self.image = Image.find(self.image_ref)
    end
    generate_image if valid?
    super
  end

  def generate_image
    image = Magick::Image.from_blob(self.image.picture).first
    self.background = image.border(100,100, COLORS.sample)

    star = Magick::Draw.new
    star.fill(COLORS.sample)
    star.polygon(0,0, 0,self.background.rows/2, self.background.columns/2,self.background.rows/2, self.background.columns/2,0, self.background.columns,0, self.background.columns/2,self.background.rows/2, self.background.columns,self.background.rows/2, self.background.columns,self.background.rows, self.background.columns/2,self.background.rows/2, self.background.columns/2,self.background.rows, 0,self.background.rows, self.background.columns/2,self.background.rows/2)
    star.draw(self.background)

    embed = Magick::Draw.new
    embed.composite((self.background.columns-image.columns)/2,(self.background.columns-image.columns)/2, 0,0, image)
    embed.draw(self.background)

    upper = Magick::Draw.new
    upper.stroke('#000000')
    upper.fill('#ffffff')
    upper.gravity(Magick::NorthGravity)
    Rails.logger.info "\n\nSIZE U: #{font_size(self.text_upper)}\n"
    upper.pointsize(font_size(self.text_upper))
    upper.stroke_width(stroke_width(self.text_lower))
    upper.stroke('#000000')
    upper.font_weight = Magick::BoldWeight
    upper.font_style  = Magick::NormalStyle
    Rails.logger.info "\n\nU POS: #{upper_text_y_position}\n"
    upper.text(x = 0, y = upper_text_y_position, text = self.text_upper)
    upper.draw(self.background)

    lower = Magick::Draw.new
    lower.stroke('#000000')
    lower.fill('#ffffff')
    lower.gravity(Magick::SouthGravity)
    Rails.logger.info "\n\nSIZE L: #{font_size(self.text_lower)}\n"
    lower.pointsize(font_size(self.text_lower))
    lower.stroke_width(stroke_width(self.text_lower))
    lower.stroke('#000000')
    lower.font_weight = Magick::BoldWeight
    lower.font_style  = Magick::NormalStyle
    Rails.logger.info "\n\nL POS: #{lower_text_y_position}\n"
    lower.text(x = 0, y = lower_text_y_position, text = self.text_lower)
    lower.draw(self.background)

    self.picture = self.background.to_blob
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
    # grubosc paska/2 - wielkosc czcionki/2
    50-font_size(self.text_lower)/2
  end

  def upper_text_y_position
    # grubosc paska/2 - wielkosc czcionki/2
    50-font_size(self.text_upper)/2-5
  end

  def font_size(text)
    size = ((self.background.columns/600.0)*48.0)
    if text.length > 25
      return (size*25.0/text.length).to_i
    else
      return size.to_i
    end
  end

  def stroke_width(text)
    font_size(text) > 50 ? 2 : 1
  end

  def default_values
    self.uid ||= provide_unique_id(:uid)
  end
end