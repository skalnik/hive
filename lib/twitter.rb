require 'twitter'

helpers do
  def fetch_tweets
    status = Twitter.timeline(twitter_username)
    tweets = []
    status.each do |tweet|
      twt = {:content => tweet.text, :source => 'Twitter', :published => tweet.created_at,
             :link => "http://twitter.com/#{twitter_username}/status/#{tweet.id}"}
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
