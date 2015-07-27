require "net/http"
require "uri"

uri= URI.parse('localhost:3000/')
http= Net::HTTP.new(uri.host, uri.port)

start_time= Time.now

80.times do
Net::HTTP.get('localhost', '/', 3000) #main alums index
Net::HTTP.get('localhost', '/alums/1', 3000) #michelle's show
Net::HTTP.get('localhost', '/fauclties/1', 3000) #link to Dr. Foster's page
Net::HTTP.get('localhost', '/alums/2', 3000) #eric
Net::HTTP.get('localhost', '/years/1', 3000) #2015
Net::HTTP.get('localhost', '/years', 3000) #clicked back button
Net::HTTP.get('localhost', '/departments', 3000)
Net::HTTP.get('localhost', '/departments/1', 3000)
end 

end_time= Time.now

diff= end_time-start_time
diff=diff*1000

puts "Started at: #{start_time}"
puts "Ended at: #{end_time}"
puts "Test took #{diff} ms"

