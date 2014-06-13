require 'securerandom'


class OclcController <  ApplicationController
  set_access_control "update_accession_record" => [:import, :preview, :index]

  def index
    missing = []

    unless AppConfig.has_key?(:oclc_search_key)
      missing << I18n.t('plugins.oclc.search_key')
    end

    unless missing.empty?
      flash[:warning] = I18n.t('plugins.oclc.messages.missing_from_config', :params => missing.join(", "))
    end

    render "search/index"
  end


  def preview(searcher, ids)

    begin 
      results = {:records => searcher.get_records(ids)}

      render :json => ASUtils.to_json(results)

    rescue OCLCSearchException => e
      render :json => {:error => e.message}
    end
  end


  def import
    key = AppConfig.has_key?(:oclc_search_key) ? AppConfig[:oclc_search_key] : nil

    ids = params[:ids].split(/\D+/).uniq.select {|id| id =~ /^\d+$/}

    if ids.count > 10
      render :json => {:error => I18n.t("plugins.oclc.messages.fewer_than_ten") + ids.join(', ')}
      return
    end
    
    searcher = OCLCSearcher.new(OCLCBaseUrl.search_api, key)

    if params[:preview]
      preview(searcher, ids)
      return
    end

    begin

      files = searcher.write_records(ids)


      job = Job.new("marcxml_accession", 
                    Hash[files.map {|file| ["oclc_import_#{SecureRandom.uuid}", file] }])
        

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
