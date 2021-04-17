# # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Julien PROUDY, Mathilde MOTTAY  #
# # # # # # # # # # # # # # # # # # # # # # #

# Permet d'établir la connexion avec la base de données classement.db 
ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => "../res/database/classement.db",
  :timeout => 5000
)
