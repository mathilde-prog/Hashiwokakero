# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Alexandre DANJOU, Mendy FATNASSI, Fatih UFACIK  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

require 'gtk3'

require_relative "Interface_MenuJouer.rb"
require_relative "interfaceClassement.rb"
require_relative "Theme.rb"

# Classe représentant l'interface d'accueil
# Cette classe contient les variables suivantes :
# @@lancement:: Indicateur booléen du premier lancement de l'accueil 
# $pseudoJoueur:: Pseudo du joueur 
# @fenetre:: Fenêtre pour intégrer l'interface d'accueil
# @box1:: Box qui contient l'interface d'accueil
# @BtnJouer:: Bouton pour accéder à l'interface du menu pour jouer  
# @BtnClassement:: Bouton pour accéder au classement 
# @BtnQuitter:: Bouton pour quitter le jeu
# @BtnTheme:: Bouton pour changer le thème 
# @popupPseudo:: Pop-up pour demander le pseudo du joueur 
# @entryPseudo:: Champ de saisie du pseudo du joueur 
class InterfaceAccueilJeu < Gtk::Builder

	# Variable pour le 1er lancement de l'accueil
	# On affiche le popup et on force le lancement en thème clair
	@@lancement = true

	$pseudoJoueur = "Anonyme" # Va contenir le pseudo du joueur

	# Initialisation de l'interface d'accueil
	# * +fenetre+ [Gtk::Window] - La fenêtre du parent
	def initialize(fenetre)
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
		
		# Configuration globale de la fenêtre
		@fenetre = fenetre
		@fenetre.add(@box1)

		@fenetre.set_resizable(false)
        @fenetre.set_default_size(900,400)
		@fenetre.set_title("Hashi - Accueil")
		@fenetre.show_all
		@fenetre.set_window_position Gtk::WindowPosition::CENTER_ALWAYS

		# Ajout d'un id à nos variables pour les utiliser dans le CSS
		@BtnJouer.name="Bouton_Jouer"
		@BtnClassement.name="Bouton_Classement"
		@BtnQuitter.name="Bouton_Quitter"

		# CSS (mise en forme des boutons)
		provider = Gtk::CssProvider.new
		provider.load(data: <<-CSS)
		/* Arrondir les bords */
		#Bouton_Jouer,#Bouton_Classement,#Bouton_Quitter{
			border-top-left-radius: 50px;
			border-bottom-right-radius: 50px;
			border-top-right-radius: 50px;
			border-bottom-left-radius: 50px;
		}
		/* Changement couleur au survol */
		#Bouton_Jouer:hover{
			background :#BDFF95;
		}
		#Bouton_Classement:hover{
			background : #FFEA85;
		}
		#Bouton_Quitter:hover{
			background :#FE9595;
		}

		CSS
		Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)

		# Permet de lancer la page en thème clair pour la première fois et d'afficher le pop-up pseudo
		if @@lancement then
			Theme.themeLancement(@BtnTheme)
			# Création de la fenêtre POP-UP
			@popupPseudo.set_resizable(false)
			@popupPseudo.set_default_size(400,100)
			@popupPseudo.set_icon("../res/img/ico.ico")
			@popupPseudo.set_title("Hashi - Choix du pseudo")
			@popupPseudo.show_all
			@popupPseudo.signal_connect('destroy') {
				@fenetre.set_sensitive(true)
			}

			@@lancement = false
		# On modifie le comportement des boutons pour qu'ils correspondent au thème choisi.
		else
			Theme.comportementBtn([@BtnTheme])
		end

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
	end

	# Méthode pour le bouton de validation du pop-up
	# Ferme le pop-up et enregistre le pseudo du joueur
    def valider
		if(@entryPseudo.text != "")
			$pseudoJoueur = @entryPseudo.text
		end
		@popupPseudo.close()
    end

	# Appelle la méthode theme de la classe Theme pour modifier le thème 
	def theme
		Theme.theme([@BtnTheme])
	end

	# Méthode liée au bouton @BtnJouer. Accède à l'interface du menu pour jouer. 
	def jouer
		@fenetre.remove(@box1)
		Interface_MenuJouer.new(@fenetre)
	end

	# Méthode liée au bouton @BtnClassement. Accède au classement. 
	def classement
		@fenetre.remove(@box1)
		Classement.creer($pseudoJoueur, @fenetre, @box1)
	end

	# Méthode liée au bouton @BtnQuitter. Permet de fermer l'application. 
    def close
		puts "Fermeture de L'application"
		Gtk.main_quit
	end

	# Méthode de survol du bouton pour qu'il change de couleur
	def btnJouerHover
		provider = Gtk::CssProvider.new
		provider.load(data: <<-CSS)
		#Bouton_Jouer:active{
			background-color: #6DE172;
		}
		CSS
		Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)
	end

end
