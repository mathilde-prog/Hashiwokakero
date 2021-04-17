# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Alexandre DANJOU, Mendy FATNASSI, Fatih UFACIK  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

require 'gtk3'
require_relative "Interface_MenuJouer.rb"
require_relative "InterfaceAccueilJeu.rb"
require_relative "Theme.rb"

# Classe représentant l'interface de chargement d'une partie sauvegardée. 
# Cette classe contient les variables d'instances suivantes :
# @BtnTheme:: Bouton pour changer le thème 
# @BtnHome:: Bouton pour retourner à l'accueil 
# @fenetre:: Fenêtre pour intégrer l'interface permettant de charger une partie sauvegardée
# @boxChargerPartie:: Box qui contient l'interface permettant de charger une partie sauvegardée
# @BtnCharger:: Bouton permettant de charger une partie 
# @BtnRetour:: Bouton permettant de retourner au menu précédent 
# @BtnEffacer:: Bouton permettant d'effacer une sauvegarde 
# @listeSauvegardes:: Liste pour stocker les données sur les parties sauvegardées 
# @zoneDonneesSauvegardes:: Zone d'affichage des données sur les parties sauvegardées 
# @scrolledWindow:: Fenêtre défilable pour les données sur les parties sauvegardées 
# @choixPartie:: Données concernant la partie sauvegardée sélectionnée par le joueur 
class InterfaceMenuJouerChargerPartie < Gtk::Builder

  # Initialisation de l'interface de chargement d'une partie sauvegardée
  # * +fenetre+ [Gtk::Window] - la fenêtre du parent
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

    # Création d'une variable d'instance par composant glade
    self.objects.each() { |p|
      puts "Création d'une variable d'instance : '@#{p.builder_name}'"
      instance_variable_set("@#{p.builder_name}".intern, self[p.builder_name])
    }

    # Permet d'ajuster la taille des boutons + lancer la page en thème clair
    Theme.comportementBtn([@BtnTheme, @BtnHome])

    # Variable d'instance
    @BtnTheme.name = "btnTheme"
    @BtnHome.name = "btnHome"
    @BtnCharger.name="Bouton_Charger"
    @BtnRetour.name="Bouton_Retour"
    @BtnEffacer.name="Bouton_Effacer"
    provider = Gtk::CssProvider.new
    provider.load(data: <<-CSS)
    #btnTheme,#btnHome:hover {all: unset;}
    #btnTheme:hover {box-shadow: none;text-shadow: none;border:0px;min-width:0px;margin-bottom:5px;}
    #btnHome:hover {box-shadow: none;text-shadow: none;border:0px;min-width:0px;padding:6px;}

    /* Changement bordure ronde */
    #Bouton_Charger,#Bouton_Retour,#Bouton_Effacer{
            border-top-left-radius: 50px;
            border-bottom-right-radius: 50px;
            border-top-right-radius: 50px;
            border-bottom-left-radius: 50px;
        }

    /* Changement de couleur au survol */
    #Bouton_Charger:hover{
        background :#BDFF95;
    }

    #Bouton_Effacer:hover,#Bouton_Retour:hover{
        background :#FE9595;
    }
    CSS
    Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)

    # Configuration globale de la fenêtre
    @fenetre = fenetre
    @fenetre.add(@boxChargerPartie)
    @fenetre.set_title("Hashi - Charger une partie")

    # Parcours du dossier de sauvegarde (nbLigne = nombre de fichier à afficher)
    nbLigne = 0
    Dir.each_child("./../res/sauvegardes") {|x| nbLigne+=1 }
    # On retire le gitIgnore
    nbLigne -= 1
    puts "Nombre de fichiers : #{nbLigne} "

    # Liste pour stocker les données des parties sauvegardées
    @listeSauvegardes = Gtk::ListStore.new(String, String, String, String, String, String, String)
    # Zone d'affichage des données des parties sauvegardées
    @zoneDonneesSauvegardes = Gtk::TreeView.new(@listeSauvegardes)
		renderer = Gtk::CellRendererText.new

    # Colonne Nom de la partie
		column = Gtk::TreeViewColumn.new("Nom de la partie",renderer, :text => 0)
		column.resizable = false
		column.expand = true
		@zoneDonneesSauvegardes.append_column(column)

    # Colonne Pseudo du joueur
    column = Gtk::TreeViewColumn.new("Pseudo du joueur",renderer, :text => 1)
		column.resizable = false
		column.expand = true
		@zoneDonneesSauvegardes.append_column(column)

    # Colonne Mode de jeu
		column = Gtk::TreeViewColumn.new("Mode de jeu",renderer, :text => 2)
		column.resizable = false
		column.expand = true
		@zoneDonneesSauvegardes.append_column(column)

    # Colonne Taille
		column = Gtk::TreeViewColumn.new("Taille",renderer, :text => 3)
		column.resizable = false
		column.expand = true
		@zoneDonneesSauvegardes.append_column(column)

    # Colonne Difficulté
    column = Gtk::TreeViewColumn.new("Difficulté",renderer, :text => 4)
		column.resizable = false
		column.expand = true
		@zoneDonneesSauvegardes.append_column(column)

    # Colonne Timer
    column = Gtk::TreeViewColumn.new("Timer",renderer, :text => 5)
		column.resizable = false
		column.expand = true
		@zoneDonneesSauvegardes.append_column(column)

    # Colonne Nombre de grilles résolues
    column = Gtk::TreeViewColumn.new("Nombre de grilles résolues",renderer, :text => 6)
		column.resizable = false
		column.expand = true
		@zoneDonneesSauvegardes.append_column(column)

    # Fenêtre défilante
		@scrolledWindow.add_with_viewport(@zoneDonneesSauvegardes)
		@zoneDonneesSauvegardes.show_all

    # Parcours du répertoire sauvegardes
    Dir.each_child("./../res/sauvegardes") {|x|
      # On ignore le gitIgnore
      if( x != ".gitignore") then
        # Ouverture du fichier
        file = File.open("./../res/sauvegardes/" + x)
        # On récupère le fichier ligne par ligne
        file_data = file.readlines.map(&:chomp)

              iter = @listeSauvegardes.append

              nomFichier = file_data[0].split("/"); # Récupération du nom du fichier pour connaitre la taille et la difficulté
              pseudo = file_data[1] # Récupération du pseudo du joueur 
              mode = file_data[2] # Récupération du mode de jeu
              taille = nomFichier[4] # Récupération de la taille de la grille
              difficulte = nomFichier[3] # Récupération de la difficulté
              timer = file_data[3] # Récupération du timer (pour Progressif et Puzzle Rush)
              nbGrillesResolues = file_data[4] # Récupération du nombre de grilles résolues (pour Progressif et Puzzle Rush)

              nomTemp = x.delete_suffix!(".sav") # Récupère le nom de la partie (sans le suffixe ".sav")
              tab = nomTemp.split("_")
              str1 = tab[0].split("-").reverse().join("/")
              str2 = tab[1].gsub("-",":")
              str1.concat(" ").concat(str2)
              iter[0] = str1 # Ajout du nom de la partie à l'affichage 
              iter[1] = pseudo # Ajout du pseudo à l'affichage
              case mode # Ajout du mode à l'affichage
              when "0"
                iter[2] = "Libre"
                iter[4] = difficulte.capitalize # Ajout de la difficulté à l'affichage uniquement pour le mode "Libre"
              when "1"
                iter[2] = "Puzzle Rush"
                iter[6] = nbGrillesResolues # Ajout du nombre de grilles résolues à l'affichage (pour progressif & puzzle rush)
              when "2"
                iter[2] = "Progressif"
                iter[6] = nbGrillesResolues # Ajout du nombre de grilles résolues  à l'affichage (pour progressif & puzzle rush)
              end
              iter[3] = taille # Ajout de la taille de la grille à l'affichage
              iter[5] =  timer # Ajout du timer à l'affichage

              # Fermeture du fichier
              file.close
          end
        }

    puts "Nombre de fichier : #{nbLigne} "

    # Le treeselection permet de savoir sur quelle ligne le joueur a cliqué. 
    treeselection = @zoneDonneesSauvegardes.selection()
    treeselection.set_mode(Gtk::SelectionMode::SINGLE)
    treeselection.signal_connect('changed'){
      @choixPartie = treeselection.selected() # On récupère la partie sélectionnée par le joueur.
    }

    # Méthode liée au bouton @BtnCharger pour jouer à la partie sélectionnée. 
    def jouerPartie
      # Le joueur doit avoir sélectionné une ligne. 
      if(@choixPartie != nil)
        # Récupération des différents paramètres de la partie sélectionnée par le joueur.
        difficulte = @choixPartie[4]
        taille = @choixPartie[3]
        pseudo = @choixPartie[1]
        temps = @choixPartie[5]
        nbGrillesResolues = @choixPartie[6]
        temp = @choixPartie[0].split(" ")
        str1 = temp[0].split("/").reverse().join("-")
        str2  = temp[1].gsub(":","-")
        str1.concat("_").concat(str2)
        cheminSAV = "./../res/sauvegardes/"+ str1 + ".sav"

        @fenetre.remove(@boxChargerPartie)

        # Lancement de la partie
        case @choixPartie[2]
        when "Libre"
          Partie.creer(@fenetre,difficulte, taille, pseudo, cheminSAV);
        when "Progressif"
          PartieProgressif.creer(@fenetre, difficulte, taille, pseudo, temps.to_i, nbGrillesResolues.to_i, cheminSAV)
        when "Puzzle Rush"
          PartiePuzzleRush.creer(@fenetre, difficulte, taille, pseudo, temps.to_i, nbGrillesResolues.to_i, cheminSAV)
        end
      end 
    end

    # Méthode liée au bouton @BtnEffacer pour effacer la partie sélectionnée par le joueur. 
    def effacerSauvegarde
        # Le joueur doit avoir sélectionné une ligne. 
        if(@choixPartie[0] != nil) then
            temp = @choixPartie[0].split(" ")
            str1 = temp[0].split("/").reverse().join("-")
            str2  = temp[1].gsub(":","-")
            str1.concat("_").concat(str2)
            cheminSAV = "./../res/sauvegardes/"+ str1 + ".sav"
           
            # On efface la ligne du tableau à l'affichage. 
            @listeSauvegardes.remove(@choixPartie)

            # On supprime le fichier de sauvegarde
            File.delete(cheminSAV)
        end
    end

    # Méthode liée au bouton @BtnHome pour retourner à l'accueil. 
    def home
      @fenetre.remove(@boxChargerPartie)
      InterfaceAccueilJeu.new(@fenetre)
    end

    # Méthode liée au bouton @BtnRetour pour retourner à la page précédente. 
    def gestionRetour
      @fenetre.remove(@boxChargerPartie)
      Interface_MenuJouer.new(@fenetre)
    end

    # Méthode liée au bouton @BtnTheme. 
    # Appelle la méthode theme de la classe Theme pour modifier le thème. 
    def theme
        Theme.theme([@BtnTheme, @BtnHome])
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
