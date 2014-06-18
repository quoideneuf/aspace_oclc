require_relative 'spec_helper'
require_relative '../frontend/models/oclc_searcher'
require_relative '../frontend/models/oclc_bib_getter'

describe "OCLC Clientware" do

  before(:all) do
    # you need to put a sandbox key and secret in 
    # 'wskey.yml' to run these tests
    # https://platform.worldcat.org/api-explorer/wcapi
    @wscred = get_wscred
  end

  let(:catalog_url) {
    "http://www.worldcat.org/webservices/catalog/search/worldcat/opensearch"
  }

  describe "OCLCSearcher" do

    it "can query OCLC and return a result set object" do
      searcher = OCLCSearcher.new(catalog_url, @wscred["search"]["key"])
      results = searcher.search('donuts')
      results.should be_a(OCLCSearchResults)
      results.hit_count.should be > 1140
    end
  end


  describe "OCLCSearchResults" do

    let(:results) {
      OCLCSearcher.new(catalog_url, @wscred["search"]["key"]).search('donuts')
    }

    it "can say how many hits it has" do
      results.hit_count.should be_a(Integer)
    end

    it "can serialize result data as json" do
      json = results.to_json
      result_data = JSON.parse(json)

      result_data['results'].count.should eq(10)

      result_data['results'].each do |result|
        result["id"].should match (/http:\/\/worldcat\.org\/oclc\/\d*$/)
      end
    end
  end
    

  describe "OCLCBibGetter" do

    let(:base_url) {
      "https://worldcat.org/bib/data"
    }

    def get_getter
      OCLCBibGetter.new(base_url, @wscred['metadata']['key'], @wscred['metadata']['secret'], @wscred['metadata']['principal_id'])
    end

    it "can get a bib record out of the catalog" do
      bib = get_getter
      
      rec = bib.get(722914006)

      doc = parse(rec)
      doc.xpath("//datafield[@tag='245']/subfield[@code='a']").text().should match /Donuts/
    end


    it "can take a set of OCLC ids and create a Marc XML collection" do
      bib = get_getter

      ids = [722914006, 857981913, 51047061]

      files = bib.write_records(ids)
      files.each do |file|
        doc = parse(IO.read(file))

        doc.xpath("//record").length.should eq(1)
        doc.xpath("//datafield[@tag='245']").length.should eq(1)
      end
    end
  end
end
