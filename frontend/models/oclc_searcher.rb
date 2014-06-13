require 'net/http'
require 'yaml'
require 'rufus/lru'

class OCLCSearchException < StandardError; end

class OCLCSearcher < Struct.new(:base_url, :wskey)

  def self.cache
    @cache ||= Rufus::Lru::Hash.new(10)
  end


  def self.do_get(params, base_url)
    hash = [base_url, params].hash

    unless cache.has_key?(hash)
      uri = URI(base_url)
      uri.query = URI.encode_www_form(params)

      response = Net::HTTP.get_response(uri)

      if response.code != '200'
        raise OCLCSearchException.new("Error during OCLC Catalog search: #{response.body}")
      end

      cache[hash] = response.body.force_encoding('UTF-8')
    end

    cache[hash]
  end


  def get_records(oclcns)
    records = []

    oclcns.each do |oclcn|
      begin
        xml = self.find(oclcn)
        if xml =~ /Record does not exist/
          records << {:oclcn => oclcn, :error => xml}
        else
          records << {:oclcn => oclcn, :xml => xml}
        end
      rescue OCLCSearchException => e
        records << {:oclcn => oclcn, :error => e.message}
      end
    end

    records
  end


  def write_records(ids)

    tempfiles = []

    get_records(ids).each do |record|

      tempfile = ASUtils.tempfile('oclc_import')
      tempfile.write(record[:xml])

      tempfile.flush
      tempfile.rewind

      puts tempfile.path

      tempfiles << tempfile
    end

    tempfiles
  end

  
  # Get a catalog record using an ID
  def find(oclcn)
    oclc_params = {}
    oclc_params[:wskey] = wskey if wskey

    url = "#{base_url}/content/#{oclcn}"

    body = self.class.do_get(oclc_params, url)
  end

end


    
