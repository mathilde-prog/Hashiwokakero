# # # # # # # # # # # # # # #
# Auteur : Dylan CLINCHAMP  #
# # # # # # # # # # # # # # #

require_relative('Case')
require_relative('Pont')

# Classe représentant une Ile. Une ile est une case de la grille de jeu.  
# Cette classe contient les variables d'instances suivantes :  
# @valeur:: La valeur indiquée sur l'Ile, donc le bon nombre de ponts  
# @listeDePontsActuels:: La liste des Pont actuels  
# @listeDeBonsPonts:: La liste des Pont corrects  
# @nbVoisins:: Le nombre de voisins  
# @listeDesVoisins:: La liste des Iles voisines  
# @largeurGrille:: La largeur de la grille  
# @grille:: la grille du jeu qui contient cette île
class Ile < Case
    
    # La valeur indiquée sur l'Ile, donc le bon nombre de ponts
    attr_accessor :valeur
    
    # La liste des Pont actuels
    attr_accessor :listeDePontsActuels
    
    # Le nombre de voisins
    attr_reader :nbVoisins
    
    # La liste des Iles voisines
    attr_reader :listeDesVoisins
    
    # On empêche l'accès à new car la méthode d'ouverture de Ile a besoin d'initialiser des variables d'instances. 
    private_class_method :new
    
    # Constructeur d'une Ile  
    # * +posX+ [Integer] - La position X de la case dans la grille de jeu, entier >=0  
    # * +posY+ [Integer] - La position Y de la case dans la grille de jeu, entier >=0  
    # * +val+ [Integer] - La valeur indiquée sur l'Ile, donc le bon nombre de ponts  
    # * +largeurGrille+ [Integer] - La largeur de la grille  
    # * +grille+ [Array<Array<Case>>] - La grille de jeu  
    def Ile.creer(posX,posY,val,largeurGrille,grille)
        new(posX,posY,val,largeurGrille,grille)
    end
    
    # Méthode d'initialisation d'une Ile  
    # * +posX+ [Integer] - La position X de la case dans la grille de jeu, entier >=0  
    # * +posY+ [Integer] - La position Y de la case dans la grille de jeu, entier >=0  
    # * +val+ [Integer] - La valeur indiquée sur l'Ile, donc le bon nombre de ponts  
    # * +largeurGrille+ [Integer] - La largeur de la grille  
    # * +grille+ [Array<Array<Case>>] - La grille de jeu  
    def initialize(posX,posY,val,largeurGrille,grille)
        super(posX,posY)
        @valeur, @largeurGrille,@grille = val,largeurGrille,grille
        @listeDePontsActuels,@listeDeBonsPonts, @listeDesVoisins = Array.new, Array.new, Array.new
        @nbVoisins = 0
    end
    
    # Méthode permettant de savoir si une Case est une Île  
    # Retourne true si la case contient une Ile. 
    def estIle?()
        return true
    end
    
    # Méthode d'ajout d'un Pont.   
    # * +p+ [Pont] - Le pont à ajouter  
    def ajouterPont(p)
        @listeDePontsActuels.push(p)
        return self
    end
    
    # Méthode d'ajout d'un bon Pont. 
    # * +p+ [Pont] - Le pont à ajouter  
    def ajouterBonPont(p)
        @listeDeBonsPonts.push(p)
        return self
    end
    
    # Méthode de calcul du nombre de ponts actuellements placés. 
    # Retourne un entier correspondant au nombre de ponts actuellement placés. 
    def getNbPonts()
        compteur = 0
        @listeDePontsActuels.each do |p| 
            compteur = compteur + p.etatPont
        end
        return compteur
    end
    
    # Méthode renvoyant un booléen reflétant si le nombre de ponts est correct. 
    # Retourne true si le nombre de ponts est correct et false si le nombre de ponts est incorrect. 
    def verifierNombreDePont()
        return (self.getNbPonts() == @valeur)
    end
    
    # Méthode indiquant si l'Ile se trouve dans un angle. 
    # Retourne true si l'Ile est dans un angle et false si l'Ile n'est pas dans un angle. 
    def estDansUnCoin()
        #1er gros bloc avant le ou => angle sup. gauche et angle inf. droit , 1nd gros bloc : angle sup. droit et angle inf. gauche 
        return ((@positionX == @positionY && (@positionX == 0 || @positionX == @largeurGrille-1)) || ( (@positionX == 0 && @positionY == @largeurGrille-1) || (@positionY == 0 && @positionX == @largeurGrille -1)))
    end
    
    # Méthode indiquant si l'Ile se trouve sur un côté. 
    # Retourne true si l'Ile est sur un côté et false si l'Ile n'est pas sur un côté. 
    def estSurLeCote()
        return ((@positionX == 0) || (@positionX == @largeurGrille-1) || (@positionY == 0) || (@positionY == @largeurGrille-1))
    end
    
    # Méthode indiquant si l'Ile se trouve au milieu. 
    # Retourne true si l'Ile est au milieu et false si l'Ile n'est pas au milieu.
    def estAuMilieu()
        return !self.estSurLeCote()
    end
    
    # Méthode renvoyant un entier correspondant à son état de connexion
    # Retourne -1 si l'Ile est insuffisamment reliée, 0 si elle est reliée avec le bon nombre de ponts, +1 si l'Ile est trop reliée. 
    def getEtat()
        if(self.getNbPonts() < @valeur)
            return -1
        end
        
        if(self.getNbPonts() > @valeur)
            return 1
        end
        
        return 0
    end
    
    # Méthode destinée à tester si l'Ile est correctement reliée. 
    # Retourne true si l'Ile est correctement reliée et false si l'Ile n'est pas correctement reliée
    def estCorrectementReliee()
        if(self.verifierNombreDePont())
            correct = true
            @listeDePontsActuels.each do |p| 
                if(p.etatPont>0)
                    pontok = false
                    @listeDeBonsPonts.each do |b|
                        if(b.etatPont() == p.etatPont() && p.eql?(b))
                            pontok = true
                        end
                    end
                    if(pontok == false)
                        correct = false
                    end
                end
            end
            return correct
        else
            return false
        end
    end
    
    # Méthode destinée à renvoyer une chaîne de caractères imprimable.
    def to_s()
        return ("Ile : x=#{@positionX} y=#{@positionY} valeur = #{@valeur}")
    end
    
    ##
    # Méthode destinée à comparer une Ile à un autre objet. 
    # * +ile2+ - La seconde Ile à comparer
    # Retourne true si l'objet est une Ile et qu'elle a la même position.
    # Retourne false si ce n'est pas un objet de type Ile ou si l'Ile en question n'a pas la même position. 
    def eql?(ile2)
        if(ile2.is_a?(Ile))
            return (@positionX == ile2.positionX && @positionY == ile2.positionY)
        else
            return false
        end
    end
    
    # Méthode indiquant si une Ile est atteignable. 
    # * +i+ - L'Ile dont on doit vérifier l'atteignabilité. 
    # * +considererPonts+ - Booléen indiquant si les ponts sur le chemin entre les deux Ile doivent être comptés comme problème d’accessibilité. 
    # Retourne true si l'Ile est atteignable et false si l'Ile n'est pas atteignable. 
    def peutEtreRelieeA?(i,considererPonts)
        pbAtteignabilite = false
        memeLigneOuMemeColonne = false

        if(@positionX == i.positionX)
            memeLigneOuMemeColonne = true
            if(@positionY>i.positionY)
                posCourante = i.positionY + 1
                posMax = @positionY
            else
                posCourante = @positionY + 1
                posMax = i.positionY
            end
            while(posMax>posCourante)
                if(@grille[@positionX][posCourante].estIle? || (considererPonts && @grille[@positionX][posCourante].contientPontConstruit > 0))
                    pbAtteignabilite = true
                end
                posCourante += 1
            end
        else
            if(@positionY == i.positionY)
                memeLigneOuMemeColonne = true
                if(@positionX>i.positionX)
                    posCourante = i.positionX + 1
                    posMax = @positionX
                else
                    posCourante = @positionX + 1
                    posMax = i.positionX
                end
                while(posMax>posCourante)
                    if(@grille[posCourante][@positionY].estIle? || (considererPonts && @grille[posCourante][@positionY].contientPontConstruit > 0))
                        pbAtteignabilite = true
                    end
                    posCourante += 1
                end
            end
        end   
        return (memeLigneOuMemeColonne && !pbAtteignabilite)
    end

    # Méthode renvoyant la liste des Ile actuellement reliées à cette Ile. 
    # Retourne le tableau des Ile reliées à cette Ile (Ile[])
    def ilesReliees()
        listeIlesReliees = Array.new
        @listeDePontsActuels.each do |p|
            if(p.etatPont>0)
                if(p.iD.eql?(self))
                    listeIlesReliees.push(p.iA)
                else
                    if(p.iA.eql?(self))
                        listeIlesReliees.push(p.iD)
                    end
                end
            end
        end
        return listeIlesReliees
    end

    # Méthode destinée à peupler la liste des voisines. 
    # * +i+ - L'Ile à ajouter aux voisines. 
    def ajouterIleVoisine(i)
        @listeDesVoisins.push(i)
        @nbVoisins += 1
        return self
    end

    # Méthode renvoyant le nombre d'îles voisines
    # Retourne le nombre d'îles voisines
    def nbIlesReliees()
        return self.ilesReliees().length()
    end
end