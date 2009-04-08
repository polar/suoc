class ChangeUserDefaults < ActiveRecord::Migration
  def self.up
   change_table :users do |t|
     t.change_default :notify_comments, false
     t.change_default :notify_friend_requests, false
     t.change_default :notify_community_news, false
   end
  end

  def self.down
   change_table :users do |t|
     t.change_default :notify_comments, true
     t.change_default :notify_friend_requests, true
     t.change_default :notify_community_news, true
   end
  end
end
