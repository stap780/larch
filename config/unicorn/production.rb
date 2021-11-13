app_name = "adventer"
working_directory "/var/www/#{app_name}/current"
pid "/var/www/#{app_name}/current/tmp/pids/unicorn.pid"
stderr_path "/var/www/#{app_name}/log/unicorn.log"
stdout_path "/var/www/#{app_name}/log/unicorn.log"
listen "/tmp/unicorn.#{app_name}.sock"
worker_processes 8
timeout 60

before_fork do |server, worker|
  old_pid = "/var/www/#{app_name}/current/tmp/pids/unicorn.pid.oldbin"
  if old_pid != server.pid
    begin
    sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
    Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end
