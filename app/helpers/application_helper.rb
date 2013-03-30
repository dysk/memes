# encoding: UTF-8

module ApplicationHelper

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def tp(value)
    "#{t(value)}: "
  end

  def meme_likers(m)
    if current_user
      if current_user.likes_meme?(m)
        link_to('-1', unlike_meme_path(m), method: :delete)
        if m.likes_count == 1
          t('likes.you_like')
        else
          t('likes.you_and_people_likes', count: m.likes_count-1)
        end
      else
        link_to('+1', like_meme_path(m), method: :post)
        likers_if_you_dont(m)
      end
    else
      likers_if_you_dont(m)
    end
  end

  def likers_if_you_dont(m)
    if m.likes_count == 1
      user = m.likers.first
      link_to(user.name, user) + t('likes.likes')
    elsif m.likes_count > 1
      user = m.likers.last
      link_to(user.name, user) + t('likes.and_people_likes', count: m.likes_count-1)
    else
      t('likes.nobody_likes')
    end
  end

  def meme_like_link(m)
    if current_user
      if current_user.likes_meme?(m)
        content_tag(:small, link_to('-1', unlike_meme_path(m), method: :delete, class: 'gray'))
      else
        content_tag(:strong, link_to('+1', like_meme_path(m), method: :post))
      end
    end
  end

  def meme_quote(m)
    "#{m.text_upper} #{m.text_lower}"
  end
end
