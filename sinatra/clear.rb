require 'sinatra/base'
 
module Sinatra
  
  module Clear

    def pretty_date(time)
     time.strftime("%d %b %Y")
    end

    def post_show_page?
      request.path_info =~ /\/posts\/\d+$/
    end

  end
 
  helpers Clear
end