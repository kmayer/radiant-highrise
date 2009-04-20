class AddDefaultConfigs < ActiveRecord::Migration
  
  def self.up
    Radiant::Config['highrise.site_url'] = nil        # https://api.url:3300/
    Radiant::Config['highrise.api_auth_token'] = nil  # "xxyyzzzy"
  end

  def self.down
    Radiant::Config.find_by_key('highrise.site_url').destroy rescue nil
    Radiant::Config.find_by_key('highrise.api_auth_token').destroy rescue nil
  end
  
end
