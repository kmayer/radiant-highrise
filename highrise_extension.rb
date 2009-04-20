# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class HighriseExtension < Radiant::Extension
  version "1.0"
  description "Integration to Highrise API"
  url "http://github.com/kmayer"
  
  # define_routes do |map|
  #   map.connect 'admin/highrise/:action', :controller => 'admin/highrise'
  # end
  
  def activate
    # admin.tabs.add "Highrise", "/admin/highrise", :after => "Layouts", :visibility => [:all]
    Page.send :include, HighriseTags
  end
  
  def deactivate
    # admin.tabs.remove "Highrise"
  end
  
end
