require 'net/http'
require 'oclc/auth'

class OCLCBibGetter < Struct.new(:base_url, :key, :secret)


  def get(id)
    @wskey ||= OCLC::Auth::WSKey.new(key, secret)

    url = "#{base_url}/#{id}?classificationScheme=LibraryOfCongress&holdingLibraryCode=MAIN"
    uri = URI.parse(url)

    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = @wskey.hmac_signature('GET', url, :principal_id => '8eaa9f92-3951-431c-975a-d7df26b8d131', :principal_idns => 'urn:oclc:wms:da')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.start do |http| 
      http.request(request)
    end

    puts response.body
  end


end

