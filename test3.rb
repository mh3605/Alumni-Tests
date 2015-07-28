#login
#get alum8
#edit alum8's uid
#get alum8
#logout

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

def patch_with_cookie(uri, form_info, old_cookie, http)
	req= Net::HTTP::Patch.new(uri)
	req.set_form_data(form_info)
	req['Cookie']= old_cookie
	output= http.request(req) #html body
	(output.body=~ /name="authenticity_token" value="(.*)"/)
	token =$1
	arr=[token, req['Set-Cookie'], output]
	return arr
end

start_time= Time.now

120.times do

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

#GET ALUM8
get_alum8_arr = get_with_cookie('/alums/8', login_output['Set-Cookie'],http)

#EDIT ALUM8
get_edit_alum8_arr= get_with_cookie('/alums/8/edit', get_alum8_arr[2]['Set-Cookie'],http)

new_uid= rand(1..1000)

edit_alum8_form= {"utf8"=>"✓", "authenticity_token"=>get_edit_alum8_arr[0], "alum[name]"=>"Sarah",
								 "alum[uid]"=>new_uid, "alum[email]"=>"", "alum[phone]"=>"", 
								"alum[about]"=>"", "alum[faculty_id]"=>"2", "alum[year_id]"=>"", "alum[department_id]"=>"1", 
								"alum[researcharea_id]"=>"", "alum[initialemployer_id]"=>"", "commit"=>"Update Alum", "id"=>"8"}
edit_alum8_arr= patch_with_cookie('/alums/8', edit_alum8_form, get_edit_alum8_arr[2]['Set-Cookie'], http)

#GET ALUM8
get_alum8_arr = get_with_cookie('/alums/8', edit_alum8_arr[2]['Set-Cookie'],http)

#SIGNOUT
signout_request= Net::HTTP::Delete.new('/profile/users/sign_out')
signout_request.set_form_data({"authenticity_token"=>get_crsf_token(get_alum8_arr[2])})
signout_request['Cookie']= get_alum8_arr[2]['Set-Cookie']
output= http.request(signout_request) #html body

end 

end_time= Time.now

diff= end_time-start_time
diff=diff*1000

puts "Started at: #{start_time}"
puts "Ended at: #{end_time}"
puts "Test took #{diff} ms"



