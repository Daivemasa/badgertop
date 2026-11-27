// Français (pour les soutiens).

import Foundation

enum FR {
    static let idle = [
        "Le ratel s'en fiche.", "Où est le miel ?", "Je n'ai peur de rien.", "Grrr.", "Cette fenêtre est mon terrier maintenant.",
        "Un cobra ? C'est le petit-déj.", "Qu'est-ce que tu regardes ?", "Je fais ce que je veux.", "Encore du travail ? Ennuyeux.", "Creuser, creuser, creuser…",
        "Ça sent le miel ici.", "J'ai un plan. Avec du miel.", "Petit mais méchant.", "Un lion ? Qu'il fasse attention.",
        "Tout l'écran est mon territoire.", "Tes fenêtres sont parfaites pour grimper.", "Je m'ennuie. C'est dangereux.",
        "Je ne dors pas, j'économise de l'énergie.", "Le Dock, c'est une super aire de jeux.", "Ce curseur m'agace.",
        "Tu travailles, je surveille.", "Je pense au miel. Toujours.", "C'est moi le chef.", "Qui a mangé mon miel ? Ah, moi.",
        "Endroit parfait pour une sieste.", "Je pars explorer.", "Psst. T'as du miel ?", "Kung-fu de ratel ! Hiyaa !",
        "Je ne suis pas gros, je suis touffu.", "Je règle les problèmes en mordant.", "Le calme avant la tempête. La tempête, c'est moi.",
        "Ton bureau est mon terrain de jeu.", "Pousse-toi !", "Mordre ou ne pas mordre ?", "Je suis ton garde du corps.",
    ]
    static let appTemplates = ["Encore %@ ?", "%@… ennuyeux.", "Tu fais quoi toute la journée dans %@ ?", "Fais une pause de %@.",
                               "Moi, je fermerais %@.", "Je mords %@ ?", "%@, c'est bien, mais je suis mieux."]
    static let apps: [(String, [String])] = [
        ("teams", ["Encore une réunion ?", "Coupe ton micro, je t'entends d'ici.", "Encore une réunion qui aurait pu être un mail."]),
        ("outlook", ["Combien de non lus ? Ne me dis pas.", "Le mail peut attendre. Le miel, non."]),
        ("chrome", ["Combien d'onglets ? Cent ?", "Ferme quelques onglets.", "Tu scrolles encore ?"]),
        ("safari", ["Combien d'onglets ?", "Tu scrolles encore ?"]),
        ("code", ["Le bug est à la ligne 42. Toujours.", "Ça compile ? Pause café.", "Ce n'est pas un bug, c'est une fonctionnalité."]),
        ("terminal", ["Le terminal ! Truc de hacker.", "sudo donne-moi-du-miel"]),
        ("spotify", ["Plus fort !", "Je danse. Tu ne le vois pas, mais je danse."]),
        ("excel", ["Les tableurs… brr.", "SOMME(miel) = pas assez."]),
        ("claude", ["Tu demandes à l'IA ? Demande à un ratel.", "Demande-lui un poème sur le miel."]),
        ("chatgpt", ["Tu demandes à l'IA ? Demande à un ratel."]),
        ("finder", ["Tu cherches quelque chose ? Moi, je cherche du miel.", "Que de dossiers !"]),
    ]
    static let morning = ["Bonjour ! Un café ?", "Si tôt et déjà au travail ?", "Petit-déj ? Du miel."]
    static let lunch = ["On mange ?", "J'ai faim. Toi aussi ?", "N'oublie pas de manger !"]
    static let afternoon = ["Coup de mou ? Prends du miel.", "Bientôt fini.", "Troisième café ?"]
    static let evening = ["Tu ne devrais pas avoir fini ?", "Le soir, on se repose.", "Moi, je serais déjà dans mon terrier."]
    static let night = ["Encore debout ?", "La nuit appartient aux ratels.", "Au lit ! Tout de suite !", "Demain tu seras fatigué."]
    static let monday = ["Lundi… bon courage.", "Nouvelle semaine, nouveau miel."]
    static let friday = ["Vendredi ! Presque le week-end !", "Vendredi après-midi ! Arrête de travailler."]
    static let weekend = ["Le week-end et tu travailles ?", "C'est le week-end ! Sors un peu."]
    static let health = ["Bois de l'eau 💧", "Redresse le dos !", "Étire-toi un peu.", "Regarde par la fenêtre.", "Respire. Inspire… expire.",
                         "Lève-toi et marche un peu.", "Cligne des yeux ! Ils sèchent."]
    static let notes = health + ["Un ratel l'aurait déjà fait.", "Pause. Maintenant.", "Tu gères. Vraiment.", "Miel > travail",
                                 "Tu as enregistré ?", "Réponds enfin à ce mail.", "Fait vaut mieux que parfait."]
    static let facts = ["Le savais-tu ? Le ratel n'a pas peur des lions.", "Un ratel survit à une morsure de cobra. Petite sieste, et il repart.",
                        "Les ratels savent ouvrir les portails.", "Le Guinness le classe animal le plus intrépide.", "Les piqûres d'abeilles ? Le ratel s'en fiche."]
    static let pet = ["…bon, d'accord.", "Grr… ❤", "Ne le dis à personne.", "Gratouille le ventre !", "Mrrr.", "Là ! Juste là !", "Hihi, ça chatouille !", "Tu es quelqu'un de bien."]
    static let woken = ["Quoi ?!", "Je dors…", "Laisse-moi dormir !", "Encore cinq minutes…"]
    static let dragged = ["POSE-MOI !", "Je mords !", "Grrrr !", "Bas les pattes !", "Enlèvement !", "Un ratel, ça ne se porte pas !"]
    static let hurt = ["Aïe !", "Ouille !", "Ça fait mal.", "Le monde tourne…", "Je vois des étoiles."]
    static let windowGone = ["Hé !", "Où est passée la fenêtre ?", "Qui a fermé mon sol ?!"]
    static let shakeOff = ["Wouh !", "Hé, doucement !", "Tremblement de terre !", "Pas juste !"]
    static let hunger = ["J'ai faim ! 🍯", "Du miel ! Tout de suite !", "Mon ventre gargouille.", "Appuie sur ⌘B, s'il te plaît."]
    static let eat = ["Miam ! Du miel !", "Miam miam.", "Merci !", "À MOI !", "Encore ! T'en as encore ?"]
    static let stolen = ["C'était MON miel !", "Grrr, la prochaine fois !", "Pas juste !", "Voleur !"]
    static let honeySpotted = ["Du miel !!", "À MOI !", "Je sens le miel !"]
    static let sleepy = ["Je vais faire une sieste.", "Je suis fatigué.", "Au terrier !"]
    static let exitHome = ["Salut !", "Bonjour.", "Je suis de retour !", "J'ai raté quoi ?"]
    static let homeClicked = ["C'est mon terrier !", "Pas touche à ma maison.", "Creusé moi-même."]
    static let dig = ["Je creuse, je creuse…", "Il y a quelque chose ici !", "Un trésor !", "Désolé pour le bazar."]
    static let arrived = ["Me voilà !", "Ma fenêtre.", "Quelle vue.", "Conquis !"]
    static let newWindow = ["Oh, une nouvelle fenêtre !", "Je veux aller là !", "Attends, je viens aussi."]
    static let carryNote = ["Je t'apporte quelque chose !", "Du courrier !", "J'ai un message pour toi."]
    static let delivered = ["Voilà.", "Lis-le !", "Livré."]
    static let noteDismissed = ["Tu n'en veux pas ? D'accord.", "Pfff.", "Tu ne l'as même pas lu !"]
    static let cursor = ["Grrr !", "Je mords !", "Quoi ?!", "C'est mon curseur.", "*crac*", "Attrapé !"]
    static let laser = ["C'est quoi ça ?!", "Je l'attrape !", "Ça bouge !"]
    static let typing = ["Tu tapes comme un fou !", "Tu écris un roman ?", "Clac clac clac…"]
    static let back = ["Enfin tu es de retour !", "Tu étais où si longtemps ?", "On a gardé ton bureau."]
    static let scared = ["Aaah !", "Tu m'as fait peur !", "Grr, pas drôle."]
    static let fightStart = ["J'arrive !", "On se bat !", "Ha !"]
    static let win = ["Gagné !", "Ratel numéro un !", "Qui est le roi ?"]
    static let lose = ["La prochaine fois…", "Je t'ai laissé gagner.", "Revanche !"]
    static let chase = ["Je t'attrape !", "Chat !", "Cours !"]
    static let follow = ["Attends-moi !", "Je viens avec toi.", "On va où ?"]
    static let greetA = ["Salut !", "Snif snif.", "Tu sens le miel.", "T'étais où ?"]
    static let greetB = ["Salut.", "Snif.", "Laisse-moi.", "J'ai pas de miel."]
    static let dialogues: [[String]] = [
        ["T'as du miel ?", "Non.", "Et celui du terrier ?", "C'est le mien !"],
        ["Pourquoi on grimpe sur les fenêtres ?", "Parce qu'on peut."],
        ["T'es mon meilleur ami.", "Je suis ton seul ami.", "Ça aussi."],
        ["Qui a mangé le dernier miel ?", "Pas moi.", "T'en as sur le nez.", "…zut."],
        ["L'humain travaille encore.", "Le pauvre.", "On l'embête ?", "Allez."],
    ]
    static let dontCare = ["Le ratel s'en fiche.", "Je m'en fiche.", "Des règles ? Connais pas.", "Je n'ai peur de rien. Jamais.",
                           "Je vois du miel. Je prends le miel.", "Je me relève et je continue.", "Pas mon problème."]
    static let searchStick = ["Je cherche un bâton.", "Il me faut une branche.", "Le ratel construit !"]
    static let foundStick = ["Pas celui-là. Pas celui-là. CELUI-LÀ !", "Je l'ai !"]
    static let built = ["Fini ! Une merveille.", "Échelle façon IKEA.", "Construit. En haut !"]
    static let propDestroyed = ["MA BRANCHE !!!", "Tu sais combien de temps je l'ai cherchée ?!", "Tu l'as fait exprès !", "Qui bouge mes fenêtres ?!"]
    static let propDestroyed2 = ["Là, je suis vraiment fâché.", "Je m'en souviendrai. Pour toujours.", "Grrr. GRRRR."]
    static let rebuild = ["Bon. J'en construis une autre. Plus grande.", "Un ratel n'abandonne jamais."]
    static let laugh = ["Hahaha ! Elle est tombée !", "Pas de chance.", "Je l'aurais mieux construite."]
    static let bees = ["Des abeilles ? Je m'en fiche.", "Les piqûres, c'est de l'assaisonnement.", "Aïe. Aïe. Miam."]
    static let wakeUp = ["Où suis-je ? Ah. Du miel.", "Petite sieste. Je continue.", "Un cobra ? Quel cobra ?"]
    static let baby = ["Maman !", "Papa, attends !", "Moi aussi !", "Pip !", "Où est le miel ?", "Je suis un grand ratel !", "On arrive bientôt ?"]
    static let protectBaby = ["Lâche mon petit !", "Ne touche pas au petit !", "GRRR ! C'est mon enfant !"]
    static let tunnelIn = ["Par ici, c'est plus court.", "Sous terre !", "Je disparais !"]
    static let tunnelOut = ["Tadaa ! Me voilà.", "Surprise !", "Le tunnel marche !"]
    static let leap = ["Hop !", "Saut !", "Youpi !"]

    // jídlo, hovínka, zvratky
    static let poopSay = ["Pardon.", "C'est pas moi.", "Oups.", "Fini. Ouf."]
    static let poopReact = ["Beurk !", "Qui a laissé ça ici ?!", "Ça pue !", "Je ne nettoie pas ça."]
    static let vomit = ["Bleuh…", "C'était sûrement pas frais.", "J'ai mangé trop vite."]
    static let vomitReact = ["Beurk, dégoûtant !", "Hahaha !", "T'as trop mangé, hein ?"]
    static let foodSpot = ["À manger !", "Un pommier !", "Un ver !", "Une taupe !!"]
    static let envy = ["Donne-m'en aussi !", "Pas juste, j'en veux !", "Et moi ?!"]
    static let moleEscaped = ["Elle s'est échappée !", "Fichue taupe !", "La prochaine fois !"]
    static let wormEat = ["Crunch.", "Un ver, miam.", "Des protéines !"]
    static let cleaned = ["Merci pour le ménage.", "Tout propre !"]
    static let eatApple = ["Une pomme ! Croc croc.", "Miam, une pomme.", "Des vitamines !"]
    static let eatMole = ["Une taupe, miam.", "Attrapée et mangée.", "Goûter souterrain !"]

    static let oldAge = ["Aïe, mon dos.", "De mon temps, les fenêtres étaient plus grandes.", "Je ne grimpe plus aussi vite.", "Où sont mes lunettes ?"]
    static let sick = ["Je ne me sens pas bien…", "Atchoum. Je suis malade.", "Un peu de miel me guérirait.", "Caresse-moi, s'il te plaît. Je suis faible."]
    static let farewell = ["C'était beau… merci pour le miel.", "Je vais faire une sieste. Une longue.", "Prends soin d'eux, d'accord ?"]
    static let mourn = ["Il me manque…", "C'était le meilleur copain.", "Je lui laisse une fleur.", "C'est vide sans lui."]
    static let birth = ["Il y a un petit ! 🍼", "Bienvenue au monde !", "Regarde, un nouveau ratel !"]
    static let newborn = ["Bonjour le monde !", "Où suis-je ?", "C'est quoi, une fenêtre ?", "Oh, une souris !"]
    static let welcomeShort = ["T'étais où ?!", "Enfin ! On croyait que tu t'étais perdu.", "Encore toi. Bon, d'accord."]
    static let welcomeLong = ["Parti toute la journée ! On meurt de faim.", "C'était long ! Où est le miel ?!", "Tu nous dois du miel."]
    static let burrowUp = ["Le terrier est plus joli !", "Regarde ce qu'on a construit !", "Notre terrier grandit !"]
}
