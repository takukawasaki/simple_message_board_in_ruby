# simple_message_board_in_ruby
add to httpd.conf
<Directory "/some/<yourname>/path/ruby">
AddType application/x-httpd-eruby .html .erb
Action application/x-httpd-eruby /cgi-bin/erb_run.rb
</Directory>