class ApiController < ApplicationController
	http_basic_authenticate_with name:ENV["API_AUTH_NAME"], password:ENV["API_AUTH_PASSWORD"], :only => [:signup, :signin, :get_token]  
	before_filter :check_for_valid_authtoken, :except => [:signup, :signin, :get_token]

	def signup
		if request.post?
			if params && params[:first_name] && params[:last_name] && params[:email] && params[:password]

				params[:user] = Hash.new
				params[:user][:first_name] = params[:first_name]
				params[:user][:last_name] = params[:last_name]
				params[:user][:email] = params[:email]

				begin
					decrypted_pass = AESCrypt.decrypt(params[:password], ENV["API_AUTH_PASSWORD"])
				rescue Exception => e
					decrypted_pass = nil
				end

				params[:user][:password] = decrypted_pass
				params[:user][:verification_code] = rand_string(20)

				user = User.new(user_params)

				if user.save
					render :json => user.to_json, :status => 200
				else 
					error_str = ""

					user.errors.each{|attr, msg|
						error_str += "#{attr} - #{msg}\n"
					}

					e = Error.new(:status => 400, :message => error_str)
					render :json => e.to_json, :status => 400
				end
			else
				e = Error.new(:status => 400, :message => "Looks like your missing some vital information!")
				render :json => e.to_json, :status => 400
			end
		end
	end	

	def test
		render :json => "Success".as_json
	end
end
