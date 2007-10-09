# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'gettext/rails'

class ApplicationController < ActionController::Base

#  before_init_gettext :set_languages
  init_gettext "rged","UTF-8","text/html" # <= Also you can set charset and content_type.

  def set_languages
    #Règlage la langue
    if !params[:lang].nil?
      #Si il y a un paramètre pour changer la langue, vérification de l'existence de la  langue
      if File.exist?(RAILS_ROOT + '/po/'+params[:lang]) || File.exist?(RAILS_ROOT + '/po/'+params[:lang]+'_'+params[:lang].upcase)
        session[:lang] = params[:lang]
      else
        session[:lang] = nil
      end
    end
    begin
      #Si la langue choisie n'existe pas, ou si c'est la première visite
      if session[:lang].nil?
        break
      end
      #Si non, on règle simplement la langue
      set_locale session[:lang]
    rescue
      #Si le navigateur envoi des informations sur la langue
      if !request.env['HTTP_ACCEPT_LANGUAGE'].nil?
        #recherche de la langue du client
        langs = request.env['HTTP_ACCEPT_LANGUAGE'].gsub(/;q=[0-1]\.[0-9]/, '').split(',')
        langs.each do |i|
          #si elle n'existe pas, les langues secondaires sont étudiés
          if File.exist?(RAILS_ROOT+'/po/'+i) || File.exist?(RAILS_ROOT+'/po/'+i+'_'+i.upcase)
            session[:lang] = i
            break
          end
        end
      end
      #Si il n'en existe toujours pas, la langue est celle utilisée par default, dans la configuration de l'application
      if session[:lang].nil?
        session[:lang] = LANG
      end
      #Réglage final de la langue
      set_locale session[:lang]
    end
  end


  # Pick a unique cookie name to distinguish our session data from others'
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  include AuthenticatedSystem

  session :session_key => '_rged_session_id'
end
