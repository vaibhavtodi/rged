module BackgrounDRb
  # this class is a dummy class that implements things required for passing data to
  # actual logger worker
  class PacketLogger
    def initialize(worker)
      @worker = worker
    end
    def info(p_data)
      @worker.send_request(:worker => :log_worker, :data => p_data)
    end

    def debug
      @worker.send_request(:worker => :log_worker, :data => p_data)
    end
  end

  class WorkData
    attr_accessor :data,:block
    def initialize(args,&block)
      @data = args
      @block = block
    end
  end

  class ThreadPool
    attr_accessor :size
    attr_accessor :threads
    attr_accessor :work_queue
    def initialize(size)
      @size = size
      @threads = []
      @work_queue = Queue.new
      @running_tasks = Queue.new
      @size.times { add_thread }
    end

    # can be used to make a call in threaded manner
    # passed block runs in a thread from thread pool
    # for example in a worker method you can do:
    #   def fetch_url(url)
    #     puts "fetching url #{url}"
    #     thread_pool.defer(url) do |url|
    #       begin
    #         data = Net::HTTP.get(url,'/')
    #         File.open("#{RAILS_ROOT}/log/pages.txt","w") do |fl|
    #           fl.puts(data)
    #         end
    #       rescue
    #         logger.info "Error downloading page"
    #       end
    #     end
    #   end
    # you can invoke above method from rails as:
    #   MiddleMan.ask_work(:worker => :rss_worker, :worker_method => :fetch_url, :data => "www.example.com")
    # assuming method is defined in rss_worker

    def defer(*args,&block)
      @work_queue << WorkData.new(args,&block)
    end

    def add_thread
      @threads << Thread.new do
        while true
          task = @work_queue.pop
          @running_tasks << task
          block_arity = task.block.arity
          begin
            block_arity == 0 ? task.block.call : task.block.call(*(task.data))
          rescue
            logger.info($!.to_s)
            logger.info($!.backtrace.join("\n"))
          end
          @running_tasks.pop
        end
      end
    end

    # method ensures exclusive run of deferred tasks for 2 seconds, so as they do get a chance to run.
    def exclusive_run
      if @running_tasks.empty? && @work_queue.empty?
        return
      else
        # puts "going to sleep for a while"
        sleep(0.05)
        return
      end
    end
  end

  # == MetaWorker class
  # BackgrounDRb workers are asynchrounous reactors which work using events
  # You are free to use threads in your workers, but be reasonable with them.
  # Following methods are available to all workers from parent classes.
  # * BackgrounDRb::MetaWorker#connect
  #
  #   Above method connects to an external tcp server and integrates the connection
  #   within reactor loop of worker. For example:
  #
  #        class TimeClient
  #          def receive_data(p_data)
  #            worker.get_external_data(p_data)
  #          end
  #
  #          def post_init
  #            p "***************** : connection completed"
  #          end
  #        end
  #
  #        class FooWorker < BackgrounDRb::MetaWorker
  #          set_worker_name :foo_worker
  #          def create(args = nil)
  #            external_connection = nil
  #            connect("localhost",11009,TimeClient) { |conn| external_connection = conn }
  #          end
  #
  #          def get_external_data(p_data)
  #            puts "And external data is : #{p_data}"
  #          end
  #        end
  # * BackgrounDRb::MetaWorker#start_server
  #
  #   Above method allows you to start a tcp server from your worker, all the
  #   accepted connections are integrated with event loop of worker
  #      class TimeServer
  #
  #        def receive_data(p_data)
  #        end
  #
  #        def post_init
  #          add_periodic_timer(2) { say_hello_world }
  #        end
  #
  #        def connection_completed
  #        end
  #
  #        def say_hello_world
  #          p "***************** : invoking hello world #{Time.now}"
  #          send_data("Hello World\n")
  #        end
  #      end
  #
  #      class ServerWorker < BackgrounDRb::MetaWorker
  #        set_worker_name :server_worker
  #        def create(args = nil)
  #          # start the server when worker starts
  #          start_server("0.0.0.0",11009,TimeServer) do |client_connection|
  #            client_connection.say_hello_world
  #          end
  #        end
  #      end

  class MetaWorker < Packet::Worker
    attr_accessor :config_file, :my_schedule, :run_time, :trigger_type, :trigger
    attr_accessor :logger, :thread_pool
    iattr_accessor :pool_size
    @pool_size = nil

    def self.pool_size(size = nil)
      if size
        @pool_size = size
      else
        @pool_size
      end
    end

    # does initialization of worker stuff and invokes create method in
    # user defined worker class
    def worker_init
      @thread_pool = ThreadPool.new(pool_size || 20)

      @config_file = YAML.load(ERB.new(IO.read("#{RAILS_HOME}/config/backgroundrb.yml")).result)
      # load_rails_env
      @logger = PacketLogger.new(self)
      if(@worker_options && @worker_options[:schedule] && no_auto_load)
        load_schedule_from_args
      elsif(@config_file[:schedules] && @config_file[:schedules][worker_name.to_sym])
        @my_schedule = @config_file[:schedules][worker_name.to_sym]
        new_load_schedule if @my_schedule
      end
      if respond_to?(:create)
        create_arity = method(:create).arity
        (create_arity == 0) ? create : create(@worker_options[:data])
      end
      @logger.info "#{worker_name} started"
      @logger.info "Schedules for worker loaded"
    end

    # loads workers schedule from options supplied from rails
    # a user may pass trigger arguments to dynamically define the schedule
    def load_schedule_from_args
      @my_schedule = @worker_options[:schedule]
      new_load_schedule if @my_schedule
    end

    # receives requests/responses from master process or other workers
    def receive_data p_data
      if p_data[:data][:worker_method] == :exit
        exit
        return
      end
      case p_data[:type]
      when :request: process_request(p_data)
      when :response: process_response(p_data)
      end
    end

    # method is responsible for invoking appropriate method in user
    def process_request(p_data)
      user_input = p_data[:data]
      logger.info "#{user_input[:worker_method]} #{user_input[:data]}"
      if (user_input[:worker_method]).nil? or !respond_to?(user_input[:worker_method])
        logger.info "Undefined method #{user_input[:worker_method]} called on worker #{worker_name}"
        return
      end
      called_method_arity = self.method(user_input[:worker_method]).arity
      logger.info "Arity of method is #{called_method_arity}"
      result = nil
      if called_method_arity != 0
        result = self.send(user_input[:worker_method],user_input[:data])
      else
        result = self.send(user_input[:worker_method])
      end
      result = "dummy_result" unless result
      send_response(p_data,result)
    end

    def load_schedule
      case @my_schedule[:trigger_args]
      when String
        @trigger_type = :cron_trigger
        cron_args = @my_schedule[:trigger_args] || "0 0 0 0 0"
        @trigger = BackgrounDRb::CronTrigger.new(cron_args)
      when Hash
        @trigger_type = :trigger
        @trigger = BackgrounDRb::Trigger.new(@my_schedule[:trigger_args])
      end
      @run_time = @trigger.fire_time_after(Time.now).to_i
    end

    # new experimental scheduler
    def new_load_schedule
      @worker_method_triggers = { }
      @my_schedule.each do |key,value|
        case value[:trigger_args]
        when String
          cron_args = value[:trigger_args] || "0 0 0 0 0"
          trigger = BackgrounDRb::CronTrigger.new(cron_args)
        when Hash
          trigger = BackgrounDRb::Trigger.new(value[:trigger_args])
        end
        @worker_method_triggers[key] = { :trigger => trigger,:data => value[:data],:runtime => trigger.fire_time_after(Time.now).to_i }
      end
    end

    # probably this method should be made thread safe, so as a method needs to have a
    # lock or something before it can use the method
    def register_status p_data
      status = {:type => :status,:data => p_data}
      begin
        send_data(status)
      rescue TypeError => e
        status = {:type => :status,:data => "invalid_status_dump_check_log"}
        send_data(status)
        logger.info(e.to_s)
        logger.info(e.backtrace.join("\n"))
      rescue
        status = {:type => :status,:data => "invalid_status_dump_check_log"}
        send_data(status)
        logger.info($!.to_s)
        logger.info($!.backtrace.join("\n"))
      end
    end

    def register_result p_data
      result = { :type => :result, :data => p_data }
      begin
        send_data(result)
      rescue TypeError => e
        logger.info(e.to_s)
        logger.info(e.backtrace.join("\n"))
      rescue
        logger.info($!.to_s)
        logger.info($!.backtrace.join("\n"))
      end
    end

    def send_response input,output
      input[:data] = output
      input[:type] = :response
      begin
        send_data(input)
      rescue TypeError => e
        logger.info(e.to_s)
        logger.info(e.backtrace.join("\n"))
        input[:data] = "invalid_result_dump_check_log"
        send_data(input)
      rescue
        logger.info($!.to_s)
        logger.info($!.backtrace.join("\n"))
        input[:data] = "invalid_result_dump_check_log"
        send_data(input)
      end
    end

    def unbind; end

    def connection_completed; end

    def check_for_timer_events
      super
      return if @worker_method_triggers.nil? or @worker_method_triggers.empty?
      @worker_method_triggers.each do |key,value|
        if value[:runtime] < Time.now.to_i
          (t_data = value[:data]) ? send(key,t_data) : send(key)
          value[:runtime] = value[:trigger].fire_time_after(Time.now).to_i
        end
      end
    end

    # method would allow user threads to run exclusively for a while
    def run_user_threads
      @thread_pool.exclusive_run
    end

    #     we are overriding the function that checks for timers
    #     def check_for_timer_events
    #       super
    #       return unless @my_schedule
    #       if @run_time < Time.now.to_i
    #         # self.send(@my_schedule[:worker_method]) if self.respond_to?(@my_schedule[:worker_method])
    #         invoke_worker_method
    #         @run_time = @trigger.fire_time_after(Time.now).to_i
    #       end
    #     end

    def invoke_worker_method
      if self.respond_to?(@my_schedule[:worker_method]) && @my_schedule[:data]
        self.send(@my_schedule[:worker_method],@my_schedule[:data])
      elsif self.respond_to?(@my_schedule[:worker_method])
        self.send(@my_schedule[:worker_method])
      end
    end

#     private
#     def load_rails_env
#       ActiveRecord::Base.allow_concurrency = true
#       db_config_file = YAML.load(ERB.new(IO.read("#{RAILS_HOME}/config/database.yml")).result)
#       run_env = @config_file[:backgroundrb][:environment] || 'development'
#       ENV["RAILS_ENV"] = run_env
#       RAILS_ENV.replace(run_env) if defined?(RAILS_ENV)
#       require RAILS_HOME + '/config/environment.rb'
#       ActiveRecord::Base.establish_connection(db_config_file[run_env])
#     end
  end # end of class MetaWorker
end # end of module BackgrounDRb

