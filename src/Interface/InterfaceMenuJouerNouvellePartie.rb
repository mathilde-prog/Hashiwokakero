# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Alexandre DANJOU, Mendy FATNASSI, Fatih UFACIK  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

require 'gtk3'

require_relative "Interface_Choix_mode_de_jeux.rb"
require_relative "InterfaceAccueilJeu.rb"
require_relative "Theme.rb"
require_relative "../Partie.rb"

# Classe représentant l'interface de nouvelle partie. 
# Cette classe contient les variables suivantes :
# $pseudoJoueur:: Pseudo du joueur 
# @BtnTheme:: Bouton pour changer le thème 
# @BtnHome:: Bouton pour retourner à l'accueil 
# @btnJouer:: Bouton pour lancer la partie en mode Libre 
# @btnRetour:: Bouton pour retourner au menu précédent 
# @difficulteLabel:: Etiquette "Choisir la difficulté"
# @tailleLabel:: Etiquette "Choisir la taille"
# @fenetre:: Fenêtre pour intégrer l'interface permettant de choisir la difficulté et la taille de la grille pour jouer en mode Libre
# @boxNouvellePartie:: Box qui contient l'interface permettant de choisir la difficulté et la taille de la grille pour jouer en mode Libre
# @modeDeJeu:: Mode de jeu 
# @comboBoxDifficulte:: Combobox pour choisir la difficulté de la grille
# @comboBoxTaille:: Combobox pour choisir la taille de la grille 
class InterfaceMenuJouerNouvellePartie < Gtk::Builder

  # Initialisation de l'interface permettant de choisir la difficulté et la taille de la grille pour jouer en mode Libre. 
  # * +fenetre+ [Gtk::Window] - la fenêtre du parent
  # * +modeDeJeu+ [String] - le mode de jeu de la partie
  def initialize(fenetre,modeDeJeu)
    #Initialisation des fichiers
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
    Theme.comportementBtn([@BtnTheme, @BtnHome])

    # Association des id pour le CSS
    @BtnTheme.name = "BtnTheme"
    @BtnHome.name = "BtnHome"
    @difficulteLabel.name = "difficulteLabel"
    @tailleLabel.name = "tailleLabel"
    @btnJouer.name="Bouton_Jouer"
    @btnRetour.name="Bouton_Retour"

    provider = Gtk::CssProvider.new
    provider.load(data: <<-CSS)

    /* Classe des comboBox */
    .combo{
        padding : 1px 1px;
        background-color: initial; /* Remet le fond des comboBox par défaut */
    }
    #btnTheme,#btnHome:hover {all: unset;}
    #btnTheme,#btnHome:hover{box-shadow: none;text-shadow: none;border:0px;min-width:0px;margin:7px;}

    /* Changement bordure ronde */
    #Bouton_Jouer,#Bouton_Retour{
            border-top-left-radius: 50px;
            border-bottom-right-radius: 50px;
            border-top-right-radius: 50px;
            border-bottom-left-radius: 50px;
        }
    /* Changement de couleur au survol */
    #Bouton_Jouer:hover{
        background :#BDFF95;
    }

    #Bouton_Retour:hover{
        background :#FE9595;
    }
    CSS
    Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)

    #Configuration globale de la fenêtre
    @fenetre = fenetre
    @fenetre.set_title("Hashi - Nouvelle partie")
    @fenetre.add(@boxNouvellePartie)
    @modeDeJeu = modeDeJeu


    # Méthode liée au bouton @btnJouer. 
    # Lance une nouvelle partie avec la difficulté et la taille pré-selectionnées par le joueur. 
    def jouerNouvellePartie
      @fenetre.remove(@boxNouvellePartie)

      # On récupère les valeurs des ComboBox
      level = @comboBoxDifficulte.active_text()
      grille = @comboBoxTaille.active_text()
      puts level
      puts grille

      # On récupére la taille de la grille
      if(@modeDeJeu == "libre")
        puts "mode libre choisie"
        puts $pseudoJoueur

        if (grille == "5x5")
          grille=5
        elsif (grille == "6x6")
          grille=6
        elsif (grille == "8x8")
          grille=8
        elsif (grille == "10x10")
          grille=10
        else
          grille=15
        end

        # Lance une partie avec la difficulté et la taille de grille choisies par le joueur
        Partie.creer(@fenetre,level, grille,$pseudoJoueur, "")
      end 
    end

    # Méthode liée au bouton @btnRetour. 
    # Permet de retourner au menu précédent. 
    def gestionRetour
     @fenetre.remove(@boxNouvellePartie)
     Interface_Choix_mode_de_jeux.new(@fenetre)
    end

    # Méthode liée au bouton @BtnHome. 
    # Permet de retourner à l'accueil. 
    def home
      @fenetre.remove(@boxNouvellePartie)
      InterfaceAccueilJeu.new(@fenetre)
    end

    # Méthode liée au bouton @BtnTheme. 
 	  # Appelle la méthode theme de la classe Theme pour modifier le thème. 
    def theme
      Theme.theme([@BtnTheme, @BtnHome])
    end

    # On connecte les signaux aux méthodes (qui doivent exister). 
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
