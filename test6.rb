#sign up for account
#look at main page
#cancel account

require "net/http"
require "uri"
http = Net::HTTP.new('localhost', 3000)

def get_crsf_token(output)
	(output.body=~ /name="csrf-token" content="(.*)"/)
	token =$1
	return token
end

def get_with_cookie(uri, old_cookie, http)
	#res= Net::HTTP.get_response('localhost', uri, 3000)
	req = Net::HTTP::Get.new(uri)
	req['Cookie']= old_cookie
	output= http.request(req) #html body
	(output.body=~ /name="authenticity_token" value="(.*)"/)
	token =$1
	arr=[token, req['Set-Cookie'], output]
	return arr
	#returns [token, new_cookie, output]
end

def post_with_cookie(uri, form_info, old_cookie, http)
	req= Net::HTTP::Post.new(uri)
	req.set_form_data(form_info)
	req['Cookie']= old_cookie
	output= http.request(req) #html body
	(output.body=~ /name="authenticity_token" value="(.*)"/)
	token =$1
	arr=[token, req['Set-Cookie'], output]
	return arr
end

start_time= Time.now

200.times do

#SIGN UP
signup_res = Net::HTTP.get_response('localhost', '/profile/users/sign_up', 3000)
signup_res.body =~ /name="authenticity_token" value="(.*)"/ #get the token from the response
signup_form_token = $1

signup_request = Net::HTTP::Post.new('/profile/users/')
signup_request.set_form_data({"utf8"=>"✓", "authenticity_token"=>signup_form_token,
                       "user[email]"=>"temp@gmail.com", "user[password]"=>"password",
                       "user[password_confirmation]"=>"password", "commit"=>"Sign up"})
signup_request['Cookie'] = signup_res['Set-Cookie']
signup_output = http.request(signup_request)

#GET /
get_home_arr = get_with_cookie('/', signup_output['Set-Cookie'],http)

#DELETE ACCOUNT
delete_account_request= Net::HTTP::Delete.new('/profile/users')
delete_account_request.set_form_data({"authenticity_token"=>get_crsf_token(get_home_arr[2])})
delete_account_request['Cookie']= get_home_arr[2]['Set-Cookie']
output= http.request(delete_account_request) #html body

end 

end_time= Time.now

diff= end_time-start_time
diff=diff*1000

puts "Started at: #{start_time}"
puts "Ended at: #{end_time}"
puts "Test took #{diff} ms"






