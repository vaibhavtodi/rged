# Put your code that runs your task inside the do_work method it will be
# run automatically in a thread. You have access to all of your rails
# models.  You also get logger and results method inside of this class
# by default.
class DateTimeWorker < BackgrounDRb::MetaWorker#::RailsBase
  set_worker_name :date_time_worker
  def create(args = nil)
    # This method is called in it's own new thread when you
    # call new worker. args is set to :args
    #logger.info("\033[33m Do Work  #{Time.now.to_s} \033[m")
    @counter = 0
    add_periodic_timer(2) { increment_counter }
    #register_status("Running")
  end
  
  def increment_counter
     @counter += 1
     register_status(@counter)
  end
  
  def set_log
    logger.info("\033[33m #{worker_name} Do Work  #{Time.now.to_s} \033[m")
  end

end
#DateWorker.register
