# coding: utf-8
require "net/http"
require "uri"
http = Net::HTTP.new('localhost', 3000)

#unfinushed method
def get_with_cookie(uri, old_cookie, http)
	#res= Net::HTTP.get_response('localhost', uri, 3000)
	req = Net::HTTP::Get.new(uri)
	req['Cookie']= old_cookie
	output= http.request(req) #html body
	(output.body=~ /name="authenticity_token" value="(.*)"/)
	token =$1
	#puts "Request body:#{output.body}"
	#puts "Token is: #{token}"
	arr=[token, req['Set-Cookie'], output]
	return arr
	#returns [token, new_cookie, output]
end

start_time= Time.now

Net::HTTP.get('localhost', '/', 3000)
#request 1: LOGIN
login_res = Net::HTTP.get_response('localhost', '/profile/users/sign_in', 3000)
login_res.body =~ /name="authenticity_token" value="(.*)"/ #get the token from the response
login_form_token = $1
#puts " \n\n Login form authenticity token is: #{login_form_token}\n\n"
#puts " Login Cookie is #{login_res['Set-Cookie']}\n\n"


login_request = Net::HTTP::Post.new('/profile/users/sign_in')
login_request.set_form_data({"utf8"=>"✓", "authenticity_token"=>login_form_token,
                       "user[email]"=>"admin@gmail.com", "user[password]"=>"password",
                       "user[remember_me]"=>"0", "commit"=>"Log in"})
login_request['Cookie'] = login_res['Set-Cookie']
login_output = http.request(login_request)

#request 2: GET HOMEPAGE
get_homepage_arr = get_with_cookie('/', login_output['Set-Cookie'],http)

=begin #get_homepage without getwithcookie method
		get_homepage_request = Net::HTTP::Get.new('/')
		get_homepage_request['Cookie'] = login_output['Set-Cookie']
		get_homepage_output = http.request(get_homepage_request)
=end

#request 3: GET ALUM1
get_alum1_arr = get_with_cookie('/alums/1',get_homepage_arr[2]['Set-Cookie'],http)

=begin #get alum1 without getwithcookie method
		get_alum1_request = Net::HTTP::Get.new('/alums/1')
		get_alum1_request['Cookie'] = get_homepage_output['Set-Cookie']
		get_alum1_output = http.request(get_alum1_request)
=end

#request 4: GET ALUM8
get_alum8_arr = get_with_cookie('/alums/8', get_alum1_arr[2]['Set-Cookie'],http)

#request 5: GET ALUM8/EDIT
edit_alum8_arr= get_with_cookie('/alums/8/edit', get_alum8_arr[2]['Set-Cookie'],http)
puts edit_alum8_arr[0] 

edit_alum8_request = Net::HTTP::Patch.new('/alums/8')
edit_alum8_request.set_form_data({"utf8"=>"✓", "authenticity_token"=>edit_alum8_arr[0], "alum[name]"=>"Sarah",
								 "alum[uid]"=>"250", "alum[email]"=>"", "alum[phone]"=>"", 
								"alum[about]"=>"", "alum[faculty_id]"=>"", "alum[year_id]"=>"", "alum[department_id]"=>"", 
								"alum[researcharea_id]"=>"", "alum[initialemployer_id]"=>"", "commit"=>"Update Alum", "id"=>"8"})
edit_alum8_request['Cookie'] = get_alum8_arr[2]['Set-Cookie']
edit_alum8_output = http.request(edit_alum8_request)






#puts out2

end_time= Time.now

diff= end_time-start_time
diff=diff*1000

puts "Started at: #{start_time}"
puts "Ended at: #{end_time}"
puts "Test took #{diff} ms"








