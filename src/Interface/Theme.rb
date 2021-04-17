# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Auteurs : Alexandre DANJOU, Mendy FATNASSI, Fatih UFACIK  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

require 'gtk3'

# Classe gérant le thème du jeu. 
# Cette classe contient la variable suivante : 
# @@style:: Indicateur booléen du thème (true correspond au thème clair et false au thème sombre)
class Theme
    @@style = true # true correspond au thème clair

    # Cette méthode permet de lancer le thème clair sur l'accueil et régler la taille de l'image. 
    # * +bouton+ [Gtk::Button] - le bouton de changement de thème
    def self.themeLancement(bouton)
        tab = [bouton]
        comportementBtn(tab)
        # On lance en theme clair
		provider = Gtk::CssProvider.new
		provider.load(data: <<-CSS)
		.mainBox{
			background: #CFCFCF
		}
        .tableauChargerPartie, .labelChoix{
            color: #000000
        }
		CSS
		Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)
    end

    # Cette méthode va redimensionner et changer les comportement des boutons. 
    # * +tab+ - Tableau de Gtk::Button dont les comportements vont être modifiés
    def self.comportementBtn(tab)
        btnTheme = tab[0]
        btnHome = tab[1]
        btnAide1 = tab[2]
        btnAide2 = tab[3]
        btnAide3 = tab[4]

        # Si le thème était clair
        if @@style then
    		imgLuneDark = Gtk::Image.new(:file => "../res/img/darkmode.svg")
    		imgLuneDark.pixbuf=imgLuneDark.pixbuf.scale_simple(64, 64, GdkPixbuf::InterpType::BILINEAR)
    		btnTheme.set_image(imgLuneDark)
            # Si on a un bouton Home
            if btnHome
                imgHomeDark = Gtk::Image.new(:file => "../res/img/bouton_home.svg")
                imgHomeDark.pixbuf = imgHomeDark.pixbuf.scale_simple(63, 63, GdkPixbuf::InterpType::BILINEAR)
                btnHome.set_image(imgHomeDark)
                btnHome.set_always_show_image(true)
            end
            # Si on a des boutons Aides
            if (btnAide1 && btnAide2 && btnAide3)
                imgAide1 = Gtk::Image.new(:file => "../res/img/image_aide.svg")
                imgAide2 = Gtk::Image.new(:file => "../res/img/image_aide.svg")
                imgAide3 = Gtk::Image.new(:file => "../res/img/image_aide.svg")
                imgAide1.pixbuf = imgAide1.pixbuf.scale_simple(56, 56, GdkPixbuf::InterpType::BILINEAR)
                imgAide2.pixbuf = imgAide2.pixbuf.scale_simple(56, 56, GdkPixbuf::InterpType::BILINEAR)
                imgAide3.pixbuf = imgAide3.pixbuf.scale_simple(56, 56, GdkPixbuf::InterpType::BILINEAR)
                btnAide1.set_image(imgAide1)
                btnAide2.set_image(imgAide2)
                btnAide3.set_image(imgAide3)
            end
        # Sinon si le thème était dark
        else
    		imgLuneWhite = Gtk::Image.new(:file => "../res/img/whitemode.svg")
    		imgLuneWhite.pixbuf=imgLuneWhite.pixbuf.scale_simple(64, 64, GdkPixbuf::InterpType::BILINEAR)
    		btnTheme.set_image(imgLuneWhite)
            # Si on a un bouton Home
            if btnHome
                imgHomeWhite = Gtk::Image.new(:file => "../res/img/bouton_home_white.svg")
                imgHomeWhite.pixbuf = imgHomeWhite.pixbuf.scale_simple(63, 63, GdkPixbuf::InterpType::BILINEAR)
                btnHome.set_image(imgHomeWhite)
                btnHome.set_always_show_image(true)
            end
            # Si on a des boutons Aides
            if (btnAide1 && btnAide2 && btnAide3)
                imgAide1 = Gtk::Image.new(:file => "../res/img/image_aide_white.svg")
                imgAide2 = Gtk::Image.new(:file => "../res/img/image_aide_white.svg")
                imgAide3 = Gtk::Image.new(:file => "../res/img/image_aide_white.svg")
                imgAide1.pixbuf = imgAide1.pixbuf.scale_simple(56, 56, GdkPixbuf::InterpType::BILINEAR)
                imgAide2.pixbuf = imgAide2.pixbuf.scale_simple(56, 56, GdkPixbuf::InterpType::BILINEAR)
                imgAide3.pixbuf = imgAide3.pixbuf.scale_simple(56, 56, GdkPixbuf::InterpType::BILINEAR)
                btnAide1.set_image(imgAide1)
                btnAide2.set_image(imgAide2)
                btnAide3.set_image(imgAide3)
            end
        end

        btnTheme.name = "btnTheme"
		provider = Gtk::CssProvider.new
		provider.load(data: <<-CSS)
        #btnTheme:hover {all: unset;}
        #btnTheme:hover{box-shadow: none;text-shadow: none;border:0px;min-width:0px;margin:7px;}
		CSS
		Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)
    end 

    # Méthode qui permet de passer d'un thème a l'autre. 
    # * +tab+ - Tableau de Gtk::Button dont les comportements vont être modifiés. 
    def self.theme(tab)
        btnTheme = tab[0]
        btnHome = tab[1]
        btnAide1 = tab[2]
        btnAide2 = tab[3]
        btnAide3 = tab[4]
        #Par défaut @style = true on passe du mode clair au mode sombre
        if @@style then
            @@style = false
            #On change les icônes
            comportementBtn(tab)
            #On change le background
            provider = Gtk::CssProvider.new
            provider.load(data: <<-CSS)
            .mainBox{
                background: #212121
            }
            .tableauChargerPartie {
                color: #ffffff
            }
            /* Classe des labels de choix de chargerPartie */
            .labelChoix{
                color: #ffffff
            }
            CSS
            Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)
            #on change la couleurs des labels
        #Si style = false on passe du mode sombre au mode clair
        else
            @@style = true
            #On change les icônes
            comportementBtn(tab)
            #On change le background
            provider = Gtk::CssProvider.new
            provider.load(data: <<-CSS)
            .mainBox{
                background: #CFCFCF
            }

            .tableauChargerPartie {
                color: #000000
            }
            /* Class des labels de choix de chargerPartie */
            .labelChoix{
                color: #000000
            }
            CSS
            Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)
        end
    end

    # Méthode permettant d'appliquer le thème actuel sur la partie en cours
    def self.themePartieAppliquer()
        if(@@style) # THEME CLAIR
            provider = Gtk::CssProvider.new
            provider.load_from_path('../res/css/partieLight.css')
            Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)
        else # THEME FONCE
            provider = Gtk::CssProvider.new
            provider.load_from_path('../res/css/partieDark.css')
            Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)
        end
    end

    # Méthode permettant de passer à un thème précis dans partie
    # * +themeVoulu+ [Boolean] - true pour thème clair, false pour thème sombre
    def self.themePartieSwitch(themeVoulu)
        @@style = themeVoulu
        self.themePartieAppliquer()
    end

    # Méthode permettant de récupérer l'état courant du thème (renvoie true si le thème est clair, false si le thème est foncé)
    def self.isClair?
        return @@style
    end

    # Méthode permettant d'appliquer le thème actuel sur l'interface du classement
    # * +btnRetourMenu+ [Gtk::Button] - Bouton de l'interface classement permettant de retourner au menu précédent 
    def self.themeClassementAppliquer(btnRetourMenu)
        provider = Gtk::CssProvider.new
		if(Theme.isClair?) # THEME CLAIR 
			provider.load_from_path('../res/css/classementLight.css')
			iconeMaisonThemeClair = Gtk::Image.new(:file => "../res/img/bouton_home.svg")
			iconeMaisonThemeClair.pixbuf = iconeMaisonThemeClair.pixbuf.scale_simple(63,63,GdkPixbuf::InterpType::BILINEAR)
			btnRetourMenu.set_image(iconeMaisonThemeClair)
		else # THEME FONCE 
			provider.load_from_path('../res/css/classementDark.css')
			iconeMaisonThemeSombre = Gtk::Image.new(:file => "../res/img/bouton_home_white.svg")
			iconeMaisonThemeSombre.pixbuf = iconeMaisonThemeSombre.pixbuf.scale_simple(63,63,GdkPixbuf::InterpType::BILINEAR)
			btnRetourMenu.set_image(iconeMaisonThemeSombre)
		end
		Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default, provider, Gtk::StyleProvider::PRIORITY_APPLICATION)
    end
end
