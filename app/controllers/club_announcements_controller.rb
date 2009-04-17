class ClubAnnouncementsController < BaseController
  filter_access_to :all
  filter_access_to [:announcement_table, :announcements_csv, :announcement_template], :require => :read

  layout "club_operations"

  def index
    @club_announcements = ClubAnnouncement.find(:all)
    if @club_announcements
      begin
        @last_update = @club_announcements.reduce(Time.now){ |a,b| a < b.updated_at ? b.update_at : a }
      rescue
        # Ruby 1.8.6 doesn't have [].reduce
        result = Time.now
        @club_announcements.reverse_each { |elem| result = result < elem.updated_at ? elem.updated_at : result }
        @last_update = result
      end
    else
      @last_update = "There are no announcements listed."
    end
    @view_modify = permitted_to? :update, :club_announcements
  end

  def show
    @club_announcement = ClubAnnouncement.find(params[:id])
  end

  def new
    @club_announcement = ClubAnnouncement.new
  end

  def edit
    @club_announcement = ClubAnnouncement.find(params[:id])
  end

  def create
    ClubAnnouncement.delete_all
    ClubAnnouncement.read(params[:club_announcements][:uploaded_data])
    redirect_to(:action => :index)
  end

  def update
    @club_announcement = ClubAnnouncement.find(params[:id])

    if @club_announcement.update_attributes(params[:club_announcement])
      flash[:notice] = 'ClubAnnouncement was successfully updated.'
      redirect_to(@club_announcement)
    else
      render :action => "edit"
    end
  end

  def announcement_table
    render :partial => "announcement_table", :locals => { :club_announcements => ClubAnnouncement.all }
  end

  def announcements_csv
    # Convert CSV to a string, it seems to be automatic in some systems.
    # Some it screws up on the size as its the number of rows instead
    # of characters.
    data = ClubAnnouncement.to_csv.to_s
    send_data(data, :type => "text/csv", :filename => "announcements.csv")
  end

  def announcement_template
    send_file(RAILS_ROOT+"/public/assets/Announcements.xls", :filename => "ANNOUNCEMENT.XLS", :type => "application/xls")
  end

  def destroy
    @club_announcement = ClubAnnouncement.find(params[:id])
    @club_announcement.destroy

    redirect_to(club_announcements_url)
  end
end
