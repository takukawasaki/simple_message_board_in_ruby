#!/usr/local/bin/ruby -Ku

require 'cgi'
require 'cgi/session'

ADMIN_ID = 'admin'
ADMIN_PASS = 'pass'

cgi = CGI.new

session = CGI::Session.new(cgi, {'new_session' => true})
id = CGI.escapeHTML(cgi['id'])
pass = CGI.escapeHTML(cgi['pass'])


if id == ADMIN_ID && pass == ADMIN_PASS
  begin
    session['id'] = id
    id = session.session_id
    c = CGI::Cookie.new({'name' => '_session_id',
                        'value' => id,
                        'path' => '/ruby/'})

    cgi.out({'cookie' => c,
             'location' => '../ruby/admin.html.erb'}){''}
    
  rescue
    cgi.out({'location' => '../ruby/msgboard_login.html.erb'}){''}
  end
else
  cgi.out({'location' => '../ruby/msgboard_login.html.erb'}){''}
  
end

