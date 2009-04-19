#
# This is the controller for using Comatose to handle the
# home pages.
#
class ComatoseAdminController < ApplicationController
  #
  # We cannot directly inherit from the CommunityEngine's BaseController
  # because that's a superclass type mismatch. So, we created a
  # BaseModule that contains the pertinent methods of the CommunityEngine.
  include AuthenticatedSystem
  include BaseModule
  helper "base"

  #
  # In the base system we include authenticated system. We just require
  # admin privileges for all methods
  #
  before_filter :login_required
  filter_access_to :all
  filter_access_to [:reorder, :versions, :set_version,
                    :preview, :expire_page_cache,
                    :generate_page_cache,
                    :export,
                    :import], :require => :update

  #
  # This function gets called if the filter functions deny access.
  #
  def permission_denied
    render :partial => "shared/permission_denied",
           :layout => "comatose_admin",
           :status => :forbidden
  end
end
