require 'rubygems'
require 'casclient'
require 'casclient/frameworks/rails/filter'
require 'net/ldap'
require_dependency 'user_patch'


class Cas < ActiveRecord::Base
 unloadable
 has_many :users

 attr_reader :mldap, :login, :user, :labo, :labo_user, :basen, :entry, :url

  def authenticate(controller)
	init_client
	CASClient::Frameworks::Rails::Filter.filter(controller)
  end
 def bind
	ldap = Net::LDAP::new
       	ldap.host = 'castor.info-ua'
       	ldap.port = 389
	ldap.base = 'OU=people,DC=univ-angers,DC=fr'
        @mldap = ldap
 end
 
 def set_login(login)
	@login = login
 end

 def setup_filter(field,value)
	if value.nil?
		warn " value is nil in setup_filter #{field} #{value.inspect}"
	end 
	f = Net::LDAP::Filter.eq(field,value)
	return f
 end

 def setup
#filters
	@user_filter = self.setup_filter('uid',@login)
	@labo_filter = self.setup_filter('auastatut','perso')
	@labo_user_filter = @user_filter & @labo_filter
		
	#attribute
	@lab_attr = Array.new
	@lab_attr = ['auastatut','uid']
	@user_attr = ['givenName', 'sn', 'mail','displayname',\
	 'auaStatut', 'eduPersonAffiliation','auaEtapeMillesime']	
 end

 def search(filter,attr)
	mfilter =Net::LDAP::Filter.eq('uid','thierry.forest')

	@mldap.search(:filter => filter, :attributes => attr,\
	:return_result => false)do |entry|
		@entry= entry
	end	
 end

 def init(login)
	self.bind
	self.set_login(login)
	self.setup
	logger.info " bind ok"
 end

 def to_hash
	attrs = Array.new
	hash = Hash.new
 end

 def create_user
		user = User.new
		if user.save
			logger.info "before gett to the truth"
		else
			logger.info "where is the thruth"
		end
		user.login = @login
		fullname = @entry[:displayname].first
		firstname = fullname.split.first
		lastname = fullname.split.last
		logger.info "HELOO #{firstname} #{fullname}"
		user.firstname = firstname
		user.lastname = lastname
		user.mail = @entry[:mail]
		user.aua_statut = @entry[:auastatut]
		
		user.admin = false
		user.status = User::STATUS_ACTIVE
      		chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      		password = ''
      		40.times { |i| password << chars[rand(chars.size-1)] }
      		user.password = password
      		user.password_confirmation = password
		if user.save
			logger.info "YUOUPPI"
		else 
			logger.info "WIRED DO"
		end
		@user = user
 end
	
 def create_student
	self.create_user
 end

 def create_perso
	self.create_user
 end

 def is_staff(login)
	self.init(login)
	if self.search(@labo_user_filter,@lab_attr)
  		return true
	else 
		return false
	end
 end

 def onthefly(login) 
   	self.init(login)
	self.search(@user_filter,@user_attr) 
   	if @entry
	 case entry.auastatut.first
		when "etu-sortant"	
			entry[:auastatut] = ['out']
			self.create_student
		when "etu"
			self.create_student
		when "perso"
			self.create_perso
		else
		logger.info "BLAH"
	 end
	else
	logger.info "Noentry"
		end
	return user
 end		
  
 def logout(controller)
     c = init_client
     controller.send(:reset_session)
     controller.send(:redirect_to, c.logout_url(controller.url_for(:action=>"index",:controller=>"welcome")))
  end

private
  def init_client
      CASClient::Frameworks::Rails::Filter.configure(:cas_base_url => "https://cas.univ-angers.fr/cas")
      return CASClient::Frameworks::Rails::Filter.client
  end

end
