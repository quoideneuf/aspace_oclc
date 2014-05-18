require 'securerandom'


class OclcController <  ApplicationController
  set_access_control "view_repository" => [:index, :search]
  set_access_control "update_archival_record" => [:import]

  def index
    missing = []

    unless AppConfig.has_key?(:oclc_search_key)
      missing << I18n.t('plugins.oclc.search_key')
    end

    unless AppConfig.has_key?(:oclc_metadata_key)
      missing << I18n.t('plugins.oclc.metadata_key')
    end

    unless AppConfig.has_key?(:oclc_metadata_secret)
      missing << I18n.t('plugins.oclc.metadata_secret')
    end

    unless missing.empty?
      flash[:warning] = I18n.t('plugins.oclc.messages.missing_from_config', :params => missing.join(", "))
    end

    render "search/index"
  end

  def show
    render :json => ["show"]
  end


  def search
    key = AppConfig.has_key?(:oclc_search_key) ? AppConfig[:oclc_search_key] : nil

    srchr = OCLCSearcher.new(OCLCBaseUrl.search_api, key)

    begin

      results = srchr.search(params[:query], params[:start_index])
      render :json => results.to_hash
    rescue OCLCSearchException => e
      render :json => {:error => e.message}
    end    
  end


  def import
    getter = OCLCBibGetter.new(OCLCBaseUrl.metadata_api, AppConfig[:oclc_metadata_key], AppConfig[:oclc_metadata_secret])

    begin

      marcxml_file = getter.capture_marc_records(params[:oclcn])

      job = Job.new("marcxml_accession", 
                    {"oclc_import_#{SecureRandom.uuid}" => marcxml_file})

      response = job.upload
      render :json => {'job_uri' => url_for(:controller => :jobs, :action => :show, :id => response['id'])}
    rescue
      render :json => {'error' => $!.to_s}
    end
  end


  def unauthorised_access
    respond_to do |format|
      format.html {
        super
      }
      format.js {
        render :status => 403, :text => "Unauthorized Access"
      }
    end
  end
end
