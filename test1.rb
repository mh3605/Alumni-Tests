#sign in
#look at 3 alums
#sign out

require "net/http"
require "uri"
http = Net::HTTP.new('localhost', 3000)

def get_with_cookie(uri, old_cookie, http)
	req = Net::HTTP::Get.new(uri)
	req['Cookie']= old_cookie
	output= http.request(req) #html body
	(output.body=~ /name="csrf-token" content="(.*)"/)
	token =$1
	arr=[token, req['Set-Cookie'], output]
	return arr
	#returns [token, new_cookie, output]
end


start_time= Time.now

200.times do
#SIGN IN
login_res = Net::HTTP.get_response('localhost', '/profile/users/sign_in', 3000)
login_res.body =~ /name="authenticity_token" value="(.*)"/ #get the token from the response
login_form_token = $1

login_request = Net::HTTP::Post.new('/profile/users/sign_in')
login_request.set_form_data({"utf8"=>"✓", "authenticity_token"=>login_form_token,
                       "user[email]"=>"admin@gmail.com", "user[password]"=>"password",
                       "user[remember_me]"=>"0", "commit"=>"Log in"})
login_request['Cookie'] = login_res['Set-Cookie']
login_output = http.request(login_request)

#GET THREE ALUMS
get_alum1_arr = get_with_cookie('/alums/1',login_output['Set-Cookie'],http)
get_alum2_arr = get_with_cookie('/alums/2', get_alum1_arr[2]['Set-Cookie'],http)
get_alum3_arr = get_with_cookie('/alums/3', get_alum2_arr[2]['Set-Cookie'],http)

#SIGNOUT
signout_request= Net::HTTP::Delete.new('/profile/users/sign_out')
signout_request.set_form_data({"authenticity_token"=>get_alum3_arr[0]})
signout_request['Cookie']= get_alum3_arr[2]['Set-Cookie']
output= http.request(signout_request) #html body

end

end_time= Time.now

diff= end_time-start_time
diff=diff*1000

puts "Started at: #{start_time}"
puts "Ended at: #{end_time}"
puts "Test took #{diff} ms"


