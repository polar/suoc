class PageController < BaseController

  def show
  @sidebar_left = true
    @page = ComatosePage.find( :first,
                :include => :page_photo,
                :conditions => { :slug => params[:id] })
    @children = @page.children

    # If there are no children, then we make the navigation
    # column contain the children of the root. If there are
    # no children of the root, we don't care.
    if @children.empty?
      p = ComatosePage.find(:first,
                :include => :page_photo,
                :conditions => { :slug => "about" })
      @children = p.children
    end
    # Stupid shit
    for c in @children do
      if c.page_photo
        c.page_photo = c.page_photo.becomes PagePhoto
      end
    end

    render :layout => "homepage"
  end
end