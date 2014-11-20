class SsoController < ApplicationController
  unloadable
  skip_before_filter :check_if_login_required, :only => [:login]
	before_filter :init_cas, :only=> [:login]

 attr_reader :user

  def login

    if @cas.authenticate(self)
        @user = User.find_by_login(session[:cas_user])
        if user.nil?
                logger.info "##User not registered##"
                self.create
        else
                logger.info "##user registered##"
                self.user_access
        end
    else
        self.reset
    end
  end


  def logout
    	cookies.delete :autologin
    	Token.delete_all(["user_id = ? AND action = ?"\
		, User.current.id, 'autologin']) if User.current.logged?
    	self.logged_user = nil
	logger.info "Session Information #{session.inspect}"
	init_cas
	@cas.logout(self)
  end

  def create
	@user = @cas.onthefly(session[:cas_user])
	if @user.save
          self.logged_user = user
          flash[:notice] = l(:LPLnotice_account_activated)
          redirect_to :controller => "my", :action => "account"
        else
          flash[:error] = l(:notice_account_invalid_creditentials)
          redirect_to :controller => "account", :action => "register"
        end
  end

  def reset
	reset_session
  end

def user_access
	logged_user 

        call_hook(:controller_account_success_authentication_after,\
		 {:user => user })
        if user.registered?  # On active le compte s'il n'est pas actif
          	user.activate
		flash[:notice] = l(:notice_account_activated)
	end
	redirect_back_or_default :controller => 'my', :action => 'page'
	end

  def login
   
    if @cas.authenticate(self) 
      	@user = User.find_by_login(session[:cas_user])
      	if user.nil?
		self.create
     	else
        	self.user_access         
      	end
    else
	self.reset
    end
  end
 private
  def logged_user
    if user && user.is_a?(User)
      User.current = user
      session[:user_id] = user.id
    else
      User.current = User.anonymous
      session[:user_id] = nil
    end
  end

  def init_cas
	@cas = Cas.new
    	render_404 unless @cas
  end
end
