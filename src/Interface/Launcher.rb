# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Alexandre DANJOU, Mendy FATNASSI, Fatih UFACIK  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

require 'gtk3'

require_relative "InterfaceAccueilJeu.rb"
require_relative "interfaceClassement.rb"

# Classe représentant le launcher de l'interface du menu.
# Cette classe contient la variable d'instance suivante :  
# @fenetre:: Fenêtre qui sera passée en paramètre au conteneur de nos autres fenêtres
class Launcher < Gtk::Builder

	# Méthode d'initialisation du launcher
	def initialize
		# Initialisation des fichiers
	    super()
	    self.add_from_file(__FILE__.sub(".rb",".glade"))
		# Création d'une variable d'instance par composant identifié dans glade
		puts "Création des variables d'instances"
		self.objects.each() { |p|
				unless p.builder_name.start_with?("___object")
					puts "\tCreation de la variable d'instance @#{p.builder_name}"
					instance_variable_set("@#{p.builder_name}".intern, self[p.builder_name])
				end
		}

		# Paramètre global de la fenêtre qui sera passée en paramètre au conteneur de nos autres fenêtres
		@fenetre.set_resizable(false)
        @fenetre.set_default_size(900,400)
		@fenetre.set_icon("../res/img/ico.ico")
		@fenetre.set_title("Hashi")
		@fenetre.show_all
		@fenetre.set_window_position Gtk::WindowPosition::CENTER_ALWAYS
		@fenetre.signal_connect('destroy') { puts "Au Revoir !!!"; Gtk.main_quit }

		# On connecte les signaux aux méthodes (qui doivent exister)
		puts "\nConnexion des signaux"
		self.connect_signals { |handler|
				puts "\tConnection du signal #{handler}"
				begin
					method(handler)
				rescue
					puts "\t\t[Attention] Vous devez definir la methode #{handler} :\n\t\t\tdef #{handler}\n\t\t\t\t....\n\t\t\tend\n"
					self.class.send( :define_method, handler.intern) {
						puts "La methode #{handler} n'est pas encore définie.. Arrêt"
						Gtk.main_quit
					}
					retry
				end
		}

		# Création du classement s'il n'est pas créé 
		Classement.creeSiBesoinBDDClassement();

        # On lance l'interface principale de notre application
        InterfaceAccueilJeu.new(@fenetre)

	end 
end

# On lance l'application
Launcher.new
Gtk.main
