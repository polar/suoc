# The controller for serving cms content...
class ComatoseAdminController < ApplicationController
  include BaseModule
  helper BaseHelper

  before_filter :admin_required
end