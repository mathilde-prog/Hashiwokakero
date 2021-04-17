# # # # # # # # # # # # # # # # # # # # # # # # 
# Auteurs : Dylan CLINCHAMP, Marie-Nina MUNAR #
# # # # # # # # # # # # # # # # # # # # # # # # 
require_relative('Case')
require_relative('Ile')
require_relative('Pont')
require_relative('Aide')
require_relative('Conseil')
require "active_record"
require 'sqlite3'
require 'gtk3'
require_relative('./Interface/Chrono')
require_relative('connectSqlite3')
require_relative('ClassementLibre')
require_relative('./Interface/Theme')
require_relative('./Interface/InterfaceMenuJouerChargerPartie')
require_relative('./Interface/InterfaceAccueilJeu')

# $modeDaltonien entier en variable globale caractérisant le mode de couleur en cours (0 = normal, 1 = deutéranope, 2 = protanope, 3 = tritanopie)

# Classe qui représente une partie
# Cette classe contient les variables d'instances suivantes :
# @grille:: un tableau à deux dimensions de Case
# @taille:: la taille de la @grille (carrée). Il existe uniquement des grilles de taille 5, 6, 8, 10 et 15
# @difficulte:: chaine de caractères indiquant la difficulté de la grille
# @listIle:: un tableau contenant les îles de la partie
# @listPont:: un tableau contenant les ponts de la partie
# @listCoup:: un tableau contenant des ponts, retraçant les interactions du joueur
# @listReDo:: un tableau contenant des ponts, remplis à l'aide du bouton undo, depuis @listCoup
# @nbCoups:: le nombre d'interactions du joueur avec les ponts
# @checkpoint:: un tableau contenant des ponts, est un état sauvegardé de @listPont
# @checkpointCoups:: un tableau contenant des ponts, est un état sauvegardé de @listCoup
# @timer:: le chronomètre utilisé pendant la partie
# @aide:: le système d'aide utilisé pendant la partie
# @chronoText:: le label qui contient le texte du chrono (mis à jour par le thread du chrono)
# @coupsText:: le label qui contient le nombre de coups du joueur
# @threadAffichageChrono:: thread permettant de mettre à jour le label du chrono
# @fenetre:: la fenêtre gtk du jeu
# @grid:: la grille gtk qui permet de contenir les boutons (cases) de l'espace hashi (gauche)
# @hboxInfos:: la box horizontale qui contient le bouton du menu et les informations de la partie
# @gridInterface:: la grille gtk qui permet de contenir les boutons d'interface (droite)
# @hbox:: la box horizontale qui contient la @grid et la @gridInterface
# @vboxGauche:: la box verticale qui contient la @grid et @hboxInfos
# @bufferConseils:: le buffer qui contient le texte généré par une aide
# @grilleBT:: un tableau qui contient les boutons dans l'ordre des cases associées (dans grille)
# @undoBouton:: bouton d'undo pour défaire le dernier pont
# @redoBouton:: bouton de redo pour refaire le dernier pont défait
# @viderBouton:: bouton pour vider la grille (grisé quand vide)
# @tailleImg:: la taille en pixel d'une image sur un des boutons de la @grid
# @conseil:: le conseil actuellement généré
# @conseilAffiche:: booléen permettant de savoir si un conseil est actuellement montré sur la grille
# @pseudo:: pseudo du joueur
# @nomMap:: chaîne de caractères correspondant à la map chargée
# @nbGrilles:: le nombre de grilles résolues (utilisé en mode Progressif et en PuzzleRush)
# @radioTheme:: les radio boutons de choix du thème dans le menu in-game
# @radioDaltonien:: les radio boutons de choix du mode de couleur dans le menu in-game
# @inGameMenu:: la box correspondant au menu in-game
class Partie
    # La grille du jeu, constituée d'un tableau de Case
    attr_reader :grille
    
    # La taille de la grille, entier correspondant au côté du carré représenté par la grille
    attr_reader :taille

    #La difficulté de la grille (chaine de caractères)
    attr_reader :difficulte
    
    # La liste des Ile
    attr_reader :listIle
    
    # La liste des Pont
    attr_reader :listPont
    
    # Le chronomètre, type Chronometre
    attr_reader :timer
    
    # L'aide, type Aide
    attr_reader :aide
    
    # La liste des coups (tableau de Pont)
    attr_reader :listCoup
    
    # Le nombre de coups, entier
    attr_reader :nbCoups

    # Méthode pour connaître le type de partie. Retourne 0. 
    def getMode()
        return 0
    end    

    # Constructeur de la classe Partie.  
    # * +fenetre+ [Gtk::Window] - Fenêtre où se trouve la partie
    # * +difficulte+ [String] - Difficulté de la grille générée (facile, moyenne, difficile)
    # * +taille+ [Integer/String] - Taille de la grille générée
    # * +pseudo+ [String] - Pseudo du joueur (donné par le menu)
    # * +cheminSAV+ [String] - Emplacement de la sauvegarde, sinon ""
    def Partie.creer(fenetre, difficulte, taille, pseudo,cheminSAV)
        new(fenetre, difficulte, taille, pseudo,cheminSAV)
    end

    # Méthode d'intialisation de Partie. 
    # * +fenetre+ [Gtk::Window] - Fenêtre où se trouve la partie
    # * +difficulte+ [String] - Difficulté de la grille générée (facile, moyenne, difficile)
    # * +taille+ [Integer/String] - Taille de la grille générée
    # * +pseudo+ [String] - Pseudo du joueur (donné par le menu)
    # * +cheminSAV+ [String] - Emplacement de la sauvegarde, sinon ""
    def initialize(fenetre, difficulte, taille, pseudo,cheminSAV)
        if(cheminSAV.empty?)
            # Va chercher aléatoirement une map de la difficulté et de la taille choisie
            @nomMap = genererMap(difficulte, taille)
            @pseudo = pseudo
            @nbCoups = 0
        end

        # Créer les listes
        @listIle = Array.new
        @listPont = Array.new
        @listCoup = Array.new
        @listReDo = Array.new
        @checkpoint=Array.new
        @checkpointCoups=Array.new
        
        
        if(!cheminSAV.empty?)
            restaurerDepuisFichier(cheminSAV)
        else
            # Remplir la listIle
            remplissageFichier()
        end
        creerPontsPotentiels()
        remplissageIlesVoisines()

        @conseil = nil
        @conseilAffiche = false
        
        #####
        # Dans le cas d'un timer descendant, on pourrait établir une couleur rouge au label du chrono quand il a atteint 10 sec par exemple.
        # Valeur css d'un chrono qui n'a plus beaucoup de temps : lbl_interface_gras_important (couleur adaptée au mode daltonien).
        # Attention, la couleur du reste du texte est fixée à noir, doit être changée par le mode sombre en blanc si nécessaire.
        #####
        
        #Début de la partie GTK
        
        @fenetre = fenetre
        creationFenetre()
        
        # Taille des svg (dépend de la fenêtre)
        @tailleImg = 600/@taille

        ##### PARTIE CSS #####
        # Pour faire le cercle gradient pour le highlight des îles, on fait le calcul du pourcentage de la surface d'un cercle sur un carré de même diamètre, soit 78.5398163398%, que l'on arrondi et agrandi pour prendre en compte le contour de l'île, soit environ 83%. 
        if($modeDaltonien == nil)
            $modeDaltonien = 0
        end
        appliquerCSS()

        creationGrilleDeBoutons()

        creationBoutonsDeLInterface()
        
        @aide = Aide.creer(self)

        @fenetre.show_all

        if(cheminSAV.empty?)
            creerChrono()
        else
            @timer.startChrono
            afficherChrono()
        end

        majGraphiqueIles()
        @listPont.each { |p|
            if(p.etatPont>0)
                majGraphique(p)
            end
        }

        if(@listCoup.size()>0)
            @undoBouton.sensitive = true
        end
        if(@listReDo.size()>0)
            @redoBouton.sensitive = true
        end

    end

    # Méthode qui applique le CSS de la partie.
    def appliquerCSS()
        # Partie couleur
        provider = Gtk::CssProvider.new
        case $modeDaltonien
        when 0
            modeCouleur = "Normal"
        when 1
            modeCouleur = "Deuteranopie"
        when 2
            modeCouleur = "Protanopie"
        when 3
            modeCouleur = "Tritanopie"
        end
        provider.load_from_path("../res/css/partie#{modeCouleur}.css")
        Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)
        # Partie thème
        Theme.themePartieAppliquer()
        return self
    end

    # Méthode qui permet d'initialiser et de lancer le chrono et son affichage.
    def creerChrono() #:doc:
        @timer = Chrono.creer(0) # Un chrono qui augmente sa valeur toutes les secondes et commence à 0. 
        @timer.startChrono # Démarre le chrono
        afficherChrono()
    end    

    # Méthode qui génére un path de map aux caractéristiques choisies en paramètres. 
    # * +difficulte+ [String] - La difficulté de la map (facile, moyenne, difficile)
    # * +taille+ [Integer/String] - La taille de la map
    def genererMap(difficulte, taille)
        repertoire = Dir.new("../res/grilles/#{difficulte}/#{taille}")
        nbEntree = -2
        repertoire.each{|f| nbEntree+=1}

        if(nbEntree>0)
            numero = rand(nbEntree)+1
            repertoire.close
            return "../res/grilles/#{difficulte}/#{taille}/#{numero}"
        else
            raise "Grille introuvable !"
        end
        return self
    end

    # Méthode de création de la fenêtre (modifiée pour ne pas créer la fenêtre)
    def creationFenetre() #:doc:
        @fenetre.set_title("Hashi - Libre - #{@pseudo}")
        @fenetre.signal_connect('destroy'){
            if(@timer.getEnExec)
                @timer.stopChrono
                Thread.kill(@threadAffichageChrono)
            end
            self.sauvegarderVersFichier()
            Gtk.main_quit
        }
    end

    # Méthode de création d'une grid de boutons et de son array correspondant pour représenter la grille de jeu
    def creationGrilleDeBoutons() #:doc:
        # Grille des boutons
        @grid = Gtk::Grid.new() # Grid qui va contenir les boutons
        @grid.column_homogeneous=true
        @grid.row_homogeneous=true
        @grilleBT = Array.new(@taille) {Array.new(@taille)} # Tableau de boutons (correspond aux cases du tableau grille)

        # Création des boutons de la grille :
        for i in 0..@taille-1
            for j in 0..@taille-1
                @grilleBT[i][j] = creerBoutonGrille(i,j) # Crée un nouveau bouton, configure son comportement et l'ajoute à la grid
            end
        end
    end    

    # Méthode qui gère les boutons de l'interface et l'ajout aux différents conteneurs pour créer l'interface graphique
    def creationBoutonsDeLInterface() #:doc:
        # Informations contenues dans hboxInfos :

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
        coupsBox = Gtk::Box.new(:vertical, spacing=5)
        coupsLabel = Gtk::Label.new("Coups", {:use_underline => false}).set_single_line_mode(true)
        coupsLabel.name = "lbl_interface"
        @coupsText = Gtk::Label.new("#{@nbCoups}", {:use_underline => false}).set_single_line_mode(true)
        @coupsText.name = "lbl_interface_gras"
        coupsBox.add(coupsLabel)
        coupsBox.add(@coupsText)

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
        @hboxInfos.add(coupsBox)
        @hboxInfos.add(difficulteBox)
        @hboxInfos.add(tailleBox)

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
                self.afficherAide()
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
        imageUndo.pixbuf=imageUndo.pixbuf.scale_simple(50, 50, GdkPixbuf::InterpType::BILINEAR)
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

        # Bouton charger le checkpoint
        chargerBouton = Gtk::Button.new(:label =>"Charger")
        chargerBouton.name = "btn_interface"
        chargerBouton.sensitive = false
        chargerBouton.signal_connect('clicked'){
            self.chargerCheckpoint()
            if(!estVide?)
                @viderBouton.sensitive = true
            end    
        }

        # Bouton sauvegarder le checkpoint
        sauvegarderBouton = Gtk::Button.new(:label =>"Sauvegarder")
        sauvegarderBouton.name = "btn_interface"
        sauvegarderBouton.signal_connect('clicked'){
            self.sauvegarderCheckpoint()
            chargerBouton.sensitive = true
        }

        # Espace d'affichage de l'aide textuelle 
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
        @gridInterface.attach(sauvegarderBouton, 0, 5, 2, 1)
        @gridInterface.attach(chargerBouton, 2, 5, 1, 1)
        @gridInterface.attach(@viderBouton, 3, 5, 2, 1)
        # 7e ligne :
        @gridInterface.attach(@undoBouton, 1, 6, 1, 1)
        @gridInterface.attach(@redoBouton, 3, 6, 1, 1)

        @hbox.add(@gridInterface)
        @fenetre.add(@hbox)
    end  
    
    # Méthode qui permet de créer un thread qui va modifier toutes les secondes l'affichage du chrono (gère les cas dépendants de la modification du chrono)
    def afficherChrono()
        @threadAffichageChrono = Thread.new do
            while @timer.getEnExec
                #On met à jour le label du timer toutes les 1 secondes
                sleep(0.5)
                @chronoText.text = @timer.afficher()
            end
        end
        return self
    end

    # Méthode qui permet de faire avancer de nb le nombre de coups (impacte l'affichage). 
    # * +nb+ - le nombre de coups à ajouter
    def evoluerNbCoups(nb)
        @nbCoups += nb
        @coupsText.text = "#{@nbCoups}"
        return self
    end
    
    # Méthode permettant de modifier un Pont (vérifie si c'est autorisé, renvoie le booléen d'autorisation de la création du pont)
    # * +p+ [Pont] - Le Pont à modifier
    # * +undo+ [Boolean] - Si appelé avec la méthode undo
    def modifierPont(p,undo)
        autorise = true
        # Passer en revue les cases changées pour possiblement empêcher le changement :
        if(p.etatPont == 0) # Si le pont que l'on veut changer doit apparaître, on doit tester si aucun autre pont nous gêne
            # On parcourt toutes les cases de tous les ponts pour voir les cases communes avec d'autres ponts. 
            for c in p.tabCases
                for autre in @listPont
                    for cautre in autre.tabCases
                        if(autorise and autre != p and autre.etatPont !=0 and c.positionX == cautre.positionX and c.positionY == cautre.positionY) #Une case est en commun et le pont en question est actif
                            autorise = false
                        end
                    end
                end
            end
        end
        
        if(autorise)
            if(!undo)
                @listReDo.clear()
            end
            # Changement d'état du pont car autorisé :
            etat = p.prochainEtat()
            # Evolution du nombre de coups
            evoluerNbCoups(1)
            # Modifier les boutons correspondant aux cases changées :
            majGraphique(p)
            if(!undo)
                @listCoup << p
                @undoBouton.sensitive = true
            end
            majGraphiqueIles()    
            if(self.verifierGrille == 0) # Ce nouveau coup a permis d'avoir la grille résolue !
                self.finDePartie()
            end 
            if(!estVide?)
                @viderBouton.sensitive = true
            end    
        end  

        return autorise
    end

    # Méthode appelée quand la partie se termine (grille résolue)
    def finDePartie() #:doc:
        @timer.stopChrono
        case @difficulte
        when "Facile"
            diff=1
        when "Moyenne"
            diff=2
        when "Difficile"
            diff=3
        else
            diff=0
        end

        scoreFinal = calculDuScore()
        info_verif_grille = Gtk::MessageDialog.new(:parent => @fenetre, :flags => :destroy_with_parent, :type => :info, :buttons => :close, :message => "Grille validée")
        info_verif_grille.secondary_text="Félicitations, vous avez réussi votre grille en #{@nbCoups} coups.\nVotre partie a duré #{@timer.afficher}.\nVotre score est : #{scoreFinal}"
        info_verif_grille.run()
        info_verif_grille.destroy()
        if(diff!=0)
            ClassementLibre.ajoutDansLaBDD(@pseudo, scoreFinal, diff)
        else
            puts ("Valeur de difficulté inconnue, le score ne sera pas sauvegardé.")
        end

        #Retour au menu
        @fenetre.remove(@hbox)
        InterfaceAccueilJeu.new(@fenetre)
    end    

    # Méthode permettant de calculer le score actuel du joueur
    def calculDuScore()
        time = @timer.valeur()
        score = 1.0/time * 100000 * @taille
        nbCoupParfait = 0
        # Si on a terminé la grille, alors les ponts présents donnent le nombre de coups idéal pour terminer la grille
        for p in @listPont
            if(p.etatPont>0)
                nbCoupParfait += p.etatPont
            end    
        end
        coupScore = [@nbCoups-nbCoupParfait, 0].max
        score -= coupScore * 10
        return score.to_i()
    end
    
    # Méthode générant une aide
    def genererAide()
        @conseil = @aide.genereConseil()
        @bufferConseils.text = @conseil.texte
        return self
    end
    
    # Méthode provoquant l'affichage d'une aide préalablement générée
    def afficherAide()
        if(@conseil.nbIlesConcernees > 0)
            if(@conseilAffiche == false)
                for c in @conseil.listeDesIlesConcernees
                    c.highlight = true
                    @grilleBT[c.positionX][c.positionY].name = "btn_grille_highlighted"
                end    
                @conseilAffiche = true
            else
                for c in @conseil.listeDesIlesConcernees
                    c.highlight = false
                    if(c.verifierNombreDePont)
                        @grilleBT[c.positionX][c.positionY].name = "btn_grille_valide"
                    elsif(c.getNbPonts > c.valeur)
                        @grilleBT[c.positionX][c.positionY].name = "btn_grille_invalide"
                    else
                        @grilleBT[c.positionX][c.positionY].name = "btn_grille_ile"
                    end
                end
                @conseilAffiche = false
            end
        end
        return self
    end   
    
    # Méthode permettant de générer la grille d'îles et les ponts solutions à partir d'un fichier
    def remplissageFichier() #:doc:
        # Lire fichier map
        donnes_map = File.read(@nomMap).split("\n")
        # On récupère la difficulté de la grille
        @difficulte = donnes_map.shift().strip()
        # On récupère la taille dans le fichier, puis le nombre d'Iles
        @taille = donnes_map.shift().to_i 
        nbIles = donnes_map.shift().to_i 
        # On crée des Array destinés à contenir les futures Ile et Pont
        arr_iles = donnes_map.take(nbIles)
        arr_ponts = donnes_map.drop(nbIles)

        # Initialiser la grille de la taille convenue
        @grille = Array.new(@taille) {|i| Array.new(@taille) {|j| Case.creer(i,j)}}
        
        # On crée les Ile à partir de l'Array du texte provenant du fichier
        arr_iles.each do |i|
            infos_i = i.split(" ")
            x = infos_i.shift().to_i
            y = infos_i.shift().to_i
            val = infos_i.shift().to_i
            ile = Ile.creer(x,y,val,@taille,@grille)
            @listIle.push(ile)
            @grille[x][y] = ile
        end
        
        # On crée les Pont (solution) à partir de l'Array du texte provenant du fichier
        arr_ponts.each do |p|
            infos_p = p.split(" ")
            posXD = infos_p.shift().to_i
            posYD = infos_p.shift().to_i
            posXA = infos_p.shift().to_i
            posYA = infos_p.shift().to_i
            type = infos_p.shift().to_i
            ileA=nil
            ileD=nil
            # On retrouve les Ile correspondantes dans la liste d'Ile
            @listIle.each do |i|
                if(i.positionX == posXA and i.positionY == posYA)
                    ileA = i
                end
                if(i.positionX == posXD and i.positionY == posYD)
                    ileD = i
                end
            end
            
            
            tab_cases = Array.new()
            x = posXD
            y = posYD
            # On trace la liste de cases survolées par le pont s'il suit Y
            if(posXD == posXA)
                y += 1
                while(y < posYA)
                    tab_cases.push(@grille[x][y])
                    y += 1
                end
            else
                # On trace la liste de cases survolées par le pont suivant X
                x += 1
                while(x < posXA)
                    tab_cases.push(@grille[x][y])
                    x += 1
                end
            end
            # On crée l'objet Pont avec le tableau des cases survolées puis on l'ajoute dans les listes correspondantes
            p = Pont.creer(tab_cases,ileD,ileA, type)
            if(ileD.is_a?(Ile) && ileA.is_a?(Ile))
                ileD.ajouterBonPont(p)
                ileA.ajouterBonPont(p)
            else
                puts "IllegalABP sur île: pas une île"
                puts "Pont incriminé : "
                puts p
            end
        end
    end    

    #Méthode qui créé les ponts potentiels de chaque ile de la liste
    def creerPontsPotentiels() #:doc:
        # On va créer tous les Pont pour remplir la liste de Pont et les liste de Pont potentiels des Iles
        @listIle.each do |i1|
            @listIle.each do |i2|
                # On vérifie qu'un Pont entre deux Ile peut exister
                if(i1 != i2 && i1.peutEtreRelieeA?(i2,false))
                    # On crée le Pont
                    tab_cases = Array.new()
                    x = i1.positionX
                    y = i1.positionY
                    # On trace la liste de cases survolées par le pont s'il suit Y
                    if(i1.positionX == i2.positionX)
                        y += 1
                        while(y < i2.positionY)
                            tab_cases.push(@grille[x][y])
                            y += 1
                        end
                    else
                        # On trace la liste de cases survolées par le pont suivant X
                        x += 1
                        while(x < i2.positionX)
                            tab_cases.push(@grille[x][y])
                            x += 1
                        end
                    end
                    
                    p = Pont.creer(tab_cases,i1,i2, 0)
                    # On vérifie que le Pont n'existe pas déjà, et que son tracé ne survole pas d'Ile
                    if(puisJeCreerPont(p) && !tab_cases.empty?)
                        ajoutOK = true
                        tab_cases.each do |c|
                            if(c.estIle?)
                                ajoutOK = false
                            end
                        end
                        if(ajoutOK)
                            i1.ajouterPont(p)
                            i2.ajouterPont(p)
                            @listPont.push(p)
                        end
                    end
                end
            end
        end
    end 
    
    # Méthode indiquant si un pont existe déjà
    # * +p+ [Pont] - Le pont dont on vérifie la présence dans la liste de ponts
    def puisJeCreerPont(p)
        @listPont.each { |p2|
            if(p2.eql?(p))
                return false
            end
        }
        return true
    end

    # Méthode permettant de remplir les voisines de chaque ile de la liste
    def remplissageIlesVoisines()#:doc:
        # Remplissage des listes d'îles voisines
        @listIle.each do |i1|
            @listIle.each do |i2|
                if(!i1.eql?(i2) && i1.peutEtreRelieeA?(i2,false))
                    i1.ajouterIleVoisine(i2)
                end
            end
        end
    end    

    # Méthode vérifiant la grille, renvoie un entier  
    # Return un entier correspondant au nombre d'îles incorrectement reliées   
    def verifierGrille()
        ilesIncorrectes = 0
        @listIle.each() do |i|
            if(!i.estCorrectementReliee())
                ilesIncorrectes += 1
            end
        end
        return ilesIncorrectes
    end
    
    # Méthode provoquant l'affichage d'une fenêtre bondisante indiquant à l'utilisateur si la grille est correcte  
    def causerVerifierGrille()
        nombre_erreurs = self.verifierGrille()
        if(nombre_erreurs == 0)
            finDePartie()
        else
            info_verif_grille = Gtk::MessageDialog.new(:parent => @fenetre, :flags => :destroy_with_parent, :type => :info, :buttons => :ok, :message => "Grille non validée")
            info_verif_grille.secondary_text="Désolé, vous n'avez pas (encore) réussi votre grille. Il vous reste #{nombre_erreurs} îles incorrectement reliées."
        end
        info_verif_grille.run()
        info_verif_grille.destroy()
        return self
    end

    # Méthode provoquant l'affichage des règles
    def afficherRegles()
        regles = Gtk::MessageDialog.new(:parent => @fenetre, :flags => :destroy_with_parent, :type => :info, :buttons => :ok, :message => "Règles du jeu")
        regles.secondary_text="Le but du jeu de Hashi est de relier des îles avec des ponts. Les pont peuvent être simples ou doubles.\nChaque île indique le nombre de ponts auquel elle doit être reliée. Un pont simple compte pour un et un double compte pour deux.\nLes îles doivent être toutes reliées entre elles d'un seul tenant."
        regles.run()
        regles.destroy()
        return self
    end
    
    # Méthode vidant la grille, en retirant tous les ponts
    def viderGrille()
        @listPont.each() do |p|
            if(p.etatPont>0)
                p.reset(true)
                majGraphique(p)
            end
        end
        @listCoup.clear()
        @listReDo.clear()
        for i in @listIle
            @grilleBT[i.positionX][i.positionY].name = "btn_grille_ile"
        end
        return self
    end

    # Méthode qui permet de savoir si la grille est vide (tous les ponts à zéro)
    def estVide?()
        @listPont.each() do |p|
            if(p.etatPont != 0)
                return false
            end    
        end
        return true
    end    
    
    # Méthode provoquant l'affichage du menu in-game
    def afficherMenu()
        @timer.stopChrono()
        tempsEcoule = @timer.valeur

        # HBOX pour daltonien
        daltonienBox = Gtk::Box.new(:horizontal, spacing=50)
        daltonienBox.homogeneous = true
        # Label pour daltonien
        daltonienLabel = Gtk::Label.new("Mode de couleurs :", {:use_underline => false}).set_single_line_mode(true)
        daltonienLabel.name = "lbl_interface_gras"
        # Groupe de radio bouton pour le mode daltonien
        @radioDaltonien = Gtk::RadioButton.new(:label => 'Vision Normale', :underline => true)
        @radioDaltonien.name = "lbl_interface"
        radioDeute = Gtk::RadioButton.new(:label => 'Deutéranopie', :member => @radioDaltonien)
        radioDeute.name = "lbl_interface"
        radioProta = Gtk::RadioButton.new(:label => 'Protanopie', :member => @radioDaltonien)
        radioProta.name = "lbl_interface"
        radioTrita = Gtk::RadioButton.new(:label => 'Tritanopie', :member => @radioDaltonien)
        radioTrita.name = "lbl_interface"
        # Choix actuel
        @radioDaltonien.active = false
        radioDeute.active = false
        radioProta.active = false
        radioTrita.active = false

        case $modeDaltonien
        when 0
            @radioDaltonien.active = true
        when 1
            radioDeute.active = true
        when 2
            radioProta.active = true
        when 3
            radioTrita.active = true
        end
        # Ajout à la HBOX
        daltonienBox.add(daltonienLabel)
        daltonienBox.add(@radioDaltonien)
        daltonienBox.add(radioDeute)
        daltonienBox.add(radioProta)
        daltonienBox.add(radioTrita)


        # HBOX pour thème
        themeBox = Gtk::Box.new(:horizontal, spacing=50)
        themeBox.homogeneous = true
        # Label pour thème
        themeLabel = Gtk::Label.new("Thème :", {:use_underline => false}).set_single_line_mode(true)
        themeLabel.name = "lbl_interface_gras"
        # Groupe de radio bouton pour thèmes
        @radioTheme = Gtk::RadioButton.new(:label => 'Clair', :underline => true)
        @radioTheme.name = "lbl_interface"
        radioSombre = Gtk::RadioButton.new(:label => 'Sombre', :member => @radioTheme)
        radioSombre.name = "lbl_interface"
        # Choix actuel
        if(Theme.isClair?)
            @radioTheme.active = true
            radioSombre.active = false

        else
            radioSombre.active = true
            @radioTheme.active = false
        end
        # Ajout à la HBOX
        themeBox.add(themeLabel)
        themeBox.add(@radioTheme)
        themeBox.add(radioSombre)

        # Bouton classement
        boutonClassement = Gtk::Button.new(:label =>"Classement")
        boutonClassement.name = "btn_interface"
        boutonClassement.signal_connect('clicked'){
            # Aller au classement en sauvegardant l'état de la grille
            @fenetre.remove(@inGameMenu)
            Classement.creer(@pseudo,@fenetre,@inGameMenu)
        }

        # Bouton sauvegarder
        boutonSauvegarder= Gtk::Button.new(:label =>"Sauvegarder dans un fichier")
        boutonSauvegarder.name = "btn_interface"
        boutonSauvegarder.signal_connect('clicked'){
            sauvegarderVersFichier()
        }

        # Bouton charger
        boutonCharger= Gtk::Button.new(:label =>"Charger depuis un fichier")
        boutonCharger.name = "btn_interface"
        boutonCharger.signal_connect('clicked'){
            @fenetre.remove(@inGameMenu)
            InterfaceMenuJouerChargerPartie.new(@fenetre)
        }

        # Bouton Accueil
        boutonAccueil= Gtk::Button.new(:label =>"Accueil")
        boutonAccueil.name = "btn_interface"
        boutonAccueil.signal_connect('clicked'){
            sauvegarderVersFichier()
            @fenetre.remove(@inGameMenu)
            InterfaceAccueilJeu.new(@fenetre)
        }

        # Bouton Retour
        boutonRetour= Gtk::Button.new(:label =>"Annuler")
        boutonRetour.name = "btn_interface"
        boutonRetour.signal_connect('clicked'){
            retourInGame(tempsEcoule)
        }

        # Bouton OK
        boutonOK= Gtk::Button.new(:label =>"OK")
        boutonOK.name = "btn_interface"
        boutonOK.signal_connect('clicked'){
            retourInGame(tempsEcoule)
            appliquerChangements()
        }

        # HBOX boutons de validation
        validationBox = Gtk::Box.new(:horizontal, spacing=50)
        validationBox.homogeneous = true
        # Ajout bouton Accueil
        validationBox.add(boutonAccueil)
        # Ajout bouton Retour
        validationBox.add(boutonRetour)
        # Ajout bouton OK
        validationBox.add(boutonOK)


        # Création VBOX @inGameMenu pour contenir le menu
        @inGameMenu = Gtk::Box.new(:vertical, spacing=25)
        @inGameMenu.name = "box_ingame"
        @inGameMenu.homogeneous = true

        # Ajout hbox daltonien
        @inGameMenu.add(daltonienBox)
        # Ajout hbox thème
        @inGameMenu.add(themeBox)
        # Ajout bouton classement
        @inGameMenu.add(boutonClassement)
        # Ajout bouton sauvegarder
        @inGameMenu.add(boutonSauvegarder)
        # Ajout bouton charger
        @inGameMenu.add(boutonCharger)
        # Ajout hbox validation
        @inGameMenu.add(validationBox)

        # Ajout dans la fenêtre
        @fenetre.remove(@hbox)
        @fenetre.add(@inGameMenu)
        @fenetre.show_all()
        return self
    end

    # Méthode permettant d'appliquer les changements de thème et de couleurs à partir des radioButton
    def appliquerChangements()
        # Récupére le nouveau mode de couleurs et l'applique
        choisi = nil
        for r in @radioDaltonien.group
            if(r.active?)
                choisi = r
            end
        end
        if(choisi != nil)
            provider = Gtk::CssProvider.new
            case choisi.label
            when "Vision Normale"
                $modeDaltonien = 0
                modeCouleur = "Normal"
            when "Deutéranopie"
                $modeDaltonien = 1
                modeCouleur = "Deuteranopie"
            when "Protanopie"
                $modeDaltonien = 2
                modeCouleur = "Protanopie"
            when "Tritanopie"
                $modeDaltonien = 3
                modeCouleur = "Tritanopie"
            end
            provider.load_from_path("../res/css/partie#{modeCouleur}.css")
            Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)
        end
        # Récupére le nouveau thème et l'applique
        Theme.themePartieSwitch(@radioTheme.active?)
        for p in @listPont
            if(p.etatPont>0)
                majGraphique(p)
            end
        end
        return self
    end

    # Méthode permettant de retourner à la partie depuis le menu in-game
    # * +tempsEcoule+ [Integer] - le temps dans le chrono au moment d'entrer dans le menu
    def retourInGame(tempsEcoule)
        @fenetre.remove(@inGameMenu)
        @fenetre.add(@hbox)
        majGraphiqueIles()
        @timer = Chrono.creer(tempsEcoule)
        @timer.startChrono()
        afficherChrono()
        @fenetre.show_all()
        return self
    end
    
    # Méthode qui prends en paramètre un widget recherché dans la grille de boutons, et renvoie ses coordonnées dans un tableau (vide si non trouvé)
    # * +widget+ [Gtk::Widget]- le widget à trouver dans la grille de bouton (@grilleBT)
    def positionDansGrille(widget) #:doc:
        for i in 0..@taille-1
            for j in 0..@taille-1
                if(@grilleBT[i][j].object_id==widget.object_id)
                    return [i,j]
                end
            end
        end
        return []
    end
    
    # Méthode qui crée un bouton en connaissant sa position dans la grille
    # * +posx+ [Integer] - la position (future) en x du bouton dans la grille des boutons (@grid)
    # * +posy+ [Integer] - la position (future) en y du bouton dans la grille des boutons (@grid)
    def creerBoutonGrille(posx, posy) #:doc:
        bouton = Gtk::Button.new()
        bouton.name = "btn_grille"
        bouton.set_can_focus(false)
        bouton.set_focus_on_click(false)
        if(@grille[posx][posy]==nil)
            puts "ATTENTION : Bouton qui ne représente pas une case de la grille"
        elsif(@grille[posx][posy].estIle?)
            # Affiche sur le bouton, l'image de la valeur de l'île :
            # Détruit l'ancienne image du bouton, s'il y en avait une
            detruireImage(bouton.image)
            imgIle = Gtk::Image.new(:file => "../res/img/#{@grille[posx][posy].valeur}.svg")
            imgIle.pixbuf=imgIle.pixbuf.scale_simple(@tailleImg,@tailleImg, GdkPixbuf::InterpType::BILINEAR)
            bouton.set_image(imgIle)
            bouton.set_always_show_image(true)
            bouton.name = "btn_grille_ile" 
        elsif(@grille[posx][posy].contientPont)
            # Comportement lors de l'appui sur un pont possible
            bouton.signal_connect('clicked'){
                # On cherche à récupérer les pont possibles sur cette case dans la liste des ponts (il peut y en avoir un ou deux)
                ponts=[]
                for p in @listPont
                    for c in p.tabCases
                        if(c.positionX == posx and c.positionY == posy) # La case du pont est la case actuellement cliquée. 
                            ponts << p
                        end
                    end
                end
                # On a récupéré dans ponts les ponts contenant la case cliquée
                # Comment choisir quel pont modifier ? On choisit pour celui qui n'est pas nul, s'ils le sont tous, le plus court, s'ils sont de la même taille, on s'aide de @choixSens
                if(ponts.length==1)
                    self.modifierPont(ponts[0], false) # Il n'y a qu'un pont sur la case
                elsif(ponts.length==2)
                    if((ponts[0].etatPont==0 && ponts[1].etatPont==0)) # Les deux ponts sont à zéro, on modifie le premier | Le premier pont est à 1, on le fait évoluer en remettant bien le deuxième à zéro (au cas où)
                        change = self.modifierPont(ponts[0], false)
                        if(!change)
                            change = self.modifierPont(ponts[1], false)
                        else
                            ponts[1].reset(false)
                        end
                    elsif(ponts[0].etatPont==1) # Un des deux ponts est affiché, on doit donc s'occuper de lui en priorité
                        self.modifierPont(ponts[0], false)
                    elsif(ponts[1].etatPont==1)
                        self.modifierPont(ponts[1], false)
                    elsif(ponts[0].etatPont==2) # Le premier pont est à 2, on le remet à zéro puis on fait évoluer le second pont |
                            self.modifierPont(ponts[0], false)
                            self.modifierPont(ponts[1], false)
                    elsif(ponts[1].etatPont==2) # Le second pont est à 1, on le fait évoluer et on remet l'autre à zéro (au cas où) | Le second pont est à 2, on remet tous les ponts à zéro (le premier avec reset, le second avec modifierPont)
                            ponts[0].reset(false)
                            self.modifierPont(ponts[1], false)
                    else 
                            raise "Problème avec les ponts qui se croisent"
                    end 
                else
                    raise "ERREUR : Pas le bon nombre de ponts sur une même case : #{ponts.length}"
                end
            }
        end
        bouton.set_relief(Gtk::ReliefStyle::NONE)
        @grid.attach(bouton, posx, posy, 1, 1)
        return bouton
    end

    # Méthode appelée lorsqu'on souhaite défaire un coup (retiré de la liste des coups et ajouté à la liste de redo)
    def unDo()
        if(!@listCoup.empty?)
            dernierCoup = @listCoup.pop()
            #Refait le cycle du pont, pour annuler le coup
            self.modifierPont(dernierCoup,true)
            self.modifierPont(dernierCoup,true)
            @listReDo.push(dernierCoup)
        end
        return self
    end    

    # Méthode appelée lorsqu'on souhaite refaire un coup
    def reDo()
        if(!@listReDo.empty?)
            dernierCoup = @listReDo.pop()
            self.modifierPont(dernierCoup,true)
            @listCoup.push(dernierCoup)
        end
        return self
    end   
    
    # Méthode appelée pour mettre à jour @checkpoint et @checkpointCoups avec les informations de @listPont et @listCoup
    def sauvegarderCheckpoint()
        @checkpoint.clear()
        for p in @listPont
            pc = Pont.creer(p.tabCases, p.iD, p.iA, p.etatPont)
            @checkpoint.append(pc)
        end
        @checkpointCoups = @listCoup.dup() # La liste des coups ne se fait pas en copie profonde car on souhaite toujours avec la référence des ponts de @listPont
        return self
    end

    # Méthode appelée pour mettre à jour @listPont et @listCoup avec les informations de @checkpoint et @checkpointCoups
    def chargerCheckpoint()
        if(!@checkpoint.empty?)
            viderGrille()
            @listCoup = @checkpointCoups.dup() # La liste des coups ne se fait pas en copie profonde car on souhaite toujours avec la référence des ponts de @listPont
            # Mettre à jour l'aspect graphique :
            for p in @listPont
                for pc in @checkpoint
                    if(p.eql?(pc))
                        while(p.etatPont!=pc.etatPont)
                            p.prochainEtat()
                        end
                        break
                    end    
                end
                if(p.etatPont > 0)
                    majGraphique(p)
                end
            end
            majGraphiqueIles()
        end    
        return self
    end    

    # Méthode appelée pour mettre à jour les graphismes d'un pont
    # * +p+ [Pont] - le pont dont l'image doit être mise à jour
    def majGraphique(p)
        for c in p.tabCases
            imgP = nil
            theme = Theme.isClair? ? "" : "w"
            if(p.etatPont==1)
                if(p.sens?)
                    imgP = Gtk::Image.new(:file => "../res/img/sph#{theme}.svg") # Image d'un pont simple horizontal
                    
                else
                    imgP = Gtk::Image.new(:file => "../res/img/spv#{theme}.svg") # Image d'un pont simple vertical
                end
            elsif(p.etatPont == 2)
                if(p.sens?)
                    imgP = Gtk::Image.new(:file => "../res/img/dph#{theme}.svg") # Image d'un pont double horizontal
                else
                    imgP = Gtk::Image.new(:file => "../res/img/dpv#{theme}.svg") # Image d'un pont double vertical
                end
            end
            if(imgP != nil) 
                imgP.pixbuf=imgP.pixbuf.scale_simple(@tailleImg, @tailleImg, GdkPixbuf::InterpType::BILINEAR) 
            end
            # Destruction de l'image anciennement sur le bouton, s'il y en avait une
            detruireImage(@grilleBT[c.positionX][c.positionY].image)
            @grilleBT[c.positionX][c.positionY].set_image(imgP)
        end
        return self
    end   
    
    # Méthode qui permet de mettre à jour la couleur des îles en fonction des ponts qui lui sont reliées
    def majGraphiqueIles()
        for i in @listIle
            if(i.verifierNombreDePont)
                @grilleBT[i.positionX][i.positionY].name = "btn_grille_valide"
            elsif(i.getNbPonts > i.valeur)
                @grilleBT[i.positionX][i.positionY].name = "btn_grille_invalide"
            else
                @grilleBT[i.positionX][i.positionY].name = "btn_grille_ile"
            end
        end
        if(@conseilAffiche)
            for c in @conseil.listeDesIlesConcernees
                @grilleBT[c.positionX][c.positionY].name = "btn_grille_highlighted"
            end
        end
        return self
    end


    # Méthode appelée chaque fois qu'on se débarrasse d'une image qu'on ne veut plus afficher.
    # Permet de réduire drastiquement la consommation de mémoire vive.
    # * +image+ [Gtk::Image] - l'image à détruire
    def detruireImage(image) #:doc:
        if(image != nil)
            image.clear
            image = nil
        end
    end  
    
    # Méthode qui créé un thread, se débarassant toutes les secondes des images inutiles dans la mémoire
    def Partie.garbageCollectorConstant()
        Thread.new do
            while true
                # On allume le garbage collector toutes les 1 sec pour vider la mémoire des images détruites par image.clear
                sleep(1)
                GC.start
            end
        end
        return self
    end    

    # Méthode permettant de sauvegarder une grille en cours de partie
    def sauvegarderVersFichier()#:doc:
        if(verifierGrille)
            nomFichier = "../res/sauvegardes/"

            # Noms de fichier via Time
            t = Time.new()
            nomFichier = nomFichier +"#{t.year}-#{t.month}-#{t.mday}_#{t.hour}-#{t.min}-#{t.sec}.sav"

            if(!nomFichier.empty?)
                if(@timer.getEnExec)
                    @timer.stopChrono
                end
                File.open(nomFichier,"w"){
                    |f|
                    f.write("#{@nomMap}\n#{@pseudo}\n#{self.getMode}\n#{@timer.valeur}\n#{@nbGrilles}\n#{@nbCoups}\n#{@listPont.size}\n#{@listCoup.size}\n#{@listReDo.size}\n")
                    @listPont.each do |p|
                        f.write("#{p.iD.positionX} #{p.iD.positionY} #{p.iA.positionX} #{p.iA.positionY} #{p.etatPont}\n")
                    end
                    @listCoup.each do |p|
                        f.write("#{p.iD.positionX} #{p.iD.positionY} #{p.iA.positionX} #{p.iA.positionY} #{p.etatPont}\n")
                    end
                    @listReDo.each do |p|
                        f.write("#{p.iD.positionX} #{p.iD.positionY} #{p.iA.positionX} #{p.iA.positionY} #{p.etatPont}\n")
                    end
                }
            end
        else
            grille_invalide = Gtk::MessageDialog.new(:parent => @fenetre, :flags => :destroy_with_parent, :type => :info, :buttons => :ok, :message => "Les ponts ne sont pas bien reliés !")
            grille_invalide.run()
            grille_invalide.destroy()
        end    
    end

    # Méthode permettant de reprendre une sauvegarde à partir d'un fichier
    # * +cheminSAV+ [String] + Emplacement de la sauvegarde, sinon ""
    def restaurerDepuisFichier(cheminSAV)#:doc:
        sauvegarde = File.read(cheminSAV).split("\n")
        # On récupère le nom de la grille
        @nomMap = sauvegarde.shift().strip()

        # On recharge la grille
        remplissageFichier()#:doc:

        # On récupère le pseudo
        @pseudo = sauvegarde.shift() 
        if(self.getMode != sauvegarde.shift().to_i)
            raise "ERREUR : Mode de jeu de la sauvegarde différent !"
        end

        if(self.getMode() == 1)
            @timer = Timer.creer(sauvegarde.shift().to_i)
        else
            @timer = Chrono.creer(sauvegarde.shift().to_i)
        end

        @nbGrilles =  sauvegarde.shift().to_i 
        @nbCoups = sauvegarde.shift().to_i 
        nb_ponts = sauvegarde.shift().to_i 
        nb_undo = sauvegarde.shift().to_i 
        nb_redo = sauvegarde.shift().to_i 

        nb_undo_ok = 0
        nb_redo_ok = 0

        arr_ponts = sauvegarde.take(nb_ponts)
        sauvegarde = sauvegarde.drop(nb_ponts)
        arr_undo = sauvegarde.take(nb_undo)
        sauvegarde = sauvegarde.drop(nb_undo)
        arr_redo = sauvegarde.take(nb_redo)
        sauvegarde = sauvegarde.drop(nb_redo)

        if(!sauvegarde.empty?)
            raise "Sauvegarde non consommée intégralement"
            puts sauvegarde
        end

        # On crée les Pont à partir de l'Array du texte provenant du fichier
        arr_ponts.each do |p|
            infos_p = p.split(" ")
            posXD = infos_p.shift().to_i
            posYD = infos_p.shift().to_i
            posXA = infos_p.shift().to_i
            posYA = infos_p.shift().to_i
            type = infos_p.shift().to_i
            ileA=nil
            ileD=nil
            # On retrouve les Ile correspondantes dans la liste d'Ile
            @listIle.each do |i|
                if(i.positionX == posXA and i.positionY == posYA)
                    ileA = i
                end
                if(i.positionX == posXD and i.positionY == posYD)
                    ileD = i
                end
            end
            
            
            tab_cases = Array.new()
            x = posXD
            y = posYD
            # On trace la liste de cases survolées par le pont s'il suit Y
            if(posXD == posXA)
                y += 1
                while(y < posYA)
                    tab_cases.push(@grille[x][y])
                    y += 1
                end
            else
                # On trace la liste de cases survolées par le pont suivant X
                x += 1
                while(x < posXA)
                    tab_cases.push(@grille[x][y])
                    x += 1
                end
            end
            # On crée l'objet Pont avec le tableau des cases survolées puis on l'ajoute dans les listes correspondantes
            p = Pont.creer(tab_cases,ileD,ileA, type)
            if(ileD.is_a?(Ile) && ileA.is_a?(Ile))
                ileD.ajouterPont(p)
                ileA.ajouterPont(p)
                @listPont.push(p)
            else
                puts "IllegalAP sur île: pas une île"
                puts "Pont incriminé : "
                puts p
            end
        end
    
        arr_undo.each do |p|
            infos_p = p.split(" ")
            posXD = infos_p.shift().to_i
            posYD = infos_p.shift().to_i
            posXA = infos_p.shift().to_i
            posYA = infos_p.shift().to_i
            type = infos_p.shift().to_i
            ileA=nil
            ileD=nil
            # On retrouve les Ile correspondantes dans la liste d'Ile
            @listIle.each do |i|
                if(i.positionX == posXA and i.positionY == posYA)
                    ileA = i
                end
                if(i.positionX == posXD and i.positionY == posYD)
                    ileD = i
                end
            end
            
            tab_cases = Array.new()
            x = posXD
            y = posYD
            # On trace la liste de cases survolées par le pont s'il suit Y
            if(posXD == posXA)
                y += 1
                while(y < posYA)
                    tab_cases.push(@grille[x][y])
                    y += 1
                end
            else
                # On trace la liste de cases survolées par le pont suivant X
                x += 1
                while(x < posXA)
                    tab_cases.push(@grille[x][y])
                    x += 1
                end
            end
            # On crée l'objet Pont avec le tableau des cases survolées puis on l'ajoute dans les listes correspondantes
            pf = Pont.creer(tab_cases,ileD,ileA, type)
            if(ileD.is_a?(Ile) && ileA.is_a?(Ile))
                @listPont.each do |p|
                    if(p.eql?(pf))
                        @listCoup.push(p)
                        nb_undo_ok += 1
                    end
                end
            else
                puts "IllegalAP sur île: pas une île"
                puts "Pont incriminé : "
                puts p
            end
        end
        if(nb_undo != nb_undo_ok || nb_undo != @listCoup.size())
            puts nb_undo
            puts nb_undo_ok
            puts @listCoup.size()
            raise "UNDO KO"
        end

        arr_redo.each do |p|
            infos_p = p.split(" ")
            posXD = infos_p.shift().to_i
            posYD = infos_p.shift().to_i
            posXA = infos_p.shift().to_i
            posYA = infos_p.shift().to_i
            type = infos_p.shift().to_i
            ileA=nil
            ileD=nil
            # On retrouve les Ile correspondantes dans la liste d'Ile
            @listIle.each do |i|
                if(i.positionX == posXA and i.positionY == posYA)
                    ileA = i
                end
                if(i.positionX == posXD and i.positionY == posYD)
                    ileD = i
                end
            end
            
            
            tab_cases = Array.new()
            x = posXD
            y = posYD
            # On trace la liste de cases survolées par le pont s'il suit Y
            if(posXD == posXA)
                y += 1
                while(y < posYA)
                    tab_cases.push(@grille[x][y])
                    y += 1
                end
            else
                # On trace la liste de cases survolées par le pont suivant X
                x += 1
                while(x < posXA)
                    tab_cases.push(@grille[x][y])
                    x += 1
                end
            end
            # On crée l'objet Pont avec le tableau des cases survolées puis on l'ajoute dans les listes correspondantes
            pf = Pont.creer(tab_cases,ileD,ileA, type)
            if(ileD.is_a?(Ile) && ileA.is_a?(Ile))
                @listPont.each do |p|
                    if(p.eql?(pf))
                        @listReDo.push(p)
                        nb_redo_ok += 1
                    end
                end
            else
                puts "IllegalAP sur île: pas une île"
                puts "Pont incriminé : "
                puts p
            end
        end
        if(nb_redo != nb_redo_ok || nb_redo != @listReDo.size())
            puts nb_redo
            puts nb_redo_ok
            puts @listReDo.size()
            raise "REDO KO"
        end
    end    

    #Méthodes privées :
    private_class_method :new

    private :creerBoutonGrille
    private :detruireImage
    private :positionDansGrille
    private :creationFenetre
    private :creationGrilleDeBoutons
    private :creationBoutonsDeLInterface
    private :creerPontsPotentiels
    private :remplissageFichier
    private :remplissageIlesVoisines
    private :finDePartie
    private :creerChrono
    private :sauvegarderVersFichier
    private :restaurerDepuisFichier

end