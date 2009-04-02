class PagePhotosController < ApplicationController

  def create
    @page_photo = PagePhoto.new(params[:page_photo])
    respond_to do |format|
      if @page_photo.save
        flash[:notice] = 'Photo was successfully created.'
        format.html { redirect_to page_photo_url(@page_photo) }
        format.xml  { head :created, :location => page_photo_url(@page_photo) }
        format.js do
          responds_to_parent do
            render :update do |page|
              page.replace_html "page_photo", :partial => 'page_photo', :object => @page_photo
              page.replace_html "page_photo_input",
                    "<input id='page_page_photo_id' name='page[page_photo_id]' type='hidden' value='#{@page_photo.id}'/>"

            end
          end
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page_photo.errors.to_xml }
        format.js do
          responds_to_parent do
            render :update do |page|
                # update the page with an error message
            end
          end
        end
      end
    end
  end

end
