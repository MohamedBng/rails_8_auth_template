class UserDecorator < Draper::Decorator
  delegate_all

  def full_name
    [object.first_name, object.last_name].join(' ')
  end

  def joined_on(format: :long)
    I18n.l(object.created_at, format: format)
  end
end
