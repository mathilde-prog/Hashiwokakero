# # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Julien PROUDY, Mathilde MOTTAY  #
# # # # # # # # # # # # # # # # # # # # # # #

# La classe ClassementPuzzleRush modélise le classement Puzzle Rush. 
# Remarque : Le mode Puzzle Rush du jeu est un mode où le joueur devra résoudre un maximum de grilles de niveau facile dans un délai imparti.
class ClassementPuzzleRush < ActiveRecord::Base

  # Retourne un tableau contenant les pseudos des joueurs
  def ClassementPuzzleRush.recupereTableauPseudos()
    begin 
      pseudo = Array.new() # Tableau pour les pseudos des joueurs 

      # Ouverture de la base de données "classement.db"
      db = SQLite3::Database.open "../res/database/classement.db"

      # Préparation et exécution de la requête pour sélectionner les pseudos des joueurs  
      stmPseudo = db.prepare "SELECT pseudo FROM classement_puzzle_rushes ORDER BY score DESC" 
      rsPseudo = stmPseudo.execute 
 
      # Récupération des pseudos dans le tableau pseudo 
      while (rowPseudo = rsPseudo.next) do
        pseudo.push(rowPseudo.join "\s")
      end
      
      return pseudo

    rescue SQLite3::Exception => e
      puts "Exception occurred"
      puts e

    ensure
        stmPseudo.close if stmPseudo
        db.close if db
    end
  end 

  # Retourne un tableau contenant les scores des joueurs
  def ClassementPuzzleRush.recupereTableauScores()
    begin 
      score = Array.new()  # Tableau pour les scores des joueurs 

      # Ouverture de la base de données "classement.db"
      db = SQLite3::Database.open "../res/database/classement.db"

      # Préparation et exécution de la requête pour sélectionner les scores des joueurs   
      stmScore = db.prepare "SELECT score FROM classement_puzzle_rushes ORDER BY score DESC" 
      rsScore = stmScore.execute 

      # Récupération des scores dans le tableau score 
      while (rowScore = rsScore.next) do
        score.push(rowScore.join "\s")
      end

      return score

    rescue SQLite3::Exception => e
      puts "Exception occurred"
      puts e

    ensure
        stmScore.close if stmScore
        db.close if db
    end
  end 

  # Efface le classement puzzle rush  
  def ClassementPuzzleRush.effaceToi()
    begin 
      db = SQLite3::Database.open "../res/database/classement.db"
      db.execute("delete from classement_puzzle_rushes")
      puts "\n# Le classement puzzle rush est effacé avec succès !"
    rescue SQLite3::Exception => e
      puts "Exception occurred"
      puts e
    ensure 
        db.close if db
    end 
  end 

  # Ajoute une ligne de score dans la table du classement Puzzle Rush si le pseudo du joueur n'y figure pas déjà ou si le joueur a amélioré son score.
  # * +pseudo+ - Pseudo du joueur (chaine de caractères)
  # * +score+ - Score du joueur (entier)
  def ClassementPuzzleRush.ajoutDansLaBDD(pseudo, score)

    begin 
      # Ouverture de la base de données "classement.db"
      db = SQLite3::Database.open "../res/database/classement.db"
  
      # Préparation et exécution de la requête pour savoir si le joueur apparaît déjà dans le classement Puzzle Rush
      stmPresence = db.prepare "SELECT * FROM classement_puzzle_rushes WHERE pseudo = '#{pseudo}'"
      nb = stmPresence.execute.count 
  
      if (nb == 0) # Cas pseudo non présent dans la table 
        # Ajout du nouveau score dans le classement (+ sauvegarde)
        new(:pseudo=>pseudo, :score=>score).save 

      else # Cas pseudo apparait déjà dans le classement 
        # Préparation et exécution de la requête pour sélectionner le score actuel du joueur 
        stmScore = db.prepare "SELECT score FROM classement_puzzle_rushes WHERE pseudo = '#{pseudo}'"
        rs = stmScore.execute 
        # Récupération du score actuel 
        scoreActuel = rs.next[0] 
        
        # Si le joueur a amélioré son score 
        if(scoreActuel.to_i < score)
          print "Bravo #{pseudo}, vous avez amélioré votre score !\n"
          # Mise à jour du classement - La ligne dans la table est actualisée. 
          db.execute "UPDATE classement_puzzle_rushes SET score = '#{score}' WHERE pseudo = '#{pseudo}'"
          puts "Le classement est mis à jour.\n\n"
        end 
      end 
  
      rescue SQLite3::Exception => e
        puts "Exception occurred"
        puts e
  
      ensure
          stmPresence.close if stmPresence
          stmScore.close if stmScore
          db.close if db
      end
  end 
end
