class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :subject, polymorphic: true

  default_scope order('created_at ASC')

  def self.create!(user, subject)
    unless user.likes?(subject)
      like = user.likes.build
      like.subject = subject
      like.save
      subject.update_column(:likes_count, subject.likes.count) if subject.respond_to?(:likes_count)
    end
  end

  def self.destroy!(user, subject)
    like = user.likes?(subject)
    like.destroy unless like.nil?
    subject.update_column(:likes_count, subject.likes.count) if subject.respond_to?(:likes_count)
  end
end