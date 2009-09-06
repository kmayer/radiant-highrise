require File.dirname(__FILE__) + '/../spec_helper'
require 'active_resource/http_mock'

# See the standard_tags_spec.rb for hints on how to write tests

describe "HighriseTags" do
  dataset :pages
  
  before(:each) do
    @page = pages(:assorted)
    Radiant::Config['highrise.site_url'] = "http://example.highrisehq.com"
    Highrise::Base.site = Radiant::Config['highrise.site_url']
  end
  
  describe "<r:highrise>" do
    before(:each) do
      @person = { :id => '1', :first_name => 'John', :last_name => 'Doe', :title => 'Boss', :company_id => '1',
        :contact_data => {
          :email_addresses => [{:address => 'john@example.com', :location => 'Work', :id => '101'}],
          :web_addresses => [{:url => 'http://example.com.i/john', :location => 'Work', :id => '102'}],
          :phone_numbers => [{:number => '(888) 999-1234', :location => 'Work'},
                             {:number => '(800) 555-9876', :location => 'Fax'}]
                          }
                }.to_xml(:root => 'person')
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/people/1.xml", {}, @person
        mock.get "/people/2.xml", {}, { :id => '2' }.to_xml(:root => 'person')
        mock.get "/people/3.xml", {}, { :id => '3', :first_name => 'John' }.to_xml(:root => 'person')
        mock.get "/companies/1.xml", {}, { :id => '1', :name => 'The Company'}.to_xml(:root => 'company')
      end
    end

    it "should render the ID" do
      @page.should render(%{<r:highrise id="1"><r:highrise:id/></r:highrise>}).as '1'
    end

    it "should render a person name" do
      @page.should render(%{<r:highrise id="1"><r:highrise:name/></r:highrise>}).as 'John Doe'
      @page.should render(%{<r:highrise id="2"><r:highrise:name/></r:highrise>}).as ''
      @page.should render(%{<r:highrise id="3"><r:highrise:name/></r:highrise>}).as 'John'
    end
    
    it "should render a title" do
      @page.should render(%{<r:highrise id="1"><r:highrise:title/></r:highrise>}).as 'Boss'
      @page.should render(%{<r:highrise id="2"><r:highrise:title/></r:highrise>}).as ''
    end
    
    it "should render a company name" do
      @page.should render(%{<r:highrise id="1"><r:highrise:company/></r:highrise>}).as 'The Company'
      @page.should render(%{<r:highrise id="2"><r:highrise:company/></r:highrise>}).as ''
    end
    
    it "should render the first work number as a phone number" do
      @page.should render(%{<r:highrise id="1"><r:highrise:phone/></r:highrise>}).as '(888) 999-1234'
      @page.should render(%{<r:highrise id="2"><r:highrise:phone/></r:highrise>}).as ''
    end
    
    it "should render the first fax number as a fax number" do
      @page.should render(%{<r:highrise id="1"><r:highrise:fax/></r:highrise>}).as '(800) 555-9876'
      @page.should render(%{<r:highrise id="2"><r:highrise:fax/></r:highrise>}).as ''
    end
    
    it "should render the first email as an email address" do
      @page.should render(%{<r:highrise id="1"><r:highrise:email/></r:highrise>}).as 'john@example.com'
      @page.should render(%{<r:highrise id="2"><r:highrise:email/></r:highrise>}).as ''
    end
    
    it "should render the first web address as a web address" do
      @page.should render(%{<r:highrise id="1"><r:highrise:web/></r:highrise>}).as 'http://example.com.i/john'
      @page.should render(%{<r:highrise id="2"><r:highrise:web/></r:highrise>}).as ''
    end
    
    it "should render a valid link tag that points back to HighriseHQ" do
      @page.should render(%{<r:highrise id="1"><r:highrise:link/></r:highrise>}).as %{<a href="#{Radiant::Config['highrise.site_url']}/people/1">John Doe</a>}
    end
    
    it "should render a valid link tag with filled text, that points back to HighriseHQ" do
      @page.should render(%{<r:highrise id="1"><r:highrise:link>Person</r:highrise:link></r:highrise>}).as %{<a href="#{Radiant::Config['highrise.site_url']}/people/1">Person</a>}
    end

    it "should render a url tag that points back to HighriseHQ" do
      @page.should render(%{<r:highrise id="1"><r:highrise:url/></r:highrise>}).as %{#{Radiant::Config['highrise.site_url']}/people/1}
    end

    it "should raise an error if the person is not found" do
      response = stub("Response")
      response.stub!(:code).and_return(404)
      id = 'non-existent-id'
      Highrise::Person.should_receive(:find).with(id).
        and_raise(ActiveResource::ResourceNotFound.new(response))
      @page.should render(%{<r:highrise id="#{id}"><r:highrise:name/> </r:highrise>}).
        with_error("Couldn't find Highrise::Person with ID=#{id}")
    end
    
  end
  
  describe "<r:highrise:each>" do
    before(:each) do
      returning @people = [] do
        3.times do |i|
          person = Highrise::Person.new
          person.id = i
          @people << person
        end
      end
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/tags.xml", {}, [{ :id => '1', :name => "tag"}].to_xml(:root => 'tags')
      end
    end
    
    it "should return a list of all contacts" do
      Highrise::Person.should_receive(:find_all_across_pages).and_return(@people)
      @page.should render(%{<r:highrise:each><r:id/> </r:highrise:each>}).as '0 1 2 '
    end
    
    it "should return a subset of contacts, given a tag_id" do
      Highrise::Person.should_receive(:find_all_across_pages).with({:params => {:tag_id => "1"}}).and_return(@people[0..1])
      @page.should render(%{<r:highrise:each tag_id="tag"><r:id/> </r:highrise:each>}).as '0 1 '
    end

    it "should raise an error if the tag_id is not found" do
      response = stub("Response")
      response.stub!(:code).and_return(404)
      id = '999'
      Highrise::Person.should_receive(:find_all_across_pages).with({:params => {:tag_id => "#{id}"}}).
        and_raise(ActiveResource::ResourceNotFound.new(response))
      @page.should render(%{<r:highrise:each tag_id="#{id}"><r:highrise:name/> </r:highrise:each>}).
        with_error("Couldn't find any TAG_ID=#{id}")
    end

    it "should raise an error if the tag_id is not found" do
      id = 'non-existent-id'
      @page.should render(%{<r:highrise:each tag_id="#{id}"><r:highrise:name/> </r:highrise:each>}).
        with_error("Couldn't find any TAG_ID=#{id}")
    end
  end
  
end
