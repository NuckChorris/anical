start = Time.now
require 'rubygems'
require 'bundler/setup'

require 'date'
require 'json'
require 'optparse'
require 'erb'
require './lib/animecalendar.rb'

options = {
  :json => false,
  :ical => true,
  :quiet => false,
  :output => $stdout
}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: ruby anical.rb [OPTIONS]"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-j", "--json", "Generate JSON") do |environment|
    options[:json] = true
  end

  opt.on("--ical", "Generate ical (default: enabled)") do
    options[:ical] = true
  end

  opt.on("-q", "--quiet", "Hides output") do
    options[:quiet] = true
  end

  opt.on("-o", "--output FILE", "Output to a file (default: stdout)") do |output|
    options[:output] = File.new(output, "w+")
  end
end

opt_parser.parse!

calendar = AnimeCalendar.new(Date.today, !options[:quiet])
episodes = calendar.episodes
shows = calendar.shows

calendar.timer "Render" do
  if options[:json]
    options[:output].print calendar.to_json
  elsif options[:ical]
    template = ERB.new(File.new("icalendar.erb").read, nil, "%<>")
    
    def time_to_ical (time)
      time.strftime("%Y%m%dT%H%M%SZ")
    end
    def wrap (str, left_margin)
      str.scan(/.{1,#{70 - left_margin}}/).join("\r\n" + (" "))
    end
    def escape (str)
      str.gsub(',', '\\,').gsub(';', '\\;')
    end

    options[:output].print(template.result(binding))
  end
end

options[:output].close()

$stderr.puts "Total:    (%#.4fs)" % (Time.now - start)
