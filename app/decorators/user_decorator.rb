class UserDecorator < Draper::Decorator
  delegate_all

  def full_name
    [ object.first_name, object.last_name ].join(" ")
  end

  def joined_on(format: :long)
    I18n.l(object.created_at, format: format)
  end

  def avatar_status_class
    object.online? ? "avatar-online" : "avatar-offline"
  end

  def avatar_html(size:)
    image = "avatar.png"
    h.content_tag :div, class: "avatar #{avatar_status_class}" do
      h.content_tag :div, class: "rounded-full flex items-center justify-center", style: "width: #{size}px; height: #{size}px;" do
       h.image_tag(image, alt: "#{object.first_name} #{object.last_name}")
      end
    end
  end

  def confirmation_badge
    if object.confirmed_at.present?
      h.content_tag(:div, "Confirmed", class: "badge badge-soft badge-success")
    else
      h.content_tag(:div, "Unconfirmed", class: "badge badge-soft badge-warning")
    end
  end
end
