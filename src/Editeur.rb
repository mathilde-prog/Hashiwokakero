# # # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Dylan CLINCHAMP, Marie-Nina MUNAR #
# # # # # # # # # # # # # # # # # # # # # # # #

require_relative('Case')
require_relative('Ile')
require_relative('Pont')
require 'gtk3'

# Classe qui représente un éditeur.  
# Cette classe contient les variables d'instances suivantes :
# @grille:: Tableau à deux dimensions de Case
# @taille:: Taille de la @grille (carrée). Il existe uniquement des grilles de taille 5, 6, 8, 10 et 15
# @listIle:: Tableau contenant les îles de la partie
# @listPont:: Tableau contenant les ponts de la partie
# @fenetre:: La fenêtre gtk du jeu
# @grid:: La grille gtk qui permet de contenir les boutons (cases) de l'espace hashi
# @grilleBT:: Un tableau qui contient les boutons dans l'ordre des cases associées (dans grille)
# @tailleImg:: La taille en pixel d'une image sur un des boutons de la @grid
# @mode:: Mode ile ou mode pont de l'éditeur (false = mode ile et true = mode pont)
# @modeBouton:: Bouton de choix du mode
# @hbox:: Box qui contient la grille de boutons et les boutons d'interface à droite
# @vbox:: Box qui contient les boutons d'interface à droite
# @comboBoxDifficulte:: Combobox de la difficultée
# @comboBoxTaille:: Combobox de la taille de la grille
class Editeur

    # La grille du jeu, constituée d'un tableau de Case
    attr_reader :grille
    
    # La taille de la grille, entier correspondant au côté du carré représenté par la grille
    attr_reader :taille
    
    # La liste des Ile
    attr_reader :listIle
    
    # La liste des Pont
    attr_reader :listPont

    # Méthode de création de l'éditeur
    # * +tailleDeLaGrille+ - La taille de la grille
    # * +difficulte+ - La difficultée de la grille
    # * +gtkOK+ - Booléen indiquant si GTK a déjà été initialisé
    def Editeur.creer(tailleDeLaGrille, difficulte, gtkOK)
        new(tailleDeLaGrille, difficulte, gtkOK)
    end    

    # Méthode d'intialisation de l'éditeur
    def initialize(tailleDeLaGrille, difficulte, gtkOK)
        if(!gtkOK)
            self.garbageCollectorConstant() # IMPORTANT : Permet d'initialiser le Garbage Collector pour s'occuper des images clean de façon régulière tout le long du programme (A APPELLER UNE SEULE FOIS)
        end

        @taille = tailleDeLaGrille

        @mode = false

        #Créer les listes
        @listIle = Array.new
        @listPont = Array.new
        
        @grille = Array.new(@taille) {|i| Array.new(@taille) {|j| Case.creer(i,j)}}

        #Début de GTK
        if(!gtkOK)
            Gtk.init()
        end

        if(!gtkOK)
            #Création d'une fenêtre
            @fenetre = Gtk::Window.new
            @fenetre.set_border_width(10)
            @fenetre.set_title("Hashi - Editeur de grille")
            @fenetre.set_icon("../res/img/ico.ico")
            @fenetre.set_default_size(800,600)
            @fenetre.signal_connect('destroy'){Gtk.main_quit}
            @fenetre.set_resizable(false)
        end

        @tailleImg = (@fenetre.size[1]-2*@fenetre.border_width)/@taille
        
        # Modification du CSS pour le style des boutons :
        provider = Gtk::CssProvider.new

        # Pour faire le cercle gradient pour le highlight des îles, on fait le calcul du pourcentage de la surface d'un cercle sur un carré de même diamètre, soit 78.5398163398%, que l'on arrondi et agrandi pour prendre en compte le contour de l'île, soit environ 83%
        provider.load(data: <<-CSS)
        #lbl_interface{font-size: 1.3em}
        #lbl_interface_italic{font-size: 1.3em; font-style: italic}
        #lbl_interface_gras{font-size: 1.3em; font-weight: bold}
        #btn_interface{font-size: 1.6em}
        #btn_grille {padding:0px;margin:0px;}
        #btn_grille_valide {background:radial-gradient(closest-side, #93FF67 83%, rgba(0,0,0,0));padding:0px;margin:0px;}
        #btn_grille_invalide {background:radial-gradient(closest-side, #FF5151 83%, rgba(0,0,0,0));padding:0px;margin:0px;}
        CSS
        Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)

        #Grille des boutons
        @grid = Gtk::Grid.new() # Grid qui va contenir les boutons
        @grid.column_homogeneous=true
        @grid.row_homogeneous=true
        @grilleBT = Array.new(@taille) {|i| Array.new(@taille) {|j| creerBoutonGrille(i,j)}} #Tableau de boutons (corresponds au case du tableau grille)

        if(gtkOK)
            @fenetre.remove(@hbox) 
         end

        # HBOX contenant la grille de boutons et la grille de boutons d'interfaces
        @hbox = Gtk::Box.new(:horizontal, spacing=50)
        @hbox.homogeneous=true

         #VBOX contenant les boutons d'interface à droite de la grille
        @vbox = Gtk::Box.new(:vertical, spacing=25)
        @vbox.homogeneous=false
        
        # Bouton switch mode placement
        @modeBouton = Gtk::Button.new(:label =>"Mode -> Ile")
        @modeBouton.name = "btn_interface"
        @modeBouton.signal_connect('clicked'){
            @mode = !@mode
            if(@mode)
                @listPont.each() do |p|
                    if(p.etatPont>0)
                        p.reset(true)
                        majGraphique(p)
                    end
                end
                @listPont.clear()
                calculerPontsPotentiels()
                for i in @listIle
                    @grilleBT[i.positionX][i.positionY].name = "btn_grille"
                end
                @modeBouton.label = "Mode -> Pont"
            else
                @listPont.each() do |p|
                    if(p.etatPont>0)
                        p.reset(true)
                        majGraphique(p)
                    end
                end
                @listPont.clear()
                for i in @listIle
                    @grilleBT[i.positionX][i.positionY].name = "btn_grille"
                end
                @modeBouton.label = "Mode -> Ile"
            end    
        }

        # Bouton charger grille
        chargerBouton = Gtk::Button.new(:label =>"Charger une grille")
        chargerBouton.name = "btn_interface"
        chargerBouton.signal_connect('clicked'){
            chargerDepuisFichier()
        }
        
        # Bouton sauvegarder grille
        sauvegarderBouton = Gtk::Button.new(:label =>"Sauvegarder la grille")
        sauvegarderBouton.name = "btn_interface"
        sauvegarderBouton.signal_connect('clicked'){
            sauvegarderVersFichier()
        }

        # Combo Box pour la difficultée du niveau
        @comboBoxDifficulte = Gtk::ComboBoxText.new()
        @comboBoxDifficulte.append("Facile","Facile")
        @comboBoxDifficulte.append("Moyenne","Moyenne")
        @comboBoxDifficulte.append("Difficile","Difficile")
        @comboBoxDifficulte.set_active_id(difficulte)

        # Combo box pour la taille de la grille
        @comboBoxTaille = Gtk::ComboBoxText.new()
        @comboBoxTaille.append("5","5")
        @comboBoxTaille.append("6","6")
        @comboBoxTaille.append("8","8")
        @comboBoxTaille.append("10","10")
        @comboBoxTaille.append("15","15")
        case tailleDeLaGrille
        when 5
            @comboBoxTaille.set_active_id("5")
        when 6
            @comboBoxTaille.set_active_id("6")
        when 8
            @comboBoxTaille.set_active_id("8")
        when 10
            @comboBoxTaille.set_active_id("10")
        when 15
            @comboBoxTaille.set_active_id("15")
        else
            raise "Erreur : difficultée non admissible"
        end

        # Bouton taille grille
        tailleBouton = Gtk::Button.new(:label =>"Changer la taille de la grille")
        tailleBouton.name = "btn_interface"
        tailleBouton.signal_connect('clicked'){           
            self.viderGrille()
            self.initialize(@comboBoxTaille.active_iter[0].to_i(),@comboBoxDifficulte.active_iter[0],true)
        }

        hboxTaille = Gtk::Box.new(:horizontal, spacing=50)
        hboxTaille.homogeneous=false

        hboxTaille.add(@comboBoxTaille)
        hboxTaille.add(tailleBouton)

        @vbox.add(chargerBouton)
        @vbox.add(sauvegarderBouton)
        @vbox.add(@modeBouton)
        @vbox.add(@comboBoxDifficulte)
        @vbox.add(hboxTaille)

        @hbox.add(@grid)
        @hbox.add(@vbox)

        @fenetre.add(@hbox)
        @fenetre.show_all
        Gtk.main        
    end

    # Méthode vidant la grille, en retirant tous les ponts
    def viderGrille()
        @listPont.each() do |p|
            if(p.etatPont>0)
                p.reset(true)
                majGraphique(p)
            end
        end
        for i in @listIle
            @grilleBT[i.positionX][i.positionY].name = "btn_grille"
        end
    end

    # Méthode vérifiant la grille. 
    # Retourne vrai si les îles sont connectées au bon nombre de ponts. Faux sinon.   
    def verifierGrille()
        @listIle.each() do |i|
            if(!i.verifierNombreDePont())
                return false
            end
        end
        return true
    end
    
    # Méthode permettant de modifier un Pont (vérifie si c'est autorisé, renvoie le booléen d'autorisation de la création du pont). 
    # * +p+ [Pont] - Le Pont à modifier
    def modifierPont(p)
        autorise = true
        # Passer en revue les cases changées pour possiblement empêcher le changement :
        if(p.etatPont == 0) # Si le pont que l'on veut changer doit apparaître, on doit tester si aucun autre pont nous gêne.
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
            # Changement d'état du pont car autorisé :
            p.prochainEtat()
            # Modifier les boutons correspondant aux cases changées :
            majGraphique(p)
            # Couleurs des îles
            for i in @listIle
                if(i.verifierNombreDePont)
                    @grilleBT[i.positionX][i.positionY].name = "btn_grille_valide"
                elsif(i.getNbPonts > i.valeur)
                    @grilleBT[i.positionX][i.positionY].name = "btn_grille_invalide"
                else
                    @grilleBT[i.positionX][i.positionY].name = "btn_grille"
                end
            end

        end  

        return autorise
    end
    
    # Méthode qui crée un bouton en connaissant sa position dans la grille
    # * +posx+ [Integer] - la position (future) en x du bouton dans la grille des boutons (@grid)
    # * +posy+ [Integer] - la position (future) en y du bouton dans la grille des boutons (@grid)
    def creerBoutonGrille(posx, posy) #:doc:
        bouton = Gtk::Button.new()
        bouton.name = "btn_grille"
        bouton.set_can_focus(false)
        bouton.set_focus_on_click(false)
        bouton.signal_connect('clicked'){

            if(!@mode) # Mode de placement des îles
                valeurChoix = Gtk::Dialog.new(:title =>"Valeur de l'île ?", :parent => @fenetre, :flags => :destroy_with_parent, :buttons => [["1",1001],["2",1002],["3",1003],["4",1004],["5",1005],["6",1006],["7",1007],["8",1008],[Gtk::Stock::DELETE,1000],[Gtk::Stock::CANCEL,:cancel]]) # Augmentés de 1000 pour éviter de tomber sur des valeurs prédéfinies
                valeurChoix.default_response=Gtk::ResponseType::CANCEL
                valeurReponse = valeurChoix.run
                valeurChoix.destroy
                case valeurReponse
                when 1001..1008 # On met une valeur dans l'île à cette position dans la grille
                   detruireImage(bouton.image)
                   imgIle = Gtk::Image.new(:file => "../res/img/#{valeurReponse-1000}.svg")
                   imgIle.pixbuf=imgIle.pixbuf.scale_simple(@tailleImg,@tailleImg, GdkPixbuf::InterpType::BILINEAR)
                   bouton.set_image(imgIle)
                    bouton.set_always_show_image(true)
                   nouvelleIle = Ile.creer(posx, posy, valeurReponse-1000, @taille, @grille)
                   trouve = false
                   for i in @listIle
                        if(nouvelleIle.eql?(i))
                            trouve = true
                            i.valeur = valeurReponse-1000
                            break
                        end    
                   end 
                   if(!trouve)
                        @listIle << nouvelleIle
                        @grille[posx][posy] = nouvelleIle
                   end 
                when 1000 # On enlève l'île à cette position dans la grille
                    detruireImage(bouton.image)
                    imgIle = nil
                    for i in @listIle
                        if(i.positionX == posx and i.positionY == posy)
                            @listIle.delete(i)
                            @grille[posx][posy] = Case.creer(posx, posy)
                            break
                        end    
                   end
                    bouton.set_image(imgIle)
                    bouton.set_always_show_image(true) 
                end
            else # Mode de placement des ponts
                # On cherche à récupérer les pont possibles sur cette case dans la liste des ponts (il peut y en avoir un ou deux). 
                ponts=[]
                for p in @listPont
                    for c in p.tabCases
                        if(c.positionX == posx and c.positionY == posy) # La case du pont est la case actuellement cliquée.
                            ponts << p
                        end
                    end
                end
                # On a récupéré dans ponts les ponts contenant la case cliquée.
                # Comment choisir quel pont modifier ? On choisit pour celui qui n'est pas nul, si ils le sont tous, le plus court, si ils sont de la même taille, on s'aide de @choixSens
                if(ponts.length==1)
                    self.modifierPont(ponts[0]) # Il n'y a qu'un pont sur la case
                elsif(ponts.length==2)
                    if((ponts[0].etatPont==0 && ponts[1].etatPont==0)) # Les deux ponts sont à zéro, on modifie le premier | Le premier pont est à 1, on le fait évoluer en remettant bien le deuxième à zéro (au cas où)
                        change = self.modifierPont(ponts[0])
                        if(!change)
                            change = self.modifierPont(ponts[1])
                        else
                            ponts[1].reset(false)
                        end
                    elsif(ponts[0].etatPont==1) # Un des deux ponts est affiché, on doit donc s'occuper de lui en priorité. 
                        self.modifierPont(ponts[0])
                    elsif(ponts[1].etatPont==1)
                        self.modifierPont(ponts[1])
                    elsif(ponts[0].etatPont==2) # Le premier pont est à 2, on le remet à zéro puis on fait évoluer le second pont |
                            self.modifierPont(ponts[0])
                            self.modifierPont(ponts[1])
                    elsif(ponts[1].etatPont==2) # Le second pont est à 1, on le fait évoluer et on remet l'autre à zéro (au cas où) | Le second pont est à 2, on remet tous les ponts à zéro (le premier avec reset, le second avec modifierPont)
                            ponts[0].reset(false)
                            self.modifierPont(ponts[1])
                    else 
                            raise "Problème avec les ponts qui se croisent"
                    end
                end
            end    
        }

        @grid.attach(bouton, posx, posy, 1, 1)
        return bouton
    end

    # Méthode appelée pour mettre à jour les graphismes d'un pont. 
    # * +p+ [Pont] - le pont dont l'image doit être mise à jour
    def majGraphique(p)
        for c in p.tabCases
            imgP = nil
            if(p.etatPont==1)
                if(p.sens?)
                    imgP = Gtk::Image.new(:file => "../res/img/sph.svg") # Image d'un pont simple horizontal
                    
                else
                    imgP = Gtk::Image.new(:file => "../res/img/spv.svg") # Image d'un pont simple vertical
                end
            elsif(p.etatPont == 2)
                if(p.sens?)
                    imgP = Gtk::Image.new(:file => "../res/img/dph.svg") # Image d'un pont double horizontal
                else
                    imgP = Gtk::Image.new(:file => "../res/img/dpv.svg") # Image d'un pont double vertical
                end
            end
            if(imgP != nil) 
                imgP.pixbuf=imgP.pixbuf.scale_simple(@tailleImg, @tailleImg, GdkPixbuf::InterpType::BILINEAR) 
            end
            # Destruction de l'image anciennement sur le bouton, s'il y en avait une. 
            detruireImage(@grilleBT[c.positionX][c.positionY].image)
            @grilleBT[c.positionX][c.positionY].set_image(imgP)
        end
    end    

    # Méthode qui permet de mettre à jour la couleur des îles en fonction des ponts qui lui sont reliées. 
    # * +i+ - L'ile qui doit être mise à jour
    def majGraphiqueIle(i)
        imgIle = Gtk::Image.new(:file => "../res/img/#{i.valeur}.svg")
        imgIle.pixbuf=imgIle.pixbuf.scale_simple(@tailleImg,@tailleImg, GdkPixbuf::InterpType::BILINEAR)
        detruireImage(@grilleBT[i.positionX][i.positionY].image)
        @grilleBT[i.positionX][i.positionY].set_image(imgIle)
        @grilleBT[i.positionX][i.positionY].set_always_show_image(true)
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

    # Méthode qui crée un thread, se débarassant toutes les secondes des images inutiles dans la mémoire. 
    def garbageCollectorConstant() #:doc: 
        Thread.new do
            while true
                # On allume le garbage collector toutes les 1 sec pour vider la mémoire des images détruites par image.clear. 
                sleep(0.5)
                GC.start
            end
        end
    end    

    # Méthode permettant de sauvegarder une grille éditée. 
    def sauvegarderVersFichier() #:doc: 
        if(verifierGrille)
            nom_fichier = ""
            dialog = Gtk::FileChooserDialog.new(:title => "Sauvegarder vers un fichier", :parent => nil, :action => :save, :buttons => [[Gtk::Stock::CANCEL, :cancel],[Gtk::Stock::OPEN, :accept]])
            if (dialog.run == :accept)
                nom_fichier = "#{dialog.filename}"
            end
            dialog.destroy
            if(!nom_fichier.empty?)
                File.open(nom_fichier,"w"){
                    |f|
                    f.write("#{@comboBoxDifficulte.active_iter[0]}\n#{@taille}\n#{@listIle.length}\n")
                    @listIle.each do |i|
                        f.write("#{i.positionX} #{i.positionY} #{i.valeur}\n")
                    end
                    @listPont.each do |p|
                        if(p.etatPont > 0)
                            f.write("#{p.iD.positionX} #{p.iD.positionY} #{p.iA.positionX} #{p.iA.positionY} #{p.etatPont}\n")
                        end
                    end
                }
            end
        else
            grille_invalide = Gtk::MessageDialog.new(:parent => @fenetre, :flags => :destroy_with_parent, :type => :info, :buttons => :ok, :message => "Les ponts ne sont pas bien reliés !")
            grille_invalide.run()
            grille_invalide.destroy()
        end    
    end

    # Méthode permettant de retravailler une grille existante. 
    def chargerDepuisFichier() #:doc:
        nom_fichier = ""
        dialog = Gtk::FileChooserDialog.new(:title => "Ouvrir un fichier", :parent => nil, :action => :open, :buttons => [[Gtk::Stock::CANCEL, :cancel],[Gtk::Stock::OPEN, :accept]])
        if (dialog.run == :accept)
            self.viderGrille()
            # Créer les listes
            @listIle = Array.new
            @listPont = Array.new
            @mode = true
            @modeBouton.label = "Mode -> Pont"
            nom_fichier = "#{dialog.filename}"
            # Remplir la listIle
            # Lire fichier map
            donnes_map = File.read(nom_fichier).split("\n")
            # On récupère la difficulté de la grille
            diff = donnes_map.shift().strip()
            case diff
            when "Facile"
                @comboBoxDifficulte.set_active_id("Facile")
            when "Moyenne"
                @comboBoxDifficulte.set_active_id("Moyenne")
            when "Difficile"
                @comboBoxDifficulte.set_active_id("Difficile")
            else
                raise "Erreur : difficultée dans le fichier non admissible"
            end
            
            # On récupère la taille dans le fichier, puis le nombre d'Iles
            @taille = donnes_map.shift().to_i 
            nbIles = donnes_map.shift().to_i 
            # On crée des Array destinés à contenir les futures Ile et Pont
            arr_iles = donnes_map.take(nbIles)
            arr_ponts = donnes_map.drop(nbIles)

            @tailleImg = (@fenetre.size[1]-2*@fenetre.border_width)/@taille

            # Initialiser la grille de la taille convenue
            @grille = Array.new(@taille) {|i1| Array.new(@taille) {|j1| Case.creer(i1,j1)}}

            #Grille de boutons GTK :
            @hbox.remove(@grid)
            @hbox.remove(@vbox)
            @grid = Gtk::Grid.new()#Grid qui va contenir les boutons
            @grid.column_homogeneous=true
            @grid.row_homogeneous=true

            @grilleBT = Array.new(@taille) {|i2| Array.new(@taille) {|j2| creerBoutonGrille(i2,j2)}}

            @hbox.add(@grid)
            @hbox.add(@vbox)

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
                    ileD.ajouterPont(p)
                    ileA.ajouterPont(p)
                    @listPont.push(p)
                else
                    puts "IllegalABP sur île: pas une île"
                    puts "Pont incriminé : "
                    puts p
                end
            end

            for p in @listPont
                majGraphique(p)
            end   
            
            for i in @listIle
                majGraphiqueIle(i)
            end

            self.calculerPontsPotentiels

            puts @listIle
            puts @listPont

        end
        dialog.destroy
        @fenetre.show_all()
    end

    # Méthode  remplissant les ponts potentiels entre les Ile
    def calculerPontsPotentiels() #:doc:
        # On va créer tous les Pont pour remplir la liste de Pont et les listes de Pont potentiels des Iles
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
                    deja = false
                    for ps in @listPont
                        if(p.eql?(ps))
                            deja = true
                            break
                        end
                    end    
                    if(!deja && !tab_cases.empty?)
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


    # Méthodes privées :
    private_class_method :new
    private :garbageCollectorConstant
    private :creerBoutonGrille
    private :detruireImage
    private :chargerDepuisFichier
    private :sauvegarderVersFichier
    private :calculerPontsPotentiels
end

Editeur.creer(5,"Facile",false)