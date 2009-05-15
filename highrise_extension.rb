# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'
require 'highrise'

class HighriseExtension < Radiant::Extension
  version "1.1"
  description "Integration with Highrise API"
  url "http://github.com/kmayer/radiant-highrise"
  
  # define_routes do |map|
  #   map.connect 'admin/highrise/:action', :controller => 'admin/highrise'
  # end
  
  def activate
    # admin.tabs.add "Highrise", "/admin/highrise", :after => "Layouts", :visibility => [:all]
    Highrise::Base.site = Radiant::Config['highrise.site_url']
    if Highrise::Base.respond_to? :user
      Highrise::Base.user = Radiant::Config['highrise.api_auth_token']
    else 
      Highrise::Base.site = Radiant::Config['highrise.site_url'].gsub('://',"://#{Radiant::Config['highrise.api_auth_token']}@")
    end
    Highrise::Base.connection.cache_store = ActiveSupport::Cache.lookup_store
    Page.send :include, HighriseTags
  end
  
  def deactivate
    # admin.tabs.remove "Highrise"
  end
  
end
