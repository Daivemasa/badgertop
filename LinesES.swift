// Español (para quienes apoyan).

import Foundation

enum ES {
    static let idle = [
        "Al tejón de miel le da igual.", "¿Dónde está la miel?", "No le temo a nada.", "Grrr.", "Esta ventana ahora es mi madriguera.",
        "¿Cobra? Eso es el desayuno.", "¿Qué miras?", "Hago lo que quiero.", "¿Trabajando otra vez? Qué aburrido.", "Cavar, cavar, cavar…",
        "Aquí huele a miel.", "Tengo un plan. Incluye miel.", "Pequeño pero malo.", "¿Un león? Que tenga cuidado.",
        "Toda la pantalla es mi territorio.", "Tus ventanas son geniales para trepar.", "Me aburro. Eso es peligroso.",
        "No duermo, ahorro energía.", "El Dock es un buen parque de juegos.", "Ese cursor me molesta.",
        "Tú trabajas, yo superviso.", "Pienso en miel. Siempre.", "Aquí mando yo.", "¿Quién se comió mi miel? Ah, yo.",
        "Sitio perfecto para una siesta.", "Me voy a explorar.", "Psst. ¿Tienes miel?", "¡Kung-fu de tejón! ¡Hiyaa!",
        "No estoy gordo, estoy esponjoso.", "Resuelvo problemas mordiendo.", "La calma antes de la tormenta. La tormenta soy yo.",
        "Tu escritorio es mi patio de recreo.", "¡Paso!", "¿Morder o no morder?", "Soy tu guardaespaldas.",
    ]
    static let appTemplates = ["¿Otra vez %@?", "%@… qué aburrido.", "¿Qué haces todo el día en %@?", "Descansa un poco de %@.",
                               "Yo cerraría %@.", "¿Muerdo %@?", "%@ está bien, pero yo soy mejor."]
    static let apps: [(String, [String])] = [
        ("teams", ["¿Otra reunión?", "Silencia el micro, te oigo desde aquí.", "Otra reunión que pudo ser un correo."]),
        ("outlook", ["¿Cuántos sin leer? No me lo digas.", "El correo puede esperar. La miel no."]),
        ("chrome", ["¿Cuántas pestañas? ¿Cien?", "Cierra algunas pestañas.", "¿Otra vez haciendo scroll?"]),
        ("safari", ["¿Cuántas pestañas?", "¿Otra vez haciendo scroll?"]),
        ("code", ["El error está en la línea 42. Siempre.", "¿Compilando? Hora del café.", "No es un bug, es una función."]),
        ("terminal", ["¡Terminal! Cosas de hacker.", "sudo dame-miel"]),
        ("spotify", ["¡Más alto!", "Estoy bailando. No se ve, pero bailo."]),
        ("excel", ["Hojas de cálculo… brr.", "SUMA(miel) = poca."]),
        ("claude", ["¿Preguntas a la IA? Pregunta a un tejón.", "Pídele un poema sobre la miel."]),
        ("chatgpt", ["¿Preguntas a la IA? Pregunta a un tejón."]),
        ("finder", ["¿Buscas algo? Yo busco miel.", "¡Cuántas carpetas!"]),
    ]
    static let morning = ["¡Buenos días! ¿Café?", "¿Tan temprano y ya trabajando?", "¿Desayuno? Miel."]
    static let lunch = ["¿Comemos?", "Tengo hambre. ¿Tú también?", "¡No olvides comer!"]
    static let afternoon = ["¿Bajón de la tarde? Toma miel.", "Ya casi terminas.", "¿Tercer café?"]
    static let evening = ["¿No deberías haber terminado ya?", "Las tardes son para descansar.", "Yo ya estaría en mi madriguera."]
    static let night = ["¿Despierto todavía?", "La noche es de los tejones.", "¡A dormir! ¡Ya!", "Mañana estarás cansado."]
    static let monday = ["Lunes… suerte.", "Nueva semana, nueva miel."]
    static let friday = ["¡Viernes! ¡Casi finde!", "¡Viernes por la tarde! Deja de trabajar."]
    static let weekend = ["¿Fin de semana y trabajas?", "¡Es fin de semana! Sal a la calle."]
    static let health = ["Bebe agua 💧", "¡Endereza la espalda!", "Estírate un poco.", "Mira por la ventana.", "Respira. Dentro… fuera.",
                         "Levántate y camina un poco.", "¡Parpadea! Se te secan los ojos."]
    static let notes = health + ["Un tejón ya lo habría hecho.", "Descanso. Ya.", "Lo estás haciendo genial.", "Miel > trabajo",
                                 "¿Has guardado?", "Responde ya ese correo.", "Hecho es mejor que perfecto."]
    static let facts = ["¿Sabías que el tejón de miel no le teme a los leones?", "Un tejón sobrevive a la mordida de una cobra. Siestita y sigue.",
                        "Los tejones saben abrir puertas.", "Guinness lo llama el animal más intrépido.", "¿Picaduras de abeja? Al tejón le dan igual."]
    static let pet = ["…bueno, puedes.", "Grr… ❤", "No se lo digas a nadie.", "¡Rasca la barriga!", "Mrrr.", "¡Ahí! ¡Justo ahí!", "¡Jeje, cosquillas!", "Eres buena persona."]
    static let woken = ["¡¿Qué?!", "Durmiendo…", "¡Déjame dormir!", "Cinco minutitos más…"]
    static let dragged = ["¡BÁJAME!", "¡Muerdo!", "¡Grrrr!", "¡Las manos quietas!", "¡Secuestro!", "¡A los tejones no se les lleva!"]
    static let hurt = ["¡Ay!", "¡Auch!", "Eso dolió.", "El mundo da vueltas…", "Veo estrellitas."]
    static let windowGone = ["¡Eh!", "¿Dónde está la ventana?", "¿Quién cerró mi suelo?"]
    static let shakeOff = ["¡Uuuh!", "¡Eh, cuidado!", "¡Terremoto!", "¡Eso no es justo!"]
    static let hunger = ["¡Tengo hambre! 🍯", "¡Miel! ¡Ya!", "Me ruge la tripa.", "Pulsa ⌘B, por favor."]
    static let eat = ["¡Rico! ¡Miel!", "Ñam ñam.", "¡Gracias!", "¡MÍO!", "¡Más! ¿Tienes más?"]
    static let stolen = ["¡Esa era MI miel!", "¡Grrr, la próxima!", "¡No es justo!", "¡Ladrón!"]
    static let honeySpotted = ["¡¡Miel!!", "¡MÍA!", "¡Huelo miel!"]
    static let sleepy = ["Me voy a echar una siesta.", "Estoy cansado.", "¡A la madriguera!"]
    static let exitHome = ["¡Hola!", "Buenos días.", "¡He vuelto!", "¿Qué me he perdido?"]
    static let homeClicked = ["¡Es mi madriguera!", "Fuera de mi casa.", "La cavé yo mismo."]
    static let dig = ["Cavo, cavo…", "¡Aquí hay algo!", "¡Tesoro!", "Perdón por el desorden."]
    static let arrived = ["¡Aquí estoy!", "Mi ventana.", "Qué vistas.", "¡Conquistado!"]
    static let newWindow = ["¡Una ventana nueva!", "¡Quiero ir ahí!", "Espera, yo también voy."]
    static let carryNote = ["¡Te traigo algo!", "¡Correo!", "Tengo un mensaje para ti."]
    static let delivered = ["Aquí tienes.", "¡Léelo!", "Entregado."]
    static let noteDismissed = ["¿No lo quieres? Vale.", "Pfff.", "¡Ni lo has leído!"]
    static let cursor = ["¡Grrr!", "¡Muerdo!", "¡¿Qué?!", "Ese es mi cursor.", "*ñac*", "¡Te pillé!"]
    static let laser = ["¡¿Qué es eso?!", "¡Lo atrapo!", "¡Se mueve!"]
    static let typing = ["¡Cómo le das al teclado!", "¿Escribes una novela?", "Clac clac clac…"]
    static let back = ["¡Por fin has vuelto!", "¿Dónde estabas tanto tiempo?", "Te hemos cuidado el escritorio."]
    static let scared = ["¡Aaah!", "¡Me has asustado!", "Grr, no tiene gracia."]
    static let fightStart = ["¡Allá voy!", "¡A pelear!", "¡Ja!"]
    static let win = ["¡Gané!", "¡Tejón número uno!", "¿Quién es el rey?"]
    static let lose = ["La próxima…", "Te dejé ganar.", "¡Revancha!"]
    static let chase = ["¡Te atrapo!", "¡Tú la llevas!", "¡Corre!"]
    static let follow = ["¡Espérame!", "Voy contigo.", "¿Adónde vamos?"]
    static let greetA = ["¡Ey!", "Snif snif.", "Hueles a miel.", "¿Dónde estabas?"]
    static let greetB = ["Hola.", "Snif.", "Déjame.", "No tengo miel."]
    static let dialogues: [[String]] = [
        ["¿Tienes miel?", "No.", "¿Y la de la madriguera?", "¡Esa es mía!"],
        ["¿Por qué trepamos ventanas?", "Porque podemos."],
        ["Eres mi mejor amigo.", "Soy tu único amigo.", "Eso también."],
        ["¿Quién se comió la última miel?", "Yo no.", "La tienes en la nariz.", "…vaya."],
        ["El humano trabaja otra vez.", "Pobrecito.", "¿Lo molestamos?", "Claro."],
    ]
    static let dontCare = ["Al tejón de miel le da igual.", "Me da igual.", "¿Reglas? Ni idea.", "No le temo a nada. Nunca.",
                           "Veo miel. Tomo miel.", "Me levanto y sigo.", "No es mi problema."]
    static let searchStick = ["Busco un palo.", "Necesito una rama.", "¡El tejón construye!"]
    static let foundStick = ["Este no. Este tampoco. ¡ESTE!", "¡Lo tengo!"]
    static let built = ["¡Listo! Una maravilla.", "Escalera como de IKEA.", "Construido. ¡Arriba!"]
    static let propDestroyed = ["¡¡¡MI RAMA!!!", "¿Sabes cuánto tardé en encontrarla?", "¡Lo has hecho a propósito!", "¿Quién mueve mis ventanas?"]
    static let propDestroyed2 = ["Ahora sí estoy enfadado.", "Esto no lo olvido. Nunca.", "Grrr. GRRRR."]
    static let rebuild = ["Vale. Construiré otra. Más grande.", "El tejón nunca se rinde."]
    static let laugh = ["¡Jajaja! ¡Se cayó!", "Mala suerte.", "Yo la habría hecho mejor."]
    static let bees = ["¿Abejas? Me da igual.", "Las picaduras son condimento.", "Ay. Ay. Rico."]
    static let wakeUp = ["¿Dónde estoy? Ah. Miel.", "Una siestita. Sigo.", "¿Cobra? ¿Qué cobra?"]
    static let baby = ["¡Mamá!", "¡Papá, espera!", "¡Yo también!", "¡Pío!", "¿Dónde está la miel?", "¡Soy un tejón grande!", "¿Ya llegamos?"]
    static let protectBaby = ["¡Suelta a mi cría!", "¡No toques al pequeño!", "¡GRRR! ¡Es mi hijo!"]
    static let tunnelIn = ["Por aquí es más corto.", "¡Bajo tierra!", "¡Desaparezco!"]
    static let tunnelOut = ["¡Tachán! Aquí estoy.", "¡Sorpresa!", "¡El túnel funciona!"]
    static let leap = ["¡Hop!", "¡Salto!", "¡Yuju!"]

    // jídlo, hovínka, zvratky
    static let poopSay = ["Perdón.", "No fui yo.", "Ups.", "Listo. Uf."]
    static let poopReact = ["¡Puaj!", "¿Quién dejó esto aquí?", "¡Qué peste!", "Yo no lo limpio."]
    static let vomit = ["Bleeeh…", "Eso estaba malo.", "Comí demasiado rápido."]
    static let vomitReact = ["¡Puaj, qué asco!", "¡Jajaja!", "Comiste demasiado, ¿eh?"]
    static let foodSpot = ["¡Comida!", "¡Un manzano!", "¡Un gusano!", "¡¡Un topo!!"]
    static let envy = ["¡Dame un poco!", "¡No es justo, yo también quiero!", "¿Y yo qué?"]
    static let moleEscaped = ["¡Se escapó!", "¡Maldito topo!", "¡La próxima vez!"]
    static let wormEat = ["Crunch.", "Gusano, rico.", "¡Proteínas!"]
    static let cleaned = ["Gracias por limpiar.", "¡Limpio!"]
    static let eatApple = ["¡Una manzana! Crunch.", "Rica manzana.", "¡Vitaminas!"]
    static let eatMole = ["Topo, rico.", "Atrapado y comido.", "¡Merienda subterránea!"]

    static let oldAge = ["Ay, mi espalda.", "En mis tiempos las ventanas eran más grandes.", "Ya no trepo tan rápido.", "¿Dónde dejé mis gafas?"]
    static let sick = ["No me encuentro bien…", "Achís. Estoy enfermo.", "Un poco de miel me curaría.", "Acaríciame, porfa. Estoy débil."]
    static let farewell = ["Fue bonito… gracias por la miel.", "Me voy a echar una siesta. Larga.", "Cuida de ellos, ¿vale?"]
    static let mourn = ["Lo echo de menos…", "Era el mejor amigo.", "Le dejo una flor.", "Sin él está vacío."]
    static let birth = ["¡Hay un pequeñín! 🍼", "¡Bienvenido al mundo!", "¡Mira, un tejón nuevo!"]
    static let newborn = ["¡Hola mundo!", "¿Dónde estoy?", "¿Qué es una ventana?", "¡Uh, un ratón!"]
    static let welcomeShort = ["¡¿Dónde estabas?!", "¡Por fin! Creíamos que te habías perdido.", "Tú otra vez. Vale."]
    static let welcomeLong = ["¡Todo el día fuera! Nos morimos de hambre.", "¡Qué largo! ¿Dónde está la miel?", "Nos debes miel."]
    static let burrowUp = ["¡La madriguera está más bonita!", "¡Mira lo que construimos!", "¡Nuestra madriguera crece!"]
}
