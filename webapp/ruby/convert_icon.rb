require 'tempfile'
require 'fileutils'
require 'hiredis'
require 'redis'
require 'redis/connection/hiredis'

ICON_S  =  32
ICON_M  =  64
ICON_L  = 128
IMAGE_S = 128
IMAGE_M = 256
IMAGE_L = nil

def redis
  @redis ||= (Thread.current[:isu4_redis] ||= Redis.new(:host => "127.0.0.1", :port => 6379))
end

def convert(orig, ext, w, h)
  data = nil

  Tempfile.open('isucontemp') do |tmp|
    newfile = "#{tmp.path}.#{ext}"
    `convert -geometry #{w}x#{h} #{orig} #{newfile}`
    File.open(newfile, 'r+b') do |new|
      data = new.read
    end
    File.unlink(newfile)
    tmp.unlink
  end

  data
end

def crop_square(orig, ext)
  identity = `identify #{orig}`
  (w, h)   = identity.split[2].split('x').map(&:to_i)

  if w > h
    pixels = h
    crop_x = ((w - pixels) / 2).floor
    crop_y = 0
  elsif w < h
    pixels = w
    crop_x = 0
    crop_y = ((h - pixels) / 2).floor
  else
    pixels = w
    crop_x = 0
    crop_y = 0
  end

  tmp = Tempfile.open("isucon")
  begin
    newfile = "#{tmp.path}.#{ext}"
    `convert -crop #{pixels}x#{pixels}+#{crop_x}+#{crop_y} #{orig} #{newfile}`
  ensure
    tmp.close
    tmp.unlink
  end

  newfile
end

dir = "./data"
Dir.glob("#{dir}/icon/*.png").each do |icon_path|
  puts icon_path
  large_file = "#{icon_path}_l"
  unless redis.exists large_file
    w = h = ICON_L
    data = convert(icon_path, 'png', w, h)
    redis.set large_file, data
  end
  small_file = "#{icon_path}_s"
  unless redis.exists small_file
    w = h = IMAGE_S
    data = convert(icon_path, 'png', w, h)
    redis.set small_file, data
  end
  middle_file = "#{icon_path}_m"
  unless redis.exists middle_file
    w = h = IMAGE_M
    data = convert(icon_path, 'png', w, h)
    redis.set middle_file, data
  end
end
