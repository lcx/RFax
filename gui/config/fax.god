#Root = File.expand_path('../../..', __FILE__)
RAILS_ROOT = "/var/rails/fax/current/gui"

# /var/rails/telco/current/current/

def generic_monitoring(w, options = {})
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 10.seconds
      c.running = false
    end
  end
  
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = options[:memory_limit]
      c.times = [3, 5] # 3 out of 5 intervals
    end
  
    restart.condition(:cpu_usage) do |c|
      c.above = options[:cpu_limit]
      c.times = 5
    end
  end
  
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

God.watch do |w|
  w.name  = "fax-ahn"
  w.group = "fax"

  w.env   = { 'ENV' => 'production' }
  w.dir   = RAILS_ROOT
  w.start = "rake start"
  w.log   = File.join(RAILS_ROOT, 'log', "#{w.name}-god.log")

  w.interval      = 30.seconds # default
  w.grace         = 10.seconds
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds

  w.behavior(:clean_pid_file)
  
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running  = false
    end
  end
end