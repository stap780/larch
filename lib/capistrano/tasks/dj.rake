namespace :delayed_job do
  desc 'Ensure that bin/delayed_job has the permission to be executable. Ideally, this should not have been needed.'
    task :ensure_delayed_job_executable do
      on roles(delayed_job_roles) do
        within release_path do
          execute :chmod, :'u+x', :'bin/delayed_job'
        end
    end
  end
end
