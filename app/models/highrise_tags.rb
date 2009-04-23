module HighriseTags
  include Radiant::Taggable
  include Highrise
  
  class TagError < StandardError; end
  
  tag 'highrise' do |tag|
    tag.expand
  end
  
  desc %{
    Cycles through each of the entries in the Highrise DB. Inside this tag, all  
    attribute tags are mapped to the current entity from Highrise. 
    
    Default object is "Person"
    
    *Usage:*
    <pre><code><r:highrise:each>
    ...
    </r:highrise:each>
    </code></pre>
  }
  tag 'highrise:each' do |tag|
    result = []
    tag_id = tag.attr['tag_id'] rescue nil
    # :all, :params => {:tag_id => '329788'}
    if tag_id 
      options = {:params => {:tag_id => tag_id}}
    else
      options = {}
    end
    
    Highrise::Person.each(options) do |person|
      tag.locals.person = person
      result << tag.expand
    end
    
    result
  end
  
  %w{name title phone fax email highriseid}.each do |method|
    desc %{
      Renders the @#{method} attribute of the current person.
    }
    tag "highrise:each:#{method.to_s}" do |tag|
      tag.locals.person.send(method).to_s
    end
  end
  
  desc %{
    Creates a tag that links back to the HighriseHQ site.
  }
  tag "highrise:link" do |tag|
    %{<a href="#{Radiant::Config['highrise.site_url']}/people/#{tag.attr['id']}">}
  end
end