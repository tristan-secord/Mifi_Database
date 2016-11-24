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

	def signin
		if request.post?
			if params && params[:email] && params[:password] && params[:device_id]
				user = User.where(:email => params[:email]).first

				if user
					if User.authenticate(params[:email], params[:password])
						device = Device.where(:device_id => params[:device_id]).first
						if device
							if !device.api_authtoken || (device.api_authtoken && device.authtoken_expiry < Time.now)
								auth_token = rand_string(20)
								auth_expiry = Time.now + (24*60*60*30)
								while User.where(:api_authtoken => auth_token).first != nil
									auth_token = rand_string(20)
									auth_expiry = Time.now + (24*60*60*30)
								end
								device.update_attributes(:api_authtoken => auth_token, :authtoken_expiry => auth_expiry)
							end
						else
							auth_token = rand_string(20)
							auth_expiry = Time.now + (24*60*60*30)
							while User.where(:api_authtoken => auth_token).first != nil
									auth_token = rand_string(20)
									auth_expiry = Time.now + (24*60*60*30)
							end
							device = Device.new(:user_id => user[:id], :device_id => params[:device_id], :api_authtoken => auth_token, :authtoken_expiry => auth_expiry)
						end
						device.save
						render :json => device.as_json(:only => [:api_authtoken, :authtoken_expiry]), status => 200
					else
						e = Error.new(:status => 401, :message => "I think you may have entered the wrong password...")
						render :json => e.to_json, :status => 401
					end
				else
					e = Error.new(:status => 400, :message => "Huh... Looks like we can't find any user by that email.")
					render :json => e.to_json, :status => 400
				end
			else
				e = Error.new(:status => 400, :message => "Looks like your missing some vital information!")
				render :json => e.to_json, :status => 400
			end 
		end
	end


	def rand_string(len)
    	o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    	string  =  (0..len).map{ o[rand(o.length)]  }.join

    	return string
  	end

	def user_params
	    params.require(:user).permit(:first_name, :last_name, :email, :username, :password, :password_hash, :password_salt, :verification_code, 
	    :email_verification, :api_authtoken, :authtoken_expiry)
	end

	 def check_for_valid_authtoken
    	authenticate_or_request_with_http_token do |token, options|     
      		@device = Device.where('users.api_authtoken = ? AND users.authtoken_expiry > ?', token, Time.now).first
      		@user = User.where('id = ?', @device[:user_id]).first
    	end
    end	
end
