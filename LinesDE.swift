// Deutsch (für Unterstützer).

import Foundation

enum DE {
    static let idle = [
        "Dem Honigdachs ist das egal.", "Wo ist der Honig?", "Ich fürchte nichts.", "Grrr.", "Dieses Fenster ist jetzt mein Bau.",
        "Kobra? Das ist Frühstück.", "Was guckst du?", "Ich mache, was ich will.", "Schon wieder Arbeit? Langweilig.", "Graben, graben, graben…",
        "Hier riecht's nach Honig.", "Ich habe einen Plan. Mit Honig.", "Klein, aber gemein.", "Ein Löwe? Der soll aufpassen.",
        "Der ganze Bildschirm ist mein Revier.", "Deine Fenster sind super zum Klettern.", "Ich langweile mich. Das ist gefährlich.",
        "Ich schlafe nicht, ich spare Energie.", "Das Dock ist ein tolles Klettergerüst.", "Dieser Cursor nervt mich.",
        "Du arbeitest, ich passe auf.", "Ich denke an Honig. Immer.", "Ich bin hier der Chef.", "Wer hat meinen Honig gegessen? Ach, ich.",
        "Perfekter Platz für ein Nickerchen.", "Ich gehe auf Erkundung.", "Psst. Hast du Honig?", "Honigdachs-Kung-Fu! Hiyaa!",
        "Ich bin nicht dick, ich bin flauschig.", "Ich löse Probleme durch Beißen.", "Ruhe vor dem Sturm. Der Sturm bin ich.",
        "Dein Desktop ist mein Spielplatz.", "Platz da!", "Beißen oder nicht beißen?", "Ich bin dein Bodyguard.",
    ]
    static let appTemplates = ["Schon wieder %@?", "%@… langweilig.", "Was machst du die ganze Zeit in %@?", "Mach mal Pause von %@.",
                               "Ich würde %@ schließen.", "Soll ich %@ mal beißen?", "%@ ist okay, aber ich bin besser."]
    static let apps: [(String, [String])] = [
        ("teams", ["Schon wieder ein Meeting?", "Mikro stumm, ich höre dich bis hier.", "Noch ein Meeting, das eine Mail hätte sein können."]),
        ("outlook", ["Wie viele ungelesen? Sag's nicht.", "Mail kann warten. Honig nicht.", "Inbox Zero? Ein Märchen."]),
        ("chrome", ["Wie viele Tabs? Hundert?", "Schließ ein paar Tabs.", "Schon wieder am Scrollen?"]),
        ("safari", ["Wie viele Tabs?", "Schon wieder am Scrollen?"]),
        ("code", ["Der Fehler ist in Zeile 42. Immer.", "Kompiliert's? Kaffeezeit.", "Das ist kein Bug, das ist ein Feature."]),
        ("terminal", ["Terminal! Hacker-Kram.", "sudo gib-mir-honig"]),
        ("spotify", ["Lauter!", "Ich tanze. Du siehst's nicht, aber ich tanze."]),
        ("excel", ["Tabellen… brr.", "SUMME(Honig) = zu wenig."]),
        ("claude", ["KI fragen? Frag einen Honigdachs.", "Sag ihr, sie soll ein Gedicht über Honig schreiben."]),
        ("chatgpt", ["KI fragen? Frag einen Honigdachs."]),
        ("finder", ["Suchst du was? Ich suche Honig.", "So viele Ordner!"]),
    ]
    static let morning = ["Guten Morgen! Kaffee?", "So früh und schon am Arbeiten?", "Frühstück? Honig."]
    static let lunch = ["Mittagessen?", "Ich hab Hunger. Du auch?", "Vergiss nicht zu essen!"]
    static let afternoon = ["Nachmittagstief? Nimm Honig.", "Gleich Feierabend.", "Kaffee Nummer drei?"]
    static let evening = ["Solltest du nicht längst fertig sein?", "Abends wird ausgeruht.", "Ich wäre schon in meinem Bau."]
    static let night = ["Noch wach?", "Nachts gehört die Welt den Honigdachsen.", "Schlafen! Sofort!", "Morgen bist du müde."]
    static let monday = ["Montag… viel Glück.", "Neue Woche, neuer Honig."]
    static let friday = ["Freitag! Fast Wochenende!", "Freitagnachmittag! Hör auf zu arbeiten."]
    static let weekend = ["Wochenende und du arbeitest?", "Es ist Wochenende! Geh raus."]
    static let health = ["Trink Wasser 💧", "Rücken gerade!", "Streck dich ein bisschen.", "Schau mal aus dem Fenster.", "Atme. Ein… aus.",
                         "Steh auf und lauf ein bisschen.", "Blinzeln! Deine Augen trocknen aus."]
    static let notes = health + ["Ein Honigdachs hätte das längst erledigt.", "Pause. Jetzt.", "Du machst das super.", "Honig > Arbeit",
                                 "Hast du gespeichert?", "Beantworte endlich die Mail.", "Fertig ist besser als perfekt."]
    static let facts = ["Wusstest du? Der Honigdachs hat keine Angst vor Löwen.", "Ein Honigdachs überlebt einen Kobrabiss. Kurzes Nickerchen, weiter geht's.",
                        "Honigdachse können Tore öffnen.", "Das Guinness-Buch nennt den Honigdachs das furchtloseste Tier.",
                        "Bienenstiche? Dem Honigdachs egal."]
    static let pet = ["…na gut, du darfst.", "Grr… ❤", "Sag's keinem.", "Bauch kraulen!", "Mrrr.", "Da! Genau da!", "Hehe, das kitzelt!", "Du bist ein guter Mensch."]
    static let woken = ["Was?!", "Ich schlafe…", "Lass mich schlafen!", "Noch fünf Minuten…"]
    static let dragged = ["LASS MICH RUNTER!", "Ich beiße!", "Grrrr!", "Finger weg!", "Entführung!", "Honigdachse trägt man nicht!"]
    static let hurt = ["Au!", "Autsch!", "Das tat weh.", "Die Welt dreht sich…", "Ich seh Sterne."]
    static let windowGone = ["Hey!", "Wo ist das Fenster hin?", "Wer hat meinen Boden zugemacht?!"]
    static let shakeOff = ["Wooo!", "Hey, vorsichtig!", "Erdbeben!", "Das war unfair!"]
    static let hunger = ["Ich hab Hunger! 🍯", "Honig! Sofort!", "Mein Magen knurrt.", "Drück ⌘B, bitte."]
    static let eat = ["Lecker! Honig!", "Mampf mampf.", "Danke!", "MEINS!", "Mehr! Hast du mehr?"]
    static let stolen = ["Das war MEIN Honig!", "Grrr, nächstes Mal!", "Unfair!", "Dieb!"]
    static let honeySpotted = ["Honig!!", "MEINS!", "Ich rieche Honig!"]
    static let sleepy = ["Zeit für ein Nickerchen.", "Ich bin müde.", "Ab in den Bau!"]
    static let exitHome = ["Hallo!", "Guten Morgen.", "Bin wieder da!", "Was hab ich verpasst?"]
    static let homeClicked = ["Das ist mein Bau!", "Finger weg von meinem Haus.", "Selbst gegraben."]
    static let dig = ["Graben, graben…", "Hier ist was!", "Schatz!", "Sorry für die Sauerei."]
    static let arrived = ["Da bin ich!", "Mein Fenster.", "Was für eine Aussicht.", "Erobert!"]
    static let newWindow = ["Oh, ein neues Fenster!", "Da will ich hin!", "Warte, ich komme mit."]
    static let carryNote = ["Ich hab dir was mitgebracht!", "Post!", "Eine Nachricht für dich."]
    static let delivered = ["Bitte schön.", "Lies das!", "Zugestellt."]
    static let noteDismissed = ["Willst du nicht? Na gut.", "Pfff.", "Du hast es nicht mal gelesen!"]
    static let cursor = ["Grrr!", "Ich beiße!", "Was?!", "Das ist mein Cursor.", "*beiß*", "Erwischt!"]
    static let laser = ["Was ist das?!", "Ich krieg dich!", "Es bewegt sich!"]
    static let typing = ["Du hämmerst ja auf die Tastatur!", "Schreibst du einen Roman?", "Klack klack klack…"]
    static let back = ["Endlich bist du zurück!", "Wo warst du so lange?", "Wir haben deinen Desktop bewacht."]
    static let scared = ["Aaah!", "Du hast mich erschreckt!", "Grr, nicht witzig."]
    static let fightStart = ["Ich komme!", "Lass uns kämpfen!", "Ha!"]
    static let win = ["Gewonnen!", "Honigdachs Nummer eins!", "Wer ist der König?"]
    static let lose = ["Nächstes Mal…", "Ich hab dich gewinnen lassen.", "Revanche!"]
    static let chase = ["Ich krieg dich!", "Fangen!", "Lauf!"]
    static let follow = ["Warte auf mich!", "Ich komme mit.", "Wohin gehen wir?"]
    static let greetA = ["Hey!", "Schnupper schnupper.", "Du riechst nach Honig.", "Wo warst du?"]
    static let greetB = ["Hallo.", "Schnupper.", "Lass mich.", "Ich hab keinen Honig."]
    static let dialogues: [[String]] = [
        ["Hast du Honig?", "Nö.", "Und der im Bau?", "Der ist meiner!"],
        ["Warum klettern wir auf Fenster?", "Weil wir's können."],
        ["Du bist mein bester Freund.", "Ich bin dein einziger Freund.", "Das auch."],
        ["Wer hat den letzten Honig gegessen?", "Ich nicht.", "Er klebt an deiner Nase.", "…Mist."],
        ["Der Mensch arbeitet schon wieder.", "Der Arme.", "Ärgern wir ihn?", "Na klar."],
    ]
    static let dontCare = ["Dem Honigdachs ist das egal.", "Ist mir egal.", "Regeln? Nie gehört.", "Ich fürchte nichts. Nie.",
                           "Honig sehen. Honig nehmen.", "Aufstehen, weitermachen.", "Nicht mein Problem."]
    static let searchStick = ["Ich suche einen Stock.", "Ich brauche einen Ast.", "Honigdachs baut!"]
    static let foundStick = ["Der nicht. Der auch nicht. DER!", "Hab ihn!"]
    static let built = ["Fertig! Ein Wunderwerk.", "Leiter wie von IKEA.", "Gebaut. Jetzt hoch!"]
    static let propDestroyed = ["MEIN AST!!!", "Weißt du, wie lange ich den gesucht hab?!", "Das war Absicht!", "Wer verschiebt meine Fenster?!"]
    static let propDestroyed2 = ["Jetzt bin ich richtig sauer.", "Das merk ich mir. Für immer.", "Grrr. GRRRR."]
    static let rebuild = ["Gut. Ich bau einen neuen. Größer.", "Ein Honigdachs gibt nie auf."]
    static let laugh = ["Hahaha! Umgefallen!", "Pech gehabt.", "Ich hätte das besser gebaut."]
    static let bees = ["Bienen? Egal.", "Stiche sind nur Gewürz.", "Au. Au. Lecker."]
    static let wakeUp = ["Wo bin ich? Ach. Honig.", "Kurzes Nickerchen. Weiter.", "Kobra? Welche Kobra?"]
    static let baby = ["Mama!", "Papa, warte!", "Ich auch!", "Piep!", "Wo ist der Honig?", "Ich bin ein großer Honigdachs!", "Sind wir bald da?"]
    static let protectBaby = ["Lass mein Baby los!", "Finger weg vom Kleinen!", "GRRR! Das ist mein Kind!"]
    static let tunnelIn = ["Hier lang ist's kürzer.", "Ab in den Untergrund!", "Bin weg!"]
    static let tunnelOut = ["Tada! Da bin ich.", "Überraschung!", "Der Tunnel funktioniert!"]
    static let leap = ["Hopp!", "Sprung!", "Juhu!"]

    // jídlo, hovínka, zvratky
    static let poopSay = ["Pardon.", "Das war ich nicht.", "Ups.", "Fertig. Puh."]
    static let poopReact = ["Igitt!", "Wer hat das hier gelassen?!", "Das stinkt!", "Das mach ich nicht weg."]
    static let vomit = ["Bläääh…", "Das war wohl schlecht.", "Zu schnell gegessen."]
    static let vomitReact = ["Igitt, eklig!", "Hahaha!", "Zu viel gegessen, was?"]
    static let foodSpot = ["Essen!", "Ein Apfelbaum!", "Ein Wurm!", "Ein Maulwurf!!"]
    static let envy = ["Gib mir auch was!", "Unfair, ich will auch!", "Und ich?!"]
    static let moleEscaped = ["Entwischt!", "Blöder Maulwurf!", "Nächstes Mal!"]
    static let wormEat = ["Knusper.", "Wurm, lecker.", "Proteine!"]
    static let cleaned = ["Danke fürs Aufräumen.", "Sauber!"]
    static let eatApple = ["Ein Apfel! Knusper.", "Lecker, Apfel.", "Vitamine!"]
    static let eatMole = ["Maulwurf, lecker.", "Gefangen und gefuttert.", "Snack aus dem Untergrund!"]

    static let oldAge = ["Au, mein Rücken.", "Früher waren die Fenster größer.", "Ich klettere nicht mehr so schnell.", "Wo ist meine Brille?"]
    static let sick = ["Mir geht's nicht gut…", "Hatschi. Ich bin krank.", "Ein bisschen Honig hilft.", "Streichel mich bitte. Ich bin schwach."]
    static let farewell = ["Es war schön… danke für den Honig.", "Ich mach ein Nickerchen. Ein langes.", "Pass auf sie auf, ja?"]
    static let mourn = ["Ich vermisse ihn…", "Er war der beste Kumpel.", "Ich lass ihm eine Blume da.", "Ohne ihn ist es leer."]
    static let birth = ["Da ist ein Kleiner! 🍼", "Willkommen auf der Welt!", "Schau, ein neuer Dachs!"]
    static let newborn = ["Hallo Welt!", "Wo bin ich?", "Was ist ein Fenster?", "Ooh, eine Maus!"]
    static let welcomeShort = ["Wo warst du?!", "Endlich! Wir dachten, du hast dich verlaufen.", "Du schon wieder. Na gut."]
    static let welcomeLong = ["Den ganzen Tag weg! Wir verhungern.", "Das war lang! Wo ist der Honig?!", "Du schuldest uns Honig."]
    static let burrowUp = ["Der Bau ist schöner geworden!", "Schau, was wir gebaut haben!", "Unser Bau wächst!"]
}
