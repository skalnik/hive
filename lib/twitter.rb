gem('twitter4r', '0.3.2')
require 'twitter'

helpers do
  def tweets(username)
    client = Twitter::Client.new
    status = client.timeline_for(:user, :id => username)
    tweets = []
    status.each do |tweet|
      twt = {:content => tweet.text, :source => 'Twitter', :published => tweet.created_at,
             :link => "http://twitter.com/#{username}/status/#{tweet.id}"}
      tweets << twt
    end
    return tweets
  end
end

get '/fetch_tweets' do
  tweets = fetch_tweets
  tweets.each do |tweet|
    unless Entry.count(tweet) > 0
      entry = Entry.new(tweet)
      entry.save!
    end
  end
  redirect '/'
end
