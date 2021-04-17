# # # # # # # # # # # # # # # 
# Auteur : Marie-Nina MUNAR #
# # # # # # # # # # # # # # #

require_relative('Case')
require_relative('Ile')
require_relative('Pont')
require_relative('Aide')
require_relative('Conseil')
require "active_record"
require 'sqlite3'
require 'gtk3'
require_relative('./Interface/Timer')
require_relative('connectSqlite3')
require_relative('ClassementPuzzleRush')
require_relative('Partie')

# Classe représentant une partie de Hashi en mode puzzle rush.
# Cette classe contient les variables d'instances suivantes (en plus de celles de la classe mère)
# @boutonFinDePartie:: Bouton invisible utilisé pour déclencher la fin de partie à la fin du chrono
# @tempsRestant:: Nombre de secondes restantes dans le timer
class PartiePuzzleRush < Partie

    # Renvoie le mode de jeu de la partie
    def getMode()
        return 1
    end

    # Constructeur de la classe PartiePuzzleRush
    # * +fenetre+ [Gtk::Window] - Fenêtre où se trouve la partie
    # * +difficulte+ [String] - Difficulté de la grille générée (facile, moyenne, difficile)
    # * +taille+ [Integer/String] - Taille de la grille générée
    # * +pseudo+ [String] - Pseudo du joueur (donné par le menu)
    # * +tempsRestant+ [Integer] - Temps restant en secondes
    # * +nbGrilles+ [Integer] - Nombre de grilles actuel
    # * +cheminSAV+ [String] - Emplacement de la sauvegarde, sinon ""
    def PartiePuzzleRush.creer(fenetre, difficulte, taille, pseudo, tempsRestant, nbGrilles,cheminSAV)
        new(fenetre, difficulte, taille, pseudo, tempsRestant, nbGrilles,cheminSAV)
    end

    # Méthode d'intialisation de Partie  
    # * +fenetre+ [Gtk::Window] - Fenêtre où se trouve la partie
    # * +difficulte+ [String] - Difficulté de la grille générée (facile, moyenne, difficile)
    # * +taille+ [Integer/String] - Taille de la grille générée
    # * +pseudo+ [String] - Pseudo du joueur (donné par le menu)
    # * +tempsRestant+ [Integer] - Temps restant en secondes
    # * +nbGrilles+ [Integer] - Nombre de grilles actuel
    # * +cheminSAV+ [String] - Emplacement de la sauvegarde, sinon ""
    def initialize(fenetre, difficulte, taille, pseudo, tempsRestant, nbGrilles,cheminSAV)
        @tempsRestant = tempsRestant
        @nbGrilles = nbGrilles
        super(fenetre, difficulte, taille, pseudo,cheminSAV)
    end

    # Méthode qui permet d'initialiser et de lancer le chrono et son affichage
    def creerChrono()
        @timer = Timer.creer(@tempsRestant) # Un chrono qui décrémente sa valeur toutes les secondes et commence à partir de la valeur donnée et s'arrête à zéro
        # Démarre le chrono
        @timer.startChrono
        afficherChrono()
    end

    # Méthode de création de la fenêtre (modifiée pour ne pas créer la fenêtre)
    def creationFenetre()
        super()
        @fenetre.set_title("Hashi - Puzzle Rush - #{@pseudo}")
    end  

    # Méthode qui gère les boutons de l'interface et l'ajout aux différents conteneurs pour créer l'interface graphique
    def creationBoutonsDeLInterface() #:doc:

        # Bouton inexistant dans l'interface, cliqué quand la partie doit se terminer (fin du chrono)
        @boutonFinDePartie = Gtk::Button.new()
        @boutonFinDePartie.signal_connect('clicked'){
            finDePartie()
        }

        #Informations contenues dans hboxInfos :

        # Bouton d'affichage du menu in-game :
        menu = Gtk::Button.new(:label => "Menu")
        menu.name = "btn_interface"
        menu.signal_connect('clicked'){
            self.afficherMenu()
        }

        # Espace pour le chrono :
        chronoBox = Gtk::Box.new(:vertical, spacing=5)
        chronoLabel = Gtk::Label.new("Chrono", {:use_underline => false}).set_single_line_mode(true)
        chronoLabel.name = "lbl_interface"
        @chronoText = Gtk::Label.new("00:00", {:use_underline => false}).set_single_line_mode(true)
        @chronoText.name = "lbl_interface_gras"
        chronoBox.add(chronoLabel)
        chronoBox.add(@chronoText)

        # Espace pour le nombre de coups :
        nbGrillesBox = Gtk::Box.new(:vertical, spacing=5)
        nbGrillesLabel = Gtk::Label.new("Finies", {:use_underline => false}).set_single_line_mode(true)
        nbGrillesLabel.name = "lbl_interface"
        nbGrillesText = Gtk::Label.new("#{@nbGrilles}", {:use_underline => false}).set_single_line_mode(true)
        nbGrillesText.name = "lbl_interface_gras"
        nbGrillesBox.add(nbGrillesLabel)
        nbGrillesBox.add(nbGrillesText)

        # Espace pour la difficulté :
        difficulteBox = Gtk::Box.new(:vertical, spacing=5)
        difficulteLabel = Gtk::Label.new("Difficulté", {:use_underline => false}).set_single_line_mode(true)
        difficulteLabel.name = "lbl_interface"
        difficulteInfo = Gtk::Label.new("#{@difficulte}", {:use_underline => false}).set_single_line_mode(true)
        difficulteInfo.name = "lbl_interface_italic"
        difficulteBox.add(difficulteLabel)
        difficulteBox.add(difficulteInfo)

        # Espace pour la taille :
        tailleBox = Gtk::Box.new(:vertical, spacing=5)
        tailleLabel = Gtk::Label.new("Taille", {:use_underline => false}).set_single_line_mode(true)
        tailleLabel.name = "lbl_interface"
        tailleInfo = Gtk::Label.new("#{@taille}x#{@taille}", {:use_underline => false}).set_single_line_mode(true)
        tailleInfo.name = "lbl_interface"
        tailleBox.add(tailleLabel)
        tailleBox.add(tailleInfo)

        # HBOX qui va contenir les informations sur la partie et le menu
        @hboxInfos = Gtk::Box.new(:horizontal, spacing=20)
        @hboxInfos.homogeneous = true
        @hboxInfos.add(menu)
        @hboxInfos.add(chronoBox)
        @hboxInfos.add(difficulteBox)
        @hboxInfos.add(tailleBox)
        @hboxInfos.add(nbGrillesBox)

        # VBOX qui va contenir la grille de hashi et les informations présentes au-dessus
        @vboxGauche = Gtk::Box.new(:vertical, spacing=40)
        @vboxGauche.homogeneous=false
        @vboxGauche.add(@hboxInfos)
        @vboxGauche.add(@grid)
        
        # HBOX qui va contenir la partie gauche et droite de l'interface
        @hbox = Gtk::Box.new(:horizontal, spacing=50)
        @hbox.homogeneous=false
        @hbox.name = "box_contenu"
        @hbox.add(@vboxGauche)

        # Conteneurs pour les boutons de l'interface à droite
        @gridInterface = Gtk::Grid.new()
        @gridInterface.column_homogeneous=true
        @gridInterface.row_homogeneous=true
        @gridInterface.row_spacing=25
        @gridInterface.column_spacing=10

        # Bouton montrer un conseil
        montrerConseil = Gtk::Button.new(:label =>"Montrer")
        montrerConseil.name = "btn_interface"
        montrerConseil.sensitive = false
        montrerConseil.signal_connect('clicked'){
            self.afficherAide()
            if(@conseilAffiche)
                montrerConseil.label = "Enlever"
            else
                montrerConseil.label = "Montrer"
            end
        }

        # Bouton générer un conseil
        genererConseil = Gtk::Button.new(:label =>"Générer un conseil")
        genererConseil.name = "btn_interface"
        genererConseil.signal_connect('clicked'){
            if(@conseilAffiche)
                montrerConseil.label = "Montrer"
            end    
            self.genererAide()
            if(@conseil.nbIlesConcernees == 0)
                montrerConseil.sensitive = false # Pas de conseil trouvé, on ne peut donc pas les montrer
            else
                montrerConseil.sensitive = true
            end
        }

        # Bouton règles du jeu
        reglesDuJeu = Gtk::Button.new(:label =>"Règles du jeu")
        reglesDuJeu.name = "btn_interface"
        reglesDuJeu.signal_connect('clicked'){
            self.afficherRegles()
        }

        # Bouton vérification de la grille
        verification = Gtk::Button.new(:label =>"Vérification de la grille")
        verification.name = "btn_interface"
        verification.signal_connect('clicked'){
            self.causerVerifierGrille()
        }

        # Bouton vider la grille
        @viderBouton = Gtk::Button.new(:label =>"Vider la grille")
        @viderBouton.name = "btn_interface"
        @viderBouton.sensitive = false
        @viderBouton.signal_connect('clicked'){
            self.viderGrille()
            if(estVide?)
                @undoBouton.sensitive = false
                @redoBouton.sensitive = false
                @viderBouton.sensitive = false
            end
        }

        # Bouton UNDO
        @undoBouton = Gtk::Button.new()
        imageUndo = Gtk::Image.new(:file => "../res/img/undo.svg")
        imageUndo.pixbuf=imageUndo.pixbuf.scale_simple(50,50, GdkPixbuf::InterpType::BILINEAR)
        @undoBouton.set_image(imageUndo)
        @undoBouton.set_always_show_image(true)
        @undoBouton.set_relief(Gtk::ReliefStyle::NONE)
        @undoBouton.sensitive = false
        @undoBouton.signal_connect('clicked'){
            self.unDo()
            if(@listCoup.empty?)
                @undoBouton.sensitive = false
            end
            if(!@listReDo.empty?)
                @redoBouton.sensitive = true
            end
            if(estVide?)
                @viderBouton.sensitive = false
            end    
        }

        # Bouton REDO
        @redoBouton = Gtk::Button.new()
        imageRedo = Gtk::Image.new(:file => "../res/img/undo.svg")
        imageRedo.pixbuf=imageRedo.pixbuf.scale_simple(50,50, GdkPixbuf::InterpType::BILINEAR)
        imageRedo.pixbuf=imageRedo.pixbuf.flip(true)
        @redoBouton.set_image(imageRedo)
        @redoBouton.set_always_show_image(true)
        @redoBouton.set_relief(Gtk::ReliefStyle::NONE)
        @redoBouton.sensitive = false
        @redoBouton.signal_connect('clicked'){
            self.reDo()
            if(@listReDo.empty?)
                @redoBouton.sensitive = false
            end 
            if(!@listCoup.empty?)   
                @undoBouton.sensitive = true
            end 
            if(estVide?)
                @viderBouton.sensitive = false
            end     
        }

        # Espace d'affichage de l'aide textuel 
        espaceConseilsText = Gtk::TextView.new()
        espaceConseilsText.editable = false
        espaceConseilsText.cursor_visible = false
        espaceConseilsText.wrap_mode = Gtk::WrapMode::WORD_CHAR
        espaceConseilsText.left_margin = 10
        espaceConseilsText.right_margin = 10
        espaceConseilsText.name = "ConseilsTextView"
        
        @bufferConseils = espaceConseilsText.buffer
        @bufferConseils.text = ""

        espaceConseils = Gtk::ScrolledWindow.new(nil, nil)
        espaceConseils.add(espaceConseilsText)

        # Ajout des boutons à la grille d'interface (droite)
        # 1ere ligne :
        @gridInterface.attach(genererConseil, 0, 0, 2, 1)
        @gridInterface.attach(montrerConseil, 3, 0, 2, 1)
        # 2eme ligne + 3e ligne :
        @gridInterface.attach(espaceConseils, 0, 1, 5, 2)
        # 4e ligne :
        @gridInterface.attach(reglesDuJeu, 1, 3, 3, 1)
        # 5e ligne :
        @gridInterface.attach(verification, 1, 4, 3, 1)
        # 6e ligne :
        @gridInterface.attach(@viderBouton, 1, 5, 3, 1)
        # 7e ligne :
        @gridInterface.attach(@undoBouton, 1, 6, 1, 1)
        @gridInterface.attach(@redoBouton, 3, 6, 1, 1)

        @hbox.add(@gridInterface)
        @fenetre.add(@hbox)
    end    

    # Méthode permettant de retourner à la partie depuis le menu in-game
    # * +tempsEcoule+ [Integer] - Le temps dans le chrono au moment d'entrer dans le menu
    def retourInGame(tempsEcoule)
        @fenetre.remove(@inGameMenu)
        @fenetre.add(@hbox)
        majGraphiqueIles()
        @timer = Timer.creer(tempsEcoule)
        @timer.startChrono()
        afficherChrono()
        @fenetre.show_all()
        return self
    end
    
    # Méthode qui permet de créer un thread qui va modifier toutes les secondes l'affichage du chrono (gère les cas dépendants de la modification du chrono)
    def afficherChrono()
        @threadAffichageChrono = Thread.new{
            while @timer.getEnExec
                @chronoText.text = @timer.afficher()
                # On gère les cas d'un timer descendant qui atteint certaines valeurs
                valeur = @timer.valeur
                if(valeur<=10)
                   @chronoText.name = "lbl_interface_gras_important"
                end
                if(valeur==0)
                    @boutonFinDePartie.clicked()
                    break
                end
                # On met à jour le label du timer toutes les 1 secondes
                sleep(0.5)
            end
        }
        return self
    end

    # Méthode générant une aide
    def genererAide()
        super()
        @timer.malusAstuce()
        if(@timer.valeur<=0)
            finDePartie()
        end
        return self
    end

    # Méthode provoquant l'affichage d'une aide préalablement générée
    def afficherAide()
        super()
        if(@conseilAffiche)
            @timer.malusAide()
            if(@timer.valeur<=0)
                finDePartie()
            end
        end
        return self
    end

    # Méthode qui permet de faire avancer de nb le nombre de coups (impacte l'affichage)
    # * +nb+ - le nombre de coups à ajouter
    def evoluerNbCoups(nb)
        @nbCoups += nb
        return self
    end

    # Méthode appelée quand la partie se termine (grille résolue)
    def finDePartie()
        @timer.stopChrono
        tempsRestant = @timer.valeur
        @fenetre.remove(@hbox)
        if(tempsRestant == 0) # La partie s'est terminée car le timer a atteint 0
            partieTerminee()
        else # On passe à la grille suivante (le mode puzzle rush ne contient que des grilles faciles de toutes tailles)
            tempsRestant+=30
            # Passage à la taille suivante
            case @taille
            when 5
                PartiePuzzleRush.creer(@fenetre, "facile", 6, @pseudo, tempsRestant, @nbGrilles+1, "")
            when 6
                PartiePuzzleRush.creer(@fenetre, "facile", 8, @pseudo, tempsRestant, @nbGrilles+1, "")
            when 8
                PartiePuzzleRush.creer(@fenetre, "facile", 10, @pseudo, tempsRestant, @nbGrilles+1, "")
            when 10
                PartiePuzzleRush.creer(@fenetre, "facile", 15, @pseudo, tempsRestant, @nbGrilles+1, "")
            else
                @nbGrilles+=1
                partieTerminee()
            end
        end    
    end  
    
    # Méthode permettant de terminer la partie(retour au menu)
    def partieTerminee() #:doc:
        scoreFinal = calculDuScore()
        score_message = Gtk::MessageDialog.new(:parent => @fenetre, :flags => :destroy_with_parent, :type => :info, :buttons => :close, :message => "Grille validée")
        score_message.secondary_text="Votre partie est terminée, votre score est : #{scoreFinal}"
        score_message.run()
        score_message.destroy()
        ClassementPuzzleRush.ajoutDansLaBDD(@pseudo, scoreFinal)
        @timer.stopChrono
        # Retour au menu
        InterfaceAccueilJeu.new(@fenetre)
    end

    # Méthode permettant de calculer le score actuel du joueur
    def calculDuScore()
        time = @timer.valeur()
        score = (time + @nbGrilles)*10
        return score
    end

    #Méthodes privées :
    private :partieTerminee
    private :creationBoutonsDeLInterface
end