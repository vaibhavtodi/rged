class CountryController < ApplicationController

def list
  if request.xhr? && params[:node] # json_node
    p_id = params[:node].to_i > 0 ? params[:node] : nil
    roots = Country.find(:all).collect{ |r|
     {'id' => r.id, 'text' => r.name, 'leaf' => true }
    }
    render :json => roots.to_json
  end
end
  
def delete_country
    return_data = Hash.new()
    country = Country.find(params[:id])
    logger.info("\033[32m Delete #{country.name}\033[m")
    if country.destroy
      return_data = {:success => true}
    else
        return_data = {:success => false, :error => _("Country ") + params[:name] + _(" can not be deleted.")}
    end
    render :text=>return_data.to_json, :layout=>false
end

def new_country
  country = Country.new
  country.name = params[:name]
  return_data = Hash.new()
  if country.save
    return_data = {:success => true, :id => country.id}
  else
    return_data = {:success => false, :error => _("Country %{name} can not be created.")% {:name => params[:name] }}
  end
  render :text=>return_data.to_json, :layout=>false
end

end
