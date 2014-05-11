# interactor :off
# logger device: 'guard.log'

guard 'redis', executable: 'redis-server', pidfile: 'tmp/pids/redis.pid', port: 6379, reload_on_change: true do
  watch(/^(app|workers|lib|config)\/.*\.rb$/) { }
end

guard 'sidekiq', concurrency: 36, pidfile: 'tmp/pids/sidekiq.pid', config: 'config/sidekiq.yml', environment: 'development', timeout: 5, reload_on_change: true do
  watch(%r{^workers/(.+)\.rb$})
end