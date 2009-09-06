require 'highrise'

class HighriseExtension < Radiant::Extension
  version "1.2"
  description "Integration with the Highrise API"
  url "http://github.com/kmayer/radiant-highrise"
  
  def activate
    Page.send :include, HighriseTags
  end
  
  def deactivate
  end
  
end
