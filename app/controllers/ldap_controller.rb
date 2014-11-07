require 'set'
require 'rubygems'
require 'net/ldap'
class LdapController < ApplicationController
unloadable
   layout 'admin'
   # Empèche l'acces par non admin
   before_filter :require_admin
   # Contrôle des envoies
   verify :method => :post, :only => [:show]

  # Renvoie un objet ldap défini
  def bind
   ldap = Net::LDAP::new
   ldap.host = 'castor.info-ua'
   ldap.port = 389
   ldap.base = 'OU=people,DC=univ-angers,DC=fr'
   return ldap
  end

  # Définition des variables globales depuis l'identifiant Ldap
  # -- ?? @test boolean
  # @ldap_id correspondant à la filière recherché
  # @year Time
  # renvoie L'objet ldap defini dans bind
  def setup(id)
        ldap = self.bind
        @test = true
        @ldap_id = id.to_s
        @year = Time.now.year.to_s
        return ldap
  end

  # utilise @ldap_id + @years
  # Renvoie un filtre ldap pour rechercher des etudiants
  def filter
    filter = Net::LDAP::Filter.eq("auaetapemillesime", @year+@ldap_id)\
    & Net::LDAP::Filter.eq("auastatut", "etu")
    return filter
  end

  # Initialise et defini l'objet ldap
  # Depuis l'identifiant ldap
  # Retourne un tableau trié contenant le resultat de la recherche
  def search(id)
    result = Array.new
    ldap = self.setup(id)
    #logger.info "ldap #{ldap}"
    attrs = ['uid','displayname','mail', 'auaetapemillesime']
    ldap.search(:base => ldap.base, :filter => self.filter,\
     :attributes => attrs)do |entry|
     #logger.info "ENTRY #{entry}"
      entry_uid = Hash.new
      entry.each do |attribute,values|
          values.each do | value |
      #      logger.info "VALUE #{value}"
              entry_uid["#{attribute}"] = "#{value}"
          end
      end
    result.push(entry_uid)
    end
    result = result.sort_by {|name|name["displayname"]}
    #logger.info "from ldap search #{result}"
    return result
  end

end
