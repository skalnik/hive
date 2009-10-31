get '/fetch_all' do
  last_fm = fetch_last_fm_tracks
  github = fetch_github_activity
  twitter = fetch_tweets
  all = last_fm + github + twitter
  all.each do |new_entry|
    unless Entry.count(new_entry) > 0
      entry = Entry.new(new_entry)
      entry.save!
    end
  end
  redirect '/'
end
