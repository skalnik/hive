require 'simple-rss'
require 'open-uri'

helpers do
  def fetch_last_fm_tracks
    url = "http://ws.audioscrobbler.com/1.0/user/#{last_fm_username}/recenttracks.rss"
    tracks_feed = SimpleRSS.parse open(url)
    tracks = []
    tracks_feed.items.each do |track|
      next if (Time.now - track.pubDate) < 60 # Skip if 60 seconds haven't elapsed, duplicate killer
      formatted_track = {:content => clean(track.title), :link => track.link, 
                         :published => track.pubDate, :source => 'Last.fm'}
      tracks << formatted_track
    end
    return tracks.reverse
  end

  def clean(string)
    string.gsub('–', '-')
  end
end

get '/fetch_last_fm_tracks' do
  tracks = fetch_last_fm_tracks
  tracks.each do |track|
    unless Entry.count(track) > 0
      entry = Entry.new(track)
      entry.save!
    end
  end
  redirect '/'
end
