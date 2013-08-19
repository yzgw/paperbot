# coding: utf-8
require 'json'
require 'twitter'

class Paperbot
  MAX_TWEET_LENGTH = 140
  
  def initialize(json_filepath)
    @papers = open(json_filepath) { |io| JSON.load(io)["papers"] }
  end
  
  def get_reference()
    reference = while(true)
      p = @papers[rand(@papers.length)]
      t = generate_tweet(p)
      if t.length > MAX_TWEET_LENGTH
        puts "discard " + t.length.to_s + " >> " + t
        next
      else
        break t
      end
    end
    reference
  end
  
  def generate_tweet(paper)
    front = "[" + paper["year"].to_s + "] " + paper["title"] + ". "
    tail = " " + "http://dl.acm.org/citation.cfm?id=" + paper["id"].to_s

    authors = paper["authors"].map { |a| abbreviate_author_name(a) }
    middle = authors.join(", ")

    restSpace = MAX_TWEET_LENGTH - front.length - tail.length
    
    if restSpace < middle.length
      if(authors.length != 1)
        middle = authors[0] + " et al."
      else
        middle = authors[0]
      end
      
      if restSpace < middle.length
        front = front[0, MAX_TWEET_LENGTH - middle.length - tail.length - 4] + "... "
        front + middle + tail 
      end
    end 
    front + middle + tail  
  end

  def abbreviate_author_name(name)
    name.gsub(/(?<=^|;\s)([A-Z])\S+/, '\1.')
  end
end

if ARGV.length == 1 then
  paperbot = Paperbot.new(ARGV[0])
  p paperbot.get_reference  
end
