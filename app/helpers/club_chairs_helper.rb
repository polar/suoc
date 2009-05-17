module ClubChairsHelper
  def show_chair_delete(chair)
    permitted_to? :delete, chair
  end
end