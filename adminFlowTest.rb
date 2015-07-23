# coding: utf-8
require "net/http"
require "uri"
http = Net::HTTP.new('localhost', 3000)

#unfinushed method
def get_with_cookie(uri, old_cookie, http)
	res= Net::HTTP.get_response('localhost', uri, 3000)
	req = Net::HTTP::Get.new(uri)
	req['Cookie']= old_cookie
	arr=[res.body, req['Set-Cookie'], http.request(req)]
	return arr
	#returns [body, new_cookie, output]
end

start_time= Time.now

Net::HTTP.get('localhost', '/', 3000)
#request 1: LOGIN
login_res = Net::HTTP.get_response('localhost', '/profile/users/sign_in', 3000)
login_res.body =~ /name="authenticity_token" value="(.*)"/ #get the token from the response
login_form_token = $1
puts " \n\n Login form authenticity token is: #{login_form_token}\n\n"
puts " Login Cookie is #{login_res['Set-Cookie']}\n\n"


login_request = Net::HTTP::Post.new('/profile/users/sign_in')
login_request.set_form_data({"utf8"=>"✓", "authenticity_token"=>login_form_token,
                       "user[email]"=>"admin@gmail.com", "user[password]"=>"password",
                       "user[remember_me]"=>"0", "commit"=>"Log in"})
login_request['Cookie'] = login_res['Set-Cookie']
login_output = http.request(login_request)

#request 2: GET HOMEPAGE
get_homepage_request = Net::HTTP::Get.new('/')
get_homepage_request['Cookie'] = login_output['Set-Cookie']
get_homepage_output = http.request(get_homepage_request)

#request 3: GET ALUM1
get_alum1_request = Net::HTTP::Get.new('/alums/1')
get_alum1_request['Cookie'] = get_homepage_output['Set-Cookie']
get_alum1_output = http.request(get_alum1_request)

get_alum1_arr = get_with_cookie('/alums/1',get_homepage_output['Set-Cookie'],http)

#request 4: EDIT ALUM8's UID
edit_alum_request = Net::HTTP::Get.new('/alums/8')
edit_alum_request['Cookie'] = get_alum1_output['Set-Cookie']
edit_alum_output = http.request(edit_alum_request)


#edit_alum_res = Net::HTTP.get_response('localhost', '/alums/8/edit', 3000) 
#crashes on the line above (36), because user has no permission to edit alums and is redirected to '/' 
#you can see in the log it prints out that USER_ADMIN is false when it should be true
#I'm assuming it's because the user is stored in the cookie and the response doesn't have that (?) 

#edit_alum_res['Cookie'] = get_alum1_output['Set-Cookie']
#edit_alum_res.body =~ /name="authenticity_token" value="(.*)"/
#edit_alum_form_token = $1

#edit_alum_request = Net::HTTP::Patch.new('/alums/8')
#edit_alum_request.set_form_data({"utf8"=>"✓", "authenticity_token"=>edit_alum_form_token, "alum[uid]"=>"3894", "commit"=>"Update Alum", "id"=>"8"})
#edit_alum_request['Cookie'] = edit_alum_res['Set-Cookie']
#edit_alum_output = http.request(edit_alum_request)


#puts out2

end_time= Time.now

diff= end_time-start_time
diff=diff*1000

puts "Started at: #{start_time}"
puts "Ended at: #{end_time}"
puts "Test took #{diff} ms"








