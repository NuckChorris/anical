require 'json'
require 'digest/md5'
require 'open-uri'
require 'nokogiri'

class AnimeCalendar
  attr_reader :episodes, :shows
  def timer (name)
    if @verbose
      $stderr.print "%-8s  " % (name + ":")
      before = Time.now
      yield
      $stderr.print "%#.4fs\n" % (Time.now - before)
    else
      yield
    end
  end
  def initialize (date, verbose)
    @verbose = verbose
    @src = ""
    @doc = nil
    @shows = {}
    @episodes = []

    timer "Load" do
      @src = open("http://www.animecalendar.net/%4d/%d" % [date.year, date.month])
    end
    timer "Parse" do
      @doc = Nokogiri::HTML(@src)
    end
    timer "Process" do
      @doc.css('#calendarContent .day').each do |day|
        date = day.at_css('th a')['href']

        day.css('.tooltip').each do |ep|
          title = ep.css('.tooltip_title h4').text.strip
          desc = ep.css('.tooltip_desc').text.strip
          info = ep.css('.tooltip_info').text.strip
          info = /Ep:\s+(?<no>\d+)\s+at\s+(?<time>\d+:\d+)\s+on\s+(?<station>.*)/.match(info)
          airtime = Time.strptime("#{date} #{info[:time]}+09:00", '/%Y/%m/%d %H:%M%z').utc

          @shows[title] = show = if @shows.has_key? title
            then @shows[title]
            else AnimeCalendar::Show.new(title, desc)
            end

          @episodes << AnimeCalendar::Episode.new(show, info[:no], airtime, info[:station])
        end
      end
    end
    def to_json (*opts)
      {
        :episodes => @episodes,
        :shows => @shows
      }.to_json(*opts)
    end
  end
  class Episode
    attr_reader :show, :number, :airtime, :station
    def initialize (show, number, airtime, station)
      @number = number
      @airtime = airtime
      @station = station
      @show = show

      show.add_episode self
    end
    def uid
      Digest::MD5.hexdigest("#{@show.title}-#{@number}-#{@station}".upcase).upcase
    end
    def to_h
      {
        :number => @number,
        :airtime => @airtime,
        :station => @station,
        :show => @show.title
      }
    end
    def to_json (*opts)
      self.to_h.to_json(*opts)
    end
  end
  class Show
    attr_reader :title, :description, :episodes
    def initialize (title, description)
      @title = title
      @description = description
    end
    def add_episode (episode)
      @episodes = [] if @episodes.nil?
      @episodes << episode
    end
    def to_h
      {
        :title => @title,
        :description => @description
      }
    end
    def to_json (*opts)
      self.to_h.to_json(*opts)
    end
  end
end
