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
  helper BaseHelper

  #
  # In the base system we include authenticated system. We just require
  # admin privileges for all methods
  #
#  before_filter :admin_required
end
