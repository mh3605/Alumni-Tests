#login
#create alum
#look at list of alums
#delete alum
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

#GET NEW ALUM
get_alums_arr = get_with_cookie('/alums/new', login_output['Set-Cookie'],http)

#ADD NEW ALUM
add_new_alum_form= {"utf8"=>"✓", "authenticity_token"=>get_alums_arr[0], "alum[name]"=>"Carl",
						"alum[uid]"=>80, "alum[email]"=>"", "alum[phone]"=>"", 
						"alum[about]"=>"", "alum[faculty_id]"=>"2", "alum[year_id]"=>"", "alum[department_id]"=>"1", 
						"alum[researcharea_id]"=>"", "alum[initialemployer_id]"=>"", "commit"=>"Update Alum", "id"=>"10"}
add_new_alum_arr= post_with_cookie('/alums', add_new_alum_form, get_alums_arr[2]['Set-Cookie'], http)

#gets new alums id
add_new_alum_arr[2].body=~ /localhost:3000\/alums\/(\d*)"/
new_alum_id= $1


#doesn't delete the right alum

#GET ALUMS
get_alums_arr = get_with_cookie('/alums', add_new_alum_arr[2]['Set-Cookie'],http)

#DELETE ALUM
delete_alum_request= Net::HTTP::Delete.new("/alums/#{new_alum_id}")
delete_alum_request.set_form_data({"authenticity_token"=>get_crsf_token(get_alums_arr[2])})
delete_alum_request['Cookie']= get_alums_arr[2]['Set-Cookie']
delete_alum_output= http.request(delete_alum_request) #html body

#GET ALUMS
get_alums_arr = get_with_cookie('/alums', delete_alum_output['Set-Cookie'],http)

#LOGOUT
signout_request= Net::HTTP::Delete.new('/profile/users/sign_out')
signout_request.set_form_data({"authenticity_token"=>get_crsf_token(get_alums_arr[2])})
signout_request['Cookie']= get_alums_arr[2]['Set-Cookie']
output= http.request(signout_request) #html body




