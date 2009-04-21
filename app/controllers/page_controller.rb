class PageController < BaseController

  def show
    @sidebar_left = true
    @page = ComatosePage.find( :first,
                :include => :page_photo,
                :conditions => { :slug => params[:id] })
    @children = @page.children if @page

    # TODO: Will have to change slug.
    @home = ComatosePage.find(:first,
                :include => :page_photo,
                :conditions => { :slug => "about" })

    # If there are no children, then we make the navigation
    # column contain the children of the parent. If we are
    # at the root, we are just home.
    if @children.empty?
      p = @page.parent ? @page.parent : @home
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