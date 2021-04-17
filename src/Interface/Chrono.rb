# # # # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Alexandre DANJOU, Marie-Nina MUNAR  #
# # # # # # # # # # # # # # # # # # # # # # # # # 

# Classe représentant le Chrono
# Cette classe contient les variables d'instances suivantes :
# @start:: Début du chrono
# @elapsed:: Temps écoulé
# @enExec:: Indique si le chrono est en cours d'exécution ou s'il est stoppé (booléen)
# @debut:: Temps au début du chrono (en secondes)
# @malus:: Malus ajoutés au temps
class Chrono

	# Permet de créer le chrono.
    # * +debut+ - Temps ajouté au chrono (en secondes)
	def Chrono.creer(debut)
		 new(debut)
	end

	private_class_method :new

	# Permet d'initialiser le chrono. 
    # * +debut+ - Temps ajouté au chrono (en secondes)
    def initialize(debut)
        @debut = debut
        @start = 0
        @elapsed = 0
        @malus = 0
	end

    # Méthode pour lancer le Chrono
    def startChrono
		@elapsed = 0
		@enExec = true
        @start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :second)
    end

    # Méthode pour stopper le Chrono
    def stopChrono
        if(@enExec)
            @enExec = false
            @elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC, :second) #Fin du chrono
        end
    end

	# Méthode qui indique si le chrono est en cours d'exécution ou s'il est stoppé. 
	def getEnExec()
		return @enExec;
	end

    # Méthode qui retire du temps a chaque fois que le joueur utilise une aide. 
	def malusAide
		@malus += 30 # On retire 30 sec
	end

	# Méthode qui retire du temps à chaque fois que le joueur utilise une astuce. 
	def malusAstuce
		@malus += 10 # On retire 10 sec
	end

    # Affiche le chrono 
    def afficher
		time = self.valeur
		#Calcul heure/minute/seconde
        heure = time/3600
        minute = (time%3600)/60
        seconde = time - minute*60 - heure*3600
        h = sprintf("%02i", heure)
        m = sprintf("%02i", minute)
        s = sprintf("%02i", seconde)
		#Affichage sur 2 chiffres
        if(heure>0)
            return "#{h}:#{m}:#{s}"
        else
            return "#{m}:#{s}"#Pas la peine d'afficher des heures si elles sont à 0
        end
    end

    # Retourne le nombre de secondes depuis le début du chrono
    def valeur
        if(@enExec) # On prend la nouvelle heure du chrono, s'il n'est pas arrêté
            @elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC, :second)
        end
        time = @elapsed - @start + @debut + @malus
        return time
    end
end
