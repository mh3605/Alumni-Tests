require "net/http"
require "uri"

#uri= URI.parse('localhost:3000/')
#http= Net::HTTP.new(uri.host, uri.port)

Net::HTTP.get('localhost', '/', 3000)

#sign_in_uri= URI('http://localhost:3000/profile/users/sign_in')

r_form=/name="authenticity_token" value="(.*)"/
#str= Net::HTTP.get(sign_in_uri)
str= Net::HTTP.get('localhost', '/profile/users/sign_in', 3000)
puts str
str=~r_form
form_token= $1
puts " Form authenticity token is: #{form_token}"

r_csrf= /meta name="csrf-param" content="authenticity_token" \/>
<meta name="csrf-token" content="(.*)"/
str=~r_csrf
csrf_token= $1
puts "CSRF authenticity token is: #{csrf_token}"

#Net::HTTP.post_form URI('http://localhost:3000/profile/users/sign_in'), 
#	{"utf8"=>"✓", "authenticity_token"=>form_token, "user"=>{"email"=>"admin@gmail.com", "password"=>"password", "remember_me"=>"0"}, "commit"=>"Log in"}

Net::HTTP.post_form URI('http://localhost:3000/profile/users/sign_in'), 
	{"utf8"=>"✓", "authenticity_token"=>form_token, "user[email]"=>"admin@gmail.com",
		"user[password]" => "password", "user[remember_me]"=>"0", "commit"=>"Log in"}
 
#Net::HTTP.post_form URI('http://localhost:3000/profile/users/sign_in'), { "user[email]" => @admin1.email, "user[password]" => @admin1.password}

 #Net::HTTP.post_form "/profile/users/sign_in", {user: {email: @admin1.email, password: @admin1.password}}
