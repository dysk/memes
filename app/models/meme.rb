class Meme < ActiveRecord::Base
  include GenerateId
  self.per_page = 6

  belongs_to :user

  after_initialize :default_values

  attr_accessor :text_upper, :text_lower
  attr_accessible :text_upper, :text_lower

  validates :text_upper, presence: true #{ if: Proc.new {|meme| meme.text_lower.blank?} }
  validates :text_lower, presence: true #{ if: Proc.new {|meme| meme.text_upper.blank?} }

  def save
    generate_image if valid?
    super
  end

  def generate_image
    image = Magick::Image.read("#{::Rails.root.to_s}/public/images/kalis.jpg").first
    upper = Magick::Draw.new
    upper.stroke('#000000')
    upper.fill('#ffffff')
    upper.pointsize('36')
    upper.stroke_width(1)
    upper.stroke('#000000')
    upper.font_weight = Magick::BoldWeight
    upper.font_style  = Magick::NormalStyle
    upper.text(x = 100, y = 50, text = self.text_upper)
    upper.draw(image)

    lower = Magick::Draw.new
    lower.stroke('#000000')
    lower.fill('#ffffff')
    lower.pointsize('36')
    lower.stroke_width(1)
    lower.stroke('#000000')
    lower.font_weight = Magick::BoldWeight
    lower.font_style  = Magick::NormalStyle
    lower.text(x = 100, y = 300, text = self.text_lower)
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

  def default_values
    self.uid ||= provide_unique_id(:uid)
  end
end