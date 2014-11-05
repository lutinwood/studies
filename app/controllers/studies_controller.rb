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

  # @caption  le nom d'une filière utilisé par la template
  def show
    user_list
    group_name = Study.find(:all,:conditions=>["ldap_id = ?", params[:ldap_id]]).first.group_name
    @caption = group_name

    render :index
  end

  # @result contient la liste de ses utilisateurs
  def user_list
    ldap = LdapController.new
    @result = ldap.search(params[:ldap_id])
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

  # Retourne l'id d'un groupe correspondant à une filière
  # depuis une jointure interne
  def get_group_id(ldap_id)
    # get the id by inner join
    id = Group.find_by_sql("\
    SELECT users.id \
    FROM studies INNER JOIN users \
    ON studies.group_name = users.lastname \
    WHERE studies.ldap_id = '" + ldap_id + "'")
    return id
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
    logger.info "FROM add_users "
    ldap_id = params[:ldap_id]
    # ldap identifier of the group ex:SLPIN1 => Licence Pro
    group_id = get_group_id(ldap_id)

    # Initialise la @result
    user_list

    # @result contient la List d'utilisateur appartenant a une filière
    if defined? @result
      logger.info "result is defined "
      # enumeration du contenu de l'agenda utilisateur
      @result.each do |student|
        logger.info "student"
          # Si l'utilisateur n' est pas déjà enregistré
          if !User.find_by_login(student["uid"])
            user = define_user(student,group_id)
            # L'utlisateur est conforme
            if user.valid?
              user.save
            else
              logger.info "USER INFO FRom ldapC..#add_user#{user.errors.full_messages}"
            end # Utilisateur valide ?
            logger.info " new user"
          end # Création d'un nouvel utilisateur
          logger.info "already user"
          user = User.find_by_login(student["uid"])
          group = Group.find_by_id(group_id)
          logger.info "User : #{user} Group : #{group}"
          group.users << user
          logger.info "TEST U #{user} TEST G #{group}"
        end # end each
        # Ajoute l'utilisateur à un groupe

    end # if defined?
    logger.info "result not defined"
    redirect_to "/studies"
  end

  def count_user_in_group
  end

  def destroy_users
    group_id = params[:id]
    logger.info "GRoup_id #{group_id}"
    users_to_delete = User.find_by_sql(\
    "SELECT user_id FROM groups_users WHERE group_id ="+ group_id + " ")
    logger.info "USERS #{users_to_delete.inspect}"
    users_to_delete.each do |user|
        logger.info " will be delete #{user[:lastname]}"
        user.destroy
    end
    logger.info "from destroy user"
    render :index
  end

  def delete
      study = Study.find_by_id(:params[:id])
      study.destroy
      redirect_to "/studies/"
  end

end
