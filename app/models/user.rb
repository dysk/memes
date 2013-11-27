class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids, :active, :as => :admin
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  has_many :memes
  has_many :likes

  def memes_count
    self.memes.count
  end

  def likes?(subject)
    self.likes.where(subject_type: subject.class.name).where(subject_id: subject.id).first
  end

  def active_for_authentication?
    super && self.active
  end

  def inactive_message
    I18n.t('devise.failure.inactive')
  end
end
