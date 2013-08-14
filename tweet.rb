# coding: utf-8
require 'json'
require 'twitter'
require 'bitly'

Twitter.configure do |config|
  config.consumer_key = "Xg0YSw4CQQEzaoycsGcCcQ"
  config.consumer_secret = "30fR6AT7pKAr5PdTMb0CEbFgImLHrSTlghazTZBlKf0"
  config.oauth_token = "825378776-kwdAbnCReyNb9mee8K12bvHv0q2M9KHAJq5ir8ot"
  config.oauth_token_secret = "421zTqMZW8dLxl6e9h9cqNek6z9VKnThOqR6Jjmw"
end

Bitly.configure do |config|
  config.api_version = 3
  config.login = "o_87cnn7ama"
  config.api_key = "R_77f261eda736eb0d9be6be72d7fd8a9c"
end

def main
  json_path = ARGV[0]
  papers = open(json_path) { |io| JSON.load(io)["papers"] }

  reference = while(true)
    p = papers[rand(papers.length)]
    t = generate_tweet(p)
    if t.length > MAX_TWEET_LENGTH
      puts "discard " + t.length.to_s + " >> " + t
      next
    else
      break t
    end
  end
  
  p reference.length.to_s + " >> " + reference
  tweet(reference)  
end

MAX_TWEET_LENGTH = 140
def generate_tweet(paper)
  front = "[" + paper["year"].to_s + "] " + paper["title"] + ". "
  tail = " " + shorten_URL("http://dl.acm.org/citation.cfm?id=" + paper["id"].to_s)

  authors = paper["authors"].map { |a| abbreviate_author_name(a) }
  restSpace = MAX_TWEET_LENGTH - front.length - tail.length
  authorSpace = authors.inject(0) { |sum, a| sum + a.length }

  middle = authors.join(", ")

  if restSpace < authorSpace
    if(authors.length != 1)
      middle = authors[0] + " et al."
    else
      middle = authors[0]
    end
    
    if restSpace > middle.length
      middle = authors[0]
    end
  end 
  
  front + middle + tail 
end

def abbreviate_author_name(name)
  name.gsub(/(?<=^|;\s)([A-Z])\S+/, '\1.')
end

def tweet(message)  
  Twitter.update(message)
end

def shorten_URL(url)  
  client = Bitly.client
  client.shorten(url).short_url
end

main
