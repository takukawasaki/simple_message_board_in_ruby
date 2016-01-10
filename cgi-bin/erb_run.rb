#!/usr/local/bin/ruby

require 'erb'

puts "Content-Type: text/html"
puts
ERB.new(IO.read(ENV['PATH_TRANSLATED'])).run

