class Entry
  include MongoMapper::Document

  key :content, :require => true
  key :published
  timestamps!
end
