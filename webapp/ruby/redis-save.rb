require 'hiredis'
require 'redis'
require 'redis/connection/hiredis'

def redis
  @redis ||= (Thread.current[:isu4_redis] ||= Redis.new(:host => "127.0.0.1", :port => 6379, :timeout => 60))
end
redis.save
