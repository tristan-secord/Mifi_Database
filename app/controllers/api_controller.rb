class ApiController < ApplicationController
	http_basic_authenticate_with name:ENV["API_AUTH_NAME"], password:ENV["API_AUTH_PASSWORD"], :only => [:signup, :signin, :get_token]
	before_action :check_for_valid_authtoken, :except => [:signup, :signin, :get_token]

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
								while Device.where(:api_authtoken => auth_token).first != nil
									auth_token = rand_string(20)
									auth_expiry = Time.now + (24*60*60*30)
								end
								device.update_attributes(:api_authtoken => auth_token, :authtoken_expiry => auth_expiry)
							end
						else
							auth_token = rand_string(20)
							auth_expiry = Time.now + (24*60*60*30)
							while Device.where(:api_authtoken => auth_token).first != nil
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

  def add_network
    if request.post?
      if params && params[:name] && params[:password] && params[:discoverable] && params[:latitude] && params[:longitude] && params[:bssid]
        params[:network] = Hash.new
        params[:network][:name] = params[:name]
        params[:network][:discoverable] = params[:discoverable]
        params[:network][:latitude] = params[:latitude]
        params[:network][:longitude] = params[:longitude]

        begin
					decrypted_pass = AESCrypt.decrypt(params[:password], ENV["API_AUTH_PASSWORD"])
          decrypted_bssid = AESCrypt.decrypt(params[:bssid], ENV["API_AUTH_PASSWORD"])
				rescue Exception => e
					decrypted_pass = nil
          decrypted_bssid = nil
				end

        params[:network][:password] = decrypted_pass
        params[:network][:bssid] = decrypted_bssid

        network = Network.new(network_params)

        if network.save
          #
					render :nothing => true, :status => 200
				else
					error_str = ""

          network.errors.each{|attr, msg|
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

  # Using the approximation that 111 km = 1 deg. lat and 111 * cos (lat) km = 1 deg lng in order to speed up processing time
  #  and speed up number of returns in query:
  # if 111 km = 1 deg. lat then 1 km = 1 / 111 deg. lat
  # if 111 * cos (lat) km = 1 deg lng then 1 km = 1 / 111 * cos (lat)
  def search_networks
    if request.post?
      if params && params[:latitude] && params[:longitude]
        latitude = params[:latitude].to_f
        longitude = params[:longitude].to_f

        @possible_networks = Network.where('? < networks.latitude AND networks.latitude < ? AND ? < networks.longitude AND networks.longitude < ?', (latitude - 1.0 / 111), (latitude + 1.0 / 111), (longitude - 1.0 / (111 * Math.cos(latitude))), (longitude + 1.0 / (111 * Math.cos(latitude))))

        # CHANGE
        ## Haversine function is computationally heavy - by reducing the search above and using possible networks
        ## it reduces the computation on the server
        ## MAY NEED TO CHANGE THIS TO A SPECIFIC QUEUE
        ## Should also order from closest to furthest
        @verified_networks = []
        for network in @possible_networks
          if (Haversine.distance(latitude, longitude, network[:latitude], network[:longitude]).to_meters <= 500)
            @verified_networks << network
          end
        end
        render :json => @verified_networks.as_json, :status => 200
      else
        e = Error.new(:status => 400, :message => "Looks like your missing some vital information!")
        render :json =>  e.to_json, :status => 400
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

  def network_params
    params.require(:network).permit(:name, :discoverable, :password, :password_hash, :password_salt, :latitude, :longitude)
  end

	 def check_for_valid_authtoken
    	authenticate_or_request_with_http_token do |token, options|
      		@device = Device.where('users.api_authtoken = ? AND users.authtoken_expiry > ?', token, Time.now).first
      		@user = User.where('id = ?', @device[:user_id]).first
    	end
    end
end
