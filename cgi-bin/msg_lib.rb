#!/usr/local/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'csv'
require 'cgi'

CSV_FILE_NAME = 'data.csv'
CSV_USER_NAME = 'user.csv'



MAX_NUM = 500

class DataModel
  attr_accessor :data, :filename
  def initialize(filename)
    @filename = filename
    @data = CSV.read(@filename)
  end

  #save data
  def saveToFile
    csv = CSV.open(@filename, 'w')
    @data.each do |arr|
      csv.add_row(arr)
    end
    csv.close
  end

  # add record
  def addRecord(rec)
    @data.insert(0,rec)
  end

  # delete record
  def delRecord
    n = @data.length
    @data.delete_at(n-1)
  end

  def get(n)
    return @data[n.to_i]
  end

  def findRecord(find,index)
    @data.each do |line|
      if line[index].index(find)
        return line
      end
    end
    return nil
  end
end


class ViewData
  attr_reader :model
  COL_TIME = 0 
  COL_NAME = 1
  COL_TITLE = 2
  COL_ABST  = 3 
  COL_CONTENT = 4

  CONT_FUNC = 'javascript:showContent'

  def initialize(m)
    @model = m
  end

  def printTable
    re = '<table border="1" width="600">'
    re += '<tr><th>title</th><th>short</th><th>sender</th><th>date</th></tr>'

    n = 0
    @model.data.each do |arr|
      re += '<tr>'
      re += '<td><a href="' + CONT_FUNC + '(' +
            n.to_s + ');">' + arr[COL_TITLE].to_s + '</a></td>'
      re += '<td>' + arr[COL_ABST].to_s + '</td>'
      re += '<td>' + arr[COL_NAME].to_s + '</td>'
      re += '<td>' + getFormattedTime(
              arr[COL_TIME] ) + '</td>'
      re += '</tr>'
      n += 1
    end

    re += '</table>'
    return re
  end

  def printData(n)
    arr = @model.get(n.to_i)
    re = '<h3>' + arr[COL_TITLE] + '</h3>'
    re += '<h4>' + arr[COL_ABST] + '</h4>'
    re += '<p>' + arr[COL_CONTENT] + '</p>'
    re += '<p>' +arr[COL_NAME] + " : " +
          getFormattedTime(arr[COL_TIME]) + '</p>'
    re += '<br><br><a href="msgboard.html.erb">back</a>'
    
  end

  def getFormattedTime(n)
    t = Time.at(n.to_i)
    return t.strftime('%Y-%m-%d %H:%M:%S')
  end
end

class DataController
  attr_reader :model, :view, :cgi, :result
  attr_accessor :mode, :sel_record

  MODE_LIST = 'list'
  MODE_CONT = 'content'
  MODE_ADD = 'add'

  def initialize
    @model = DataModel.new(CSV_FILE_NAME)
    @view = ViewData.new(@model)
    @result = ""
    @cgi = CGI.new
    @mode = CGI.escapeHTML(@cgi['mode'])
    @sel_record = CGI.escapeHTML(@cgi['sel'])
    self.controll
  end

  def controll
    case @mode
    when ''
      @result = dolist
    when MODE_LIST
      @result = dolist
    when MODE_CONT
      @result = doContent
    when MODE_ADD
      doAdd
      @result = dolist
    end
  end

  def dolist
    @view.printTable
  end

  def doContent
    @view.printData(@sel_record)
  end

  def doAdd
    time = Time.new.to_i
    name = CGI.escapeHTML(@cgi['name'])
    pass = CGI.escapeHTML(@cgi['pass'])
    title = CGI.escapeHTML(@cgi['title'])
    abst = CGI.escapeHTML(@cgi['abst'])
    content = CGI.escapeHTML(@cgi['content'])
    content = content.gsub(/[\r\n]+/, "<br>")

    user = DataModel.new(CSV_USER_NAME)
    find = user.findRecord(name,ViewUser::COL_ID)

    if (find[ViewUser::COL_PASS] == pass)
      arr = [time, name, title,abst,content]
      @model.addRecord(arr)
      if @model.data.length > MAX_NUM
        @model.delRecord
      end
      @model.saveToFile
    end
  end
end


#=> User view

class ViewUser
  attr_reader :model

  COL_ID = 0
  COL_PASS = 1

  def initialize(m)
    @model = m
  end

  def printTable
    re = '<table border="1" width="400">'
    re += '<tr><th>ID</th><th>PASSWORD</th></tr>'
    n = 0
    @model.data.each do |arr|
      re += '<tr>'
      re += '<td>' + arr[COL_ID].to_s + '</td>'
      re += '<td>' + arr[COL_PASS].to_s + '</td>'
      re += '<tr>'
      n += 1
    end
    re += '</table>'
    return re
  end
end

class UserController
  attr_reader :model , :view, :cgi, :result, :mode
  attr_accessor :mode

  MODE_LIST = 'list'
  MODE_ADD = 'add'

  def initialize()
    @model = DataModel.new(CSV_USER_NAME)
    @view = ViewUser.new(@model)
    @cgi = CGI.new
    @mode = CGI.escapeHTML(@cgi['mode'])
    controll
  end

  def controll
    case @mode
    when ''
      dolist
    when MODE_ADD
      doAdd
      dolist
    end
  end

  def dolist
    @result = @view.printTable
  end

  def doAdd
    id = CGI.escapeHTML(@cgi['id'])
    pass = CGI.escapeHTML(@cgi['pass'])
    arr = [id,pass]
    @model.addRecord(arr)
    @model.saveToFile
  end
  
end

