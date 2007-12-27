class SchedulerController < ApplicationController
  def index
    #render :nothing => true
    redirect_back_or_default(:controller => 'scheduler', :action => 'list')
  end
  
  def my_load
    if request.xhr?
      workers = {}
      workers['rows'] = Worker.find(:all).collect{ |w|
          {'name' => w.name, 'id' => w.id}
      }
      render :json => workers.to_json
    end
  end
  
  def delete
    ret = {}
    worker = Worker.find(params[:id].to_i);
    if worker.destroy
      file_name = get_file_name(worker.name.underscore)
      if File.exist?(file_name)
        File.delete(file_name);
        ret[:success] = true
      else
        ret[:success] = false
        ret[:error] = _("%{model} %{name} can not be deleted.")% {:model => _("File"), :name => worker.name}        
      end
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be deleted.")% {:model => _("Worker"), :name => worker.name}
    end
    render :json => ret.to_json, :layout => false    
  end
  
  def create
    ret = {}
    worker = Worker.new;
    worker.name = '';

    if worker.save
      logger.info("\033[33m New Worker in database: \033[m");
      ret[:id] = worker.id
      ret[:success] = true
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be created.")% {:model => _("Worker"), :name => worker.name}
    end
    render :json => ret.to_json, :layout => false
  end
  
  def set_event
    ret = {}
    logger.info("\033[33m Worker id: #{params[:id]}, Event: \033[m");
    logger.info("\033[33m \tSec: #{params[:sec]}, Min: #{params[:min]}, Hour: #{params[:hour]}, Day: #{params[:day]}, Month: #{params[:month]}, Weekday: #{params[:any]}, Year: #{params[:year]}\033[m");
    trigger = {}
    trigger[:create] = {
      :trigger_args => nil
      }
    worker = Worker.find(params[:id].to_i)
    if !params[:sec].blank?
      logger.info("\033[33m  SECONDES: #{params[:sec]}\033[m");
      worker.sec = params[:sec].to_i
      trigger[:create][:trigger_args] = worker.sec.to_s + " "
    else
      worker.sec = nil
      trigger[:create][:trigger_args] = "* "
    end
    if !params[:min].blank?
      worker.min = params[:min].to_i
      trigger[:create][:trigger_args] += worker.min.to_s + " "
    else
      worker.min = nil
      trigger[:create][:trigger_args] += "* "
    end
    if !params[:hour].blank?
      worker.hour = params[:hour].to_i
      trigger[:create][:trigger_args] += worker.hour.to_s + " "
    else
      worker.hour = nil
      trigger[:create][:trigger_args] += "* "
    end
    if !params[:day].blank?
      worker.day = params[:day].to_i
      trigger[:create][:trigger_args] += worker.day.to_s + " "
    else
      worker.day = nil
      trigger[:create][:trigger_args] += "* "
    end  
    if !params[:month].blank?
      worker.month = params[:month].to_i
      trigger[:create][:trigger_args] += worker.month.to_s + " "
    else
      worker.month = nil
      trigger[:create][:trigger_args] += "* "
    end
    if !params[:any].blank? && params[:any] != 'Any'
      worker.weekday = params[:any].to_i
      trigger[:create][:trigger_args] += worker.weekday.to_s + " "
    else
      worker.weekday = nil
      trigger[:create][:trigger_args] += "* "
    end
    if !params[:year].blank?
      worker.year = params[:year].to_i
      trigger[:create][:trigger_args] += worker.year.to_s
    else
      worker.year = nil
      trigger[:create][:trigger_args] += "*"
    end
    if worker.save
      set_trigger((worker.name + "Worker").underscore, trigger)
      ret[:success] = true
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be updated.")% {:model => _("Worker"), :name => worker.name}
    end      
    render :json => ret.to_json, :layout => false  
  end
  
  
  def save
    ret = {}
    worker = Worker.find(params[:id].to_i)
    file_name = get_file_name(worker.name.underscore)
    if File.exist?(file_name)
      file = File.open(file_name, mode="w")
      file.write(params[:code])
      file.close();
      ret[:success] = true
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be updated.")% {:model => _("File"), :name =>file_name}
    end      
    render :json => ret.to_json, :layout => false  
  end
  
  def load_code
    ret = {}
    ret[:content] = ""
    file_name = get_file_name(params[:name].underscore)
    if File.exist?(file_name)      
      file = File.open(file_name, mode="r")
      if file != nil
        while !file.eof?
          ret[:content] << file.gets
        end
        logger.info("\033[33m Code Loaded with worker: #{file_name}\033[m");
        file.close
        ret[:success] = true
        worker = Worker.find(params[:id])
        ret[:sec] = worker.sec
        ret[:min] = worker.min
        ret[:hour] = worker.hour
        ret[:day] = worker.day
        ret[:month] = worker.month
        ret[:weekday] = worker.weekday
        ret[:year] = worker.year
      else
        ret[:success] = false
        ret[:error] = _("%{model} %{name} can not be readed.")% {:model => _("File "), :name => file_name}
      end
    else
      ret[:success] = true
      ret[:error] = _("%{model} %{name} failded.")% {:model => _("Load code for "), :name => params[:name]}
    end   
    
    render :json => ret.to_json, :layout => false
  end
  
  def update ()
    ret = {}
    worker = nil
    logger.info("\033[33m Worker Id: #{params[:id]}, old: #{params[:old]}, new: #{params[:name]}\033[m");
    if params[:id].to_i != 0
      worker  = Worker.find(params[:id].to_i)
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be updated.")% {:model => _("Worker"), :name => params[:id]}
      render :json => ret.to_json, :layout => false
    end
    worker.name = params[:name].camelize
    file_name = get_file_name(params[:old].underscore)
    logger.info("\033[33m File name: #{file_name}\033[m");
    if File.exist?(file_name)
      if params[:name] != params[:old]
        logger.info("\033[33m File #{file_name} rename to #{get_file_name(params[:name].underscore)}\033[m");
        File.rename(file_name, get_file_name(params[:name].underscore))
        #file = File.open(get_file_name(params[:name].underscore), mode="a+")
        #reg = Regexp.new(/class\s*\w*\s*<\s*BackgrounDRb::Worker::RailsBase/);
        #file.sub(reg, "class #{params[:name].camelize}Worker < BackgroundDRb::Worker::RailsBase");
        #file.close
      end
    else
      if params[:name] != nil && params[:name] != ""
        file = File.open(get_file_name(params[:name].underscore), mode="w")
        file.write(
"# Put your code that runs your task inside the do_work method it will be
# run automatically in a thread. You have access to all of your rails
# models.  You also get logger and results method inside of this class
# by default.
class #{params[:name].camelize}Worker < BackgrounDRb::MetaWorker
  set_worker_name :#{(params[:name].camelize + "Worker").underscore}
  def create(args = nil)
    # This method is called in it's own new thread when you
    # call new worker. args is set to :args

  end
end
"
        );
        file.close
        logger.info("\033[33m New Worker File create in libs\033[m");
      end
    end
    if worker.save
      ret[:success] = true
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be updated.")% {:model => _("Worker"), :name => worker.name}
    end
    render :json => ret.to_json, :layout => false
  end
  
  private
  
    def get_file_name(name)
      file_name = ""
      require 'pathname'
      back_root = Pathname.new(RAILS_ROOT).realpath.to_s + "/config/backgroundrb.yml"
      if File.exist?(back_root)
        yml_file = YAML.load(IO.read(back_root))
        worker_dir = yml_file[:backgroundrb][:worker_dir]
        if worker_dir == nil
          worker_dir = "lib/workers"
        end
        logger.info("\033[33m BackgroundRb config file: #{worker_dir} Loaoded, #{yml_file.inspect} \033[m")
        file_name = File.join(worker_dir, "/#{name}_worker.rb")
      end
      file_name
    end
    
    def set_trigger(name, trigger)
      yml_file = nil
      require 'pathname'
      back_root = Pathname.new(RAILS_ROOT).realpath.to_s + "/config/backgroundrb.yml"
      if !File.exist?(back_root)
        File.new(back_root, "w")
      end
      logger.info("\033[33m Schedule Yaml: #{trigger.inspect}\033[m");
#      yml_file = {}
      yml_file = YAML.load(IO.read(back_root))
      
        logger.info("\033[33m Schedule Yaml class: #{yml_file.class}\033[m");
      if yml_file == false || yml_file[:schedules].blank?
        yml_file[:schedules] = {}
      end
#      if !yml_file[:schedules][:"#{name}"].blank?
#        logger.info("\033[33m Schedule Yaml 1 \033[m");
#        yml_file[:schedules][:"#{name}"] = trigger
#      else
#        logger.info("\033[33m Schedule Yaml 3 \033[m");
        #yml_file = {"schedules" =>{}}
#        yml_file["schedules"] = yml_file["schedules"] + "#{name}"
        yml_file[:schedules][:"#{name}"] = trigger
#      end
      File.open(back_root, "w") do |out|
      YAML.dump(yml_file, out)
      end
    end
  
end
