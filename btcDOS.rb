require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-aggregates'
require 'dm-migrations'

$KCODE = 'UTF8' unless RUBY_VERSION >= '1.9'

require 'db-config.rb'

Dir.glob('models/**/*.rb').each do |f|
  require f
end

require "socket"
require 'thread'

class BtcDOS
  attr_accessor :start_time
  attr_accessor :stop_time

  def initialize
    self.start_time = Time.now.to_i

    # initialize rooms
    Room.all.destroy!
    channel_list.each do |chan|
      room = Room.new
      room.name = chan
      room.save
    end

    bots = []

    10.times.each do |i|
      bots << Thread.new(i) do |ni|
        bot = Bot.new
      end
    end

    bots.each { |bot| bot.join }

  end

  def fake_channel_list
    ["#assmunch00", "#assmunch01", "#assmunch02"]
  end

  def channel_list
    (00..99).collect { |i| if i < 10 then "#bitcoin0#{i}" else "#bitcoin#{i}" end }
  end

end

btc = BtcDOS.new
