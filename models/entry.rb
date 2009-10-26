class Entry
  include MongoMapper::Document

  key :content, :require => true
  timestamps!
end
