class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session


  def page_not_found
    e = Error.new(:status => 404, :message => "Wrong URL or HTTP method")    
    render :json => e.to_json, :status => 404
  end
end
