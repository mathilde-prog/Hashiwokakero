# # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Julien PROUDY, Mathilde MOTTAY  #
# # # # # # # # # # # # # # # # # # # # # # #

require "active_record"
require 'sqlite3'
require 'gtk3'

require_relative "../connectSqlite3.rb"
require_relative "../ClassementLibre.rb"
require_relative "../ClassementProgressif.rb"
require_relative "../ClassementPuzzleRush.rb"
require_relative "InterfaceAccueilJeu.rb"
require_relative "Theme.rb"

# La classe Classement représente le classement et son interface. 
# Cette classe contient les variables d'instances suivantes : 
# @fenetre:: Fenêtre pour intégrer l'interface du classement 
# @boxClassement:: Box qui contient l'interface du classement 
# @boxMenu:: Box qui contient le menu qui appelle le classement 
# @ancienTitre:: Titre du menu qui appelle le classement
# @scrolledWindow:: Fenêtre défilable pour les données du classement 
# @listeDonneesClassement:: Liste pour stocker les données du classement 
# @zoneDonneesClassement:: Zone d'affichage des données du classement 
# @messageClassement:: Zone pour le message du classement 
# @bufferMessageClassement:: Buffer qui contient le texte du message du classement 
# @btnRetourMenu:: Bouton pour retourner au menu 
# @boutonEffacer:: Bouton pour effacer les scores 
# @comboBoxMode:: Combobox pour choisir le mode 
# @comboBoxDifficulte:: Combobox pour choisir la difficulté
# @etiquetteDifficulte:: Etiquette "Difficulté"
# @pseudo:: Pseudo du joueur qui regarde le classement 
# @nbJoueursDansLeClassement:: Nombre de joueurs dans le classement
class Classement < Gtk::Builder

	private_class_method :new; 
	
	# Création du classement 
	# * +pseudoJoueur+ - Pseudo du joueur qui regarde le classement 
	# * +fenetreMenu+ - Fenêtre du menu qui appelle le classement 
	# * +boxMenu+ - Box qui contient le menu qui appelle le classement 
	def Classement.creer(pseudoJoueur, fenetreMenu, boxMenu)
		new(pseudoJoueur, fenetreMenu, boxMenu)
	end 

	# Méthode d'initialisation du classement 
	# * +pseudoJoueur+ - Pseudo du joueur qui regarde le classement 
	# * +fenetreMenu+ - Fenêtre du menu qui appelle le classement 
	# * +boxMenu+ - Box qui contient le menu qui appelle le classement 
	def initialize (pseudoJoueur, fenetreMenu, boxMenu)
	    super()
	    
		self.add_from_file(__FILE__.sub(".rb",".glade"))
		# Création d'une variable d'instance par composant identifié dans glade
		self.objects.each() { |p| 	
				unless p.builder_name.start_with?("___object") 
					instance_variable_set("@#{p.builder_name}".intern, self[p.builder_name]) 
				end
		}
		
		# On connecte les signaux aux méthodes (qui doivent exister)
		self.connect_signals { |handler| 
				begin
					method(handler) 
				rescue	
					puts "\t\t[Attention] Vous devez définir la méthode #{handler} :\n\t\t\tdef #{handler}\n\t\t\t\t....\n\t\t\tend\n"
					self.class.send( :define_method, handler.intern) {
						puts "La méthode #{handler} n'est pas encore définie.. Arrêt"
						Gtk.main_quit
					}
					retry
				end
		}	

		#Configuration globale de la fenêtre
		@fenetre = fenetreMenu
		@ancienTitre = @fenetre.title;
		@fenetre.set_title("Hashi - Tableau des scores")
		@fenetre.add(@boxClassement)

		@boxMenu = boxMenu

		# On applique le bon CSS selon le thème (clair ou sombre). 
		Theme.themeClassementAppliquer(@btnRetourMenu)

		# Création de 3 colonnes (classement / pseudo / score) pour la zone des données du classement 
		@listeDonneesClassement = Gtk::ListStore.new(String, String, String)
		@zoneDonneesClassement = Gtk::TreeView.new(@listeDonneesClassement)
		renderer = Gtk::CellRendererText.new

		# Colonne Classement 
		column = Gtk::TreeViewColumn.new("Classement",renderer, :text => 0)
		column.resizable = false
		column.expand = true 
		@zoneDonneesClassement.append_column(column)

		# Colonne Pseudo 
		column = Gtk::TreeViewColumn.new("Pseudo",renderer, :text => 1)
		column.resizable = false
		column.expand = true 
		@zoneDonneesClassement.append_column(column)

		# Colonne Score 
		column = Gtk::TreeViewColumn.new("Score",renderer, :text => 2)
		column.resizable = false
		column.expand = true 
		@zoneDonneesClassement.append_column(column)

		@scrolledWindow.add_with_viewport(@zoneDonneesClassement)
		@zoneDonneesClassement.show_all

		# Buffer pour le message du classement 
        @bufferMessageClassement = @messageClassement.buffer

		@pseudo = pseudoJoueur 
		@nbJoueursDansLeClassement = 0

		actualiseTableauDesScores(); 
	end

	# Retourne au menu 
	private def retourMenu() #:doc:
		@fenetre.remove(@boxClassement)
		@fenetre.add(@boxMenu)
		@fenetre.set_title(@ancienTitre)
	end 

	# Efface le classement sélectionné par le joueur
	private def effaceClassement #:doc:
		# Affichage particulier dans l'interface quand le classement est effacé
		@bufferMessageClassement.set_text("Il n'y pas de classement pour ce mode.\n")
		@listeDonneesClassement.clear 
		iter = @listeDonneesClassement.append 
		iter[0] = "N/A"
		iter[1] = "N/A"
		iter[2] = "N/A"

		# Efface le classement dans la base de données 
		case @comboBoxMode.active_iter[0] 
		when "Libre" 
			if @comboBoxDifficulte.active_iter[0] == "Facile"
				ClassementLibre.effaceNiveau(1)
			elsif @comboBoxDifficulte.active_iter[0] == "Moyen"
				ClassementLibre.effaceNiveau(2)
			else @comboBoxDifficulte.active_iter[0] == "Difficile"
				ClassementLibre.effaceNiveau(3)
			end 
		when "Progressif"
			ClassementProgressif.effaceToi()
		when "Puzzle Rush"
			ClassementPuzzleRush.effaceToi()
		end
	end 

	# Crée la base de données classement si elle n'existe pas 
	def Classement.creeSiBesoinBDDClassement 
		begin
			db = SQLite3::Database.open "../res/database/classement.db"
			db.execute "CREATE TABLE IF NOT EXISTS classement_libres (pseudo TEXT, score NUMERIC, difficulte NUMERIC);"
			db.execute "CREATE TABLE IF NOT EXISTS classement_puzzle_rushes (pseudo TEXT, score NUMERIC);"
			db.execute "CREATE TABLE IF NOT EXISTS classement_progressifs (pseudo TEXT, score NUMERIC);"		
		rescue SQLite3::Exception => e 
			puts "Exception occurred"
			puts e
		ensure
			db.close if db
		end
	end 

	# Gère la visibilité de la combobox Difficulte
	private def gereVisibiliteDifficulte #:doc:
		if @comboBoxMode.active_iter[0] != "Libre"
			@comboBoxDifficulte.visible = false 
			@etiquetteDifficulte.visible = false
		else  
			@comboBoxDifficulte.visible = true 
			@etiquetteDifficulte.visible = true
		end 
	end 

	# Actualise le tableau des scores 
	private def actualiseTableauDesScores #:doc:
		gereVisibiliteDifficulte()	
		
		# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
		# Récupération des données du classement selon ce que l'utilisateur choisit dans la ou les combobox #
		# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
		case @comboBoxMode.active_iter[0] 
		when "Libre" 
			# Récupération des tableaux contenant les pseudos et scores à partir de la classe ClassementLibre
			if @comboBoxDifficulte.active_iter[0] == "Facile"
				tableauPseudos = ClassementLibre.recupereTableauPseudos(1)
				tableauScores = ClassementLibre.recupereTableauScores(1)
			elsif @comboBoxDifficulte.active_iter[0] == "Moyen"
				tableauPseudos = ClassementLibre.recupereTableauPseudos(2)
				tableauScores = ClassementLibre.recupereTableauScores(2)
			else @comboBoxDifficulte.active_iter[0] == "Difficile"
				tableauPseudos = ClassementLibre.recupereTableauPseudos(3)
				tableauScores = ClassementLibre.recupereTableauScores(3)
			end 

		when "Progressif"
			# Récupération des tableaux contenant les pseudos et scores à partir de la classe ClassementProgressif
			tableauPseudos = ClassementProgressif.recupereTableauPseudos()
			tableauScores = ClassementProgressif.recupereTableauScores()

		when "Puzzle Rush"
			# Récupération des tableaux contenant les pseudos et scores à partir de la classe ClassementPuzzleRush
			tableauPseudos = ClassementPuzzleRush.recupereTableauPseudos()
			tableauScores = ClassementPuzzleRush.recupereTableauScores()
		end 

		# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
		# Affichage du rang, du pseudo et du score de chaque joueur qui figure dans le classement #
		# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
		@nbJoueursDansLeClassement = tableauPseudos.length()
		@listeDonneesClassement.clear

		# Cas classement vide - aucune donnée 
		if(@nbJoueursDansLeClassement == 0)
			iter = @listeDonneesClassement.append
			iter[0] = "N/A"
			iter[1] = "N/A"
			iter[2] = "N/A"
		else 
			# Ajoute les rangs, pseudos et scores des joueurs à la liste des données du classement 
			for i in 0..@nbJoueursDansLeClassement-1
				iter = @listeDonneesClassement.append
				iter[0] = (i+1).to_s # Rang 
				iter[1] = tableauPseudos[i] # Pseudo 
				iter[2] = tableauScores[i] # Score 
			end
		end 

		# Calcule le rang du joueur qui regarde le classement et lui affiche un message 
		calculRang(tableauPseudos)
	end

	# Calcule le rang du joueur qui regarde le classement et affiche un message sur l'interface 
	# * +tableauPseudos+ - Tableau contenant les pseudos 
	private def calculRang(tableauPseudos) #:doc:

		if(@nbJoueursDansLeClassement == 0)
			@bufferMessageClassement.set_text("Il n'y pas de classement pour ce mode.\n")
		else 
			ind = tableauPseudos.index(@pseudo)
			if(ind == nil)
				@bufferMessageClassement.set_text("Vous n'apparaissez pas dans ce classement.\n")
			elsif ((ind+1) == 1)
				@bufferMessageClassement.set_text("Bravo, vous êtes le numéro 1 à ce classement !")
			else
	 			@bufferMessageClassement.set_text("Pour ce classement, vous êtes " + (ind+1).to_s + "ème sur " + @nbJoueursDansLeClassement.to_s + ".")
			end 
		end 
	end 
end 

