// English lines (default language).

import Foundation

enum EN {
    static let idle = [
        "Honey badger doesn't care.", "Where's the honey?", "I fear nothing.", "Grrr.", "This window is my burrow now.",
        "Cobra? That's breakfast.", "What are you looking at?", "I do what I want.", "Working again? Boring.", "Dig, dig, dig…",
        "Smells like honey here.", "Who's sitting on my window?", "I have a plan. It involves honey.", "Haven't bitten anyone today. Yet.",
        "Small but mean.", "A lion? He'd better watch out.", "This is my territory. The whole screen.", "Pixels taste good.",
        "I know you're hiding honey somewhere.", "Your windows are great for climbing.", "Hmm… I could dig a hole here.",
        "I'm bored. That's dangerous.", "I feel like someone's watching me. You.", "I'm not sleeping, I'm saving energy.",
        "A honey badger never loses. Sometimes it just doesn't win.", "They won't let me into the menu bar. Discrimination.",
        "The Dock is a nice jungle gym.", "That cursor annoys me.", "One day I'll own a whole beehive.", "Bravest animal in the world. Look it up.",
        "Whatever you're doing, do it with more enthusiasm.", "You look like you need a honey badger. Lucky you.", "I climb, therefore I am.",
        "Claws sharpened. Let's go.", "That window looks interesting.", "I plan to misbehave. Later.", "Silver back is in fashion this year.",
        "Who has the nicest fur? Me.", "Tap tap tap.", "Sniff sniff… something's here.", "I can smell bees somewhere.",
        "Why are all your windows so tall?", "I'd bite you, but I like you.", "Digging is a lifestyle.", "I just live here.",
        "You work, I'll supervise.", "If work were honey, you'd be done by now.", "Don't disturb, I'm thinking.", "Thinking about honey. Always.",
        "My burrow is nicer than your office.", "Lovely day for causing trouble.", "I yawn because I can.", "This is mine.",
        "I'm the boss here.", "Nobody tells me what to do. Not even you.", "I think I hear buzzing.", "Who ate my honey? Oh. Me.",
        "I like heights. And honey. And heights with honey.", "Perfect spot for a nap.", "Going exploring.", "Mapping the terrain.",
        "Relax, I'm a professional.", "When's the break?", "Try smiling. There you go.", "Today is honey day. Like every day.",
        "Brr brr. That wasn't an engine, that was my stomach.", "I'm here for moral support.", "Don't worry, I'm guarding your desktop.",
        "All quiet on the desktop. Mostly.", "Psst. Got honey?", "Honey badger kung fu! Hiyaa!", "I could do this blindfolded.",
        "You're a bit of a honey badger too, aren't you?", "Want to know a secret? No. It's mine.", "I'm your new coworker. I do nothing.",
        "I'd love to help, but I have paws.", "Climb, climb, climb…", "One more window, then a break.", "I can see everything from up here.",
        "I'm not fat, I'm fluffy.", "I'll start exercising tomorrow.", "If I were bigger, I'd eat your Dock.", "I know where your Trash is. Don't worry.",
        "My dream: a desktop made of honey.", "So, how's it going?", "Working hard? Hardly working.", "I solve problems by biting them.",
        "Calm before the storm. I'm the storm.", "Someone has to make a mess here.", "I'm not mean, I have a strong personality.",
        "Your desktop is my playground.", "Coming through!", "To bite or not to bite.", "In the wild I'd climb trees. Here I climb Outlook.",
        "Sometimes I wonder why I'm not a cat. Then I remember I'm better.", "I'm your bodyguard.", "No fear, the honey badger is here.",
        "Hm. Hmm. Hmmm.", "This place needs more holes.", "Checking that your screen isn't falling. It's fine.",
    ]

    static let appTemplates = [
        "%@ again?", "%@… boring.", "What are you doing in %@ all day?", "Take a break from %@.", "I'd close %@.",
        "%@? Nothing there, I checked.", "How long have you been in %@?", "I don't think %@ likes you.",
        "%@ could use a honey badger.", "%@ is fine, but I'm better.", "If I had fingers, I'd click in %@ too.",
        "A bit more %@ and then we go outside, ok?", "Still %@. Still.", "Should I try biting %@?",
        "I saw what you did in %@. I won't tell.", "Who invented %@? I want a word with them.",
    ]

    static let apps: [(String, [String])] = [
        ("teams", ["Another meeting?", "Mute your mic, I can hear you from here.", "Teams wants something again.", "Camera's on? Wave!",
                   "Another meeting that could've been an email.", "Set your status to 'Honey badger – do not disturb'."]),
        ("outlook", ["How many unread? Don't tell me.", "Email can wait. Honey can't.", "Inbox zero? Fairy tale.", "Delete it. All of it.",
                     "Will you finally answer that email?", "Another newsletter. Grr."]),
        ("mail", ["Mail! Anything for me?", "Spam, spam, spam.", "Email can wait. Honey can't."]),
        ("slack", ["Slack is blinking. Again.", "Mute those channels.", "Someone tagged you. Probably for nothing."]),
        ("chrome", ["How many tabs? A hundred?", "Close some tabs, I can't breathe.", "Scrolling again?", "Chrome eats RAM. I eat honey."]),
        ("safari", ["How many tabs, Safari?", "Looking up honey recipes?", "Scrolling again?"]),
        ("firefox", ["A fox? Where? I'll bite it.", "Scrolling again?"]),
        ("code", ["The bug is on line 42. Always.", "Compiling? Coffee time.", "Have you tried turning it off and on again?",
                  "Commit before you break it.", "It's not a bug, it's a feature.", "Works on my machine, says every programmer."]),
        ("xcode", ["Xcode is indexing again?", "Build failed? Bite it.", "Swift is fast. So am I."]),
        ("terminal", ["Terminal! Hacker stuff.", "sudo give-me-honey", "Please don't type rm -rf."]),
        ("iterm", ["Terminal! Hacker stuff.", "sudo give-me-honey"]),
        ("spotify", ["Play something to walk to!", "Louder!", "I'm dancing. You can't see it, but I'm dancing."]),
        ("music", ["Play something to walk to!", "Louder!"]),
        ("excel", ["Spreadsheets… brr.", "How many more cells?", "SUM(honey) = not enough."]),
        ("word", ["Writing a novel? Am I in it?", "One more paragraph!", "There's a typo somewhere. Definitely."]),
        ("powerpoint", ["Next slide!", "Add a honey badger, it'll be a better presentation.", "Too much text on that slide."]),
        ("keynote", ["Next slide!", "Add a honey badger, it'll be a better presentation."]),
        ("zoom", ["Wave at the camera!", "Is your mic on?", "Who's that? Can I bite them?"]),
        ("claude", ["Asking AI? Ask a honey badger.", "Tell it to write a poem about honey.", "Artificial intelligence, natural badger."]),
        ("chatgpt", ["Asking AI? Ask a honey badger.", "Tell it to write a poem about honey."]),
        ("finder", ["Looking for something? I'm looking for honey.", "So many folders!", "Clean up your desktop. I live here, but still."]),
        ("calendar", ["How many meetings today? Too many.", "Schedule a break. With me."]),
        ("messages", ["Who are you texting?", "Say hi from me!", "Send them a honey badger photo."]),
        ("whatsapp", ["Who are you texting?", "Send them a honey badger photo."]),
        ("notes", ["Note to self: buy honey.", "Idea: more honey."]),
        ("figma", ["Nice! But it's missing a honey badger.", "Move it one pixel left. No, right.", "I'm made of pixels too!"]),
        ("settings", ["Breaking something?", "Don't change my stuff."]),
    ]

    static let morning = ["Good morning! Coffee?", "So early and already working?", "I'm not awake yet.", "Breakfast? Honey.", "Why is it so early?"]
    static let lunch = ["Lunch?", "I'm hungry. You too?", "Food time!", "Don't forget to eat!", "Lunch break is sacred."]
    static let afternoon = ["Afternoon slump? Have some honey.", "Almost done for the day.", "Coffee number three?", "The afternoon drags on."]
    static let evening = ["Shouldn't you be done by now?", "Evenings are for resting.", "Close that and go relax.", "I'd be in my burrow by now."]
    static let night = ["Up late?", "I'd be in my burrow by now.", "Night is for honey badgers, not people.", "You'll be tired tomorrow.",
                        "Sleep! Now!", "What are you doing up so late?", "Your bed is calling. I can hear it."]
    static let monday = ["Monday… good luck.", "Monday is the worst day. Right after Tuesday.", "New week, new honey."]
    static let friday = ["Friday! Almost weekend!", "Friday afternoon! Stop working.", "Friday = honey day."]
    static let weekend = ["Weekend and you're working?", "It's the weekend! Go outside.", "No work on weekends. Honey badger law."]

    static let health = ["Drink some water 💧", "Straighten your back!", "Stretch a little.", "Look out the window.", "Rest your eyes.",
                         "Breathe. In… out.", "Blink. Your eyes are drying out.", "Get up and walk around.", "Roll your shoulders.",
                         "Drink! Water, not coffee.", "You're sitting like a shrimp."]
    static let notes = health + [
        "A honey badger would have done it already.", "Break. Now.", "You're doing great. Really.", "Don't forget to eat!", "Honey > work",
        "How about a walk?", "Did you save it?", "Answer that email already.", "Sit up straight 🦡", "Call your mom.",
        "You've got this.", "One thing at a time.", "Coffee isn't water.", "Tidy your desk. A little.", "Done is better than perfect.",
        "Close 5 tabs. You'll feel better.", "Mute notifications for an hour.", "Lunch at the desk doesn't count.", "Don't forget to back up.",
    ]

    static let facts = [
        "Did you know a honey badger isn't afraid of lions?", "A honey badger can survive a cobra bite. Takes a nap, moves on.",
        "Honey badgers can open gates. And close them again.", "A honey badger digs a burrow in minutes.",
        "Honey badger skin is so loose it can turn around inside it and bite you.", "Guinness lists the honey badger as the most fearless animal.",
        "Honey badgers team up with honeyguide birds. The bird finds the hive, I wreck it.", "A honey badger is basically a big angry weasel.",
        "Bee stings? Honey badgers don't care.", "Latin name: Mellivora capensis.", "Honey badgers have claws as long as your finger.",
        "Honey badgers can build ladders out of sticks. Really.", "Honey badgers live in Africa and Asia. And now on your desktop.",
    ]

    static let pet = ["…fine, you may.", "Grr… ❤", "Don't tell anyone.", "Belly rubs!", "Mrrr.", "Oh, alright.", "There! That's the spot!",
                      "I'm a tough honey badger. But this is nice.", "More. More. Ok, enough.", "With honey this would be perfect.",
                      "I like you. Tell anyone and I'll bite you.", "A bit more to the left.", "Better than honey. Almost.", "Hehe, that tickles!",
                      "I forgive you for not having honey.", "Paw? Here's a paw.", "You're a good human.", "Behind the ear!", "Honey badger approves."]
    static let woken = ["What?!", "Sleeping…", "Let me sleep!", "Who woke me?!", "Five more minutes…", "I was dreaming about honey! You ruined it."]
    static let dragged = ["PUT ME DOWN!", "I'll bite!", "Grrrr!", "You'll pay for this.", "Hands off!", "Where are you taking me?!",
                          "Kidnapping! Kidnapping!", "I can walk by myself!", "Honey badgers don't get carried!", "Wheee! I mean… GRR!"]
    static let hurt = ["Ouch!", "Ow!", "That hurt.", "The world is spinning…", "I see stars.", "Who put the ground so low?", "I'm fine. Probably.", "Oof."]
    static let windowGone = ["Hey!", "Where did the window go?", "Whoa!", "Who closed my floor?!", "Fallinggg!", "Warn me next time!"]
    static let shakeOff = ["Wooo!", "Hey, careful!", "Earthquake!", "Aaaah!", "That wasn't fair!", "Who's shaking the windows?!"]
    static let hunger = ["I'm hungry! 🍯", "Honey! Now!", "My stomach is growling.", "Could I have some honey? Please. I mean NOW.",
                         "Starving. Literally. Almost.", "No honey and I start biting.", "Honey. Honey. Honey.", "Press ⌘B, please."]
    static let eat = ["Yum! Honey!", "Munch munch.", "Thanks!", "MINE!", "Best honey of my life!", "Mmmm…", "More! Got more?", "Honey is life."]
    static let stolen = ["That was MY honey!", "Grrr, next time!", "Not fair!", "Thief!", "I was first!", "I'll remember this."]
    static let honeySpotted = ["Honey!!", "MINE!", "I smell honey!", "Nobody touch it!", "Honey alert!"]
    static let sleepy = ["Going for a nap.", "I'm tired.", "To the burrow!", "Good night.", "Battery low.", "Need a nap."]
    static let exitHome = ["Hi!", "Good morning.", "I'm back!", "What did I miss?", "Let's go cause trouble.", "Home is nice, outside is better."]
    static let homeClicked = ["That's my burrow!", "Hands off my house.", "Home sweet home.", "Knocking? Nobody's home.", "Dug it myself."]
    static let dig = ["Dig, dig…", "Something's here!", "Just digging.", "Treasure!", "Digging a tunnel to Africa.", "Sorry about the mess."]
    static let arrived = ["Here I am!", "My window.", "Done.", "What a view.", "Climbing your window!", "Conquered!", "I can see everything from here."]
    static let newWindow = ["Ooh, a new window!", "I want to go there!", "Wait, I'm coming too.", "New jungle gym!", "That window is mine!"]
    static let carryNote = ["I brought you something!", "Mail!", "I have a message for you.", "Honey badger post!"]
    static let delivered = ["Here you go.", "Read it!", "This is for you.", "Delivered.", "Sign here with your paw."]
    static let noteDismissed = ["Don't want it? Fine.", "Pfff.", "I'll bring a better one next time.", "You didn't even read it!"]
    static let cursor = ["Grrr!", "I'll bite!", "What?!", "That's my cursor.", "*bite*", "Got you!", "Caught it!", "Come here, you arrow!", "Cursor hunted."]
    static let laser = ["What is that?!", "I'll catch it!", "It's moving!", "Cursor on the run!", "Stop!"]
    static let typing = ["Wow, you're hammering that keyboard!", "Writing a novel?", "Clack clack clack…", "So many letters!",
                         "Don't forget to breathe.", "The keyboard is smoking!"]
    static let back = ["Finally you're back!", "Where were you so long?", "We missed you. A little.", "Hi! We guarded your desktop.",
                       "We didn't break anything. Mostly."]
    static let scared = ["Aaah!", "You scared me!", "Grr, that wasn't funny.", "My heart!"]

    static let fightStart = ["Here I come!", "Let's fight!", "Ha!", "You'll see!", "Honey badger incoming!"]
    static let win = ["I won!", "Honey badger number one!", "Who's the king?", "Hehe.", "Easy.", "Champion!"]
    static let lose = ["Next time…", "I let you win.", "Ow.", "I had dust in my eye.", "Rematch!", "That doesn't count."]
    static let chase = ["I'll catch you!", "Tag!", "Run!", "I'm faster!", "You're it!"]
    static let follow = ["Wait for me!", "I'm coming with you.", "Where are we going?", "Right behind you!"]
    static let greetA = ["Hey!", "Sniff sniff.", "You smell like honey.", "Where've you been?", "Hello, buddy.", "What's new?"]
    static let greetB = ["Hi.", "Sniff.", "Don't bother me.", "Yeah, hi.", "I have no honey.", "You again?"]

    static let dialogues: [[String]] = [
        ["Got honey?", "Nope.", "What about the one in the burrow?", "That's mine!"],
        ["Did you see that cursor?", "Yeah. Suspicious.", "Bite it?", "Bite it."],
        ["Why do we climb windows?", "Because we can."],
        ["Who's stronger?", "Me.", "No, me!", "…rematch later."],
        ["Hear that?", "What?", "Buzzing!", "That's the computer, dummy."],
        ["I have an idea.", "Again?", "Let's dig a tunnel to the Dock.", "Genius."],
        ["You're my best friend.", "I'm your only friend.", "That too."],
        ["I bit a lion today.", "No you didn't.", "In my dream I did."],
        ["The human is working again.", "Poor thing.", "Shall we annoy them?", "Let's."],
        ["I'm hungry.", "Me too.", "Let's look sad?", "*sad look*"],
        ["What time is it?", "Honey time.", "It always is.", "Exactly."],
        ["Who ate the last honey?", "Not me.", "It's on your nose.", "…darn."],
        ["Are you afraid of anything?", "Nothing.", "Not even the vacuum?", "…that doesn't count."],
        ["If you could be any animal, what would you be?", "Honey badger.", "Same."],
    ]

    static let dontCare = [
        "Honey badger doesn't care.", "I don't care.", "Whatever.", "Couldn't care less.", "Rules? Never heard of them.",
        "You're mad? I don't care.", "I fear nothing. Ever.", "Honey badger takes what it wants.", "See honey. Take honey.",
        "No idea what happened. Don't care.", "Get up, keep going.", "Pain is just a feeling. I don't have feelings.",
        "Not interested. At all.", "If it bugs you, that's your problem.", "I'm a honey badger. I don't explain myself.",
        "You threw me? Fine. I'm coming back.", "Cobra bit me? Pff.", "Not my problem.",
    ]
    static let searchStick = ["Looking for a stick.", "Need a branch.", "Where's a decent stick?", "Honey badger builds!", "I'll build a ladder myself."]
    static let foundStick = ["Not this one. Not that one. THIS ONE!", "Got it!", "Beautiful branch.", "This will do."]
    static let built = ["Done! An engineering marvel.", "Ladder like from IKEA.", "Built. Now up!", "Who needs stairs?", "Architect honey badger, nice to meet you."]
    static let propDestroyed = ["MY BRANCH!!!", "Do you know how long I looked for that?!", "You did that on purpose!",
                                "Grrrrr! That was the build of the century!", "Who's moving my windows?!", "All that work, gone!", "YOU… VANDAL!"]
    static let propDestroyed2 = ["Now I'm really angry.", "I'll remember this. Forever.", "I'll get you back.", "Grrr. Grrrr. GRRRR.", "I'm stomping. See me stomp?"]
    static let rebuild = ["Fine. I'll build a new one. Bigger.", "Think I'll give up? You don't know honey badgers.", "Second try. With rage this time.", "Honey badger never gives up."]
    static let laugh = ["Hahaha! It fell!", "Ha!", "Some build, huh?", "Hehe, tough luck.", "I'd have built it better."]
    static let bees = ["Bees? Don't care.", "Stings are just seasoning.", "Ow. Ow. Yum.", "Bzzz? Busy eating.", "Let them sting, the honey is mine."]
    static let wakeUp = ["Where am I? Oh. Honey.", "Took a little nap. Moving on.", "Cobra? What cobra?", "I'm back. Where's the honey?"]

    static let baby = ["Mom!", "Dad, wait!", "Me too!", "Squeak!", "Where's the honey?", "I'm a big honey badger!", "Grr! (tiny)",
                       "Carry me?", "I want to climb too!", "Why? Why? Why?", "Are we there yet?", "Hungry. Again.", "Look what I can do!"]
    static let protectBaby = ["Let go of my baby!", "Don't touch the little one!", "GRRR! That's my kid!", "Put him down. NOW."]
    static let tunnelIn = ["This way is shorter.", "Going underground!", "Vanishing!", "Digging a tunnel…", "See you elsewhere.", "Honey badger subway, all aboard!"]
    static let tunnelOut = ["Ta-da! Here I am.", "Surprise!", "The tunnel works!", "Where am I? Oh, good.", "Hello from below!", "Ugh, dirt in my ears."]
    static let leap = ["Hop!", "Jump!", "Wheee!", "No fear!", "I got this."]

    // jídlo, hovínka, zvratky
    static let poopSay = ["Pardon me.", "Wasn't me.", "Oops.", "Done. Phew.", "Nature called.", "Don't look!"]
    static let poopReact = ["Ew!", "Who left this here?!", "That stinks!", "Gross. But fascinating.", "I'm not cleaning that."]
    static let vomit = ["Bleeeh…", "That was probably off.", "Ugh. It's out.", "Ate too fast.", "I feel sick…"]
    static let vomitReact = ["Ew, disgusting!", "Hahaha!", "I'm not cleaning that.", "Ate too much, huh?"]
    static let foodSpot = ["Food!", "An apple tree!", "A worm!", "A mole!!", "Something's growing!", "Snack!"]
    static let envy = ["Give me some too!", "Not fair, I want some!", "You greedy thing.", "What about me?!", "Leave me a bite!"]
    static let moleEscaped = ["It got away!", "Darn mole!", "I'll get you next time!", "It was faster. This time."]
    static let wormEat = ["Crunch.", "Worm, yum.", "Protein!", "It wiggled. Not anymore."]
    static let cleaned = ["Thanks for cleaning.", "Cleaning up after us? Nice.", "Spotless!"]
    static let eatApple = ["An apple! Crunch crunch.", "Fruit. Healthy. Ew. But good.", "Yum, apple.", "Vitamins!"]
    static let eatMole = ["Mole, yum.", "Caught and eaten.", "Sorry, little mole…", "Underground snack!"]

    // life: old age, sickness, death, birth, return, burrow
    static let oldAge = ["Ow, my back.", "Back in my day, windows were bigger.", "I don't climb as fast as I used to.", "Where did I leave my glasses?", "I remember the old Finder.", "Peace and quiet. And honey."]
    static let sick = ["I don't feel so good…", "Achoo. I think I'm sick.", "A bit of honey would fix me.", "Pet me, please. I feel weak.", "My tummy hurts."]
    static let farewell = ["It was lovely… thanks for the honey.", "I'm going for a nap. A long one.", "Take care of them, okay?", "Honey badger don't fear. Not even now."]
    static let mourn = ["I miss him…", "He was the best buddy.", "I'll leave a flower here.", "He was climbing here just a moment ago.", "It's empty without him."]
    static let birth = ["There's a little one! 🍼", "Welcome to the world, kiddo!", "Look, a new badger!", "He's gonna be a proper troublemaker."]
    static let newborn = ["Hello world!", "Where am I?", "What's a window?", "I'm hungry! I think.", "Ooh, a mouse!"]
    static let welcomeShort = ["Where were you?!", "Finally! We thought you got lost.", "You again. Fine, okay.", "We missed you. A bit. Not much."]
    static let welcomeLong = ["You were gone all day! We're starving.", "That was long! Where's the honey?!", "We thought you left us. You owe us honey.", "We were about to find another computer."]
    static let burrowUp = ["The burrow got nicer!", "Look what we built!", "Our burrow is growing!", "Now that's living."]
}
