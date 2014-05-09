module Stackoverflow
  require 'cgi'

  def self.interpret(command)
    responses = []

    return responses if !require File.expand_path("../../config.rb", __FILE__) || ApiConfig::GOOGLE_SEARCH_API_KEY.nil? || ApiConfig::GOOGLE_SEARCH_API_KEY == ""

    google_results = get_remote_json("https://www.googleapis.com/customsearch/v1?cx=012211726421152102993%3Autn0onfqvdc&key=#{ApiConfig::GOOGLE_SEARCH_API_KEY}", {:q => command})['items']
    
    stackoverflow_answers = google_results.select{ |result| result['link'].start_with?("http://stackoverflow.com/questions")}

    return responses if Array(stackoverflow_answers).length == 0

    links_array = stackoverflow_answers[0]['link'].split('/')
    id = links_array[links_array.index('questions')+1].to_i
    
    return responses if id == 0

    stackoverflow_result = get_remote_json("https://api.stackexchange.com/2.2/questions/#{id}?order=desc&sort=votes&site=stackoverflow&filter=!ay7uLWNahtxLpA")

      responses << {
        :command => "open #{stackoverflow_result['items'][0]['link']}",
        :explanation => handle_stackoverflow_data(stackoverflow_result['items'][0]), 
        :no_name => true,
        :already_executed => true,
        :processor => :stackoverflow_code_highlight
      }

    responses
  end

  private

  def self.handle_stackoverflow_data(data)
    "-----------------------\n"+
    "Stackoverflow question:\n"+ 
    "-----------------------\n\n"+
    data['title'].bold +
    "\n\n"+
    CGI.unescapeHTML(data['body_markdown'])+
    "\n\n"+
    "------------\n"+
    "Best Answer:\n"+
    "------------\n\n"+
    CGI.unescapeHTML(data['answers'][0]['body_markdown'])
  end

  def self.get_remote_json(url, params={})
    require 'uri'
    require 'net/http'
    require "json"
    uri = URI(url)
    if !params.empty?
      if uri.query.nil? || uri.query == ""
        uri.query = URI.encode_www_form(params)
      else
        uri.query += "&"+URI.encode_www_form(params)
      end
    end

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    res = http.request(Net::HTTP::Get.new(uri.request_uri))

    case res
      when Net::HTTPSuccess then  
        begin
          if res.header[ 'Content-Encoding' ].eql?('gzip') then
            # puts "Performing gzip decompression for response body." if debug_mode
            sio = StringIO.new(res.body)
            gz = Zlib::GzipReader.new(sio)
            content = gz.read()
            # puts "Finished decompressing gzipped response body." if debug_mode
          else
            # puts "Page is not compressed. Using text response body. " if debug_mode
            content = res.body
          end
        rescue Exception
          puts "Error occurred (#{$!.message})"
          # handle errors
          raise $!.message
        end
    end

    return JSON.parse(content)
  end

end

$web_executors << Stackoverflow
