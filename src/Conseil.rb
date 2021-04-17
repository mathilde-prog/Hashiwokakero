# # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Julien PROUDY, Mathilde MOTTAY  #
# # # # # # # # # # # # # # # # # # # # # # #

# La classe Conseil représente un conseil. Dans le jeu, les conseils sont fournis par le système d'aide. 
# Cette classe contient les variables d'instance suivantes : 
# @listeDesIlesConcernees:: Liste des îles concernées par le conseil 
# @nbIlesConcernees:: Nombre d'îles concernées par le conseil 
# @texte:: Texte d'application du conseil
# @priorite:: Entier qui représente l'indice de priorité du conseil. Plus il est bas, plus le conseil est prioritaire. 
class Conseil
    
    # Texte d'application du conseil
    attr_reader :texte
    # La liste des îles concernées par le conseil
    attr_reader :listeDesIlesConcernees
    # Le nombre d'îles concernées par le conseil
    attr_reader :nbIlesConcernees
    # Un entier qui représente l'indice de priorité du conseil. Plus il est bas, plus le conseil est prioritaire.  
    attr_reader :priorite
    
    private_class_method :new
    
    # Création d'un conseil 
    # * +unTexte+ - Une chaine de caractères qui explique le conseil
    # * +unePriorite+ - Un entier qui représente l'indice de priorité du conseil
    def Conseil.nouveau(unTexte, unePriorite)
        new(unTexte, unePriorite)
    end 

    # Méthode d'intialisation d'un conseil
    # * +unTexte+ - Une chaine de caractères qui explique le conseil
    # * +unePriorite+ - Un entier qui représente l'indice de priorité du conseil
    def initialize(unTexte, unePriorite) 
        @texte = unTexte 
        @listeDesIlesConcernees = Array.new 
        @nbIlesConcernees = 0
        @priorite = unePriorite
    end 

    # Ajoute une île à la liste des îles concernées par le conseil
    # * +uneIle+ - Ile à ajouter à la liste des îles concernées par le conseil
    def ajoutIleConcernee(uneIle)
        @listeDesIlesConcernees.push(uneIle)
        @nbIlesConcernees += 1
    end

end