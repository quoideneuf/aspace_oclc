require 'net/http'
require 'oclc/auth'
require 'asutils'

class OCLCBibGetter < Struct.new(:base_url, :key, :secret)


  def capture_marc_records(ids)
    tempfile = ASUtils.tempfile('oclc_import')

    tempfile.write("<collection>\n")

    ids.each do |id|
      xml = get(id)
      tempfile.write(xml)
    end

    tempfile.write("\n</collection>")

    tempfile.flush
    tempfile.rewind

    return tempfile
  end


  def get(id)
    @wskey ||= OCLC::Auth::WSKey.new(key, secret)

    url = "#{base_url}/#{id.to_s}?classificationScheme=LibraryOfCongress"
    uri = URI.parse(url)

    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = @wskey.hmac_signature('GET', url, :principal_id => '8f19c890-991c-4cd8-aad9-00db6d82e1c7', :principal_idns => 'urn:oclc:wms:da')
    request['Accept'] = "application/atom+xml;content=\"application/vnd.oclc.marc21+xml\""

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.start do |http| 
      http.request(request)
    end

    response.body
  end

end

