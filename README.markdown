# Highrise API Integration for RadiantCMS

Use typical radiant tags to get people data out of your [Highrise][h] account.

## Prerequisites

This uses my version of the [HighriseAPI][api] gem, hosted at [GitHub][gems], by
adding the following to your environment.rb file:

    config.gem "kmayer-highrise", :version => ">=0.9.2"
    
and then

    rake gem:install
    
and optionally

    rake gem:unpack
    
but you can also install it as a plugin in `RAILS_ROOT/vendor/plugins`:

    git submodule add git://github.com/kmayer/highrise.git vendor/plugins/highrise

## Installation

In your RadiantCMS root,

    script/extension install highrise
    
or via GitHub

    git submodule add git://github.com/kmayer/radiant-highrise.git vendor/exentions/highrise

You need to configure 2 settings (via script/console or the excellent [settings extension][s]):

    Radiant::Config['highrise.site_url']
    Radiant::Config['highrise.api_auth_token']
    
You can find these on the "My info" page of your Highrise account and clicking
on "Reveal authentication token for feeds/API".

## Example

    <r:highrise:each tag_id="1234">
      <r:name/>, <r:title/>
      ph: <r:phone/>, fx: <r:fax/>
      <r:email/>
    <r:highrise:each/>

## Documentation

RTFT (Read The Fine Tests), see the inline tag docs, and here's a quick, but probably incomplete
summary:

    <r:highrise [id="nnn"]> -- finds the person with id= (number)
    <r:highrise:each [tag_id="nnn"]> -- finds people tagged with tag_id= (number)
    
    <r:highrise:name/>
    <r:highrise:title/>
    <r:highrise:phone/>
    <r:highrise:fax/>
    <r:highrise:email/>
    
    <r:highrise:link/> -- creates an A HREF tag back to the Highrise page for this person

## Bugs, Issues, Kudos and Katcalls

[Issue tracker on GitHub][i]

## Author

[Ken Mayer][k]

---
[api]: http://github.com/kmayer/highrise
[gems]: http://gems.github.com/
[h]: http://highrisehq.com
[i]: http://github.com/kmayer/radiant-highrise/issues
[k]: mailto:kmayer@bitwrangler.com
[s]: http://github.com/Squeegy/radiant-settings
