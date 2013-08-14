# -*- encoding: utf-8 -*-
require 'nokogiri'
require "open-uri"
require 'cgi'
require "json"

class Paper
  def initialize(conference_id, id, title, authors, year)
    @conference_id = conference_id
    @id = id
    @title = title
    @authors = authors
    @year = year
  end
  attr_accessor :conference_id, :id, :title, :authors, :year
  
  def to_hash
    {
      "conference_id" => @conference_id,
      "id" => @id,
      "title" => @title,
      "authors" => @authors,
      "year" => @year
    }
  end
end

class Conferences
  def initialize(id, year)
    @id = id
    @year = year
  end
  attr_accessor :id, :year
end

def main
  papers = Array.new
  
  while line = STDIN.gets do
    args = line.split
    conference = Conferences.new(args[0], args[1])
    papers += getPapers(conference)
  end
  
  jsons = { "papers" => papers.map{|p| p.to_hash} }.to_json
  
  open("output.json", "w") do |f|
    f.write(jsons)
  end
end

def getPapers(conference)
  url = "http://dl.acm.org/tab_about.cfm?id=" + conference.id.to_s + "&type=proceeding&parent_id=" + conference.id.to_s
  puts url
  charset = nil
  html = open(url) do |f|
    charset = f.charset
    f.read
  end
  
  # puts html
  
  doc = Nokogiri::HTML.parse(html, nil, charset)
  papers = scrapConferencePage(conference, doc)
  
  papers
end

def scrapConferencePage(conference, doc)
  papers = Array.new
  trs = doc.xpath("//tr")
  puts trs.length
  e = 0
  i = 1
  while(i < trs.length) do
    if !trs[i].xpath(".//td[@colspan='1']").empty? 
      puts e.to_s + " >> " + i.to_s
      block = trs.slice(e, i-e-1)
      title = block.xpath(".//td[@colspan='1']").text
      if(title != "")
        url  = block.xpath(".//td[@colspan='1']/span/a").attribute("href").text
        querys = CGI::parse(URI.parse(url).query)        

        id = querys["id"][0].to_i
        authors = block.xpath(".//td")[3].text.split(",").map{ |a| a.strip }

        papers.push(Paper.new(conference.id, id, title, authors, conference.year))
      end
      e = i
    end
    i += 1
  end
  papers
end


main
