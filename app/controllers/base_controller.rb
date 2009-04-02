class BaseController < ApplicationController

  helper "base"

  def site_index
    redirect_to :controller => "page", :action => :show, :id => "about"
  end
end
