require 'set'
require 'rubygems'
require 'net/ldap'
class LdapController < ApplicationController
unloadable
   layout 'admin'
   before_filter :require_admin

   verify :method => :post, :only => [:show]
  def bind
   ldap = Net::LDAP::new
   ldap.host = 'castor.info-ua'
   ldap.port = 389
   ldap.base = 'OU=people,DC=univ-angers,DC=fr'
   return ldap

  end

  def setup(id)
        ldap = self.bind
        @ldap_id = id.to_s
        @year = Time.now.year.to_s
        return ldap
  end

  def filter
    filter = Net::LDAP::Filter.eq("auaetapemillesime", @year+@ldap_id)\
    & Net::LDAP::Filter.eq("auastatut", "etu")\
    & Net::LDAP::Filter.eq("displayname","*Clement*")
    return filter
  end

  def search(id)
    result = Set.new
    ldap = self.setup(id)
    logger.info "Ldap #{ldap.inspect}"
    attrs = ['uid','displayname','mail', 'auaetapemillesime']
    ldap.search(:base => ldap.base, :filter => self.filter, :attributes => attrs)do |entry|
      entry_uid = Hash.new
      entry.each do |attribute,values|
          values.each do | value |
              entry_uid["#{attribute}"] = "#{value}"
          end
      end
        logger.info "Result #{result.inspect}"
    result.add(entry_uid)
    end
    return result
  end

  def show
      group_name = Study.find(:all,:conditions=>["ldap_id = ?", params[:ldap_id]]).first.group_name
      @caption = group_name
      logger.info " CAPTION #{@caption.inspect}"
      @result = search(params[:ldap_id])
  end

  def create_group(group_name)
    @group = Group.new
    @group.lastname = group_name
    @group.save
    logger.info "GRoupe #{group_name} created"
    return @group
  end

  def add_user
    @result = search(params[:ldap_id])

    @result.each do |student|
      if User.find_by_login(student["uid"])
        logger.info "user exist"
      else
        user = User.new
        user.login = student["uid"]
        user.firstname = student["displayname"].split[0]
        user.lastname = student["displayname"].split[1]
        user.mail = student["mail"]
        #user.cas = 'auacas'
        user.aua_statut = "etu"
        user.aua_millesime = params[:ldap_id]
        user.admin = false
        user.status = User::STATUS_ACTIVE

      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      password = ''
      40.times { |i| password << chars[rand(chars.size-1)] }
      user.password = password
      user.password_confirmation = password

            if user.valid?
                user.save
                #get the group
                group_name = Study.find(:all, :conditions => ["ldap_id = ?", params[:ldap_id]]).first.group_name
                check_group = Group.find(:all,:conditions => ["lastname = ?", group_name])
                logger.info "checkgroup #{check_group}"
                if check_group
                  @group = check_group
                else
                  logger.info "group not found"
                  @group = create_group(params[:group_name])
                end
                logger.info " USER #{user.id} #{user.login} "
                logger.info " GRoup  sd #{@group[0].id}"
                @groups = Group.find_by_id(@group[0].id)
                @groups.users << user

          #logger.info "Utilisateurs  #{user.login} intégré au groupe #{@group["lastname"]}"
                else
          logger.info "USER INFO FRom ldapC..#add_user#{user.errors.full_messages}"
            end
        end
      end
        redirect_to "/users"
      end
end
