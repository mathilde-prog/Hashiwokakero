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
require_relative('ClassementProgressif')
require_relative('Partie')

# Classe représentant une partie de Hashi en mode progressif. 
# Cette classe contient la variable d'instance suivante (en plus de celles de la classe mère)
# @tempsEcoule:: Temps restant en secondes 
class PartieProgressif < Partie

    # Retourne le mode de jeu de la partie
    def getMode()
        return 2
    end

    # Constructeur de la classe PartieProgressif
    # * +fenetre+ [Gtk::Window] - Fenêtre où se trouve la partie
    # * +difficulte+ [String] - Difficulté de la grille générée (facile, moyenne, difficile)
    # * +taille+ [Integer/String] - Taille de la grille générée
    # * +pseudo+ [String] - Pseudo du joueur (donné par le menu)
    # * +tempsEcoule+ [Integer] - Temps restant en secondes
    # * +nbGrilles+ [Integer] - Nombre de grilles actuel
    # * +cheminSAV+ [String] - Emplacement de la sauvegarde, sinon ""
    def PartieProgressif.creer(fenetre, difficulte, taille, pseudo, tempsEcoule, nbGrilles,cheminSAV)
        new(fenetre, difficulte, taille, pseudo, tempsEcoule, nbGrilles, cheminSAV)
    end

    # Méthode d'intialisation de Partie  
    # * +fenetre+ [Gtk::Window] - Fenêtre où se trouve la partie
    # * +difficulte+ [String] - Difficult" de la grille générée (facile, moyenne, difficile)
    # * +taille+ [Integer/String] - Taille de la grille générée
    # * +pseudo+ [String] - Pseudo du joueur (donné par le menu)
    # * +tempsEcoule+ [Integer] - Temps restant en secondes
    # * +nbGrilles+ [Integer] - Nombre de grilles actuel
    # * +cheminSAV+ [String] - Emplacement de la sauvegarde, sinon ""
    def initialize(fenetre, difficulte, taille, pseudo, tempsEcoule, nbGrilles,cheminSAV)
        @tempsEcoule = tempsEcoule
        @nbGrilles = nbGrilles
        super(fenetre, difficulte, taille, pseudo,cheminSAV)
    end

    # Méthode qui permet d'initialiser et de lancer le chrono et son affichage
    def creerChrono()
        @timer = Chrono.creer(@tempsEcoule) # Un chrono qui décrémente sa valeur toutes les secondes et commence à partir de la valeur donnée et s'arrête à zéro
        # Démarre le chrono
        @timer.startChrono 
        afficherChrono()
    end

    # Méthode de création de la fenêtre (modifiée pour ne pas créer la fenêtre)
    def creationFenetre()
        super()
        @fenetre.set_title("Hashi - Progressif - #{@pseudo}")
    end  
    
    # Méthode générant une aide
    def genererAide()
        super()
        @timer.malusAstuce()
        return self
    end

    # Méthode provoquant l'affichage d'une aide préalablement générée
    def afficherAide()
        super()
        if(@conseilAffiche)
            @timer.malusAide()
        end
        return self
    end

    # Méthode qui permet de créer un thread qui va modifier toutes les secondes l'affichage du chrono (gère les cas dépendants de la modification du chrono)
    def afficherChrono()
        @threadAffichageChrono = Thread.new{
            while @timer.getEnExec
                @chronoText.text = @timer.afficher()
                # On met à jour le label du timer toutes les 1 secondes
                sleep(0.5)
            end
        }
        return self
    end

    # Méthode appelée quand la partie se termine (grille résolue)
    def finDePartie()
        @timer.stopChrono
        tempsEcoule = @timer.valeur
        @fenetre.remove(@hbox)
        case @difficulte
        when "Facile"
            PartieProgressif.creer(@fenetre, "moyenne", @taille, @pseudo, tempsEcoule, @nbGrilles+1, "")
        when "Moyenne"
            PartieProgressif.creer(@fenetre, "difficile", @taille, @pseudo, tempsEcoule, @nbGrilles+1, "")
        when "Difficile"
            # Passage à la taille suivante
            case @taille
            when 5
                PartieProgressif.creer(@fenetre, "facile", 6, @pseudo, tempsEcoule, @nbGrilles+1, "")
            when 6
                PartieProgressif.creer(@fenetre, "facile", 8, @pseudo, tempsEcoule, @nbGrilles+1, "")
            when 8
                PartieProgressif.creer(@fenetre, "facile", 10, @pseudo, tempsEcoule, @nbGrilles+1, "")
            when 10
                PartieProgressif.creer(@fenetre, "facile", 15, @pseudo, tempsEcoule, @nbGrilles+1, "")
            else
                @nbGrilles+=1
                partieTerminee()
            end
        else
            raise "Mauvaise difficulté"
        end
        
        
    end  
    
    # Méthode permettant de terminer la partie (retour au menu)
    def partieTerminee() #:doc:
        scoreFinal = calculDuScore()
        info_verif_grille = Gtk::MessageDialog.new(:parent => @fenetre, :flags => :destroy_with_parent, :type => :info, :buttons => :close, :message => "Grille validée")
        info_verif_grille.secondary_text="Votre partie est terminée, votre score est : #{scoreFinal}"
        info_verif_grille.run()
        info_verif_grille.destroy()
        ClassementProgressif.ajoutDansLaBDD(@pseudo, scoreFinal)
        @timer.stopChrono
        #Retour au menu
        InterfaceAccueilJeu.new(@fenetre)
    end

    # Méthode permettant de calculer le score actuel du joueur
    def calculDuScore()
        time = @timer.valeur()
        score = 1.0/time * 100000 * @nbGrilles
        return score.to_i()
    end

    # Méthode privée :
    private :partieTerminee

end