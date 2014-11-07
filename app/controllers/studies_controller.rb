#class StudiesController < ApplicationController
class StudiesController < ApplicationController
  unloadable

  layout 'admin'
  before_filter :require_admin

  # Création d'une filière et d'un groupe correspondant
  def create

    @study = Study.new
      study = params[:study]
      @study.ldap_id = study[:ldap_id]
      @study.group_name = study[:group_name]
      #verifications du champ de saisie
      if !@study.ldap_id.nil? && !@study.group_name.nil?
              @study.save
              # créé le groupe à la volée
              Group.new(:lastname =>study[:group_name]).save
            else
              create
        end
        render :index
  end

  def show
    @studies = Study.find(:all)
    render :index
  end

  # @caption  le nom d'une filière utilisé par la template
  def show_user_list
    #logger.info "from user show"
    user_list
    group_name = Study.find(params[:id]).group_name
    @caption = group_name
    logger.info "CAPTION \n#{@caption} RESULT \n #{@result}"
    @studies = Study.find(:all)
    render :index
  end

  # @result contient la liste de ses utilisateurs
  def user_list
    ldap = LdapController.new

    @result = ldap.search(Study.find(params[:id]).ldap_id)
    #logger.info "from user #{Study.find(params[:id]).ldap_id} list #{@result} gt"
  end

  # Informe la variable @studies qui contient toute les filières déclarées
  def index
      @studies = Study.find(:all)
      render :index
  end

  # Supprime la filière ainsi que le groupe correspondant
  def destroy
    study = Study.find_by_id(params[:id])
    #supprime le groupe si il ne l'est aps dèjà
    if Group.find_by_lastname(study[:group_name])
      Group.find_by_lastname(study[:group_name]).destroy
    end
    #supprime la filière
    study.destroy

    render :index
  end

  # Renvoie un Objet Utilisateur
  # Défini depuis les informations LDAP
  def define_user(student,ldap_id)
    user = User.new
    user.login = student["uid"]
    user.firstname = student["displayname"].split[0]
    user.lastname = student["displayname"].split[1]
    user.mail = student["mail"]
    #user.cas = 'auacas'
    user.aua_statut = "etu"
    user.aua_millesime = ldap_id
    user.admin = false
    user.status = User::STATUS_ACTIVE

    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    password = ''
    40.times { |i| password << chars[rand(chars.size-1)] }
    user.password = password
    user.password_confirmation = password
    return user
  end

  # Ajoute les étudiants d'une filière comme utilisateurs du groupe
  # correspondant
  def add_users_to_group

    study = Study.find(params[:id])
    ldap_id = study.id
    # ldap identifier of the group ex:SLPIN1 => Licence Pro
    group_id = Group.find_by_lastname(study.group_name).id
    # Initialise la @result
    user_list
    # @result contient la List d'utilisateur appartenant a une filière
    if defined? @result
      logger.info "result is defined þð #{@result}"
      # enumeration du contenu de l'agenda utilisateur
      @result.each do |student|
          # Si l'utilisateur n' est pas déjà enregistré
          if !User.find_by_login(student["uid"])
            user = define_user(student,group_id)
            # L'utlisateur est conforme
            if user.valid?
              user.save
            else
              logger.info "USER INFO FRom ldapC..#add_user#{user.errors.full_messages}"
            end # Utilisateur valide ?
          end # Création d'un nouvel utilisateur
          user = User.find_by_login(student["uid"])
          group = Group.find_by_id(group_id)
          if !group.users.include?(user)
            group.users << user
          end
        end # end each
        # Ajoute l'utilisateur à un groupe

    end # if defined?
    logger.info "result not defined"
    redirect_to "/studies"
  end

  def destroy_users
    param_id = params[:id]
    logger.info "param_id #{param_id}"
    study = Study.find(param_id)
    logger.info " study #{study[:group_name]}"
    group_id = Group.find_by_lastname(study[:group_name])[:id]
    logger.info "GRoup_id #{group_id}"
    group  = Group.find(group_id)
      group.users.each do |user|
        logger.info " USER #{user.inspect}"
        logger.info " will be delete #{user[:lastname]}"
        user.destroy
      end

    logger.info "from destroy user"
    redirect_to "/studies/"
  end

  def remove
    logger.info "From delete method #{params[:id]}"
      study = Study.find_by_id(params[:id])
      study.destroy
      redirect_to "/studies/"
  end

end
