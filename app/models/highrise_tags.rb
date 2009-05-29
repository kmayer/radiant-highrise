require 'highrise'

module HighriseTags
  include Radiant::Taggable
  include Highrise
  
  Highrise::Person.class_eval do
    class << self
      def lookup(id, list, item, location)
        module_eval <<-EOT
          def #{id}
            contact_data.#{list}.each do |i|
              return i.#{item}.strip if i.location == "#{location}"
            end
            ''
          end
        EOT
      end
      
      private :lookup
    end
    
    lookup(:phone, 'phone_numbers',   'number',  'Work')
    lookup(:fax,   'phone_numbers',   'number',  'Fax')
    lookup(:email, 'email_addresses', 'address', 'Work')
  end
  
  class TagError < StandardError; end
  
  desc %{
    Inside this tag, all attribute tags are mapped to the current entity from Highrise. 
        
    *Usage:*
    <pre><code><r:highrise [id="nnnnn"]>...</r:highrise></code></pre>
  }
  tag 'highrise' do |tag|
    id = tag.attr['id'] rescue nil
    if id
      begin
        tag.locals.person = Highrise::Person.find(id)
      rescue ActiveResource::ResourceNotFound => e
        if e.to_s =~ /Failed with 404/
          raise TagError.new("Couldn't find Highrise::Person with ID=#{id}")
        else
          raise TagError.new(e.to_s)
        end
      end
    end
    tag.expand
  end
  
  %w{name title phone fax email id}.each do |method|
    desc %{
      Renders the @#{method} attribute of the current person.
      
      *Usage:*
      <pre><code><r:highrise:#{method}/></code></pre>
    }
    tag "highrise:#{method.to_s}" do |tag|
      begin
        tag.locals.person.send(method).to_s
      rescue NameError  # None available
        ''
      end
    end
  end
  
  desc %{
    Renders the @company name attribute of the current person

    *Usage:*
    <pre><code><r:highrise:company/></code></pre>
  }
  tag 'highrise:company' do |tag|
    begin
      tag.locals.person.company.name
    rescue NameError # N/A
      ''
    end
  end

  desc %{
    Renders a url to HighriseHQ site.
    
    *Usage:*
    <pre><code><a href="<r:highrise:url/>"><r:highrise:name/></a></code></pre>
  }
  tag "highrise:url" do |tag|
    highrise_url(tag)
  end

  
  desc %{
    Creates a tag that links back to the HighriseHQ site.
    
    A self-closed tag (e.g. <code><r:highrise:link/></code> will render the person's name as the anchor text. 

    *Usage:*
    <pre><code><r:highrise:link>Highrise...</r:highrise:link></code></pre>
  }
  tag "highrise:link" do |tag|
    text = tag.double? ? tag.expand : tag.locals.person.name    
    %{<a href="#{highrise_url(tag)}">#{text}</a>}
  end

  desc %{
    Cycles through each of the entries in the Highrise DB. Inside this tag, all attribute tags are mapped to the current entity from Highrise. 
    
    *Usage:*
    <pre><code><r:highrise:each [tag_id="_highrise-tag_"]>...</r:highrise:each></code></pre>
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
    
    begin
      Highrise::Person.find_all_across_pages(options).each do |person|
        tag.locals.person = person
        result << tag.expand
      end
    rescue  ActiveResource::ResourceNotFound => e
      if e.to_s =~ /Failed with 404/
        raise TagError.new("Couldn't find any TAG_ID=#{tag_id}")
      else
        raise TagError.new(e.to_s)
      end
    end
    result
  end
  
  private
  
  def highrise_url(tag)
    %{#{Radiant::Config['highrise.site_url']}/people/#{tag.locals.person.id}}
  end
end