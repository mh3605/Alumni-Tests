# coding: utf-8
require "net/http"
require "uri"
http = Net::HTTP.new('localhost', 3000)

### 1. Delete 2002 from years
### 2. Delete Jonathon Katz
### 3. Change Elaine Shi's research area to something thats not security

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

#not tested yet
def delete_with_cookie(uri, old_cookie, http)
	req= Net::HTTP::Delete.new(uri)
	req['Cookie']= old_cookie
	output= http.request(req)
	(output.body=~ /name="authenticity_token" value="(.*)"/)
	token =$1
	arr=[token, req['Set-Cookie'], output]
	return arr
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

#request 4A: GET ALUM8
get_alum8_arr = get_with_cookie('/alums/8', get_alum1_arr[2]['Set-Cookie'],http)

#request 4B: GET ALUM8/EDIT
edit_alum8_arr= get_with_cookie('/alums/8/edit', get_alum8_arr[2]['Set-Cookie'],http)
#puts edit_alum8_arr[0] #token

#request 4C: EDIT ALUM8
new_uid= rand(1..1000)
puts "Sarah's new UID shoudl be #{new_uid}."

edit_alum8_form= {"utf8"=>"✓", "authenticity_token"=>edit_alum8_arr[0], "alum[name]"=>"Sarah",
								 "alum[uid]"=>new_uid, "alum[email]"=>"", "alum[phone]"=>"", 
								"alum[about]"=>"", "alum[faculty_id]"=>"2", "alum[year_id]"=>"", "alum[department_id]"=>"1", 
								"alum[researcharea_id]"=>"", "alum[initialemployer_id]"=>"", "commit"=>"Update Alum", "id"=>"8"}
edit_alum8_arr= patch_with_cookie('/alums/8', edit_alum8_form, get_alum8_arr[2]['Set-Cookie'], http)


=begin #patch alum with patchwithcookie method
			edit_alum8_request = Net::HTTP::Patch.new('/alums/8')
			edit_alum8_request.set_form_data({"utf8"=>"✓", "authenticity_token"=>edit_alum8_arr[0], "alum[name]"=>"Sarah",
											 "alum[uid]"=>"250", "alum[email]"=>"", "alum[phone]"=>"", 
											"alum[about]"=>"", "alum[faculty_id]"=>"", "alum[year_id]"=>"", "alum[department_id]"=>"", 
											"alum[researcharea_id]"=>"", "alum[initialemployer_id]"=>"", "commit"=>"Update Alum", "id"=>"8"})
			edit_alum8_request['Cookie'] = get_alum8_arr[2]['Set-Cookie']
			edit_alum8_output = http.request(edit_alum8_request)
=end

#request 5A: GET NEW YEARS 
get_years_arr= get_with_cookie('/years/new', edit_alum8_arr[2]['Set-Cookie'], http)

#request 5B: ADD NEW YEAR
add_new_year_form= {"utf8"=>"✓", "authenticity_token"=>get_years_arr[0], "year[yr]"=>"2002", "commit"=>"Create Year"}
add_new_year_arr= post_with_cookie('/years', add_new_year_form, get_years_arr[2]['Set-Cookie'], http)

#request 6A: GET NEW FACULTIES
get_faculties_arr = get_with_cookie('/faculties/new', add_new_year_arr[2]['Set-Cookie'],http)

#request 6B: ADD NEW FACULTY
add_new_faculty_form= {"utf8"=>"✓", "authenticity_token"=>get_faculties_arr[0], "faculty[name]"=>"Jonathon Katz", 
						"faculty[uid]"=>"932804", "faculty[email]"=> "katz@cs.umd.edu", "faculty[about]"=> "all about dr. katz", 
						"faculty[department_id]"=>"", "faculty[researcharea_id]"=>"3", "commit"=>"Create Faculty" }
add_new_faculty_arr= post_with_cookie('/faculties', add_new_faculty_form, get_faculties_arr[2]['Set-Cookie'], http)

#request 7A: GET FACULTY2/EDIT
get_faculty2_arr= get_with_cookie('/faculties/2/edit', add_new_faculty_arr[2]['Set-Cookie'],http)
#puts edit_alum8_arr[0] #token

#request 7B: EDIT FACUTLY2
edit_faculty2_form= {"utf8"=>"✓", "authenticity_token"=>get_faculty2_arr[0], "faculty[name]"=>"Elaine Shi", 
						"faculty[uid]"=>"932804", "faculty[email]"=> "shi@cs.umd.edu", "faculty[about]"=> "all about Elaine", 
						"faculty[department_id]"=>"1", "faculty[researcharea_id]"=>"1", "commit"=>"Update Faculty" }
edit_faculty2_arr= patch_with_cookie('/faculties/2', edit_faculty2_form, get_faculty2_arr[2]['Set-Cookie'], http)




end_time= Time.now

diff= end_time-start_time
diff=diff*1000

puts "Started at: #{start_time}"
puts "Ended at: #{end_time}"
puts "Test took #{diff} ms"








