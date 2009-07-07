module UsersHelper
  def user_name(user)
    if !user.name.blank?
      h user.name
    elsif current_user == user
      link_to "no name", edit_user_path(user), :title => "Click to edit your name"
    else
      "no name"
    end
  end
end
