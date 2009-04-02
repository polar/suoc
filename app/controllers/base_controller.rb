class BaseController < ApplicationController

  def site_index
    redirect_to :controller => "page", :action => :show, :id => "about"
  end
end
