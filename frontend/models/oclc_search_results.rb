require 'nokogiri'

class OCLCSearchResults
  attr_reader :hit_count


  def initialize(query, response_xml)
    @query = query

    @doc = parse_xml(response_xml)

    @hit_count = @doc.xpath("//totalResults").text().to_i
    @items_per_page = @doc.xpath("//itemsPerPage").text().to_i
    @start_index = @doc.xpath("//startIndex").text().to_i
  end


  def to_json
    to_hash.to_json
  end


  def to_hash
    page = @items_per_page > 0 ? (((@start_index - 1) + @items_per_page) / @items_per_page) : 0
    {
      :page => page,
      :at_start => page == 0 || (@start_index == 1),
      :at_end => page == 0 || ((@hit_count - @start_index) < @items_per_page),
      :hit_count => hit_count,
      :start_index => @start_index,
      :last_index => @start_index + @items_per_page,
      :records_per_page => @items_per_page,
      :query => @query,
      :results => hashed_entries
    }
  end


  private

  def parse_xml(xml)
    doc = Nokogiri::XML.parse(xml)

    doc.remove_namespaces!
    doc.encoding = 'utf-8'
    doc
  end


  def hashed_entries
    loaded_entries.map {|e| e.to_hash }
  end


  def loaded_entries
    @loaded_entries ||= []
    if @loaded_entries.empty?
      @doc.xpath("//entry").each do |node|
        @loaded_entries << Entry.new(node)
      end
    end

    @loaded_entries
  end


  class Entry < Struct.new(:node)

    def id
      @id ||= node.xpath("id").text()
    end

    def title
      @title ||= node.xpath("title").text()
    end

    def summary
      @summary ||= node.xpath("summary").text()
    end

    def to_hash
      i = summary.index(' ', 300)
      summ_less, summ_more = i.nil? ? [summary, nil] : [summary[0..i], summary[i..-1]]
      oclcn = id.sub(/.*\//, '')

      hsh = {
        :id => id,
        :oclcn => oclcn,
        :title => title,
        :summary => summ_less,
      }

      hsh[:summary_more] = summ_more if summ_more

      hsh
    end
  end

end
