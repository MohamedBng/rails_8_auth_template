class UserDecorator < Draper::Decorator
  delegate_all

  def full_name
    [ object.first_name.capitalize, object.last_name.capitalize ].join(" ")
  end

  def joined_on(format: :long)
    I18n.l(object.created_at, format: format)
  end

  def confirmation_badge
    if object.confirmed_at.present?
      h.content_tag(:div, "Confirmed", class: "badge badge-soft badge-success")
    else
      h.content_tag(:div, "Unconfirmed", class: "badge badge-soft badge-warning")
    end
  end
end
