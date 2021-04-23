# # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Julien PROUDY, Mathilde MOTTAY  #
# # # # # # # # # # # # # # # # # # # # # # #

require_relative('Case')
require_relative('Ile')
require_relative('Conseil')

# La classe Aide représente le système de résolution d'aide. 
# Elle permet de chercher et générer des conseils en détectant les techniques d'aides applicables à un instant T. 
# Cette classe contient les variables d'instance suivantes : 
# @listeDesConseils:: Liste des conseils correspondant aux aides 
# @partie:: Partie qui utilise le système d'aide 
class Aide

    # Liste des conseils correspondant aux aides
    attr_reader :listeDesConseils

    # Partie qui utilise le système d'aide 
    attr_reader :partie 

    private_class_method :new

    # Création d'un système d'aide. 
    # * +unePartie+ - Partie qui utilise le système d'aide 
    def Aide.creer(unePartie)
        new(unePartie)
    end 

    # Méthode d'intialisation du système d'aide.   
    # * +unePartie+ - Partie qui utilise le système d'aide 
    def initialize(unePartie) 
        @partie = unePartie 
        @listeDesConseils = Array.new
    end 

    ################################### TECHNIQUES DE DEPART ###################################

    # Ajoute un conseil à la liste si l'île a l'indice 4, est dans un coin et n'est pas déjà correctement reliée.
    # Conseil à générer : On en déduit que l'île doit être connectée avec un double-pont à chacune de ses îles voisines. 
    # * +ile+ - Ile 
    private def ile4DansUnCoin(ile) #:doc:
        if((ile.estDansUnCoin() == true) && (ile.valeur() == 4) && ((ile.estCorrectementReliee() == false)))
            conseil = Conseil.nouveau("Quand une île d'indice 4 se situe dans un coin, elle a obligatoirement deux îles voisines. Sachant que le nombre de ponts pour relier deux îles ne peut dépasser deux, il y a naturellement deux double-ponts connectés avec chacune de ses îles voisines.",1)
            conseil.ajoutIleConcernee(ile)
            @listeDesConseils.push(conseil) 
        end
    end

    # Ajoute un conseil à la liste si l'île a l'indice 6, est sur le côté, a 3 voisins et n'est pas déjà correctement reliée. 
    # Conseil à générer : On en déduit que l'île doit être connectée avec un double-pont à chacune de ses îles voisines. 
    # * +ile+ - Ile  
    private def ile6SurLeCote(ile) #:doc:
        if ((ile.valeur() == 6) && (ile.estSurLeCote() == true) && (ile.nbVoisins() ==  3) && (ile.estCorrectementReliee() == false))
            conseil = Conseil.nouveau("Quand une île d'indice 6 se situe sur le côté, elle a obligatoirement trois voisins. Vous devez la connecter avec un double-pont à chacune de ses îles voisines.",1)
            conseil.ajoutIleConcernee(ile)
            @listeDesConseils.push(conseil) 
        end  
    end 
    
    # Ajoute un conseil à la liste si l'île a l'indice 8, est au milieu et n'est pas déjà correctement reliée.  
    # Conseil à générer : On en déduit que l'île doit être connectée avec un double-pont à chacune de ses îles voisines.
    # * +ile+ - Ile 
    private def ile8AuMilieu(ile) #:doc:
        if((ile.valeur() == 8) && (ile.estAuMilieu() == true) && (ile.getNbPonts() != 8))
            conseil = Conseil.nouveau("Quand une île d'indice 8 se situe au milieu de la grille, elle a obligatoirement quatre îles voisines. Pour que le nombre de ponts connectés soit valide, vous devez relier l'île à chacune de ses voisines avec un double-pont.",1)
            conseil.ajoutIleConcernee(ile)
            @listeDesConseils.push(conseil) 
        end 
    end 

    # Ajoute un conseil à la liste si l'île a l'indice 4, a 2 voisins et n'est pas déjà correctement reliée.
    # Conseil à générer : On en déduit que l'île doit être connectée avec un double-pont à chacune de ses îles voisines.
    # * +ile+ - Ile 
    private def ile4Avec2Voisins(ile) #:doc:
        if ((ile.valeur() == 4) && (ile.nbVoisins() == 2) && (ile.estCorrectementReliee() == false))
            conseil = Conseil.nouveau("Si une île d'indice 4 a deux îles voisines, une seule solution s'offre à vous : vous devez la relier avec un double-pont à ses voisines.",2)
            conseil.ajoutIleConcernee(ile)
            @listeDesConseils.push(conseil) 
        end  
    end 

    # Ajoute un conseil à la liste si l'île a l'indice 6, a 3 voisins et n'est pas déjà correctement reliée.
    # Conseil à générer : On en déduit que l'île doit être connectée avec un double-pont à chacune de ses îles voisines.
    # * +ile+ - Ile 
    private def ile6Avec3Voisins(ile) #:doc:
        if ((ile.valeur() == 6) && (ile.nbVoisins() == 3) && (ile.estCorrectementReliee() == false))
            conseil = Conseil.nouveau("Si une île d'indice 6 a trois îles voisines, une seule solution s'offre à vous : vous devez la relier avec un double-pont à chacune de ses voisines.",2)
            conseil.ajoutIleConcernee(ile)
            @listeDesConseils.push(conseil) 
        end 
    end 

    ############################################################################################

    ################################### TECHNIQUES DE BASE ###################################

    # Ajoute un conseil à la liste si l'île a un seul voisin et n'est pas déjà correctement reliée.
    # Conseil à générer : On en déduit facilement que l'île doit être reliée à son unique voisine.
    # * +ile+ - Ile 
    private def uneIleAvecUnSeulVoisin(ile) #:doc:
        if((ile.nbVoisins() == 1) && (ile.estCorrectementReliee() == false))
            conseil = Conseil.nouveau("Il est possible qu'une île avec un indice inférieur à 3 ne possède qu'une seule et unique île voisine. On peut ainsi les relier sans difficulté.",1)
            conseil.ajoutIleConcernee(ile)
            @listeDesConseils.push(conseil) 
        end
    end

    # Ajoute un conseil à la liste si l'île a l'indice 3, est dans un coin et n'a pas 3 ponts. 
    # Conseil à générer : L'île doit être connectée avec un pont simple à une de ses îles voisines et avec un double-pont à l'autre
    # * +ile+ - Ile 
    private def ile3DansUnCoin(ile) #:doc:
        if((ile.valeur() == 3) && (ile.estDansUnCoin() == true) && (ile.getNbPonts() != 3))
            conseil = Conseil.nouveau("Quand une île d'indice 3 se situe dans un coin, elle a obligatoirement deux îles voisines. Vous devez la relier avec un simple pont à une de ses voisines et la relier à l'autre avec un double-pont. Faites une tentative !",3)
            conseil.ajoutIleConcernee(ile)
            @listeDesConseils.push(conseil) 
        end 
    end

    # Ajoute un conseil à la liste si l'île a l'indice 3, a 2 voisines et n'a pas 3 ponts. 
    # Conseil à générer : L'île doit être connectée avec un pont simple à une de ses îles voisines et avec un double-pont à l'autre
    # * +ile+ - Ile 
    private def ile3Avec2Voisines(ile) #:doc:
        if((ile.valeur() == 3) && (ile.nbVoisins() == 2) && (ile.getNbPonts() != 3))
            conseil = Conseil.nouveau("Si une île d'indice 3 a deux îles voisines, vous devez la relier avec un simple pont à une de ses voisines et la relier à l'autre avec un double-pont. Faites une tentative !",4)
            conseil.ajoutIleConcernee(ile)
            @listeDesConseils.push(conseil) 
        end 
    end

    # Ajoute un conseil à la liste si l'île a l'indice 5, a 3 voisins, est sur le côté et n'est pas reliée au minimum avec un pont simple à chacune de ses voisines.
    # Conseil à générer : L'île doit avoir au minimum un pont simple connecté à chacune de ses trois îles voisines. 
    # * +ile+ - Ile 
    private def ile5SurLeCote(ile) #:doc:  
        if((ile.valeur() == 5) && (ile.estSurLeCote() == true) && (ile.nbVoisins() == 3) && (ile.nbIlesReliees() < 3))
            conseil = Conseil.nouveau("Quand une île d'indice 5 se situe sur le côté, elle doit avoir au minimum un pont simple connecté à chacune de ses trois îles voisines.",2)
            conseil.ajoutIleConcernee(ile)
            @listeDesConseils.push(conseil) 
        end 
    end

    # Ajoute un conseil à la liste si l'île a l'indice 7, a 4 voisins, est au milieu et n'est pas reliée au minimum avec un pont simple à chacune de ses voisines.
    # Conseil à générer : L'île doit avoir au minimum un pont simple connecté à chacune de ses quatres îles voisines. 
    # * +ile+ - Ile 
    private def ile7AuMilieu(ile) #:doc:
        if((ile.valeur() == 7) && (ile.estAuMilieu() == true) && (ile.nbVoisins == 4) && (ile.nbIlesReliees() < 4))
            conseil = Conseil.nouveau("Quand une île d'indice 7 se situe au milieu de la grille, elle doit avoir au minimum un pont simple connecté à chacune de ses quatre îles voisines.",2)
            conseil.ajoutIleConcernee(ile)
            @listeDesConseils.push(conseil) 
        end 
    end

    # Ajoute un conseil à la liste si l'île a l'indice 3, est dans un coin, n'est pas déjà correctement reliée et a parmi ses îles voisines une île d'indice 1. 
    # Conseil à générer : L'île doit être connectée avec un pont simple à sa voisine d'indice 1 et avec un double-pont à son autre voisine. 
    # * +ile+ - Ile 
    private def ile3DansUnCoinSpecial(ile) #:doc:
        if ((ile.valeur() == 3) && (ile.estDansUnCoin() == true) && (ile.estCorrectementReliee() == false))
            for i in ile.listeDesVoisins()
                if(i.valeur() == 1)
                    conseil = Conseil.nouveau("Quand une île d'indice 3 se situe dans un coin, elle a obligatoirement deux îles voisines. Dans le cas où une de ses voisines est une île d'indice 1, vous devez les relier avec un pont simple. Il ne vous reste plus qu'à relier l'île d'indice 3 avec un double-pont à son autre voisine.",1)
                    conseil.ajoutIleConcernee(ile)
                    @listeDesConseils.push(conseil) 
                end 
            end
        end 
    end 

    # Ajoute un conseil à la liste si l'île a l'indice 3, a 2 voisines, n'est pas déjà correctement reliée et a parmi ses îles voisines une île d'indice 1. 
    # Conseil à générer : L'île doit être connectée avec un pont simple à sa voisine d'indice 1 et avec un double-pont à son autre voisine. 
    # * +ile+ - Ile 
    private def ile3Avec2VoisinesSpecial(ile) #:doc:
        if ((ile.valeur() == 3) && (ile.nbVoisins() == 2) && (ile.estCorrectementReliee() == false))
            for i in ile.listeDesVoisins()
                if(i.valeur() == 1)
                    conseil = Conseil.nouveau("Quand une île d'indice 3 a deux îles voisines. Dans le cas où une de ses voisines est une île d'indice 1, vous devez les relier avec un pont simple. Il ne vous reste plus qu'à relier l'île d'indice 3 avec un double-pont à son autre voisine.",2)
                    conseil.ajoutIleConcernee(ile)
                    @listeDesConseils.push(conseil) 
                end 
            end
        end 
    end 

    # Ajoute un conseil à la liste si l'île a l'indice 5, est sur le côté, a parmi ses îles voisines une île d'indice 1 et n'est pas reliée au minimum avec un pont simple à chacune de ses voisines. 
    # Conseil à générer : L'île doit être connectée avec un pont simple à sa voisine d'indice 1 et avec un double-pont à ses autres voisines. 
    # * +ile+ - Ile     
    private def ile5SurLeCoteSpecial(ile) #:doc:
        if ((ile.valeur() == 5) && (ile.estSurLeCote() == true)  && (ile.nbVoisins() == 3) && (ile.nbIlesReliees() < 3))
            for i in ile.listeDesVoisins()
                if(i.valeur() == 1)
                    conseil = Conseil.nouveau("Quand une île d'indice 5 se situe sur le côté, elle a obligatoirement trois îles voisines. Dans le cas où une de ses voisines est une île d'indice 1, vous devez les relier avec un pont simple. Il ne vous reste plus qu'à relier l'île d'indice 5 avec des double-ponts à ses autres voisines.",1)
                    conseil.ajoutIleConcernee(ile)
                    @listeDesConseils.push(conseil) 
                end 
            end 
        end 
    end 

    # Ajoute un conseil à la liste si l'île a l'indice 7, est au milieu, n'est pas déjà correctement reliée et a parmi ses îles voisines une île avec l'indice 1.
    # Conseil à générer : L'île doit être connectée avec un pont simple à sa voisine d'indice 1 et avec un double-pont à ses autres voisines. 
    # * +ile+ - Ile       
    private def ile7AuMilieuSpecial(ile) #:doc:
        if ((ile.valeur() == 7) && (ile.estAuMilieu() == true) && (ile.estCorrectementReliee() == false))
            for i in ile.listeDesVoisins()
                if(i.valeur() == 1)
                    conseil = Conseil.nouveau("Quand une île d'indice 7 se situe au milieu de la grille, elle a obligatoirement quatre îles voisines. Dans le cas où une de ses voisines est une île d'indice 1, vous devez les relier avec un pont simple. Il ne vous reste plus qu'à relier l'île d'indice 7 avec des double-ponts à ses autres voisines.",1)
                    conseil.ajoutIleConcernee(ile)
                    @listeDesConseils.push(conseil) 
                end 
            end
        end
    end 

    # Ajoute un conseil à la liste si l'île a l'indice 4, a 3 voisins, n'est pas déjà correctement reliée et a parmi ses îles voisines deux îles avec l'indice 1. 
    # Conseil à générer : L'île doit être connectée avec un pont simple à ses voisines d'indice 1 et avec un double-pont à son autre voisine. 
    # * +ile+ - Ile   
    private def ile4CasSpecial(ile) #:doc:
        nbVoisinesIndice1 = 0

        if ((ile.valeur() == 4) && (ile.nbVoisins() == 3) && (ile.getNbPonts() < 4)) 
            for i in ile.listeDesVoisins()
                if(i.valeur() == 1)
                    nbVoisinesIndice1 += 1  
                end 
            end
            
            if(nbVoisinesIndice1 == 2)
                conseil = Conseil.nouveau("Quand une île d'indice 4 a exactement trois îles voisines dont deux d'entres elles ont pour indice 1, vous devez relier l'île à ses deux voisines d'indice 1 avec un simple pont et la relier à sa troisième voisine avec un double-pont.",1)
                conseil.ajoutIleConcernee(ile)
                @listeDesConseils.push(conseil) 
            end 
        end 
    end 

    # Ajoute un conseil à la liste si l'île a l'indice 6, est au milieu, a 4 voisins (dont une île d'indice 1) et n'est pas déjà reliée à ses trois autres voisins par un simple pont.
    # Conseil à générer : L'île doit avoir au minimum un pont connecté à chacune de ses 3 autres îles voisines (celles qui ne sont pas d'indice 1).  
    # * +ile+ - Ile   
    private def ile6auMilieuSpecial(ile) #:doc:
        nbVoisinesIndice1 = 0
        nbVoisinesIndiceDifferentDe1Reliees = 0
    
        if((ile.valeur() == 6) && (ile.estAuMilieu() == true) && (ile.nbVoisins() == 4))
    
            for i in ile.listeDesVoisins()
                if(i.valeur() == 1)
                    nbVoisinesIndice1 += 1  
                end 
            end
    
            for j in ile.ilesReliees()
                if(j.valeur() > 1)
                    nbVoisinesIndiceDifferentDe1Reliees +=1
                end 
            end
                
            if((nbVoisinesIndice1 == 1) && (ile.nbIlesReliees() <= 3) && (nbVoisinesIndiceDifferentDe1Reliees != 3))
                conseil = Conseil.nouveau("Si une île d'indice 6 dans le centre de la grille a quatre îles voisines, peu importe si cette île est connectée ou non à sa voisine d'indice 1, elle doit avoir au minimum un simple pont connecté à ses trois autres îles voisines.",1)
                conseil.ajoutIleConcernee(ile)
                @listeDesConseils.push(conseil) 
            end
        end
    end

    # Ajoute un conseil à la liste si l'île est une île d'indice 2 reliée à une autre île d'indice 2. 
    # Remarque : Si on connecte des îles d’indice 2 entre elles, elles seront isolées des autres îles et le joueur se trouvera dans une impasse.
    # Conseil à générer : Il faut éviter l'isolation (connexité). 
    # * +ile+ - Ile       
    private def erreurIlesIndice2RelieesParDoublePont(ile) #:doc:
        if((ile.valeur() == 2) && (ile.estCorrectementReliee() == false))
            if((ile.getNbPonts() == 2) && (ile.nbIlesReliees() == 1))
                for i in ile.ilesReliees()
                    if(i.valeur() == 2)
                        conseil = Conseil.nouveau("Pour résoudre le puzzle, toutes les îles doivent être connectées entre elles. Si vous reliez deux îles d'indice 2 par un double-pont, vous serez dans une impasse. Ce raisonnement fonctionne également pour deux îles d'indice 1 reliées.",0)
                        conseil.ajoutIleConcernee(ile)
                        conseil.ajoutIleConcernee(i)
                        @listeDesConseils.push(conseil)                     
                    end 
                end 
            end
        end
    end 

    # Ajoute un conseil à la liste si l'île est une île d'indice 1 reliée à une autre île d'indice 1. 
    # Remarque : Si on connecte des îles d’indice 1 entre elles, elles seront isolées des autres îles et le joueur se trouvera dans une impasse.
    # Conseil à générer : Il faut éviter l'isolation (connexité). 
    # * +ile+ - Ile   
    private def erreurIlesIndice1Reliees(ile) #:doc:
        if((ile.valeur == 1) && (ile.estCorrectementReliee() == false))
            for i in ile.ilesReliees()
                if(i.valeur() == 1)
                    conseil = Conseil.nouveau("Pour résoudre le puzzle, toutes les îles doivent être connectées entre elles. Si vous reliez deux îles d'indice 1, vous serez dans une impasse. Ce raisonnement fonctionne également pour deux îles d'indice 2 reliées par un double-pont.",0)
                    conseil.ajoutIleConcernee(ile)
                    conseil.ajoutIleConcernee(i)
                    @listeDesConseils.push(conseil) 
                end 
            end 
        end
    end 

    # Ajoute un conseil à la liste si l'île est une ile d'indice 1 qui a une ou plusieurs îles voisines d'indice 1 et une seule voisine d'indice supérieur à 1.
    # Conseil à générer : Il faut relier l'île à sa voisine d'indice supérieur à 1 par un pont simple. 
    # * +ile+ - Ile   
    private def ile1AvecUneSeuleVoisineDifferenteDe1(ile) #:doc:
        nbVoisinesIndice1 = 0
        if((ile.valeur() == 1))
            for i in ile.listeDesVoisins()
                if(i.valeur() == 1)
                    nbVoisinesIndice1 += 1  
                end 
            end

            for j in ile.ilesReliees()
                if(j.valeur() > 1)
                    return
                end 
            end

            if(nbVoisinesIndice1 >= 1 && nbVoisinesIndice1 == ile.nbVoisins()-1 )
                conseil = Conseil.nouveau("Quand une île d'indice 1 possède plusieurs voisines dont une ou plusieurs îles d'indice 1 et une autre île d'indice différent de 1, elle doit être reliée à l'île d'indice différent de 1 par un pont simple pour éviter l'isolement de deux îles d'indice 1.",1)
                conseil.ajoutIleConcernee(ile)
                @listeDesConseils.push(conseil) 
            end
        end
    end

    # Ajoute un conseil à la liste si l'île est une île d’indice 2 qui a seulement deux îles voisines d'indice 2.  
    # Conseil à générer : Il faut relier l'île avec un pont simple à chacune de ses îles voisines. 
    # * +ile+ - Ile   
    private def ile2AvecDeuxVoisines2(ile) #:doc:
        nbVoisinesIndice2 = 0
        if((ile.valeur() == 2) && ile.nbVoisins() == 2)
            for i in ile.listeDesVoisins()
                if(i.valeur() == 2)
                    nbVoisinesIndice2 += 1  
                end 
            end

            if((nbVoisinesIndice2 == 2) && (ile.nbIlesReliees() < 2))
                conseil = Conseil.nouveau("Si une île d'indice 2 a seulement deux îles voisines d'indice 2, elle doit être reliée à ses voisines par un pont simple.",1)
                conseil.ajoutIleConcernee(ile)
                @listeDesConseils.push(conseil) 
            end
        end
    end

    # Ajoute un conseil à la liste si l'île est une île d'indice 1 qui n'a plus qu'une seule île joignable. 
    # Conseil à générer : Une île d'indice 1 qui n'a plus qu'une seule île voisine joignable doit être reliée par un pont simple à celle-ci.
    # * +ile+ - Ile 
    private def ile1AvecUneSeuleSolution(ile) #:doc:
        voisinBienReliee = 0
        ileQuiPeutEtreReliee = 0

        if((ile.valeur() == 1) && (ile.getNbPonts() == 0))
            for i in ile.listeDesVoisins()
                if((i.getNbPonts() == i.valeur()) && (i.estCorrectementReliee() == true))
                    voisinBienReliee += 1
                end
            end

            for j in ile.listeDesVoisins()
                if(ile.peutEtreRelieeA?(j,true) && (j.getNbPonts() < j.valeur()))
                    ileQuiPeutEtreReliee += 1
                end
            end

            if((voisinBienReliee > 1 && voisinBienReliee == ile.nbVoisins()-1) || (ileQuiPeutEtreReliee == 1))
                conseil = Conseil.nouveau("Une île d'indice 1 qui n'a plus qu'une seule île voisine joignable doit être reliée par un pont simple à celle-ci.",0)
                conseil.ajoutIleConcernee(ile)
                @listeDesConseils.push(conseil) 
            end
        end
    end

    # Ajoute un conseil à la liste si un pont peut être mis entre deux îles (il sera forcément bon) et n'aura aucune incidence sur le reste de la grille.
    # Conseil à générer : Cette île peut être reliée avec son ile voisine par un pont simple supplémentaire sans problème
    # * +ile+ - Ile 
    private def ileOuOnPeutAjouterUnPont(ile) #:doc:
        voisinesCorrectementReliee = 0
        ileVoisineQuiManque1Pont = 0

        if((ile.valeur() > 1) && (ile.getNbPonts() == ile.valeur()-1))

            for i in ile.listeDesVoisins()
                if(i.getNbPonts() == i.valeur()-1)
                    ileVoisineQuiManque1Pont += 1 
                elsif(i.estCorrectementReliee() == true)
                    voisinesCorrectementReliee += 1
                end
            end

            if((ileVoisineQuiManque1Pont == 1) && (voisinesCorrectementReliee == ile.nbVoisins()-1))
                conseil = Conseil.nouveau("On remarque qu'une île peut être reliée avec son île voisine par un pont simple supplémentaire sans problème",3)
                conseil.ajoutIleConcernee(ile)
                @listeDesConseils.push(conseil) 
            end
        end
    end

    # Ajoute un conseil à la liste si l'île est isolée du reste de ses îles voisines.
    # Conseil à générer : Cette île ne peut être reliée à aucune autre île, il faut revoir les ponts de ses îles voisines.
    # * +ile+ - Ile
    private def estIsolee(ile) #:doc:
        voisinesBloqueesOuRemplies = Array.new 
  
        if(ile.getNbPonts() == 0) 
            for i in ile.listeDesVoisins()
                if(i.getNbPonts() == i.valeur())
                    voisinesBloqueesOuRemplies.push(i)
                end
            end

            for j in ile.listeDesVoisins()
                if( ile.peutEtreRelieeA?(j,true) == false )
                    voisinesBloqueesOuRemplies.push(j)
                end
            end

            if(voisinesBloqueesOuRemplies.uniq.length() == ile.nbVoisins()) 
                voisinesBloqueesOuRemplies.clear(); 
                conseil = Conseil.nouveau("On remarque qu'une île ne peut être reliée à aucune autre île, il faut revoir les ponts de ses îles voisines",0)
                conseil.ajoutIleConcernee(ile)
                @listeDesConseils.push(conseil) 
            end  
        end
    end

    ############################################################################################

    ################################### TECHNIQUE AVANCEE ########################################

    # Ajoute un conseil à la liste si l'île est isolée avec des ponts (ne peut être reliée à aucune de ses voisines).    
    # Conseil à générer : la connexité doit être respectée.  
    # * +ile+ - Ile   
    private def estIsoleeAvecDesPonts(ile) #:doc:
        if(ile.getNbPonts() == 0) 
            for i in ile.listeDesVoisins()
                if(ile.peutEtreRelieeA?(i,true) == true)
                    return 
                end
            end
            conseil = Conseil.nouveau("Attention, il semblerait qu'une des îles soit isolée des autres par un pont. Pour rappel, la connexité doit être respectée. Il est primordial de faire attention aux îles aux alentours avant de placer un pont.",0)
            conseil.ajoutIleConcernee(ile)
            @listeDesConseils.push(conseil) 
        end
    end

    # Ajoute un conseil à la liste si un segment isolé est détecté. 
    # Conseil à générer : la connexité doit être respectée.
    private def detectionSegmentIsole  #:doc:
        i = 0
        j = 0 
        nbIlesRelieesTotalement = 0
        nbIles = 0

        ilesRelieesTotalement = Array.new 

        while(i < @partie.taille) do
            while(j < @partie.taille) do
                if(@partie.grille[i][j].estIle?)
                    ile = @partie.grille[i][j]
                    nbIles += 1 
                    if(ile.valeur() == ile.getNbPonts())
                        ilesRelieesTotalement.push(ile)
                        nbIlesRelieesTotalement += 1
                    end
                end 
                j += 1
            end
            j = 0
            i += 1
        end

        for k in ilesRelieesTotalement
            for u in k.ilesReliees
                if(!ilesRelieesTotalement.include?(u))   
                    return ; 
                end 
            end
        end 

        if((nbIlesRelieesTotalement != nbIles) && (nbIlesRelieesTotalement != 0))
            conseil = Conseil.nouveau("On détecte un segment isolé. Pour rappel, la connexité doit être respectée.",0)
            for m in ilesRelieesTotalement
                conseil.ajoutIleConcernee(m)
            end
            @listeDesConseils.push(conseil) 
        end
    end 

    ############################################################################################

    # Cherche un conseil en appelant toutes les méthodes de détection d'aides. 
    # * +ile+ - Ile 
    def chercheConseil(ile) 
        ile4DansUnCoin(ile)
        ile6SurLeCote(ile)
        ile8AuMilieu(ile)
        ile4Avec2Voisins(ile)
        ile6Avec3Voisins(ile)
        uneIleAvecUnSeulVoisin(ile)
        ile3DansUnCoin(ile)
        ile3Avec2Voisines(ile)
        ile5SurLeCote(ile)
        ile7AuMilieu(ile)
        ile3DansUnCoinSpecial(ile)
        ile3Avec2VoisinesSpecial(ile)
        ile5SurLeCoteSpecial(ile)
        ile7AuMilieuSpecial(ile)
        ile4CasSpecial(ile)
        ile6auMilieuSpecial(ile)
        erreurIlesIndice2RelieesParDoublePont(ile)
        erreurIlesIndice1Reliees(ile)
        ile1AvecUneSeuleVoisineDifferenteDe1(ile)
        ile2AvecDeuxVoisines2(ile)
        estIsoleeAvecDesPonts(ile)
        ile1AvecUneSeuleSolution(ile)
        ileOuOnPeutAjouterUnPont(ile)
        estIsolee(ile)
    end 

    # Génére un conseil 
    def genereConseil() 
        @listeDesConseils.clear() # On "remet à zéro" la liste des conseils 

        # Parcours de la grille de jeu pour chercher les conseils
        i = 0
        j = 0 
        while(i < @partie.taille) do
            while(j < @partie.taille) do
                if(@partie.grille[i][j].estIle?() == true)
                    chercheConseil(@partie.grille[i][j])
                end
                j += 1
            end
            j = 0
            i += 1
        end

        detectionSegmentIsole()

        # Si des conseils ont été trouvés
        if(@listeDesConseils.empty? == false)            
            # Supprime les conseils dupliqués pour en garder un exemplaire et trie les conseils selon leur ordre de priorité 
            return listeDesConseils.uniq { |conseil| conseil.texte }.sort_by(& :priorite)[0] # Retourne un conseil pour aider le joueur
        else 
            return Conseil.nouveau("Malheureusement, nous n'avons aucun conseil à vous donner.",0)
        end 
    end 
end 
