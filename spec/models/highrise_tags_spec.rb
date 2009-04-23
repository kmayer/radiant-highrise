require File.dirname(__FILE__) + '/../spec_helper'

# See the standard_tags_spec.rb for hints on how to write tests

describe "HighriseTags" do
  before(:all) do
    Radiant::Config['highrise.site_url'] = 'http://example.highrisehq.com'
    Radiant::Config['highrise.api_auth_token'] = 'xxxyyzzy'
  end
  
  before(:each) do
    # TODO Use fakeweb to intercept calls to Net::HTTP
  end
  
  it "should require a valid configuration"
  
  it "should raise an error if the site is unreachable"
    
  describe "<r:highrise>" do
    it "should return contact info for the person with the matching id"
  end
  
  describe "<r:highrise:each>" do
    it "should return a list all contacts"
    
    it "should return a subset of contacts, given a tag_id"
    
    it "should render a person name"
    
    it "should render a title"
    
    it "should render the first work number as a phone number"
    
    it "should render the first fax number as a fax number"
    
    it "should render the first email as an email address"
    
    it "should render the HighriseHQ ID"
  end
  
  describe "<r:highrise:link>" do
    it "should render a valid link tag that points back to HighriseHQ"
  end
  
  
private

  def page(symbol = nil)
    if symbol.nil?
      @page ||= pages(:assorted)
    else
      @page = pages(symbol)
    end
  end
end
