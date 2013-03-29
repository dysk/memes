class Meme < ActiveRecord::Base
  BORDER_X_SIZE = 100
  BORDER_Y_SIZE = 100
  X_SIZE = 600
  Y_SIZE = 600
  FONT_BASE_SIZE = 48
  MAX_NORMAL_TEXT_LENGTH = 20

  MEMES_DIR = 'public/memes'

  include GenerateId
  self.per_page = 8

  belongs_to :user
  belongs_to :image

  after_initialize :default_values

  attr_accessor :image_ref, :background
  attr_accessible :text_upper, :text_lower, :image_ref

  validates :text_upper, presence: true, length: { in: 1..35 }
  validates :text_lower, presence: true, length: { in: 1..35 }
  validates :image_ref, inclusion: { in: Proc.new {Image.all.map{|i| i.id.to_s}}, message: I18n.t('image.not_included') }

  COLORS = ["aqua", "blue", "blue violet", "brown", "crimson", "dark blue", "dark green", "dark orange", "dark red", "firebrick", "fuchsia", "indigo", "khaki", "lime", "olive", "orange red", "purple", "sea green", "sky blue", "steel blue", "turquoise", "teal", "tomato", "yellow green"]

  def save
    if self.image_ref.blank?
      self.errors.add :file, I18n.t('image.errors.invalid_format')
    else
      self.image = Image.find(self.image_ref)
    end
    generate_meme if valid?
    super
  end

  def destroy
    FileUtils.rm("#{MEMES_DIR}/#{self.uid}.jpg")
    super
  end

  def generate_meme
    image = Magick::Image.from_blob(self.image.picture).first
    self.background = image.border(BORDER_X_SIZE,BORDER_Y_SIZE, COLORS.sample)

    draw_star
    insert_picture(image)
    insert_texts

    write_to_file
    store_in_db
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

  def draw_star
    star = Magick::Draw.new
    star.fill(COLORS.sample)
    star.polygon(0,0, 0,self.background.rows/2, self.background.columns/2,self.background.rows/2, self.background.columns/2,0, self.background.columns,0, self.background.columns/2,self.background.rows/2, self.background.columns,self.background.rows/2, self.background.columns,self.background.rows, self.background.columns/2,self.background.rows/2, self.background.columns/2,self.background.rows, 0,self.background.rows, self.background.columns/2,self.background.rows/2)
    star.draw(self.background)
  end

  def insert_picture(image)
    embed = Magick::Draw.new
    embed.composite((self.background.columns-image.columns)/2,(self.background.columns-image.columns)/2, 0,0, image)
    embed.draw(self.background)
  end

  def insert_texts
    insert_upper_text
    insert_lower_text
  end

  def insert_upper_text
    upper = Magick::Draw.new
    upper.stroke('#000000')
    upper.fill('#ffffff')
    upper.gravity(Magick::NorthGravity)
    #Rails.logger.info "\n\nSIZE U: #{font_size(self.text_upper)}\n"
    upper.pointsize(font_size(self.text_upper))
    upper.stroke_width(stroke_width(self.text_lower))
    upper.stroke('#000000')
    upper.font_weight = Magick::BoldWeight
    upper.font_style  = Magick::NormalStyle
    #Rails.logger.info "\n\nU POS: #{upper_text_y_position}\n"
    upper.text(x = 0, y = upper_text_y_position, text = self.text_upper)
    upper.draw(self.background)
  end

  def insert_lower_text
    lower = Magick::Draw.new
    lower.stroke('#000000')
    lower.fill('#ffffff')
    lower.gravity(Magick::SouthGravity)
    #Rails.logger.info "\n\nSIZE L: #{font_size(self.text_lower)}\n"
    lower.pointsize(font_size(self.text_lower))
    lower.stroke_width(stroke_width(self.text_lower))
    lower.stroke('#000000')
    lower.font_weight = Magick::BoldWeight
    lower.font_style  = Magick::NormalStyle
    #Rails.logger.info "\n\nL POS: #{lower_text_y_position}\n"
    lower.text(x = 0, y = lower_text_y_position, text = self.text_lower)
    lower.draw(self.background)
  end

  def lower_text_y_position
    # grubosc paska/2 - wielkosc czcionki/2
    BORDER_Y_SIZE/2-font_size(self.text_lower)/2
  end

  def upper_text_y_position
    # grubosc paska/2 - wielkosc czcionki/2
    BORDER_Y_SIZE/2-font_size(self.text_upper)/2-5
  end

  def font_size(text)
    size = ((self.background.columns/Y_SIZE.to_f)*FONT_BASE_SIZE)
    if text.length > MAX_NORMAL_TEXT_LENGTH
      return (size*MAX_NORMAL_TEXT_LENGTH/text.length.to_f).to_i
    else
      return size.to_i
    end
  end

  def stroke_width(text)
    font_size(text) > FONT_BASE_SIZE+2 ? 2 : 1
  end

  def write_to_file
    self.background.write("#{MEMES_DIR}/#{self.uid}.jpg")
  end

  def store_in_db
    self.picture = self.background.to_blob
  end

  def default_values
    self.uid ||= provide_unique_id(:uid)
  end
end