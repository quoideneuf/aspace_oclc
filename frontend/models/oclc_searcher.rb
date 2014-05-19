require 'net/http'
require 'yaml'
require 'rufus/lru'

class OCLCSearchException < StandardError; end

class OCLCSearcher < Struct.new(:base_url, :wskey)

  def self.cache
    @cache ||= Rufus::Lru::Hash.new(10)
  end


  def self.do_get(params, base_url)
    hash = params.hash

    unless cache.has_key?(hash)
      uri = URI(base_url)
      uri.query = URI.encode_www_form(params)

      response = Net::HTTP.get_response(uri)

      if response.code != '200'
        raise OCLCSearchException.new("Error during OCLC Catalog search: #{response.body}")
      end

      cache[hash] = response.body
    end

    cache[hash]
  end


  def search(query, start = 1)
    body = get_search_results(query, start)
    OCLCSearchResults.new(query, body)
  end


  private

  def get_search_results(query, start)
    oclc_params = {
      :q => query,
      :start => start.to_s,
    }
    oclc_params[:wskey] = wskey if wskey

    body = self.class.do_get(oclc_params, base_url)
  end
end


    
