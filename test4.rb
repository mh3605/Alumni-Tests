#login
#look at all faculty
#edit faculty
#add new faculty
#delete faculty that was added
#look at all 
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

80.times do

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

#GET ALL FACULTIES
get_faculties_arr = get_with_cookie('/faculties',login_output['Set-Cookie'],http)

#GET FACULTY2
get_faculty2_arr = get_with_cookie('/faculties/2', get_faculties_arr[2]['Set-Cookie'],http)

#EDIT FACULTY2
get_edit_faculty2_arr= get_with_cookie('/faculties/2/edit', get_faculty2_arr[2]['Set-Cookie'],http)

new_uid= rand(1..1000)

edit_faculty2_form= {"utf8"=>"✓", "authenticity_token"=>get_edit_faculty2_arr[0], "faculty[name]"=>"Elaine Shi", 
						"faculty[uid]"=>new_uid, "faculty[email]"=> "shi@cs.umd.edu", "faculty[about]"=> "all about Elaine", 
						"faculty[department_id]"=>"1", "faculty[researcharea_id]"=>"1", "commit"=>"Update Faculty" }
edit_faculty2_arr= patch_with_cookie('/faculties/2', edit_faculty2_form, get_edit_faculty2_arr[2]['Set-Cookie'], http)

#GET NEW FACULTY
get_faculties_arr = get_with_cookie('/faculties/new', login_output['Set-Cookie'],http)

#ADD NEW FACULTY
add_new_faculty_form= {"utf8"=>"✓", "authenticity_token"=>get_faculties_arr[0], "faculty[name]"=>"Marine Carpuat", 
						"faculty[uid]"=>"222", "faculty[email]"=> "carpuat@cs.umd.edu", "faculty[about]"=> "all about Marine", 
						"faculty[department_id]"=>"1", "faculty[researcharea_id]"=>"1", "commit"=>"Update Faculty" }
add_new_faculty_arr= post_with_cookie('/faculties', add_new_faculty_form, get_faculties_arr[2]['Set-Cookie'], http)

#gets new faculty id
add_new_faculty_arr[2].body=~ /localhost:3000\/faculties\/(\d*)"/
new_faculty_id= $1

#GET FACULTY
get_faculties_arr = get_with_cookie('/faculties', add_new_faculty_arr[2]['Set-Cookie'],http)

#DELETE FACULTY
delete_faculty_request= Net::HTTP::Delete.new("/faculties/#{new_faculty_id}")
delete_faculty_request.set_form_data({"authenticity_token"=>get_crsf_token(get_faculties_arr[2])})
delete_faculty_request['Cookie']= get_faculties_arr[2]['Set-Cookie']
delete_faculty_output= http.request(delete_faculty_request) #html body

#GET FACULTIES
get_faculties_arr = get_with_cookie('/faculties', delete_faculty_output['Set-Cookie'],http)

#LOGOUT
signout_request= Net::HTTP::Delete.new('/profile/users/sign_out')
signout_request.set_form_data({"authenticity_token"=>get_crsf_token(get_faculties_arr[2])})
signout_request['Cookie']= get_faculties_arr[2]['Set-Cookie']
output= http.request(signout_request) #html body

end 

end_time= Time.now

diff= end_time-start_time
diff=diff*1000

puts "Started at: #{start_time}"
puts "Ended at: #{end_time}"
puts "Test took #{diff} ms"


