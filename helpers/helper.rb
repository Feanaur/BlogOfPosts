module Helper

  def pretty_date(time)
    time.strftime("%d %b %Y")
  end

  def post_show_page?
    request.path_info =~ /\/posts\/\d+$/
  end

  def is_user_logged_on?
    session[:user]!=nil
  end

  def is_belong_to_user?(entity)
    entity.user_id==session[:user].id
  end
  
end