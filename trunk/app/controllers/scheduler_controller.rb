class SchedulerController < ApplicationController
  def index
    #render :nothing => true
    redirect_back_or_default(:controller => 'scheduler', :action => 'list')
  end
  
  #Load the list of workers for the data store
  def my_load
    if request.xhr?
      workers = {}
      workers['rows'] = Worker.find(:all).collect{ |w|
          {'name' => w.name}
      }
      render :json => workers.to_json
    end
  end
  
  #Load the list of workers for the data store
  def progress_load
    if request.xhr?
      workers = {}
      workers['rows'] = Worker.find(:all).collect{ |w|
          {'name' => w.name, 'id' => w.id}
      }
      render :json => workers.to_json
    end
  end
  
  def refresh
    ret = {}
    if true
      ret[:success] = true
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be refreshed.")% {:model => _("Monitoring"), :name => ''}
    end
    render :json => ret.to_json, :layout => false
  end
  
  #delete a worker
  def delete
    ret = {}
    worker = Worker.find(params[:id].to_i);
    name = (worker.name + "Worker").underscore
    if worker.destroy
      file_name = get_file_name(worker.name.underscore)
      if File.exist?(file_name)
        File.delete(file_name);
      end
      delete_trigger(name)
      ret[:success] = true
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
      ret[:id] = worker.id
      ret[:success] = true
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be created.")% {:model => _("Worker"), :name => ''}
    end
    render :json => ret.to_json, :layout => false
  end
  
  def set_event
    ret = {}
    trigger = {}
    trigger[:create] = {
      :trigger_args => nil
      }
    worker = Worker.find(params[:id].to_i)
    if !params[:sec].blank?
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
      if trigger[:create][:trigger_args] != "* * * * * * *"
        set_trigger((worker.name + "Worker").underscore, trigger)
      end
      ret[:success] = true
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be updated.")% {:model => _("Worker"), :name => worker.name}
    end      
    render :json => ret.to_json, :layout => false  
  end
  
  def disable_event
    ret = {}
    
    worker = Worker.find(params[:id].to_i)
    diff = ""
    if worker.sec == nil
      diff = "*"
    else
      diff = worker.sec.to_s
    end 
    if worker.min == nil
      diff += " *"
    else
      diff += " " + worker.min.to_s
    end
    if worker.hour == nil
      diff += " *"
    else
      diff += " " + worker.hour.to_s
    end
    if worker.day == nil
      diff += " *"
    else
      diff += " " + worker.day.to_s
    end
    if worker.month == nil
      diff += " *"
    else
      diff += " " + worker.month.to_s
    end
    if worker.weekday == nil
      diff += " *"
    else
      diff += " " + worker.weekday.to_s
    end
    if worker.year == nil
      diff += " *"
    else
      diff += " " + worker.year.to_s
    end
    if diff == params[:combin]
      ret[:disable] = true
    else
      ret[:disable] = false
    end
    if true
      
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
    file_name = get_file_name(params[:old].underscore)
    file_name_new = get_file_name(params[:name].underscore)
    
    if File.exist?(file_name_new)
      ret[:success] = false
      ret[:error] = _("%{model} %{name} already exist.")% {:model => _("File"), :name => file_name_new}
    else
      if File.exist?(file_name)     
        if params[:name] != params[:old]
          File.rename(file_name, get_file_name(params[:name].underscore))
        end
      else
        if params[:name] != nil && params[:name] != ""
          file = File.open(file_name_new, mode="w")
          file.write(
  "# Put your code that runs your task inside the do_work method it will be
  # run automatically in a thread. You have access to all of your rails
  # models.  You also get logger and results method inside of this class
  # by default.
  class #{params[:name].camelize}Worker < BackgrounDRb::MetaWorker
    set_worker_name :#{(params[:name].camelize + "Worker").underscore}
    def create(args = nil)
      # this method is called, when worker is loaded for the first time
      @counter = 0
      add_periodic_timer(2) { increment_counter }
    end
    def increment_counter
       @counter += 1
       register_status(@counter)
    end
    # define other methods, that you will invoke from rails.
  end
  "
          )
          file.close
        end
      end
      worker  = Worker.find(params[:id].to_i)
      worker.name = params[:name].camelize
      if worker.save
        ret[:success] = true
      else
        ret[:success] = false
        ret[:error] = _("%{model} %{name} can not be updated.")% {:model => _("Worker"), :name => params[:name].camelize}
      end
    end
    render :json => ret.to_json, :layout => false
  end
  
  def get_status
    worker = Worker.find(params[:id])
    ret = {}
    name = (worker.name + "Worker").underscore
    ret[:status] = "#{name}:\n\t#{Time.now()}: #{status(name)}\n"
    if true
      ret[:success] = true
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be updated.")% {:model => _("Worker"), :name => worker.name}
    end
    render :json => ret.to_json, :layout => false
  end
  
  def get_all_status    
    ret = {}
    #master = MasterWorker.new
    t_response = MiddleMan.query_all_workers
    running_workers = "All Status:\n" + t_response.map { |key,value|
      "\t#{key}:\n\t\t#{Time.now()}: #{status(key)}\n"
    }.join("")
    ret[:status] = running_workers
    if true
      ret[:success] = true
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be updated.")% {:model => _("Worker"), :name => worker.name}
    end
    render :json => ret.to_json, :layout => false
  end
  
  def stop_worker
    worker = Worker.find(params[:id])
    ret = {}
    name = (worker.name + "Worker").underscore
    MiddleMan.delete_worker(:worker => :"#{name}")
    if true
      ret[:success] = true
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be stoped.")% {:model => _("Worker"), :name => name}
    end
    render :json => ret.to_json, :layout => false
  end
  
  def start_worker
    worker = Worker.find(params[:id])
    ret = {}
    name = (worker.name + "Worker").underscore
    schedule = get_schedule(name)
    if !schedule.blank?
      MiddleMan.new_worker(:worker => :"#{name}", :schedule => schedule)
      ret[:success] = true
    else
      ret[:success] = false
      ret[:error] = _("%{model} %{name} can not be started.")% {:model => _("Worker"), :name => name}
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
      yml_file = YAML.load(IO.read(back_root))      
      if yml_file == false || yml_file[:schedules].blank?
        yml_file[:schedules] = {}
      end
      yml_file[:schedules][:"#{name}"] = trigger
      File.open(back_root, "w") do |out|
      YAML.dump(yml_file, out)
      end
    end
    
    def delete_trigger(name)
      yml_file = nil
      require 'pathname'
      back_root = Pathname.new(RAILS_ROOT).realpath.to_s + "/config/backgroundrb.yml"
      if File.exist?(back_root)
        yml_file = YAML.load(IO.read(back_root))
        if !yml_file == false && !yml_file[:schedules].blank? && !yml_file[:schedules][:"#{name}"].blank?
          yml_file[:schedules].delete(:"#{name}")
          File.open(back_root, "w") do |out|
          YAML.dump(yml_file, out)
          end
        end
      end
    end
    
    def get_schedule(name)
      yml_file = nil
      require 'pathname'
      back_root = Pathname.new(RAILS_ROOT).realpath.to_s + "/config/backgroundrb.yml"
      if File.exist?(back_root)
        yml_file = YAML.load(IO.read(back_root))
        yml_file[:schedules][:"#{name}"]
      else
        ""
      end
    end
    
    def status(name)
      MiddleMan.ask_status(:worker => :"#{name}") 
    end
  
end
