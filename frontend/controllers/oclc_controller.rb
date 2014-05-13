class OclcController <  ApplicationController
  set_access_control "view_repository" => [:index, :search]

  def index
    unless AppConfig.has_key?(:oclc_search_key)
      flash[:warning] = I18n.t('plugins.oclc.no_search_key')
    end

    render "search/index"
  end

  def show
    render :json => ["show"]
  end


  def search
    key = AppConfig.has_key?(:oclc_search_key) ? AppConfig[:oclc_search_key] : nil

    srchr = OCLCSearcher.new("http://www.worldcat.org/webservices/catalog/search/worldcat/opensearch", key)

    begin

      results = srchr.search(params[:query], params[:start_index])
      render :json => results.to_hash
    rescue OCLCSearchException => e
      render :json => {:error => e.message}
    end
    
  end

end
