class ContentAdminController < ComatoseAdminController
  include TinyMCE
 
  # We use the editor to modify the description field only.
  # This happens in new, create, update, and edit.
  #
  uses_tiny_mce :options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}),
    :only => [:new, :create, :update, :edit]

end
