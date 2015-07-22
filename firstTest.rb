require "net/http"
require "uri"

uri= URI.parse('localhost:3000/')

Net::HTTP.get('localhost', '/', 3000)
#Net::HTTP.get('localhost', '/profile/users/sign_in/',3000)

#params =  {user[email] => "admin@gmail.com", user[password] => "password"}
#Net::HTTP.post_form uri, params
##Net::HTTP.post_form URI('localhost:3000/profile/users/sign_in/') {"user[email]" => "admin@gmail.com", "user[password]" => "password"}
##Net::HTTP.get(uri)

Net::HTTP.get('localhost', '/alums/new', 3000)
Net::HTTP.post_form URI('localhost:3000/alums') {"name" => "Catherine"}
