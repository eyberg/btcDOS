class Room
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String
  property :chankey,    String
  property :tries,      Integer, :default => 0
  property :ops,        Boolean, :default => false
  property :created_at, DateTime, :default => lambda { DateTime.now }
  property :updated_at, DateTime, :default => lambda { DateTime.now }

end
