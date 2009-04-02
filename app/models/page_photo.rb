class PagePhoto < ActiveRecord::Base
  has_attachment prepare_options_for_attachment_fu(AppConfig.page_photo['attachment_fu_options'])

  validates_as_attachment
end
