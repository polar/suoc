# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include BaseHelper

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

  #
  # This function formats the club member id.
  #
  def fmt_memberid(member)
    if member.club_memberid && member.club_memberid.length > 5
      member.club_memberid.insert(5,"-")
    end
  end

  #
  # Format the date.
  # TODO: Configure for European Dates.
  def fmt_date(date)
    if (date)
      date.strftime("%m-%d-%Y")
    end
  end
end
