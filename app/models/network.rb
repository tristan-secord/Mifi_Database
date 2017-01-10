class Network < ActiveRecord::Base
  ActiveRecord::Base.include_root_in_json = false
  attr_accessor :password
  before_save :encrypt_password

  validates_confirmation_of :password
  validates_presence_of [:name], :on => :create
  validates_presence_of [:discoverable], :on => :create
  validates :password, length: { in: 6..30 }, :on => :create

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def self.authenticate(login_name, password)
    network = self.where("name =?", login_name).first

    if network
      begin
        password = AESCrypt.decrypt(password, ENV["API_AUTH_PASSWORD"])
      rescue Exception => e
        password = nil
        puts "error - #{e.message}"
      end

      if network.password_hash == BCrypt::Engine.hash_secret(password, network.password_salt)
        network
      else
        nil
      end
    else
      nil
    end
  end
end
