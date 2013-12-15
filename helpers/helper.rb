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
    entity.user==session[:user]
  end

  def post_preview(post)
    preview = ""
    unless post==nil
      i=0
      until i>100 && post.body[i-1] == "."
        if i<post.body.length
          preview += post.body[i]
          i+=1
        else
          preview
          break
        end
      end
    end
    preview
  end
  
end