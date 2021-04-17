# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Alexandre DANJOU, Mendy FATNASSI, Fatih UFACIK  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

require 'gtk3'

require_relative "InterfaceMenuJouerNouvellePartie.rb"
require_relative "Interface_MenuJouer.rb"
require_relative "InterfaceAccueilJeu.rb"
require_relative "Theme.rb"
require_relative "../PartieProgressif.rb"
require_relative "../PartiePuzzleRush.rb"

# Classe représentant l'interface de choix du mode de jeu
# Cette classe contient les variables suivantes :
# $pseudoJoueur:: Pseudo du joueur 
# @BtnTheme:: Bouton pour changer le thème 
# @BtnHome:: Bouton pour retourner à l'accueil 
# @BtnAide1:: Bouton explicatif du mode de jeu Libre 
# @BtnAide2:: Bouton explicatif du mode de jeu Progressif 
# @BtnAide3:: Bouton explicatif du mode de jeu Puzzle Rush 
# @fenetre:: Fenêtre pour intégrer l'interface permettant de choisir le mode de jeu
# @boxMain:: Box qui contient l'interface permettant de choisir le mode de jeu 
# @BtnModeJeuLibre:: Bouton permettant de choisir le mode de jeu Libre 
# @BtnModeProgressif:: Bouton permettant de choisir le mode de jeu Progressif 
# @BtnModePuzzleRush:: Bouton permettant de choisir le mode de jeu Puzzle Rush 
# @BtnRetour:: Bouton pour retourner au menu précédent 
class Interface_Choix_mode_de_jeux < Gtk::Builder
  
  # Initialisation de l'interface de choix du mode de jeu
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

    #Permet d'ajuster la taille des boutons + lancer la page en thème clair
    Theme.comportementBtn([@BtnTheme, @BtnHome, @BtnAide1, @BtnAide2, @BtnAide3])

    #Configuration globale de la fenêtre
    @fenetre = fenetre
    @fenetre.set_title("Hashi - Choix du mode de jeu")
    @fenetre.add(@boxMain)

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

    @BtnHome.name = "BtnHome"
    @BtnTheme.name = "BtnTheme"
    @BtnAide1.name = "BtnAide1"
    @BtnAide2.name = "BtnAide2"
    @BtnAide3.name = "BtnAide3"

    # Ajout d'un id à nos variables pour les utiliser dans le CSS
    @BtnModeJeuLibre.name="Bouton_Jeux_Libre"
    @BtnModeProgressif.name="Bouton_Jeux_Progressif"
    @BtnModePuzzleRush.name="Bouton_Jeux_PuzzleRush"
    @BtnRetour.name="Bouton_Retour"
    

		# CSS (mise en forme des boutons)
    provider = Gtk::CssProvider.new()
    provider.load(data: <<-CSS)
    #BtnHome,#BtnTheme,#BtnAide1,#BtnAide2,#BtnAide3:hover {
      all: unset;
      box-shadow: none;
      text-shadow: none;
      border:0px;
      min-width:0px;
      padding:7px;
    }
    /* Arrondir les bords */
    #Bouton_Retour,#Bouton_Jeux_Libre,#Bouton_Jeux_Progressif,#Bouton_Jeux_PuzzleRush{
      border-top-left-radius: 50px;
			border-bottom-right-radius: 50px;
			border-top-right-radius: 50px;
			border-bottom-left-radius: 50px;
    }
    /* Changement de couleur au survol */
		#Bouton_Jeux_Libre:hover{
			background :#BDFF95;
		}
    #Bouton_Jeux_Progressif:hover{
      background : #FFEA85;
    }
    #Bouton_Jeux_PuzzleRush:hover{
      background : #F2FB86;
    }
		#Bouton_Retour:hover{
			background :#FE9595;
		}
    CSS
    Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)

  end 

  # Méthode liée au bouton @BtnModeJeuLibre. 
  # Permet d'accéder à l'interface permettant de choisir la difficulté et la taille de la grille. 
  def modeJeuLibre
    @fenetre.remove(@boxMain)
    InterfaceMenuJouerNouvellePartie.new(@fenetre,"libre")
  end

  # Méthode liée au bouton @BtnModeProgressif. 
  # Permet de lancer une partie en mode Progressif. 
  def modeJeuProgressif
    @fenetre.remove(@boxMain)
    PartieProgressif.creer(@fenetre,"facile", 5,$pseudoJoueur,0, 0, "")

  end

  # Méthode liée au bouton @BtnModePuzzleRush. 
  # Permet de lancer une partie en mode Puzzle Rush. 
  def modeJeuPuzzleRush
    @fenetre.remove(@boxMain)
    temps=300
    PartiePuzzleRush.creer(@fenetre,"facile", 5,$pseudoJoueur,temps, 0, "")

  end

  # Méthode liée au bouton @BtnHome.
  # Permet de retourner à l'accueil. 
  def home
    @fenetre.remove(@boxMain)
    InterfaceAccueilJeu.new(@fenetre)
  end

  # Méthode liée au bouton @BtnRetour.
  # Retourne au menu précédent. 
  def gestionRetour
    @fenetre.remove(@boxMain)
    Interface_MenuJouer.new(@fenetre)
  end

  # Méthode liée au bouton @BtnTheme. 
 	# Appelle la méthode theme de la classe Theme pour modifier le thème. 
  def theme
      Theme.theme([@BtnTheme, @BtnHome, @BtnAide1, @BtnAide2, @BtnAide3])
  end

end
