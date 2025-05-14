class RoleDecorator < Draper::Decorator
  delegate_all

  def badge
    bg_color = object.color.presence || "#6c757d" # Default to neutral grey
    text_color = h.ideal_text_color(bg_color)

    h.content_tag :span, class: "badge badge-soft", style: "background-color: #{bg_color}; color: #{text_color};" do
      object.name.titleize
    end
  end

  def name
    object.name.titleize
  end
end
