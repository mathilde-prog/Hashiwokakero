# # # # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Alexandre DANJOU, Marie-Nina MUNAR  #
# # # # # # # # # # # # # # # # # # # # # # # # # 

require_relative "Chrono"

# Classe représentant le Timer qui décrémente sa valeur jusqu'à zéro. 
# Cette classe contient les variables d'instances suivantes :
# @duree:: Durée impartie
# @timeLeft:: Temps restant
class Timer < Chrono

	# Permet de créer le timer. 
	# * +debut+ - le temps de début du timer (en secondes)
	def Timer.creer(debut)
		 new(debut)
	end

	private_class_method :new

	# Permet d'initialiser le timer. 
	# * +debut+ - le temps de début du timer (en secondes)
    def initialize(debut)
        super(debut)
		@duree = debut
		@timeLeft = 0
	end

	# Permet de retirer du temps à chaque fois que le joueur utilise une aide.
	def malusAide
		return @duree -= 30 # On retire 30 sec
	end

	# Permet de retirer du temps à chaque fois que le joueur utilise une astuce. 
	def malusAstuce
		return @duree -= 10 # On retire 10 sec
	end

	# Redéfinition de la valeur pour retourner le temps restant
    def valeur
		if(@enExec)
        	@elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC, :second)
		end
        time = @elapsed - @start
		@timeLeft  = [@duree - time, 0].max # temps restant
		return @timeLeft
    end
end
