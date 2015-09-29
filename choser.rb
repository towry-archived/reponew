# (c) 2015 Towry Wang

require 'net/http'
require 'net/https'
require 'optparse'

module Reponew
  class Choser
    def initialize
      url = URI('https://github.com')
      @http = Net::HTTP.new(url.host, url.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def try(name = nil)
      return false unless !name.nil?

      begin
        response = @http.head("/#{name}")

        if response['status'] =~ /200 OK/
          return false
        else
          return true
        end
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse => e 
        return false
      end
    end
  end

  if __FILE__ == $0
    options = {:count => 5, :num => 3}

    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: ruby choser.rb [options]"
      opt.separator ""
      opt.separator "Options"
      opt.on("-c", "--count [COUNT]", "How many names do you want") do |count|
        options[:count] = count.to_i
      end
      opt.on("-n", "--num [NUM]", "How long should the name be, default is 3") do |num|
        options[:num] = num.to_i
      end
    end

    opt_parser.parse!

    choser = Choser.new

    chars = ('a'..'z').to_a
    result = []
    options[:count].times do 
      name = (0...options[:num]).map { chars[rand(26)]}.join
      puts "trying `#{name}`..."
      if choser.try(name)
        result.push name
      end
    end

    puts "--------- Done ---------\n"

    if result.length == 0
      puts "None"
      exit
    end

    puts result
  end
end
