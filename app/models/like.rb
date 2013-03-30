class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :subject, polymorphic: true

  default_scope order('created_at ASC')
end