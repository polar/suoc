class ClubDocumentsController < BaseController
  layout "club_operations"

  filter_access_to :all

  def index
    @files = []
    Dir.foreach(RAILS_ROOT+"/public/admin") do |d|
      puts d  if !(d =~/^\./)
      if !(d =~/^\./) && d =~/.*\.html$/
        @files << { :url => url_for ("admin/"+d), :name => d}
        puts @files
      end
    end
  end
end
