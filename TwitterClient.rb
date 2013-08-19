# coding: utf-8
require 'twitter'
require 'json'

class TwitterClient
  def initialize(configuration_filepath)
    conf = JSON.load( open(configuration_filepath) )
    
    Twitter.configure do |config|
      config.consumer_key = conf["twitter"]["consumer_key"]
      config.consumer_secret = conf["twitter"]["consumer_secret"]
      config.oauth_token = conf["twitter"]["oauth_token"]
      config.oauth_token_secret = conf["twitter"]["oauth_token_secret"]
    end
  end
  
  def tweet(message)
    Twitter.update(message)
  end
end

if ARGV.length == 2 then
  client = TwitterClient.new(ARGV[0])
  client.tweet(ARGV[1])
end
