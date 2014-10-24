#class StudiesController < ApplicationController
class StudiesController < ApplicationController
  unloadable

  layout 'admin'
  before_filter :require_admin

  def new
    @study = Study.new
  end

  def create
    @study = Study.new
      study = params[:study]
      @study.ldap_id = study[:ldap_id]
      @study.group_name = study[:group_name]
      #verifications du champ de saisie
      if !@study.ldap_id.nil? && !@study.group_name.nil?
              @study.save
            else
              create
        end
    show
  end

  def update
    warn "params #{params.inspect}"
    redirect_to "/studies/"
  end

  def show
    @studies = Study.find(:all)
  end

  def index
      show
      new


  end

  def destroy
    study = Study.find_by_id(params[:id])
    #warn " Study #{study.inspect}"
    study.destroy
    redirect_to "/studies/"
  end

  def delete
      study = Study.find_by_id(:params[:id])
      study.destroy
      warn " Study destroy"
      redirect_to "/studies/"
  end
end
