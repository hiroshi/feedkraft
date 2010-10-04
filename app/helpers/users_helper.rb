module UsersHelper
  def user_name(user)
    "@" + user.identifier
  end
end
