# # # # # # # # # # # # # # # 
# Auteur : Marie-Nina MUNAR #
# # # # # # # # # # # # # # # 

require_relative('Case')

# Classe qui représente un pont (un pont existe depuis la création de la grille, seul son état change)
# Cette classe contient les variables d'instances suivantes :
# @etatPont:: variable entière valant 0, 1 ou 2 selon si le pont n'existe pas, si il est simple ou double  
# @tabCases:: un tableau des cases que couvre le pont  
# @iD:: [Case] L'Ile de départ  
# @iA:: [Case] L'Ile d'arrivée  

class Pont
    # L'état du pont est une variable entière valant 0, 1 ou 2 et accessible seulement en lecture  
    attr_reader :etatPont
    
    # Le tableau des cases que couvre le pont est accessible en lecture et non modifiable  
    attr_reader :tabCases
    
    # [Case] L'Ile de départ  
    attr_reader :iD
    
    # [Case] L'Ile d'arrivée
    attr_reader :iA
    
    # On empêche l'accès à new car la méthode pour créer un pont est paramétrée et ne peut s'utiliser qu'ainsi
    private_class_method :new
    
    # Création d'un pont à partir des deux îles qu'il relie, la création de pont se fait à l'initialisation de la grille. 
    # * +tabCases+ - Le tableau des Case que prend le pont
    # * +iD+ [Case] - L'Ile de départ
    # * +iA+ [Case] - L'Ile d'arrivée
    # * +etat+ [Integer] - L'état initial du pont
    def Pont.creer(tabCases,iD,iA,etat)
        new(tabCases,iD,iA, etat)
    end
    
    # Méthode d'initialisation du pont.
    # * +tabCases+ - le tableau des Case que prend le pont
    # * +iD+ [Case] - L'Ile de départ
    # * +iA+ [Case] - L'Ile d'arrivée
    # * +etat+ [Integer] - L'état initial du pont
    def initialize(tabCases,iD,iA, etat)
        @etatPont = etat
        @iD,@iA = iD,iA
        @tabCases = tabCases
        for c in @tabCases 
            c.contientPont = true
            c.contientPontConstruit = @etatPont
        end
    end
    
    # Méthode qui permet de passer d'un pont vide à un pont simple, d'un pont simple à un pont double et d'un pont double à pas de pont.
    # La méthode renvoie la valeur actuelle du pont après cette opération. 
    def prochainEtat()
        @etatPont = @etatPont == 2 ? 0 : @etatPont+1
        for c in @tabCases
            c.contientPontConstruit = @etatPont
        end   
        return @etatPont 
    end

    # Méthode qui permet de donner la taille du pont (calculée à partir de sa liste de cases).
    def longueur()
        return @tabCases.length
    end    

    # Méthode qui permet de connaitre le sens du pont.
    # Renvoie true si horizontal, false si vertical
    def sens?()
        sens=true # true pour horizontal, false pour vertical
        if(@iD.positionX==@iA.positionX)
            # Pont à la verticale
            sens=false
        end
        return sens
    end 

    # Méthode qui remet le pont à l'état vide.
    # * +avecCases+ [Boolean] - indique si les cases qui étaient occupées par le pont doivent être remises à l'état innocupé
    def reset(avecCases)
        if(avecCases)
            for c in @tabCases
                c.contientPontConstruit = 0
            end  
        end
        return @etatPont = 0
    end
    
    # Méthode destinée à comparer un Pont à un autre objet. 
    # * +p2+ - le second pont à comparer
    # Retourne true si l'objet est une Ile et qu'elle a la même position.  
    # Retourne false si ce n'est pas un objet de type Ile ou si l'Ile en question n'a pas la même position. 
    def eql?(p2)
        if(p2.is_a?(Pont))
            return (iA == p2.iA && iD == p2.iD)
        else
            return false
        end
    end
    
    # Méthode destinée à renvoyer une chaîne de caractères imprimable.
    def to_s()
        return ("Pont : etat = #{@etatPont}, prem. case : [#{@tabCases.first().positionX};#{@tabCases.first().positionY}], derniere case : [#{@tabCases.last().positionX};#{@tabCases.last().positionY}]")
    end
end