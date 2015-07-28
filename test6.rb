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
