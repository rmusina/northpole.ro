require './app'

use Rack::CommonLogger
use Rack::Reloader, 0

run Ki::Ki.new
