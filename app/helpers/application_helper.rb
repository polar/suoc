# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  #
  # We have a special error message that just puts the
  # error message for the field. We expect each message
  # to be a full sentence.
  #
  def error_messages(object)
    return '' if object.errors.empty?
    content_tag('div',
     content_tag('ul', object.errors.collect {|attr_name, msg|
       content_tag('li', msg)}),
      { :class => 'errorExplanation' })
  end


end
