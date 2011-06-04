class Bot
  attr_accessor :state
  attr_accessor :irc_socket
  attr_accessor :irc_port
  attr_accessor :irc_server
  attr_accessor :nick
  attr_accessor :mcp

  def initialize(main_ref)
    self.mcp = main_ref
    self.state = :up
    self.irc_server = "127.0.0.1" #"irc.freenode.net" #"irc.lfnet.org"
    self.irc_port = "6667"
    self.nick = (0..6).collect { ((48..57).to_a + (65..90).to_a + (97..122).to_a)[Kernel.rand(58)].chr }.join

    connect_to_irc

    log_output

    sleep 5
    puts "#{self.nick} waiting to rock it"
    sleep 5

    begin
      work
    rescue Interrupt
    rescue Exception => detail
      puts detail.message()
      print detail.backtrace.join("\n")
    retry
    end

    puts "killing bot"
  end

  def log_output
    thread = Thread.new do

      puts 'logging'

      while line = self.irc_socket.gets

        look_for_ops(line)

        puts line

      end

    end

  end

  def look_for_ops(line)

    matches = line.match(/MODE\s(.*)\s\+k/)
    if !matches.nil? then
      room = Room.first(:name => matches[1])
      room.ops = true
      room.save

      # remove lock
      self.mcp.rooms.delete(room.name)

      puts "got ops on #{matches[1]}"
    end

    matches = line.match(/(#.*)\s:You're not channel operator/)
    if !matches.nil? then
      puts "leaving #{matches[1]} for now"
      part(matches[1])
    end

  end

  def connect_to_irc
    self.irc_socket = TCPSocket.open(self.irc_server, self.irc_port)
    self.irc_socket.puts "USER #{nick} 0 * #{nick}"
    self.irc_socket.puts "NICK #{nick}"
    #self.irc_socket.puts "PRIVMSG #{nick}"
  end
 
  def close_irc
    self.irc_socket.puts "QUIT"
  end

  def send_to_irc(msg, chan)
    self.irc_socket.puts "PRIVMSG #{chan} :#{msg}"
  end

  def fuck_the(chan)
    puts "setting the modes on #{chan.name}"

    self.irc_socket.puts "MODE #{chan.name} +s"
    self.irc_socket.puts "MODE #{chan.name} +p"
    self.irc_socket.puts "MODE #{chan.name} +k blah"

    chan.tries += 1
    chan.save
  end

  def join_the(chan)
    puts "joining #{chan.name}"
    self.irc_socket.puts "JOIN #{chan.name}"
  end

  def setup_pinger
    th = Thread.new do
      loop do
        ping
        sleep(120)
      end
    end
  end

  def work
    setup_pinger

    while self.state.eql? :up

      room = Room.first(:ops => false, :order => [:tries.asc])

      if room.nil? then
        puts "killed them all"
        self.stop_time = Time.now.to_i
        puts "Took: #{(self.stop_time - self.start_time)} seconds"
        exit
      end

      chk_room(room)

      sleep(5)
    end
  end

  def chk_room(room)

    if !self.mcp.rooms.include?(room.name) then
      self.mcp.rooms.push(room.name)

      join_the(room)
      sleep(5)
      fuck_the(room)
    end

  end

  def part(room)
    self.irc_socket.puts "PART #{room}"
  end

  def ping
    self.irc_socket.puts "PING #{self.nick}"
  end

end
