# Put your code that runs your task inside the do_work method it will be
# run automatically in a thread. You have access to all of your rails
# models.  You also get logger and results method inside of this class
# by default.
class DepartmentCreatingWorker < BackgrounDRb::Worker::RailsBase

  attr_reader :progress, :id_departments, :country_id


  def do_work(args)
    # This method is called in it's own new thread when you
    # call new worker. args is set to :args
    results[:do_work_time] = Time.now.to_s
    logger.info("\033[33m Do Work  \033[m")
    @progress = 0
    @id_departments = []
    @departments = []
    @country_id = 0

    tmp = []
    Country.find(:all).each { |e|
      tmp << e.id
    }

    set_country_id(tmp[rand(Country.count)]);

    Department.find(:all).each { |e|
      if e.country_id == @country_id
        @id_departments << e.id
      end
    }

    logger.info("\033[33m\tcountry_id: #{@country_id} \033[m")
    create_list(args)
    results[:departments] = @departments
    results[:departments].each { |e|
    logger.info("\033[33m \tWorker #{@jobkey} Result #{e.inspect()} \033[m")
    }
    self.delete
  end

  def set_country_id(i)
    @country_id = i
  end

  def set_departments(d)
    @departments << {:department_id => d.id, :name => d.name, :created => Time.new()}
  end

  def rand_alphanumeric(size=16)
    s = ""
    size.times { s << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
    s
  end

  def rand_parent_id()
    tmp = rand(@id_departments.size)
    Department.find(@id_departments[tmp])
  end

  def create_department()
    d = Department.new
    d.country_id = @country_id
    d.name = rand_alphanumeric()
    @progress = @progress + 1
    d
  end

  def create_list(args)
    while (@progress < args)
      d = create_department()
      if @id_departments.size() == 0
        d.save
        @id_departments << d.id
        set_departments(d)
      else
        tmp = rand(6)
        if tmp == 0
          retie_left(d)
        else
          if tmp == 1
            retie_right(d)
          else
            if tmp == 2
              d.save
              @id_departments << d.id
              set_departments(d)
             else
              retie_child(d)
            end
          end
        end
      end
    end
  end

  def retie_child(d)
    if d.save
      d.move_to_child_of(rand_parent_id())
      @id_departments << d.id
      set_departments(d)
    end
  end

  def retie_left(d)
    if d.save
      d.move_to_left_of(rand_parent_id())
      @id_departments << d.id
      set_departments(d)
    end
  end

  def retie_right(d)
    if d.save
      d.move_to_right_of(rand_parent_id())
      @id_departments << d.id
      set_departments(d)
    end
  end

end
DepartmentCreatingWorker.register
