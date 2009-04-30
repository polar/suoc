class RechangeNotificationDefaults < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
	t.change_default :notify_comments, true
        t.change_default :notify_friend_requests, true
    end
  end

  def self.down
    change_table :users do |t|
	t.change_default :notify_comments, false
        t.change_default :notify_friend_requests, false
    end
  end
end
