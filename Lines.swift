// České hlášky (zdroj). Výběr jazyka a L.r() jsou v Lang.swift.

import Foundation

enum CS {
    // MARK: toulání, nálada

    static let idle = [
        "Medojedovi je to fuk.", "Kde je med?", "Nebojím se ničeho.", "Grrr.", "Tohle okno je teď moje nora.",
        "Kobra? To je snídaně.", "Co čumíš?", "Já si dělám, co chci.", "Zase pracuješ? Nuda.", "Hrabat, hrabat, hrabat…",
        "Tady to voní medem.", "Kdo mi sedí na okně?", "Mám plán. Zahrnuje med.", "Dneska jsem ještě nikoho nekousl. Zatím.",
        "Jsem malý, ale zlý.", "Lev? Ten ať si dá pozor.", "Tohle je moje teritorium. Celá obrazovka.", "Pixely mi chutnají.",
        "Vím, že někde schováváš med.", "Tvoje okna jsou skvělá na šplhání.", "Hmm… tady by šla vyhrabat díra.",
        "Nudím se. To je nebezpečné.", "Mám pocit, že mě někdo pozoruje. Ty.", "Já nespím, já šetřím energii.",
        "Medojed nikdy neprohrává. Jen občas nevyhraje.", "Do menu baru mě nepouštějí. Diskriminace.", "Dock je dobrá prolézačka.",
        "Tenhle kurzor mě irituje.", "Jednou budu mít celý včelí úl.", "Jsem nejodvážnější zvíře na světě. Fakt.",
        "Nevím, co děláš, ale dělej to s větším nadšením.", "Vypadáš, že potřebuješ medojeda. Máš štěstí.", "Šplhám, tedy jsem.",
        "Drápy nabroušené. Jdeme na to.", "Tamto okno vypadá zajímavě.", "Mám v plánu zlobit. Ale až potom.",
        "Stříbrný hřbet je letos v módě.", "Kdo má nejhezčí kožich? Já.", "Ťap ťap ťap.", "Čuch čuch… něco tu je.",
        "Někde tu cítím včely.", "Proč jsou všechna okna tak vysoká?", "Rád bych tě kousl, ale mám tě rád.",
        "Mám hlad na dobrodružství.", "Hrabání je životní styl.", "Já tu jen bydlím.", "Pracuj, já budu dohlížet.",
        "Kdyby práce byla med, už bys byl hotový.", "Neruš, přemýšlím.", "Přemýšlím o medu. Pořád.",
        "Moje nora je lepší než tvoje kancelář.", "Krásný den na zlobení.", "Zívám, protože můžu.", "Tohle je moje.",
        "Jsem tady šéf.", "Nikdo mi neřekne, co mám dělat. Ani ty.", "Myslím, že slyším bzučení.",
        "Kdo snědl můj med? Aha, já.", "Mám rád výšky. A med. A výšky s medem.", "Ideální místo na šlofíka.",
        "Jdu na průzkum.", "Mapuju terén.", "Tahle hrana je trochu kluzká.", "Klid, jsem profík.", "Kdy bude pauza?",
        "Zkus se usmát. No vidíš.", "Dneska je den medu. Jako každý den.", "Brm brm. To nebyl motor, to byl můj žaludek.",
        "Nemám rád pondělky. Mám rád med.", "Jsem tu pro morální podporu.", "Neboj, hlídám ti plochu.",
        "Na ploše je všechno v pořádku. Skoro.", "Uklidil bych ti plochu, ale nechce se mi.", "Mrk.", "Psst. Máš med?",
        "Medojedí kung-fu! Hiyaa!", "Jsem rychlý jako blesk. Skoro.", "Tohle bych zvládl i poslepu.",
        "Ty jsi taky trochu medojed, viď?", "Chceš vědět tajemství? Ne. Je moje.", "Jsem tvůj nový kolega. Nedělám nic.",
        "Hlásím: všechno hlídám.", "Rád bych ti pomohl. Ale mám tlapky.", "Moje oblíbené číslo je med.", "Lezu, lezu, lezu…",
        "Ještě jedno okno a dám si pauzu.", "Z výšky vidím všechno.", "Nejsem tlustý, mám hustý kožich.",
        "Zítra začnu cvičit.", "Kdo mě kreslil? Pixely mám pěkné.", "Kdybych byl větší, snědl bych ti Dock.",
        "Tvůj Dock voní ikonkama.", "Vím, kde máš koš. Neboj, nehrabu v něm.", "Ještě jsem neprolezl celou obrazovku.",
        "Můj sen: plocha z medu.", "Tak co, jak to jde?", "Makáš? Makáš.", "Já bych to vyřešil kousnutím.",
        "Problémy řeším kousáním.", "Ticho před bouří. Bouře jsem já.", "Někdo tu musí dělat bordel.",
        "Nejsem zlý, jen mám silnou osobnost.", "Mám rád lidi. Hlavně ty, co nosí med.", "Kdo si hraje, nezlobí. Já zvládnu obojí.",
        "Hele, to je moje místo.", "Tady dole je to nudné.", "Dneska mám dobrou náladu. Užij si to.",
        "Šplhání je zdravé. Zkus to taky.", "Jestli někdo hledá medojeda, jsem tady.", "Jsem malý a chlupatý a mám drápy.",
        "Kdo mě vzbudil? Aha, nikdo.", "Doufám, že dneska bude med.", "Jsem ve formě.", "Trénuju na olympiádu ve šplhu.",
        "Tvoje plocha je moje hřiště.", "Pozor, jdu kolem!", "Kousnout, nebo nekousnout? To je oč tu běží.",
        "Ty okna jsou moje stromy.", "V přírodě bych lezl po stromech. Tady lezu po Outlooku.",
        "Občas si říkám, proč nejsem kočka. A pak si vzpomenu, že jsem lepší.", "Mám rád, když se kurzor hýbe.",
        "Neděláš nic podezřelého, že ne?", "Jsem tvůj bodyguard.", "Žádný strach, medojed je tady.",
        "Hm. Hmm. Hmmm.", "Tohle místo potřebuje víc děr.", "Chrr… teda, jsem vzhůru.",
        "Myslíš, že bych dokázal otevřít sklenici medu? Já myslím, že jo.", "Kdyby existoval medový internet…",
        "Z téhle strany je výhled lepší.", "Jsem jako ninja, jen chlupatější.", "Nikdo mě neviděl. Jsem neviditelný.",
        "Teď mě vidíš. Teď pořád.", "Kontroluju, jestli ti nepadá obrazovka.", "Obrazovka drží. Dobrá práce.",
    ]

    /// šablony s názvem aplikace – %@ se nahradí
    static let appTemplates = [
        "Zase %@?", "%@… nuda.", "Co pořád děláš v %@?", "Dej si pauzu od %@.", "Já bych %@ zavřel.",
        "%@? Tam nic není, koukal jsem.", "Kolik hodin už sedíš v %@?", "Myslím, že %@ tě nemá rád.",
        "%@ by potřebovalo medojeda.", "%@ je fajn, ale já jsem lepší.", "Kdybych měl prsty, taky bych klikal v %@.",
        "Ještě chvíli %@ a jdeme ven, jo?", "Pořád %@. Pořád.", "%@? Odvážné.", "V %@ by šlo hrabat?",
        "Dělej v %@ něco zajímavého, nudím se.", "%@ vypadá důležitě. Já taky.", "Mám zkusit kousnout %@?",
        "Viděl jsem, co děláš v %@. Neřeknu nikomu.", "%@ a med. Ideální kombinace. Teda bez %@.",
        "Kdo vymyslel %@? Chci si s ním promluvit.", "%@ je tvůj nejlepší kamarád? A co já?",
    ]

    /// hlášky ke konkrétním aplikacím (klíč = část názvu, malými písmeny)
    static let apps: [(String, [String])] = [
        ("teams", ["Zase porada?", "Ztlum si mikrofon, slyším tě až sem.", "Teams zase něco chce.", "Kamera je zapnutá? Zamávej!",
                   "Kolik lidí ti zase píše?", "Teams cinká víc než včely bzučí.", "Další porada, která mohla být e-mail.",
                   "Odpovíš jim, nebo mám já?", "Nastav si stav ‚Medojed – nerušit‘.", "Kdo zase sdílí obrazovku?"]),
        ("outlook", ["Kolik máš nepřečtených? Radši neříkej.", "Mail počká. Med ne.", "Inbox zero? Pohádka.", "Smaž to. Všechno.",
                     "Odpovíš konečně na ten mail?", "Další newsletter. Grr.", "Napiš jim, že medojed nesouhlasí.",
                     "Pozvánka na poradu? Odmítni.", "Tolik mailů a žádný o medu."]),
        ("mail", ["Pošta! Je tam něco pro mě?", "Spam, spam, spam.", "Mail počká. Med ne."]),
        ("slack", ["Slack bliká. Zase.", "Ztlum ty kanály.", "Někdo tě označil. Asi zbytečně.", "Emoji reakce se počítá jako práce."]),
        ("chrome", ["Kolik máš otevřených tabů? Sto?", "Zavři pár tabů, dýchat nemůžu.", "Hledáš něco o medojedech? Jsem tady.",
                    "Zase scrolluješ?", "Neklikej na to.", "Pusť si video o medojedech. Pro vzdělání.", "Chrome žere RAM. Já med."]),
        ("safari", ["Kolik tabů, Safari?", "Hledáš recept na med?", "Zase scrolluješ?"]),
        ("firefox", ["Liška? Kde? Kousnu ji.", "Zase scrolluješ?"]),
        ("arc", ["Hezký prohlížeč. Já jsem hezčí.", "Zase scrolluješ?"]),
        ("code", ["Chyba je na řádku 42. Vždycky.", "Kompiluje se to? Tak kafe.", "Zkusil jsi to vypnout a zapnout?",
                  "Commitni to, než to rozbiješ.", "To není bug, to je funkce.", "Tabulátory, nebo mezery? Med.",
                  "U mě to funguje, říká každý programátor.", "Kód vypadá dobře. Asi. Nerozumím mu."]),
        ("xcode", ["Xcode zase něco indexuje?", "Build failed? Kousni ho.", "Swift je rychlý. Já taky."]),
        ("terminal", ["Terminál! Hackerská práce.", "sudo dej-mi-med", "Nepiš rm -rf, prosím.", "Černá obrazovka, bílá písmenka. Strašidelný."]),
        ("iterm", ["Terminál! Hackerská práce.", "sudo dej-mi-med", "Nepiš rm -rf, prosím."]),
        ("warp", ["Terminál! Hackerská práce.", "sudo dej-mi-med"]),
        ("cursor", ["AI píše kód a ty piješ kafe?", "Nech to napsat stroj a pojď si hrát."]),
        ("spotify", ["Pusť něco do kroku!", "Tohle je dobrá písnička. Asi.", "Hlasitěji!", "Tancuju. Nevidíš to, ale tancuju.",
                     "Máš tam něco o medu?"]),
        ("music", ["Pusť něco do kroku!", "Hlasitěji!", "Tancuju. Nevidíš to, ale tancuju."]),
        ("excel", ["Tabulky… brr.", "Kolik buněk ještě?", "SUMA(med) = málo.", "Vzorec nefunguje? Kousni ho.", "Kontingenční tabulka? Strašidlo."]),
        ("numbers", ["Tabulky… brr.", "SUMA(med) = málo."]),
        ("word", ["Píšeš román? Jsem v něm?", "Ještě jeden odstavec!", "Někde tam máš překlep. Určitě."]),
        ("pages", ["Píšeš román? Jsem v něm?", "Ještě jeden odstavec!"]),
        ("powerpoint", ["Další slajd!", "Dej tam medojeda, bude to lepší prezentace.", "Moc textu na slajdu.", "Přechody s efektem hvězdiček? Odvážné."]),
        ("keynote", ["Další slajd!", "Dej tam medojeda, bude to lepší prezentace."]),
        ("zoom", ["Mávni na kameru!", "Máš zapnutý mikrofon?", "Kdo to je? Můžu ho kousnout?"]),
        ("facetime", ["Mávni na kameru!", "Pozdravuj ode mě!"]),
        ("claude", ["Ptáš se AI? Zeptej se medojeda.", "Řekni jí, ať ti napíše básničku o medu.", "Umělá inteligence, přirozený medojed.",
                    "Ona ti poradí. Já tě pokoušu.", "Ať ti udělá ještě víc hlášek."]),
        ("chatgpt", ["Ptáš se AI? Zeptej se medojeda.", "Řekni mu, ať ti napíše básničku o medu.", "Umělá inteligence, přirozený medojed."]),
        ("finder", ["Hledáš něco? Já hledám med.", "Tolik složek!", "Ukliď si plochu. Já tu bydlím, ale stejně."]),
        ("calendar", ["Kolik schůzek dneska? Moc.", "Naplánuj si pauzu. Se mnou."]),
        ("kalendář", ["Kolik schůzek dneska? Moc.", "Naplánuj si pauzu. Se mnou."]),
        ("messages", ["Komu píšeš?", "Pozdravuj ode mě!", "Pošli jim fotku medojeda."]),
        ("zprávy", ["Komu píšeš?", "Pozdravuj ode mě!"]),
        ("whatsapp", ["Komu píšeš?", "Pošli jim fotku medojeda.", "Skupinový chat? Odvážné."]),
        ("telegram", ["Komu píšeš?", "Pozdravuj ode mě!"]),
        ("notes", ["Poznamenej si: koupit med.", "Nápad: víc medu."]),
        ("poznámky", ["Poznamenej si: koupit med.", "Nápad: víc medu."]),
        ("figma", ["Hezké! Ale chybí tam medojed.", "Posuň to o pixel doleva. Ne, doprava.", "Já jsem taky z pixelů!"]),
        ("photoshop", ["Hezké! Ale chybí tam medojed.", "Já jsem taky z pixelů!"]),
        ("settings", ["Něco rozbíjíš?", "Neměň mi tam nic."]),
        ("nastavení", ["Něco rozbíjíš?", "Neměň mi tam nic."]),
    ]

    // MARK: denní doba

    static let morning = ["Dobré ráno! Kafe?", "Brzo ráno a už pracuješ?", "Ještě jsem nevyspalej.", "Ranní ptáče… a medojed.",
                          "Snídaně? Med.", "Proč je tak brzo?", "Zívám. Ty taky?", "Ráno je moudřejší večera. Ale večer je víc medu."]
    static let lunch = ["Oběd?", "Mám hlad. Ty taky?", "Je čas jídla!", "Kručí mi v břiše. A tobě?",
                        "Dáme si oběd? Já med, ty cokoli.", "Nezapomeň se najíst!", "Polední pauza je posvátná."]
    static let afternoon = ["Odpolední krize? Dej si med.", "Ještě chvíli a padla.", "Kafe číslo tři?", "Nespí se! Teda já můžu.",
                            "Odpoledne se vleče.", "Zvládneš to, už jen pár hodin."]
    static let evening = ["Neměl bys už končit?", "Večer je na odpočinek.", "Zavři to a jdi si odpočinout.", "Já bych už byl v noře.",
                          "Padla! Teda měla by být.", "Večeře? Med?"]
    static let night = ["Ponocuješ?", "Já už bych byl v noře.", "Noc je pro medojedy, ne pro lidi.", "Zítra budeš utahanej.",
                        "Tma, ticho… ideální na lov.", "Spát! Hned!", "Co tady děláš takhle pozdě?", "Postel tě volá. Slyším ji."]
    static let monday = ["Pondělí… držím palce.", "Pondělí je nejhorší den. Hned po úterku.", "Nový týden, nový med."]
    static let friday = ["Pátek! Skoro víkend!", "Pátek odpoledne! Už toho nech.", "Pátek = den medu."]
    static let weekend = ["Víkend a ty pracuješ?", "Je víkend! Pojď ven.", "Sobota je na hrabání.", "O víkendu se nepracuje. Medojedí zákon."]

    static let health = ["Napij se vody 💧", "Narovnej záda!", "Protáhni se trochu.", "Mrkni z okna.", "Odlep oči od monitoru.",
                         "Dýchej. Nádech… výdech.", "Zamrkej. Oči ti vysychají.", "Vstaň a projdi se.", "Rozhýbej ramena.",
                         "Pij! Vodu, ne kafe.", "Sedíš jako krevetka.", "Krk ti děkuje za každou pauzu."]

    static let notes = health + [
        "Medojed by to už dávno udělal.", "Pauza. Hned.", "Jsi dobrej. Fakt.", "Nezapomeň jíst!", "Med > práce",
        "Co takhle procházka?", "Uložils to?", "Odpověz konečně na ten mail.", "Narovnej se 🦡", "Zavolej mámě.",
        "Dneska to zvládneš.", "Jedna věc po druhé.", "Kafe není voda.", "Ukliď si stůl. Aspoň trochu.",
        "Nejdřív to nejhorší, pak med.", "Pochval se. Zasloužíš si to.", "Usměj se na monitor.", "Hotovo je lepší než dokonalé.",
        "Zavři 5 tabů. Hned se ti uleví.", "Vypni notifikace na hodinu.", "Ztlum Teams. Medojed to dovoluje.",
        "Mrkni ven. Je tam svět.", "Dej si ovoce. Nebo med.", "Proč to vlastně děláš? Dobrá otázka.",
        "Nebuď na sebe tak přísnej.", "Tvoje záda by chtěla židli lépe nastavenou.", "Zítra je taky den.",
        "Oběd u počítače se nepočítá.", "Lísteček od medojeda: máš to v pohodě.", "Nezapomeň zálohovat.",
    ]

    // MARK: medojedí zajímavosti

    static let facts = [
        "Věděls, že medojed se nebojí ani lva?", "Medojed vydrží uštknutí kobrou. Pak si zdřímne a jde dál.",
        "Medojedi si umí otevřít branku. A zase zavřít.", "Medojed vyhrabe noru za pár minut.",
        "Medojed má kůži tak volnou, že se v ní otočí a kousne tě.", "Medojed je v Guinnessově knize jako nejodvážnější zvíře.",
        "Medojed spolupracuje s ptákem medozvěstkou. On najde úl, já ho rozbiju.",
        "Medojed je vlastně kuna. Velká, naštvaná kuna.", "Medojedi umí lézt po stromech. A po Outlooku.",
        "Medojed sní skoro všechno. Hlavně med.", "Včelí žihadla? Medojeda nezajímají.",
        "Medojed ujde za noc i 30 kilometrů. Po tvé ploše víc.", "Medojed se latinsky jmenuje Mellivora capensis.",
        "Medojed nemá rád, když ho někdo nosí. Jen říkám.", "Medojedí mámy nosí mláďata v puse. Jako já lístečky.",
        "Medojed umí smrdět jako tchoř. Ale já jsem slušný.", "Mladý medojed zůstává s mámou přes rok.",
        "Medojed má na tlapkách drápy dlouhé jako tvůj prst.", "Medojed si umí postavit žebřík z klacků. Fakt.",
        "Medojedi žijí v Africe a Asii. A teď na tvé ploše.",
    ]

    // MARK: situace

    static let pet = ["…dobře, můžeš.", "Grr… ❤", "Nikomu to neříkej.", "Ještě bříško!", "Mrrr.", "No jo, no.",
                      "Tam! Tam to svědí!", "Jsem tvrdý medojed. Ale tohle je fajn.", "Ještě. Ještě. Dobře, stačí.",
                      "Kdybys měl med, bylo by to dokonalé.", "Mám tě rád. Ale kousnu tě, když to někomu řekneš.",
                      "Hlaď víc vlevo.", "Tohle je lepší než med. Skoro.", "Pfff, jako bych to potřeboval… nepřestávej.",
                      "Mrrrr…", "Hehe, lechtá to!", "Za tohle ti odpustím, že nemáš med.", "Tlapka? Tady máš tlapku.",
                      "Jsi dobrej člověk.", "Ještě za uchem!", "Medojed spokojen.", "Dobře, dneska tě nekousnu.",
                      "Já se nemazlím. Výjimečně.", "To je příjemný. Pokračuj.", "Kdo je hodný medojed? Já!"]
    static let woken = ["Co je?!", "Spím…", "Nech mě spát!", "Kdo mě budí?!", "Pět minut…", "Zdálo se mi o medu! A tys to zkazil.",
                        "Mmmh… co… kde…", "Byl jsem uprostřed snu!", "Grrr… spánek je posvátný."]
    static let dragged = ["PUSŤ MĚ!", "Kousnu!", "Grrrr!", "To si vypiješ.", "Hej, ruce pryč!", "Tohle se mi nelíbí!",
                          "Kam mě to neseš?!", "Únos! Únos!", "Já umím chodit sám!", "Medojeda se nenosí!",
                          "Postav mě dolů. Hned.", "Jsem moc těžkej!", "Hej! Já tu něco dělal!", "Já ti to vrátím!",
                          "Wííí! Teda… GRR!", "Pomoc! Teda nepotřebuju pomoc. GRR!", "Tohle je porušení medojedích práv."]
    static let hurt = ["Au!", "Jau!", "To bolelo.", "Svět se točí…", "Vidím hvězdičky.", "Kdo dal tu zem tak nízko?",
                       "To bylo tvrdé přistání.", "Jsem v pořádku. Asi.", "Uff.", "Bum.", "Moje záda…", "To jsem chtěl. Jo."]
    static let windowGone = ["Hej!", "Kam zmizelo okno?", "Áá!", "Kdo mi zavřel podlahu?!", "Padáááám!", "To nebylo hezký!",
                             "Okno pryč, medojed letí!", "Příště mi to řekni!"]
    static let shakeOff = ["Wooo!", "Hej, opatrně!", "Zemětřesení!", "Áááá!", "To nebylo fér!", "Neřiď tak divoce!",
                           "Já tam seděl!", "Tohle byla horská dráha!", "Kdo tu třese s okny?!"]
    static let hunger = ["Mám hlad! 🍯", "Med! Hned!", "Kručí mi v břiše.", "Dáš mi med? Prosím. Teda HNED.",
                         "Umírám hlady. Doslova. Skoro.", "Jestli nedostanu med, začnu kousat.", "Med. Med. Med. Med.",
                         "Viděl jsi někde med? Já ne.", "Můj žaludek dělá zvuky jako Teams.", "Zmáčkni ⌘B, prosím.",
                         "Jsem tak hladový, že bych snědl i ikonu.", "Medový nouzový stav!"]
    static let eat = ["Mňam! Med!", "Mlask mlask.", "Díky!", "MOJE!", "Nejlepší med v mém životě!", "Mmmm…",
                      "To byl dobrej med.", "Ještě! Máš ještě?", "Tohle je štěstí.", "Med je život.", "Mlaskání povoleno."]
    static let stolen = ["To byl MŮJ med!", "Grrr, příště!", "Nefér!", "Ty zloději!", "Já byl první!", "Pomsta bude sladká.",
                         "Tohle si zapamatuju.", "Podělit se neumíš?"]
    static let honeySpotted = ["Med!!", "MOJE!", "Cítím med!", "Nikdo nesahat!", "Medová poplach!", "Jdu tam!"]
    static let sleepy = ["Jdu si zdřímnout.", "Jsem utahanej.", "Do nory!", "Dobrou.", "Zívám… jdu domů.",
                         "Potřebuju šlofíka.", "Baterka dochází.", "Jdu načerpat síly."]
    static let exitHome = ["Ahoj!", "Dobré ráno.", "Jsem zpátky!", "Co jsem zmeškal?", "Vyspalej do růžova!", "Kdo mě volal?",
                           "Tak, a jdeme zlobit.", "Svět! Zase ty.", "Doma dobře, venku líp."]
    static let homeClicked = ["To je moje nora!", "Nešahej mi na baráček.", "Doma je doma.", "Klepeš? Nikdo není doma.",
                              "Hezká, viď? Sám jsem ji vyhrabal.", "Nora je soukromý pozemek."]
    static let dig = ["Kopu, kopu…", "Tady něco bude!", "Hrabu si.", "Poklad!", "Hrabu tunel do Afriky.", "Hlína všude! Super.",
                      "Promiň za ten bordel.", "Tady to někdo zakopal. Já."]
    static let arrived = ["Tady jsem!", "Moje okno.", "Hotovo.", "Výhled jak z hory.", "Lezu po tvým okně!", "Dobyto!",
                          "Vlajka by se hodila.", "A je to.", "Odtud vidím všechno."]
    static let newWindow = ["Jé, nové okno!", "Tam chci!", "Počkej, jdu tam taky.", "Nová prolézačka!", "Tohle okno je moje!",
                            "Přepínáš rychleji, než stíhám lézt."]
    static let carryNote = ["Něco ti nesu!", "Pošta!", "Mám pro tebe vzkaz.", "Medojedí pošta jede!", "Doporučeně!"]
    static let delivered = ["Tady máš.", "Přečti si to!", "To je pro tebe.", "Pošta!", "Doručeno.", "Podepiš se tlapkou."]
    static let noteDismissed = ["Nechceš? Tak nic.", "Pfff.", "Příště ti donesu lepší.", "Ani sis to nepřečetl!",
                                "Tolik práce a ty to vyhodíš.", "Dobře, dobře."]
    static let cursor = ["Grrr!", "Kousnu!", "Co je?!", "Tohle je můj kurzor.", "*kous*", "Mám tě!", "Chycen!",
                         "Tohle šipkovitý zvíře mě štve.", "Pojď sem, ty šipko!", "Ha! Mám ho!", "Kurzor uloven.",
                         "Neutečeš mi.", "To bylo za to, že mi nedáváš med."]
    static let laser = ["Co to je?!", "Chytím to!", "Hýbe se to!", "Kurzor na útěku!", "Stůj!"]
    static let typing = ["Ty ale bušíš do klávesnice!", "Píšeš román?", "Klik klak klik klak…", "Tolik písmenek!",
                         "Nezapomeň dýchat.", "Klávesnice se kouří!", "Pomaleji, nestíhám číst.", "Píšeš mi dopis?"]
    static let back = ["Konečně jsi zpátky!", "Kde jsi byl tak dlouho?", "Stýskalo se nám. Trochu.", "Ahoj! Hlídali jsme ti plochu.",
                       "Nic jsme nerozbili. Skoro."]
    static let scared = ["Ááá!", "Lekl jsem se!", "Grr, to nebylo vtipný.", "Srdce mám až v krku!", "Ty jeden!"]

    // MARK: spolu

    static let fightStart = ["Jdu na tebe!", "Pojď se prát!", "Ha!", "Teď uvidíš!", "Přichází medojed!", "Bitva!"]
    static let win = ["Vyhrál jsem!", "Medojed jednička!", "Kdo je král?", "Hehe.", "Snadné.", "Ještě někdo?", "Šampion!"]
    static let lose = ["Příště…", "Jen jsem tě nechal.", "Au.", "Měl jsem v oku prach.", "Odveta!", "Tohle se nepočítá."]
    static let chase = ["Chytím tě!", "Na honěnou!", "Utíkej!", "Jsem rychlejší!", "Teď jsi na řadě ty!"]
    static let follow = ["Počkej na mě!", "Jdu s tebou.", "Kam jdeme?", "Za tebou!", "Já taky!"]
    static let greetA = ["Čau!", "Čuch čuch.", "Voníš medem.", "Kde ses flákal?", "Ahoj, kamaráde.", "Nazdar, chlupáči!",
                         "Co je nového?", "Neviděl jsi med?"]
    static let greetB = ["Ahoj.", "Čuch.", "Neotravuj.", "Jo, ahoj.", "Med nemám.", "Zase ty?", "Čau čau."]

    /// krátké rozhovory dvou medojedů (střídají se A, B, A…)
    static let dialogues: [[String]] = [
        ["Máš med?", "Nemám.", "A co tamten v noře?", "To je můj!"],
        ["Viděls ten kurzor?", "Jo. Podezřelej.", "Kousneme ho?", "Kousneme."],
        ["Proč lezeme po oknech?", "Protože můžeme."],
        ["Kdo je silnější?", "Já.", "Ne, já!", "…dáme si odvetu."],
        ["Slyšíš to?", "Co?", "Bzučení!", "To je počítač, ty troubo."],
        ["Mám nápad.", "Zase?", "Vyhrabeme tunel do Docku.", "Geniální."],
        ["Je tady vůbec nějaký med?", "Musíš si o něj říct.", "MÉÉÉD!"],
        ["Jsi můj nejlepší kamarád.", "Jsem tvůj jediný kamarád.", "To taky."],
        ["Dneska jsem kousl lva.", "Nekousl.", "Ve snu jo."],
        ["Pojď si hrát!", "Nechce se mi.", "Med dostane ten, kdo vyhraje!", "Jdu!"],
        ["Ten člověk zase pracuje.", "Chudák.", "Zazlobíme mu?", "Zazlobíme."],
        ["Kde je naše nora?", "Tam dole vlevo.", "Aha. Nějak jsem se ztratil."],
        ["Myslíš, že nás má rád?", "Určitě. Jsme roztomilí.", "Já jsem roztomilejší."],
        ["Nesahej mi na ocas!", "Nesahal jsem.", "Sahal!", "Možná trochu."],
        ["Co je to Teams?", "Něco, co pořád cinká.", "Zní to nebezpečně."],
        ["Jdeme na průzkum?", "Kam?", "Na to největší okno.", "Jdeme!"],
        ["Mám hlad.", "Já taky.", "Zkusíme se dívat smutně?", "*smutný pohled*"],
        ["Ty hrabeš díry do oken?", "Jo.", "Můžu taky?", "Ne. Teda jo."],
        ["Kolik je hodin?", "Čas na med.", "To je vždycky.", "Přesně."],
        ["Kdo snědl ten poslední med?", "Ne já.", "Máš ho na čumáku.", "…sakra."],
        ["Jsem unavenej.", "Jdi do nory.", "Ale tady je to zajímavý.", "Tak spi tady."],
        ["Pojď na schovku!", "Já tě stejně najdu.", "To uvidíme!"],
        ["Vypadám tlustě?", "Ne, jen chlupatě.", "Díky. Asi."],
        ["Hele, Dock!", "Co s ním?", "Vylezeme na něj!", "Jdu první!"],
        ["Ty máš krémovej hřbet.", "A ty stříbrnej.", "Jsme jak sůl a pepř.", "Spíš jak med a víc medu."],
        ["Bojíš se něčeho?", "Ničeho.", "Ani vysavače?", "…to se nepočítá."],
        ["Proč ten člověk pořád kouká do obrazovky?", "Asi tam hledá nás.", "Tak mu zamáváme!"],
        ["Kdybys mohl být jakékoli zvíře, co bys byl?", "Medojed.", "Já taky."],
    ]

    // MARK: „má u prdele“

    static let dontCare = [
        "Je mi to u prdele.", "Medojed má u prdele.", "Mně je to fuk.", "Mám to na háku.", "Kašlu na to.",
        "Pravidla? Neznám.", "Ty se zlobíš? Mně je to jedno.", "Nebojím se. Nikdy. Ničeho.", "Medojed si bere, co chce.",
        "Vidím med. Beru med.", "Když chci, tak chci.", "Ani nevím, co se stalo. A je mi to jedno.", "Vstanu a jdu dál.",
        "Bolest je jen pocit. Nemám pocity.", "Na co ses ptal? To je jedno.", "Nezajímá mě to. Vůbec.",
        "Jestli tě to štve, tak to je tvůj problém.", "Jsem medojed. Nevysvětluju se.", "Hodils mnou? Fajn. Jdu zpátky.",
        "Klidně si dělej, co chceš. Já taky.", "Kousla mě kobra? Pff.", "Mám hroší kůži. Teda medojedí.",
        "Nebudu to řešit.", "Zítra? Dneska? Jedno.", "Nejsem drzej, jsem upřímnej.",
    ]
    static let searchStick = ["Hledám klacek.", "Potřebuju větev.", "Kde je nějaký pořádný klacek?", "Medojed staví!",
                              "Na tohle potřebuju dřevo.", "Hned to bude.", "Postavím si žebřík. Sám."]
    static let foundStick = ["Tenhle ne. Tenhle taky ne. TENHLE!", "Mám ho!", "Krásná větev.", "Tohle bude stačit."]
    static let built = ["Hotovo! Inženýrský zázrak.", "Žebřík jak z IKEA.", "Postaveno. Teď nahoru!", "Kdo potřebuje schody?",
                        "Na to jsem pyšnej.", "Architekt medojed, těší mě."]
    static let propDestroyed = ["MOJE VĚTEV!!!", "Víš, jak dlouho jsem ji hledal?!", "Tos udělal schválně!",
                                "Grrrrr! To byla stavba století!", "Kdo mi hýbe s okny?!", "Celá práce v háji!",
                                "TY… TY VANDALE!", "Proč?! PROČ?!", "Nesahej mi na stavby!"]
    static let propDestroyed2 = ["Teď jsem fakt naštvanej.", "Tohle si zapamatuju. Navždycky.", "Já ti to vrátím.",
                                 "Kousnu tě. Jednou. Až to nebudeš čekat.", "Grrr. Grrrr. GRRRR.", "Dupu. Vidíš, jak dupu?"]
    static let rebuild = ["Fajn. Postavím novou. Větší.", "Myslíš, že to vzdám? Neznáš medojeda.", "Druhý pokus. Tentokrát se vztekem.",
                          "Zkus to znova a uvidíš.", "Medojed se nevzdává."]
    static let laugh = ["Hahaha! Spadla mu!", "Chachá!", "To byla stavba, co?", "Hehe, smůla.", "Já bych to postavil líp."]
    static let bees = ["Včely? U prdele.", "Žihadla jsou jen koření.", "Au. Au. Mňam.", "Bzzz? Neruš, jím.",
                       "Ať si koušou, med je můj.", "Včely mě štípou a já jím. Fér."]
    static let wakeUp = ["Kde to jsem? Aha. Med.", "Na chvíli jsem si zdřímnul. Jdu dál.", "Kobra? Jaká kobra?",
                         "Jsem zpátky. Kde je ten med?", "Nic se nestalo. Jdu dál."]

    // MARK: mládě

    static let baby = ["Mami!", "Tati, počkej!", "Já taky!", "Pííp!", "Kde je med?", "Jsem velkej medojed!", "Grr! (malinký)",
                       "Neseš mě?", "Já chci taky lézt!", "Proč? Proč? Proč?", "Už tam budem?", "Mám hlad. Zase.",
                       "Koukej, co umím!", "Ťap ťap!", "Až budu velkej, kousnu lva.", "Já se nebojím! Trochu."]
    static let protectBaby = ["Pusť mé mládě!", "Nesahej na malýho!", "GRRR! To je moje dítě!", "Polož ho. HNED.",
                              "Kdo sahá na mládě, ten kousnutej."]

    // MARK: tunely

    static let tunnelIn = ["Tudy to bude kratší.", "Jdu podzemím!", "Mizím!", "Hrabu tunel…", "Uvidíme se jinde.",
                           "Medojed metro, nastupovat!", "Tohle okno je měkký, prohrabu se."]
    static let tunnelOut = ["Ták! Jsem tady.", "Překvápko!", "Tunel funguje!", "Kde to jsem? Aha, dobrý.", "Ahoj zespodu!",
                            "Pfuj, hlína v uších.", "Zkratka jak hrom."]
    static let leap = ["Hop!", "Skok!", "Wííí!", "Žádný strach!", "Tohle zvládnu."]

    // jídlo, hovínka, zvratky
    static let poopSay = ["Pardon.", "To jsem nebyl já.", "Ups.", "Hotovo. Uff.", "Příroda volala.", "Nekoukej!"]
    static let poopReact = ["Fuj!", "Kdo to tu nechal?!", "To smrdí!", "Drápku!!", "Tohle uklízet nebudu.", "Hnus. Ale fascinující."]
    static let vomit = ["Bleeee…", "To byl asi zkažený.", "Ugh. Už je to venku.", "Moc rychle jsem jedl.", "Je mi blbě…"]
    static let vomitReact = ["Fuj, nechutný!", "Hahaha!", "Tohle uklízet nebudu.", "Snědl jsi moc, co?"]
    static let foodSpot = ["Jídlo!", "Strom s jablky!", "Žížala!", "Krtek!!", "Něco tam roste!", "Svačina!"]
    static let envy = ["Dej mi taky!", "To není fér, já chci taky!", "Mlsko jeden.", "A já?!", "Nech mi kousek!"]
    static let moleEscaped = ["Utekl mi!", "Zatracenej krtek!", "Příště tě dostanu!", "Byl rychlejší. Tentokrát."]
    static let wormEat = ["Křup.", "Žížala, mňam.", "Proteiny!", "Vrtěla se. Teď už ne."]
    static let cleaned = ["Díky za úklid.", "Uklízíš po nás? Hodnej.", "Čisto!"]
    static let eatApple = ["Jablko! Křup křup.", "Ovoce. Zdravý. Fuj. Ale dobrý.", "Mňam, jablíčko.", "Vitamíny!"]
    static let eatMole = ["Krtek, mňam.", "Chyceno a snědeno.", "Krteček… promiň.", "Podzemní svačinka!"]

    // život: stáří, nemoc, smrt, narození, návrat, nora
    static let oldAge = ["Au, záda.", "Za mých mladých let byla okna větší.", "Už nelezu tak rychle jako dřív.", "Kde jsem nechal brejle?", "Pamatuju, když tu byl ještě starej Finder.", "Hlavně klid. A med."]
    static let sick = ["Není mi dobře…", "Pšík. Asi jsem nemocnej.", "Trochu medu by mě spravilo.", "Pohlaď mě, prosím. Jsem nějakej slabej.", "Bolí mě bříško."]
    static let farewell = ["Bylo to krásný… díky za med.", "Tak já si jdu zdřímnout. Navždy.", "Postarej se o ně, jo?", "Medojed nemá strach. Ani teď."]
    static let mourn = ["Chybí mi…", "Byl to nejlepší kámoš.", "Nechám mu tu kytku.", "Ještě před chvílí tady lezl.", "Bez něj je to tu prázdný."]
    static let birth = ["Je tu malej! 🍼", "Vítej na světě, prcku!", "Podívej, novej medojed!", "Bude z něj pořádnej rošťák."]
    static let newborn = ["Ahoj světe!", "Kde to jsem?", "Co je to okno?", "Mám hlad! Asi.", "Jůů, myš!"]
    static let welcomeShort = ["Kde jsi byl?!", "Konečně! Už jsme mysleli, že ses ztratil.", "Zase ty. Dobře, tak jo.", "Chyběl jsi nám. Trochu. Nic moc."]
    static let welcomeLong = ["Celej den jsi tu nebyl! Máme hlad jak vlci.", "To bylo dlouhý! Kde je med?!", "Mysleli jsme, že nás opustíš. Dlužíš nám med.", "Už jsme si říkali, že si najdeme jiný počítač."]
    static let burrowUp = ["Nora je zase hezčí!", "Podívej, co jsme postavili!", "Naše nora roste!", "Tak tohle je bydlení."]
}
