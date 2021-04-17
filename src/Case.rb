# # # # # # # # # # # # # # # 
# Auteur : Dylan CLINCHAMP  #
# # # # # # # # # # # # # # # 

# Classe représentant une case de la grille de jeu.   
# Cette classe contient les variables d'instances suivantes :  
# @positionX:: La position X de la case dans la grille de jeu, entier >=0  
# @positionY:: La position Y de la case dans la grille de jeu, entier >=0  
# @contientPont:: Signale si la Case contient potentiellement un pont (état indifférent), booléen  
# @contientPontConstruit :: Signale si la Case contient un Pont construit (état du pont à 1 ou 2), booléen  
# @highlight:: Signale si la Case doit être surlignée pour aider le joueur, booléen  
class Case
    # La position X de la case dans la grille de jeu, entier >=0
    attr_reader :positionX
    # La position Y de la case dans la grille de jeu, entier >=0
    attr_reader :positionY
    # Signale si la Case contient potentiellement un pont (état indifférent), booléen
    attr_accessor :contientPont
    # Signale si la Case contient un Pont construit (état du pont 0, 1, 2), entier
    attr_accessor :contientPontConstruit
    # Signale si la Case doit être surlignée pour aider le joueur, booléen
    attr_accessor :highlight
    
    # On empêche l'accès à new car la méthode d'ouverture de Case a besoin d'initialiser des variables d'instances
    private_class_method :new
    
    # Constructeur d'une Case. 
    # * +posX+ [Integer] - La position X de la case dans la grille de jeu, entier >=0  
    # * +posY+ [Integer] - La position Y de la case dans la grille de jeu, entier >=0  
    def Case.creer(posX,posY)
        new(posX, posY)
    end
    
    # Méthode d'initialisation d'une Case.  
    # * +posX+ [Integer] - La position X de la case dans la grille de jeu, entier >=0  
    # * +posY+ [Integer] - La position Y de la case dans la grille de jeu, entier >=0
    def initialize(posX, posY)
        @positionX, @positionY = posX, posY
        @contientPont = false
        @contientPontConstruit = 0
        @highlight = false
    end
    
    # Méthode permettant de savoir si une Case est une Île.   
    # Retourne false si la case ne contient pas d'Ile. 
    def estIle?()
        return false
    end
    
    # Méthode destinée à renvoyer une chaîne de caractères imprimable. 
    def to_s()
        return ("Case : x=#{@positionX} y=#{@positionY} contientPont = #{@contientPont} contientPontConstruit = #{@contientPontConstruit}")
    end
end