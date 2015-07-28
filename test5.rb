#login
#edit account
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

def put_with_cookie(uri, form_info, old_cookie, http)
	req= Net::HTTP::Put.new(uri)
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

#GET EDIT ACCOUNT
get_edit_account_arr = get_with_cookie('/profile/users/edit', login_output['Set-Cookie'],http)

#EDIT ACCOUNT
edit_account_form= {"utf8"=>"✓", "authenticity_token"=>get_edit_account_arr[0], "user[email]"=>
			"admin@gmail.com", "user[password]"=>"password", "user[password_confirmation]"=>"password", 
			"user[current_password]"=>"password", "commit"=>"Update"}
edit_account_arr= put_with_cookie('/profile/users', edit_account_form, get_edit_account_arr[2]['Set-Cookie'], http)

#GET /
get_home_arr = get_with_cookie('/', edit_account_arr[2]['Set-Cookie'],http)

#LOGOUT
signout_request= Net::HTTP::Delete.new('/profile/users/sign_out')
signout_request.set_form_data({"authenticity_token"=>get_crsf_token(get_home_arr[2])})
signout_request['Cookie']= get_home_arr[2]['Set-Cookie']
output= http.request(signout_request) #html body








