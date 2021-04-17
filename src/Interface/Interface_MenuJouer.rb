# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Alexandre DANJOU, Mendy FATNASSI, Fatih UFACIK  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

require_relative "Interface_Choix_mode_de_jeux.rb"
require_relative "InterfaceMenuJouerChargerPartie.rb"
require_relative "InterfaceAccueilJeu.rb"
require_relative "Theme.rb"

require 'gtk3'

# Classe représentant l'interface du menu permettant de jouer
# Cette classe contient les variables d'instances suivantes :
# @BtnTheme:: Bouton pour changer le thème 
# @fenetre:: Fenêtre pour intégrer l'interface du menu permettant de jouer 
# @boxMenuJouer:: Box qui contient l'interface du menu permettant de jouer 
# @btnNouvellePartie:: Bouton pour accéder à l'interface du choix du mode de jeu 
# @btnChargerPartie:: Bouton pour accéder à l'interface permettant de charger une partie
# @btnRetour:: Bouton pour retourner au menu d'accueil 
class Interface_MenuJouer < Gtk::Builder
  
  # Initialisation de l'interface permettant de jouer
  # * +fenetre+ [Gtk::Window] - La fenêtre du parent
  def initialize(fenetre)
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

    # Permet d'ajuster la taille des boutons + lancer la page en thème clair
    Theme.comportementBtn([@BtnTheme])

    # Configuration globale de la fenêtre
    @fenetre = fenetre
    @fenetre.set_title("Hashi - Menu Jouer")
    @fenetre.add(@boxMenuJouer)

    # Variable d'instance
    # Rattachement de l'id au bouton pour le CSS
    @btnNouvellePartie.name="Bouton_Nouvelle_Partie";
    @btnChargerPartie.name="Bouton_Charger_Partie";
    @btnRetour.name="Bouton_Retour";

    # CSS (mise en forme des boutons)
		provider = Gtk::CssProvider.new
		provider.load(data: <<-CSS)
		/* Arrondir les bords */
		#Bouton_Nouvelle_Partie,#Bouton_Charger_Partie,#Bouton_Retour{
			border-top-left-radius: 50px;
			border-bottom-right-radius: 50px;
			border-top-right-radius: 50px;
			border-bottom-left-radius: 50px;
		}
		/* Changement de couleur au survol */
		#Bouton_Nouvelle_Partie:hover{
			background :#BDFF95;
		}
    #Bouton_Charger_Partie:hover{
      background : #FFEA85;
    }
		#Bouton_Retour:hover{
			background :#FE9595;
		}
		CSS
		Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)
		
    # Méthode liée au bouton @btnNouvellePartie. 
    # Permet d'accéder à l'interface du choix du mode de jeu. 
    def nouvellePartie
      @fenetre.remove(@boxMenuJouer)
      Interface_Choix_mode_de_jeux.new(@fenetre)
    end

    # Méthode liée au bouton @btnChargerPartie. 
    # Permet d'accéder à l'interface permettant de charger une partie.  
    def chargerPartie
      @fenetre.remove(@boxMenuJouer)
      InterfaceMenuJouerChargerPartie.new(@fenetre)
    end

    # Méthode liée au bouton @btnRetour.
    # Permet d'accéder à l'interface du menu d'accueil
    def gestionRetour
      @fenetre.remove(@boxMenuJouer)
      InterfaceAccueilJeu.new(@fenetre)
    end

  	# Appelle la méthode theme de la classe Theme pour modifier le thème 
    def theme
      Theme.theme([@BtnTheme])
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

end

