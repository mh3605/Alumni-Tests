require "net/http"
require "uri"

uri = URI('http://localhost:3000/profile/users/sign_in')
req = Net::HTTP::Post.new(uri)
puts req
req.set_form_data("utf8"=>"✓", "user"=>{"email"=>"admin@gmail.com", "password"=>"password", "remember_me"=>"0"}, "commit"=>"Log in")
res = Net::HTTP.start(uri.hostname, uri.port) do |http|
	puts res
 puts http.request(req)
end

