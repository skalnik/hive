require 'simple-rss'
require 'open-uri'

helpers do
  def fetch_github_activity
    url = "http://github.com/#{github_username}.atom"
    activity_feed = SimpleRSS.parse open(url)
    activity = []
    activity_feed.items.each do |act|
      formatted_act = {:title => act.title, :content => unescape(act.content), :link => act.link,
                       :source => 'Github', :published => act.published}
      activity << formatted_act
    end
    return activity.reverse
  end
  
  def unescape(string)
    return_string = string.gsub('&lt;', '<')
    return_string.gsub!('&gt;', '>')
    return_string.gsub!('&quot;', '"')
    return return_string
  end
end

get '/fetch_github_activity' do
  activity = fetch_github_activity
  activity.each do |act|
    unless Entry.count(act) > 0
      entry = Entry.new(act)
      entry.save!
    end
  end
  redirect '/'
end
