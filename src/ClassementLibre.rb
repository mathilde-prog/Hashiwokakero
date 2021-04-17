# # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Julien PROUDY, Mathilde MOTTAY  #
# # # # # # # # # # # # # # # # # # # # # # #

# La classe ClassementLibre modélise le classement libre. 
# Remarque : Le mode libre du jeu est un mode où l'utilisateur sera libre de choisir la taille de la grille et la difficulté.
class ClassementLibre < ActiveRecord::Base

  # Retourne un tableau contenant les pseudos des joueurs
  # * +niveauDifficulte+ - Niveau de difficulté du mode libre (entier) 
  def ClassementLibre.recupereTableauPseudos(niveauDifficulte)
    begin 
      pseudo = Array.new() # Tableau pour les pseudos des joueurs 

      # Ouverture de la base de données "classement.db"
      db = SQLite3::Database.open "../res/database/classement.db"

      # Préparation et exécution de la requête pour sélectionner les pseudos des joueurs  
      stmPseudo = db.prepare "SELECT pseudo FROM classement_libres WHERE difficulte = '#{niveauDifficulte}' ORDER BY score DESC" # tri par score 
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
  # * +niveauDifficulte+ - Niveau de difficulté du mode libre (entier)
  def ClassementLibre.recupereTableauScores(niveauDifficulte)
    begin 
      score = Array.new()  # Tableau pour les scores des joueurs 

      # Ouverture de la base de données "classement.db"
      db = SQLite3::Database.open "../res/database/classement.db"

      # Préparation et exécution de la requête pour sélectionner les scores des joueurs   
      stmScore = db.prepare "SELECT score FROM classement_libres WHERE difficulte = '#{niveauDifficulte}' ORDER BY score DESC" # tri par score 
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

  # Efface le classement libre du niveau de difficulté passé en paramètre  
  # * +niveauDifficulte+ - Niveau de difficulté du mode libre (entier)
  def ClassementLibre.effaceNiveau(niveauDifficulte)
    begin 
      # Ouverture de la base de données "classement.db"
      db = SQLite3::Database.open "../res/database/classement.db"

      # On efface le contenu de la table classement_libres pour le niveau de difficulté choisi  
      db.execute("delete from classement_libres WHERE difficulte = '#{niveauDifficulte}'")
      puts "\n# Le classement libre niveau #{niveauDifficulte} est effacé avec succès !"

    rescue SQLite3::Exception => e
      puts "Exception occurred"
      puts e

    ensure 
        db.close if db
    end 
  end 

  # Ajoute une ligne de score dans la table du classement libre si le pseudo du joueur n'y figure pas déjà ou si le joueur a amélioré son score. 
  # * +pseudo+ - Pseudo du joueur (chaine de caractères) 
  # * +score+ - Score du joueur (entier)
  # * +difficulte+ - Niveau de difficulté du mode libre (entier)
  def ClassementLibre.ajoutDansLaBDD(pseudo, score, difficulte)
    begin 
    # Ouverture de la base de données "classement.db"
    db = SQLite3::Database.open "../res/database/classement.db"

    # Préparation et exécution de la requête pour savoir si le joueur apparait déjà dans le classement pour un niveau de difficulté en particulier 
    stmPresence = db.prepare "SELECT * FROM classement_libres WHERE difficulte = '#{difficulte}' AND pseudo = '#{pseudo}'"
    nb = stmPresence.execute.count 

    if (nb == 0) # Cas pseudo non présent dans la table pour le niveau de difficulté choisi
      # Ajout du nouveau score dans le classement (+ sauvegarde)
      new(:pseudo=>pseudo, :score=>score, :difficulte=>difficulte).save 
    else # Cas pseudo a déjà un classement pour le niveau de difficulté choisi 
      # Préparation et exécution de la requête pour sélectionner le score actuel du joueur pour le niveau de difficulté choisi
      stmScore = db.prepare "SELECT score FROM classement_libres WHERE difficulte = '#{difficulte}' AND pseudo = '#{pseudo}'"
      rs = stmScore.execute 
      # Récupération du score actuel 
      scoreActuel = rs.next[0] 
      
      # Si le joueur a amélioré son score 
      if(scoreActuel.to_i < score)
        print "Bravo #{pseudo}, vous avez amélioré votre score pour la difficulté "
        case difficulte
        when 1 # Niveau facile
          print "facile !\n"
        when 2 # Niveau moyen 
          print "moyen !\n"
        when 3 # Niveau difficile 
          print "difficile !\n"
        else
          print "Erreur: difficulte a une valeur invalide."
        end

        # Mise à jour du classement - La ligne dans la table est actualisée. 
        db.execute "UPDATE classement_libres SET score = '#{score}' WHERE difficulte = '#{difficulte}' AND pseudo = '#{pseudo}'"
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
