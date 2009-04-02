class PageController < BaseController

  def show
  @sidebar_left = true
    @page = ComatosePage.find( :first,
                :include => :page_photo,
                :conditions => { :slug => params[:id] })
    @children = @page.children

    #
    # Stupid shit
    for c in @children do
      if c.page_photo
        c.page_photo = c.page_photo.becomes PagePhoto
      end
    end

    render :layout => "homepage"
  end
end