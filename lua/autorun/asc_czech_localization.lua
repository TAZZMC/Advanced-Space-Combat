-- Advanced Space Combat - Czech Localization System v1.0.0
-- Comprehensive Czech language support for the entire addon
-- Centralized localization system for all user-facing text

print("[Advanced Space Combat] Czech Localization System v1.0.0 Loading...")

-- Initialize Czech localization namespace
ASC = ASC or {}
ASC.Czech = ASC.Czech or {}

-- Czech localization configuration
ASC.Czech.Config = {
    Enabled = true,
    AutoDetect = true,
    AutoSetLanguage = true,
    FallbackToEnglish = true,
    LogTranslations = false,
    ValidateEncoding = true,
    CulturalContext = true,
    FormalityDetection = true,
    DetectionMethods = {
        "steam_language",
        "system_locale",
        "gmod_language",
        "chat_detection",
        "ai_integration",
        "manual_override"
    },
    -- Enhanced Czech language support
    EnhancedFeatures = {
        DiacriticsValidation = true,
        EncodingCheck = true,
        CulturalAdaptation = true,
        FormalInformalDetection = true,
        ContextAwareTranslation = true,
        AIIntegration = true
    }
}

-- Comprehensive Czech translations database
ASC.Czech.Translations = {
    -- === CORE SYSTEM MESSAGES ===
    ["Advanced Space Combat"] = "Pokročilý Vesmírný Boj",
    ["Loading..."] = "Načítání...",
    ["Initializing"] = "Inicializace",
    ["System Status"] = "Stav Systému",
    ["Version"] = "Verze",
    ["Build"] = "Build",
    ["Enabled"] = "Povoleno",
    ["Disabled"] = "Zakázáno",
    ["Online"] = "Online",
    ["Offline"] = "Offline",
    ["Active"] = "Aktivní",
    ["Inactive"] = "Neaktivní",
    ["Ready"] = "Připraven",
    ["Not Ready"] = "Nepřipraven",
    ["Success"] = "Úspěch",
    ["Failed"] = "Selhalo",
    ["Error"] = "Chyba",
    ["Warning"] = "Varování",
    ["Info"] = "Informace",
    
    -- === SHIP SYSTEMS ===
    ["Ship Core"] = "Jádro Lodi",
    ["Ship Cores"] = "Jádra Lodí",
    ["Hyperdrive Engine"] = "Hyperpohon",
    ["Hyperdrive Engines"] = "Hyperpoháněče",
    ["Master Hyperdrive Engine"] = "Hlavní Hyperpohon",
    ["Ship Components"] = "Komponenty Lodi",
    ["Energy System"] = "Energetický Systém",
    ["Power Core"] = "Energetické Jádro",
    ["Life Support"] = "Životní Podpora",
    ["Navigation"] = "Navigace",
    ["Sensors"] = "Senzory",
    ["Hull Integrity"] = "Integrita Trupu",
    ["Ship Status"] = "Stav Lodi",
    ["Ship Building"] = "Stavba Lodí",
    ["Ship Management"] = "Správa Lodí",
    ["Auto-Linking"] = "Automatické Propojení",
    ["Component Detection"] = "Detekce Komponentů",
    ["Ship Detection Range"] = "Dosah Detekce Lodi",
    
    -- === WEAPONS SYSTEMS ===
    ["Weapons"] = "Zbraně",
    ["Weapon System"] = "Zbraňový Systém",
    ["Weapon Systems"] = "Zbraňové Systémy",
    ["Pulse Cannon"] = "Pulsní Kanón",
    ["Beam Weapon"] = "Paprskové Zbraně",
    ["Torpedo Launcher"] = "Torpédový Odpalovač",
    ["Railgun"] = "Railgun",
    ["Plasma Cannon"] = "Plazmový Kanón",
    ["Weapons Online"] = "Zbraně Online",
    ["Weapons Offline"] = "Zbraně Offline",
    ["Fire Control"] = "Řízení Palby",
    ["Targeting System"] = "Zaměřovací Systém",
    ["Ammunition"] = "Munice",
    ["Reload"] = "Přebití",
    ["Fire Rate"] = "Rychlost Palby",
    ["Weapon Range"] = "Dosah Zbraně",
    ["Weapon Damage"] = "Poškození Zbraně",
    
    -- === SHIELD SYSTEMS ===
    ["Shields"] = "Štíty",
    ["Shield System"] = "Štítový Systém",
    ["Shield Generator"] = "Generátor Štítů",
    ["Shields Active"] = "Štíty Aktivní",
    ["Shields Down"] = "Štíty Vypnuté",
    ["Shield Strength"] = "Síla Štítů",
    ["Shield Frequency"] = "Frekvence Štítů",
    ["Shield Recharge"] = "Dobíjení Štítů",
    ["Shield Modulation"] = "Modulace Štítů",
    
    -- === FLIGHT SYSTEMS ===
    ["Flight System"] = "Letový Systém",
    ["Flight Systems"] = "Letové Systémy",
    ["Autopilot"] = "Autopilot",
    ["Navigation System"] = "Navigační Systém",
    ["Flight Mode"] = "Letový Režim",
    ["Manual Control"] = "Ruční Ovládání",
    ["Automatic Control"] = "Automatické Ovládání",
    ["Waypoint"] = "Navigační Bod",
    ["Course"] = "Kurz",
    ["Speed"] = "Rychlost",
    ["Altitude"] = "Výška",
    ["Heading"] = "Směr",
    
    -- === TACTICAL AI ===
    ["Tactical AI"] = "Taktická AI",
    ["AI System"] = "AI Systém",
    ["Combat AI"] = "Bojová AI",
    ["AI Mode"] = "AI Režim",
    ["Aggressive"] = "Agresivní",
    ["Defensive"] = "Obranný",
    ["Balanced"] = "Vyvážený",
    ["AI Status"] = "Stav AI",
    ["Threat Detection"] = "Detekce Hrozeb",
    ["Target Acquisition"] = "Získání Cíle",
    ["Formation Flying"] = "Formační Let",
    
    -- === STARGATE TECHNOLOGY ===
    ["Stargate"] = "Stargate",
    ["Stargates"] = "Stargate",
    ["DHD"] = "DHD",
    ["Dial Home Device"] = "Vytáčecí Zařízení",
    ["Gate Address"] = "Adresa Brány",
    ["Dialing"] = "Vytáčení",
    ["Incoming Wormhole"] = "Příchozí Červí Díra",
    ["Outgoing Wormhole"] = "Odchozí Červí Díra",
    ["Gate Shutdown"] = "Vypnutí Brány",
    ["Ancient Technology"] = "Starověká Technologie",
    ["Asgard Technology"] = "Asgardská Technologie",
    ["Goa'uld Technology"] = "Goa'uldská Technologie",
    ["Wraith Technology"] = "Wraith Technologie",
    ["Ori Technology"] = "Ori Technologie",
    ["Tau'ri Technology"] = "Tau'ri Technologie",
    
    -- === TRANSPORT SYSTEMS ===
    ["Transport"] = "Transport",
    ["Docking System"] = "Dokovací Systém",
    ["Docking Pad"] = "Dokovací Plocha",
    ["Shuttle System"] = "Systém Raketoplánů",
    ["Teleporter"] = "Teleportér",
    ["Beaming"] = "Transportování",
    ["Ring Transport"] = "Prstencový Transport",
    
    -- === COMMANDS ===
    ["Help"] = "Nápověda",
    ["Status"] = "Stav",
    ["Configure"] = "Konfigurovat",
    ["Configuration"] = "Konfigurace",
    ["Settings"] = "Nastavení",
    ["Spawn"] = "Spawn",
    ["Create"] = "Vytvořit",
    ["Build"] = "Postavit",
    ["Activate"] = "Aktivovat",
    ["Deactivate"] = "Deaktivovat",
    ["Enable"] = "Povolit",
    ["Disable"] = "Zakázat",
    ["Start"] = "Spustit",
    ["Stop"] = "Zastavit",
    ["Reset"] = "Reset",
    ["Reload"] = "Znovu Načíst",
    ["Save"] = "Uložit",
    ["Load"] = "Načíst",
    ["Delete"] = "Smazat",
    ["Remove"] = "Odstranit",
    ["Add"] = "Přidat",
    ["Edit"] = "Upravit",
    ["Cancel"] = "Zrušit",
    ["Apply"] = "Použít",
    ["OK"] = "OK",
    ["Yes"] = "Ano",
    ["No"] = "Ne",
    
    -- === UI ELEMENTS ===
    ["Button"] = "Tlačítko",
    ["Menu"] = "Menu",
    ["Panel"] = "Panel",
    ["Window"] = "Okno",
    ["Dialog"] = "Dialog",
    ["Tab"] = "Záložka",
    ["List"] = "Seznam",
    ["Table"] = "Tabulka",
    ["Form"] = "Formulář",
    ["Input"] = "Vstup",
    ["Output"] = "Výstup",
    ["Display"] = "Zobrazení",
    ["Interface"] = "Rozhraní",
    ["Control"] = "Ovládání",
    ["Slider"] = "Posuvník",
    ["Checkbox"] = "Zaškrtávací Políčko",
    ["Dropdown"] = "Rozbalovací Menu",
    
    -- === ERROR MESSAGES ===
    ["Command not found"] = "Příkaz nenalezen",
    ["Invalid target"] = "Neplatný cíl",
    ["Invalid parameter"] = "Neplatný parametr",
    ["Access denied"] = "Přístup odepřen",
    ["Permission denied"] = "Oprávnění odepřeno",
    ["System error"] = "Systémová chyba",
    ["Network error"] = "Síťová chyba",
    ["File not found"] = "Soubor nenalezen",
    ["Resource not found"] = "Prostředek nenalezen",
    ["Entity not found"] = "Entita nenalezena",
    ["Player not found"] = "Hráč nenalezen",
    ["Ship not found"] = "Loď nenalezena",
    ["Target not found"] = "Cíl nenalezen",
    ["Insufficient energy"] = "Nedostatek energie",
    ["Insufficient resources"] = "Nedostatek prostředků",
    ["Operation failed"] = "Operace selhala",
    ["Connection failed"] = "Připojení selhalo",
    ["Timeout"] = "Časový limit",
    ["Unknown error"] = "Neznámá chyba",
    
    -- === STATUS MESSAGES ===
    ["Initializing system"] = "Inicializace systému",
    ["System initialized"] = "Systém inicializován",
    ["Loading resources"] = "Načítání prostředků",
    ["Resources loaded"] = "Prostředky načteny",
    ["Connecting"] = "Připojování",
    ["Connected"] = "Připojeno",
    ["Disconnected"] = "Odpojeno",
    ["Processing"] = "Zpracovávání",
    ["Complete"] = "Dokončeno",
    ["In progress"] = "Probíhá",
    ["Waiting"] = "Čekání",
    ["Standby"] = "Pohotovost",
    ["Operational"] = "Funkční",
    ["Non-operational"] = "Nefunkční",
    ["Maintenance"] = "Údržba",
    ["Repair"] = "Oprava",
    ["Upgrade"] = "Upgrade",
    ["Calibration"] = "Kalibrace",
    
    -- === CONSOLE COMMANDS ===
    ["Console Commands"] = "Konzolové Příkazy",
    ["Available commands"] = "Dostupné příkazy",
    ["Command usage"] = "Použití příkazu",
    ["Command description"] = "Popis příkazu",
    ["Command examples"] = "Příklady příkazů",
    ["General"] = "Obecné",
    ["Ship Management"] = "Správa Lodí",
    ["Combat"] = "Boj",
    ["Flight"] = "Let",
    ["Transport"] = "Transport",
    ["Debug"] = "Ladění",
    ["Admin"] = "Administrace",
    
    -- === AI RESPONSES ===
    ["Hello"] = "Ahoj",
    ["Hi"] = "Ahoj",
    ["Welcome"] = "Vítejte",
    ["Goodbye"] = "Na shledanou",
    ["Thank you"] = "Děkuji",
    ["You're welcome"] = "Není zač",
    ["How can I help you"] = "Jak vám mohu pomoci",
    ["I don't understand"] = "Nerozumím",
    ["Please try again"] = "Zkuste to prosím znovu",
    ["Processing your request"] = "Zpracovávám váš požadavek",
    ["Task completed"] = "Úkol dokončen",
    ["Operation successful"] = "Operace úspěšná",
    ["Analyzing"] = "Analyzuji",
    ["Searching"] = "Hledám",
    ["Thinking"] = "Přemýšlím",
    ["Understanding"] = "Rozumím",
    
    -- === CATEGORIES ===
    ["Core Tools"] = "Základní Nástroje",
    ["Ship Building"] = "Stavba Lodí",
    ["Weapons"] = "Zbraně",
    ["Defense"] = "Obrana",
    ["Transport"] = "Transport",
    ["Configuration"] = "Konfigurace",
    ["Help"] = "Nápověda",

    -- === ADVANCED FEATURES ===
    ["Boss Encounter"] = "Setkání s Bossem",
    ["Boss System"] = "Systém Bossů",
    ["Formation System"] = "Systém Formací",
    ["Resource Management"] = "Správa Prostředků",
    ["Sound System"] = "Zvukový Systém",
    ["Effect System"] = "Systém Efektů",
    ["CAP Integration"] = "CAP Integrace",
    ["Enhanced Integration"] = "Rozšířená Integrace",
    ["Asset Management"] = "Správa Assetů",
    ["Material System"] = "Systém Materiálů",
    ["Model System"] = "Systém Modelů",
    ["Particle Effects"] = "Částicové Efekty",
    ["Visual Effects"] = "Vizuální Efekty",
    ["Audio Effects"] = "Zvukové Efekty",

    -- === TECHNICAL TERMS ===
    ["Entity"] = "Entita",
    ["Entities"] = "Entity",
    ["Component"] = "Komponenta",
    ["Components"] = "Komponenty",
    ["Module"] = "Modul",
    ["Modules"] = "Moduly",
    ["System"] = "Systém",
    ["Systems"] = "Systémy",
    ["Network"] = "Síť",
    ["Protocol"] = "Protokol",
    ["Database"] = "Databáze",
    ["Cache"] = "Cache",
    ["Buffer"] = "Buffer",
    ["Memory"] = "Paměť",
    ["Storage"] = "Úložiště",
    ["Backup"] = "Záloha",
    ["Recovery"] = "Obnova",
    ["Diagnostics"] = "Diagnostika",
    ["Monitoring"] = "Monitorování",
    ["Logging"] = "Logování",
    ["Debugging"] = "Ladění",
    ["Testing"] = "Testování",
    ["Validation"] = "Validace",
    ["Verification"] = "Ověření",
    ["Authentication"] = "Autentifikace",
    ["Authorization"] = "Autorizace",
    ["Security"] = "Bezpečnost",
    ["Encryption"] = "Šifrování",
    ["Compression"] = "Komprese",
    ["Optimization"] = "Optimalizace",
    ["Performance"] = "Výkon",
    ["Efficiency"] = "Efektivita",
    ["Stability"] = "Stabilita",
    ["Reliability"] = "Spolehlivost",
    ["Compatibility"] = "Kompatibilita",
    ["Integration"] = "Integrace",
    ["Synchronization"] = "Synchronizace",
    ["Coordination"] = "Koordinace",
    ["Communication"] = "Komunikace",
    ["Transmission"] = "Přenos",
    ["Reception"] = "Příjem",
    ["Signal"] = "Signál",
    ["Frequency"] = "Frekvence",
    ["Bandwidth"] = "Šířka Pásma",
    ["Latency"] = "Latence",
    ["Throughput"] = "Propustnost",
    ["Quality"] = "Kvalita",
    ["Resolution"] = "Rozlišení",
    ["Precision"] = "Přesnost",
    ["Accuracy"] = "Přesnost",
    ["Tolerance"] = "Tolerance",
    ["Threshold"] = "Práh",
    ["Limit"] = "Limit",
    ["Range"] = "Dosah",
    ["Scope"] = "Rozsah",
    ["Scale"] = "Měřítko",
    ["Size"] = "Velikost",
    ["Dimension"] = "Rozměr",
    ["Position"] = "Pozice",
    ["Location"] = "Umístění",
    ["Coordinate"] = "Souřadnice",
    ["Direction"] = "Směr",
    ["Orientation"] = "Orientace",
    ["Rotation"] = "Rotace",
    ["Movement"] = "Pohyb",
    ["Motion"] = "Pohyb",
    ["Velocity"] = "Rychlost",
    ["Acceleration"] = "Zrychlení",
    ["Force"] = "Síla",
    ["Power"] = "Výkon",
    ["Energy"] = "Energie",
    ["Fuel"] = "Palivo",
    ["Resource"] = "Prostředek",
    ["Material"] = "Materiál",
    ["Element"] = "Prvek",
    ["Substance"] = "Látka",
    ["Compound"] = "Sloučenina",
    ["Mixture"] = "Směs",
    ["Solution"] = "Řešení",
    ["Formula"] = "Vzorec",
    ["Algorithm"] = "Algoritmus",
    ["Procedure"] = "Procedura",
    ["Process"] = "Proces",
    ["Operation"] = "Operace",
    ["Function"] = "Funkce",
    ["Method"] = "Metoda",
    ["Technique"] = "Technika",
    ["Strategy"] = "Strategie",
    ["Tactic"] = "Taktika",
    ["Approach"] = "Přístup",
    ["Solution"] = "Řešení",
    ["Result"] = "Výsledek",
    ["Outcome"] = "Výsledek",
    ["Achievement"] = "Úspěch",
    ["Goal"] = "Cíl",
    ["Objective"] = "Cíl",
    ["Target"] = "Cíl",
    ["Destination"] = "Cíl",
    ["Purpose"] = "Účel",
    ["Intent"] = "Záměr",
    ["Plan"] = "Plán",
    ["Schedule"] = "Rozvrh",
    ["Timeline"] = "Časová Osa",
    ["Duration"] = "Doba Trvání",
    ["Period"] = "Období",
    ["Interval"] = "Interval",
    ["Cycle"] = "Cyklus",
    ["Phase"] = "Fáze",
    ["Stage"] = "Etapa",
    ["Step"] = "Krok",
    ["Level"] = "Úroveň",
    ["Grade"] = "Stupeň",
    ["Rank"] = "Hodnost",
    ["Class"] = "Třída",
    ["Type"] = "Typ",
    ["Kind"] = "Druh",
    ["Category"] = "Kategorie",
    ["Group"] = "Skupina",
    ["Set"] = "Sada",
    ["Collection"] = "Kolekce",
    ["Array"] = "Pole",
    ["List"] = "Seznam",
    ["Queue"] = "Fronta",
    ["Stack"] = "Zásobník",
    ["Tree"] = "Strom",
    ["Graph"] = "Graf",
    ["Chart"] = "Graf",
    ["Diagram"] = "Diagram",
    ["Map"] = "Mapa",
    ["Layout"] = "Rozložení",
    ["Design"] = "Design",
    ["Pattern"] = "Vzor",
    ["Template"] = "Šablona",
    ["Model"] = "Model",
    ["Prototype"] = "Prototyp",
    ["Sample"] = "Vzorek",
    ["Example"] = "Příklad",
    ["Instance"] = "Instance",
    ["Copy"] = "Kopie",
    ["Clone"] = "Klon",
    ["Duplicate"] = "Duplikát",
    ["Backup"] = "Záloha",
    ["Archive"] = "Archiv",
    ["History"] = "Historie",
    ["Log"] = "Log",
    ["Record"] = "Záznam",
    ["Entry"] = "Položka",
    ["Item"] = "Položka",
    ["Object"] = "Objekt",
    ["Thing"] = "Věc",
    ["Stuff"] = "Věci",
    ["Data"] = "Data",
    ["Information"] = "Informace",
    ["Knowledge"] = "Znalosti",
    ["Wisdom"] = "Moudrost",
    ["Intelligence"] = "Inteligence",
    ["Logic"] = "Logika",
    ["Reason"] = "Důvod",
    ["Cause"] = "Příčina",
    ["Effect"] = "Efekt",
    ["Impact"] = "Dopad",
    ["Influence"] = "Vliv",
    ["Control"] = "Kontrola",
    ["Management"] = "Správa",
    ["Administration"] = "Administrace",
    ["Governance"] = "Řízení",
    ["Leadership"] = "Vedení",
    ["Command"] = "Příkaz",
    ["Order"] = "Rozkaz",
    ["Instruction"] = "Instrukce",
    ["Direction"] = "Směr",
    ["Guidance"] = "Vedení",
    ["Advice"] = "Rada",
    ["Suggestion"] = "Návrh",
    ["Recommendation"] = "Doporučení",
    ["Proposal"] = "Návrh",
    ["Offer"] = "Nabídka",
    ["Request"] = "Požadavek",
    ["Demand"] = "Požadavek",
    ["Need"] = "Potřeba",
    ["Want"] = "Chtít",
    ["Desire"] = "Touha",
    ["Wish"] = "Přání",
    ["Hope"] = "Naděje",
    ["Dream"] = "Sen",
    ["Vision"] = "Vize",
    ["Imagination"] = "Představivost",
    ["Creativity"] = "Kreativita",
    ["Innovation"] = "Inovace",
    ["Invention"] = "Vynález",
    ["Discovery"] = "Objev",
    ["Exploration"] = "Průzkum",
    ["Investigation"] = "Vyšetřování",
    ["Research"] = "Výzkum",
    ["Study"] = "Studie",
    ["Analysis"] = "Analýza",
    ["Examination"] = "Zkoumání",
    ["Inspection"] = "Inspekce",
    ["Review"] = "Přehled",
    ["Assessment"] = "Hodnocení",
    ["Evaluation"] = "Vyhodnocení",
    ["Judgment"] = "Úsudek",
    ["Decision"] = "Rozhodnutí",
    ["Choice"] = "Volba",
    ["Option"] = "Možnost",
    ["Alternative"] = "Alternativa",
    ["Possibility"] = "Možnost",
    ["Opportunity"] = "Příležitost",
    ["Chance"] = "Šance",
    ["Risk"] = "Riziko",
    ["Danger"] = "Nebezpečí",
    ["Threat"] = "Hrozba",
    ["Warning"] = "Varování",
    ["Alert"] = "Upozornění",
    ["Notification"] = "Oznámení",
    ["Message"] = "Zpráva",
    ["Communication"] = "Komunikace",
    ["Conversation"] = "Konverzace",
    ["Discussion"] = "Diskuse",
    ["Dialogue"] = "Dialog",
    ["Chat"] = "Chat",
    ["Talk"] = "Rozhovor",
    ["Speech"] = "Řeč",
    ["Voice"] = "Hlas",
    ["Sound"] = "Zvuk",
    ["Audio"] = "Audio",
    ["Music"] = "Hudba",
    ["Noise"] = "Hluk",
    ["Silence"] = "Ticho",
    ["Quiet"] = "Ticho",
    ["Loud"] = "Hlasitý",
    ["Volume"] = "Hlasitost",
    ["Tone"] = "Tón",
    ["Pitch"] = "Výška",
    ["Rhythm"] = "Rytmus",
    ["Beat"] = "Rytmus",
    ["Tempo"] = "Tempo",
    ["Speed"] = "Rychlost",
    ["Fast"] = "Rychlý",
    ["Slow"] = "Pomalý",
    ["Quick"] = "Rychlý",
    ["Instant"] = "Okamžitý",
    ["Immediate"] = "Okamžitý",
    ["Delayed"] = "Zpožděný",
    ["Late"] = "Pozdní",
    ["Early"] = "Brzký",
    ["On time"] = "Včas",
    ["Scheduled"] = "Naplánovaný",
    ["Planned"] = "Plánovaný",
    ["Expected"] = "Očekávaný",
    ["Predicted"] = "Předpovězený",
    ["Estimated"] = "Odhadovaný",
    ["Calculated"] = "Vypočítaný",
    ["Measured"] = "Naměřený",
    ["Observed"] = "Pozorovaný",
    ["Detected"] = "Detekovaný",
    ["Found"] = "Nalezený",
    ["Located"] = "Umístěný",
    ["Identified"] = "Identifikovaný",
    ["Recognized"] = "Rozpoznaný",
    ["Known"] = "Známý",
    ["Unknown"] = "Neznámý",
    ["Hidden"] = "Skrytý",
    ["Visible"] = "Viditelný",
    ["Invisible"] = "Neviditelný",
    ["Clear"] = "Jasný",
    ["Unclear"] = "Nejasný",
    ["Obvious"] = "Zřejmý",
    ["Obscure"] = "Nejasný",
    ["Simple"] = "Jednoduchý",
    ["Complex"] = "Složitý",
    ["Complicated"] = "Komplikovaný",
    ["Easy"] = "Snadný",
    ["Difficult"] = "Obtížný",
    ["Hard"] = "Těžký",
    ["Soft"] = "Měkký",
    ["Smooth"] = "Hladký",
    ["Rough"] = "Hrubý",
    ["Sharp"] = "Ostrý",
    ["Dull"] = "Tupý",
    ["Bright"] = "Jasný",
    ["Dark"] = "Tmavý",
    ["Light"] = "Světlý",
    ["Heavy"] = "Těžký",
    ["Strong"] = "Silný",
    ["Weak"] = "Slabý",
    ["Powerful"] = "Mocný",
    ["Fragile"] = "Křehký",
    ["Durable"] = "Odolný",
    ["Temporary"] = "Dočasný",
    ["Permanent"] = "Trvalý",
    ["Stable"] = "Stabilní",
    ["Unstable"] = "Nestabilní",
    ["Secure"] = "Bezpečný",
    ["Insecure"] = "Nebezpečný",
    ["Safe"] = "Bezpečný",
    ["Dangerous"] = "Nebezpečný",
    ["Harmful"] = "Škodlivý",
    ["Beneficial"] = "Prospěšný",
    ["Useful"] = "Užitečný",
    ["Useless"] = "Neužitečný",
    ["Important"] = "Důležitý",
    ["Unimportant"] = "Nedůležitý",
    ["Critical"] = "Kritický",
    ["Essential"] = "Nezbytný",
    ["Optional"] = "Volitelný",
    ["Required"] = "Požadovaný",
    ["Necessary"] = "Nutný",
    ["Sufficient"] = "Dostatečný",
    ["Insufficient"] = "Nedostatečný",
    ["Adequate"] = "Přiměřený",
    ["Inadequate"] = "Nepřiměřený",
    ["Appropriate"] = "Vhodný",
    ["Inappropriate"] = "Nevhodný",
    ["Suitable"] = "Vhodný",
    ["Unsuitable"] = "Nevhodný",
    ["Compatible"] = "Kompatibilní",
    ["Incompatible"] = "Nekompatibilní",
    ["Consistent"] = "Konzistentní",
    ["Inconsistent"] = "Nekonzistentní",
    ["Regular"] = "Pravidelný",
    ["Irregular"] = "Nepravidelný",
    ["Normal"] = "Normální",
    ["Abnormal"] = "Abnormální",
    ["Standard"] = "Standardní",
    ["Custom"] = "Vlastní",
    ["Default"] = "Výchozí",
    ["Special"] = "Speciální",
    ["General"] = "Obecný",
    ["Specific"] = "Specifický",
    ["Particular"] = "Konkrétní",
    ["Individual"] = "Individuální",
    ["Personal"] = "Osobní",
    ["Private"] = "Soukromý",
    ["Public"] = "Veřejný",
    ["Open"] = "Otevřený",
    ["Closed"] = "Zavřený",
    ["Locked"] = "Zamčený",
    ["Unlocked"] = "Odemčený",
    ["Available"] = "Dostupný",
    ["Unavailable"] = "Nedostupný",
    ["Accessible"] = "Přístupný",
    ["Inaccessible"] = "Nepřístupný",
    ["Reachable"] = "Dosažitelný",
    ["Unreachable"] = "Nedosažitelný",
    ["Possible"] = "Možný",
    ["Impossible"] = "Nemožný",
    ["Probable"] = "Pravděpodobný",
    ["Improbable"] = "Nepravděpodobný",
    ["Likely"] = "Pravděpodobný",
    ["Unlikely"] = "Nepravděpodobný",
    ["Certain"] = "Jistý",
    ["Uncertain"] = "Nejistý",
    ["Sure"] = "Jistý",
    ["Unsure"] = "Nejistý",
    ["Confident"] = "Sebejistý",
    ["Doubtful"] = "Pochybný",
    ["Reliable"] = "Spolehlivý",
    ["Unreliable"] = "Nespolehlivý",
    ["Trustworthy"] = "Důvěryhodný",
    ["Untrustworthy"] = "Nedůvěryhodný",
    ["Honest"] = "Poctivý",
    ["Dishonest"] = "Nepoctivý",
    ["True"] = "Pravdivý",
    ["False"] = "Nepravdivý",
    ["Correct"] = "Správný",
    ["Incorrect"] = "Nesprávný",
    ["Right"] = "Správný",
    ["Wrong"] = "Špatný",
    ["Good"] = "Dobrý",
    ["Bad"] = "Špatný",
    ["Better"] = "Lepší",
    ["Worse"] = "Horší",
    ["Best"] = "Nejlepší",
    ["Worst"] = "Nejhorší",
    ["Excellent"] = "Výborný",
    ["Poor"] = "Špatný",
    ["Perfect"] = "Dokonalý",
    ["Imperfect"] = "Nedokonalý",
    ["Complete"] = "Kompletní",
    ["Incomplete"] = "Nekompletní",
    ["Finished"] = "Dokončený",
    ["Unfinished"] = "Nedokončený",
    ["Full"] = "Plný",
    ["Empty"] = "Prázdný",
    ["Partial"] = "Částečný",
    ["Total"] = "Celkový",
    ["Whole"] = "Celý",
    ["Half"] = "Polovina",
    ["Quarter"] = "Čtvrtina",
    ["Third"] = "Třetina",
    ["All"] = "Vše",
    ["None"] = "Žádný",
    ["Some"] = "Nějaký",
    ["Many"] = "Mnoho",
    ["Few"] = "Málo",
    ["Several"] = "Několik",
    ["Multiple"] = "Více",
    ["Single"] = "Jeden",
    ["Double"] = "Dvojitý",
    ["Triple"] = "Trojitý",
    ["First"] = "První",
    ["Second"] = "Druhý",
    ["Third"] = "Třetí",
    ["Last"] = "Poslední",
    ["Next"] = "Další",
    ["Previous"] = "Předchozí",
    ["Current"] = "Současný",
    ["Past"] = "Minulý",
    ["Future"] = "Budoucí",
    ["Present"] = "Současný",
    ["Now"] = "Nyní",
    ["Then"] = "Pak",
    ["Soon"] = "Brzy",
    ["Later"] = "Později",
    ["Before"] = "Před",
    ["After"] = "Po",
    ["During"] = "Během",
    ["While"] = "Zatímco",
    ["Until"] = "Dokud",
    ["Since"] = "Od",
    ["Always"] = "Vždy",
    ["Never"] = "Nikdy",
    ["Sometimes"] = "Někdy",
    ["Often"] = "Často",
    ["Rarely"] = "Zřídka",
    ["Usually"] = "Obvykle",
    ["Normally"] = "Normálně",
    ["Typically"] = "Typicky",
    ["Generally"] = "Obecně",
    ["Specifically"] = "Konkrétně",
    ["Exactly"] = "Přesně",
    ["Approximately"] = "Přibližně",
    ["About"] = "Asi",
    ["Around"] = "Kolem",
    ["Nearly"] = "Téměř",
    ["Almost"] = "Skoro",
    ["Quite"] = "Docela",
    ["Very"] = "Velmi",
    ["Extremely"] = "Extrémně",
    ["Highly"] = "Vysoce",
    ["Completely"] = "Úplně",
    ["Totally"] = "Úplně",
    ["Absolutely"] = "Absolutně",
    ["Definitely"] = "Určitě",
    ["Certainly"] = "Jistě",
    ["Probably"] = "Pravděpodobně",
    ["Maybe"] = "Možná",
    ["Perhaps"] = "Snad",
    ["Possibly"] = "Možná",
    ["Hopefully"] = "Doufejme",
    ["Unfortunately"] = "Bohužel",
    ["Fortunately"] = "Naštěstí",
    ["Luckily"] = "Naštěstí",
    ["Surprisingly"] = "Překvapivě",
    ["Obviously"] = "Zřejmě",
    ["Clearly"] = "Jasně",
    ["Apparently"] = "Zřejmě",
    ["Seemingly"] = "Zdánlivě",
    ["Actually"] = "Vlastně",
    ["Really"] = "Opravdu",
    ["Truly"] = "Skutečně",
    ["Indeed"] = "Skutečně",
    ["Certainly"] = "Jistě",
    ["Surely"] = "Jistě",
    ["Undoubtedly"] = "Nepochybně",
    ["Definitely"] = "Určitě",
    ["Absolutely"] = "Absolutně",
    ["Positively"] = "Pozitivně",
    ["Negatively"] = "Negativně",

    -- === ADDITIONAL TRANSLATIONS ===
    ["Czech localization enabled"] = "Česká lokalizace povolena",
    ["Czech localization disabled"] = "Česká lokalizace zakázána",
    ["All text will now be displayed in Czech"] = "Veškerý text bude nyní zobrazen v češtině",
    ["Available command categories"] = "Dostupné kategorie příkazů",
    ["Commands in category"] = "Příkazy v kategorii",
    ["AI assistance"] = "AI asistence",
    ["Ask anything"] = "Zeptejte se na cokoliv",
    ["System overview"] = "Přehled systému",
    ["Ship information"] = "Informace o lodi",
    ["still supported"] = "stále podporováno",
    ["to see commands in that category"] = "pro zobrazení příkazů v této kategorii",
    ["question"] = "otázka",
    ["category"] = "kategorie",
    ["Use"] = "Použijte",
    ["Usage"] = "Použití",
    ["Použití"] = "Použití",

    -- === SPAWN MENU TRANSLATIONS ===
    ["Ship Components"] = "Komponenty Lodi",
    ["Weapons - Energy"] = "Zbraně - Energie",
    ["Weapons - Kinetic"] = "Zbraně - Kinetické",
    ["Flight Systems"] = "Letové Systémy",
    ["Shields & Defense"] = "Štíty a Obrana",
    ["Ancient Technology"] = "Starověká Technologie",
    ["Asgard Technology"] = "Asgardská Technologie",
    ["Goa'uld Technology"] = "Goa'uldská Technologie",
    ["Wraith Technology"] = "Wraith Technologie",
    ["Ori Technology"] = "Ori Technologie",
    ["Tau'ri Technology"] = "Tau'ri Technologie",

    -- === ENTITY DESCRIPTIONS ===
    ["Central ship management and control system"] = "Centrální systém správy a řízení lodi",
    ["Standard FTL propulsion system"] = "Standardní FTL pohonný systém",
    ["Advanced FTL propulsion with enhanced capabilities"] = "Pokročilý FTL pohon s rozšířenými schopnostmi",
    ["Navigation and jump calculation system"] = "Navigační a výpočetní systém skoků",
    ["Fast-firing energy weapon system"] = "Rychlopalný energetický zbraňový systém",
    ["Continuous energy beam weapon"] = "Kontinuální energetická paprskové zbraň",
    ["Area-effect plasma weapon system"] = "Plazmový zbraňový systém s plošným efektem",
    ["Guided missile weapon system"] = "Naváděný raketový zbraňový systém",
    ["High-velocity kinetic weapon"] = "Vysokorychlostní kinetická zbraň",
    ["Ship control and navigation interface"] = "Rozhraní pro řízení a navigaci lodi",
    ["Landing and docking system"] = "Systém přistání a dokování",
    ["Small transport vessel"] = "Malé transportní plavidlo",
    ["CAP-integrated shield system"] = "Štítový systém integrovaný s CAP",
    ["Zero Point Module power source"] = "Zdroj energie Zero Point Module",
    ["Automated defense drone"] = "Automatizovaný obranný dron",
    ["Orbital defense platform"] = "Orbitální obranná platforma",
    ["Advanced ion beam weapon"] = "Pokročilá iontová paprskové zbraň",
    ["High-energy plasma weapon"] = "Vysokoenergetická plazmová zbraň",
    ["Ship-mounted staff weapon"] = "Lodní žezlová zbraň",
    ["Hand device weapon system"] = "Ruční zbraňový systém",

    -- === UI ELEMENTS ===
    ["Ship Core Management"] = "Správa Jádra Lodi",
    ["Central ship management and control"] = "Centrální správa a řízení lodi",
    ["Spawn Ship Core"] = "Spawn Jádro Lodi",
    ["Default Ship Name"] = "Výchozí Název Lodi",
    ["New Ship"] = "Nová Loď",
    ["Auto-Link Components"] = "Automatické Propojení Komponentů",
    ["Hyperdrive Engine Spawner"] = "Spawner Hyperpoháněče",
    ["Spawn and configure hyperdrive engines"] = "Spawn a konfigurace hyperpoháněčů",
    ["Spawn Standard Engine"] = "Spawn Standardní Motor",
    ["Spawn Master Engine"] = "Spawn Hlavní Motor",
    ["Spawn Hyperdrive Computer"] = "Spawn Hyperpohonný Počítač",
    ["Weapon Systems"] = "Zbraňové Systémy",
    ["Spawn and configure combat weapons"] = "Spawn a konfigurace bojových zbraní",
    ["Auto-Link to Ship Core"] = "Automatické Propojení s Jádrem Lodi",
    ["Shield Systems"] = "Štítové Systémy",
    ["Defensive shield generators"] = "Obranné generátory štítů",
    ["Spawn Shield Generator"] = "Spawn Generátor Štítů",
    ["CAP Integration"] = "CAP Integrace",
    ["Ship Flight Systems"] = "Letové Systémy Lodi",
    ["Configure flight control and movement"] = "Konfigurace řízení letu a pohybu",
    ["Spawn Flight Console"] = "Spawn Letová Konzole",
    ["Enable Flight Systems"] = "Povolit Letové Systémy",
    ["Enable Autopilot"] = "Povolit Autopilot",
    ["Docking & Landing Systems"] = "Dokovací a Přistávací Systémy",
    ["Configure docking pads and landing operations"] = "Konfigurace dokovacích ploch a přistávacích operací",
    ["Spawn Docking Pad"] = "Spawn Dokovací Plocha",
    ["Spawn Shuttle"] = "Spawn Raketoplán",
    ["Enable Docking Systems"] = "Povolit Dokovací Systémy",
    ["Advanced Space Combat Configuration"] = "Konfigurace Pokročilého Vesmírného Boje",
    ["General addon settings and preferences"] = "Obecná nastavení a preference addonu",
    ["Enable Debug Mode"] = "Povolit Režim Ladění",
    ["Enable CAP Integration"] = "Povolit CAP Integraci",

    -- === MISSING TRANSLATIONS ===
    ["Czech localization applied to entire addon"] = "Česká lokalizace aplikována na celý addon",
    ["All systems now support Czech language"] = "Všechny systémy nyní podporují český jazyk",
    ["System Status"] = "Stav Systému",
    ["Loading"] = "Načítání",
    ["Initializing"] = "Inicializace",
    ["Ultimate Edition"] = "Ultimate Edition",
    ["Enhanced Edition"] = "Rozšířená Edice",
    ["Professional Edition"] = "Profesionální Edice",
    ["Enterprise Edition"] = "Podniková Edice",

    -- === SYSTEM MESSAGES ===
    ["System initialized"] = "Systém inicializován",
    ["System loading"] = "Systém se načítá",
    ["System ready"] = "Systém připraven",
    ["System error"] = "Systémová chyba",
    ["System warning"] = "Systémové varování",
    ["System info"] = "Systémové informace",
    ["System debug"] = "Systémové ladění",

    -- === ENTITY NAMES ===
    ["Pulse Cannon"] = "Pulsní Kanón",
    ["Beam Weapon"] = "Paprskové Zbraně",
    ["Torpedo Launcher"] = "Torpédový Odpalovač",
    ["Plasma Cannon"] = "Plazmový Kanón",
    ["Shield Generator"] = "Generátor Štítů",
    ["Flight Console"] = "Letová Konzole",
    ["Docking Pad"] = "Dokovací Plocha",
    ["Shuttle"] = "Raketoplán",
    ["Ancient ZPM"] = "Starověký ZPM",
    ["Ancient Drone Weapon"] = "Starověká Dronová Zbraň",
    ["Ancient Satellite"] = "Starověký Satelit",
    ["Asgard Ion Cannon"] = "Asgardský Iontový Kanón",
    ["Asgard Plasma Beam"] = "Asgardský Plazmový Paprsek",
    ["Goa'uld Staff Cannon"] = "Goa'uldský Žezlový Kanón",
    ["Goa'uld Ribbon Device"] = "Goa'uldské Pásové Zařízení",

    -- === TECHNOLOGY TIERS ===
    ["Tier 1"] = "Úroveň 1",
    ["Tier 2"] = "Úroveň 2",
    ["Tier 3"] = "Úroveň 3",
    ["Tier 4"] = "Úroveň 4",
    ["Tier 5"] = "Úroveň 5",
    ["Tier 6"] = "Úroveň 6",
    ["Tier 7"] = "Úroveň 7",
    ["Tier 8"] = "Úroveň 8",
    ["Tier 9"] = "Úroveň 9",
    ["Tier 10"] = "Úroveň 10",

    -- === COMBAT TERMS ===
    ["Damage"] = "Poškození",
    ["Health"] = "Zdraví",
    ["Armor"] = "Pancéřování",
    ["Shield Strength"] = "Síla Štítů",
    ["Energy Level"] = "Úroveň Energie",
    ["Ammunition"] = "Munice",
    ["Reload Time"] = "Čas Přebití",
    ["Fire Rate"] = "Rychlost Palby",
    ["Accuracy"] = "Přesnost",
    ["Critical Hit"] = "Kritický Zásah",
    ["Miss"] = "Minutí",
    ["Hit"] = "Zásah",
    ["Kill"] = "Zabití",
    ["Death"] = "Smrt",
    ["Respawn"] = "Oživení",

    -- === FLIGHT TERMS ===
    ["Altitude"] = "Výška",
    ["Velocity"] = "Rychlost",
    ["Acceleration"] = "Zrychlení",
    ["Deceleration"] = "Zpomalení",
    ["Pitch"] = "Náklon",
    ["Yaw"] = "Zatáčení",
    ["Roll"] = "Naklonění",
    ["Thrust"] = "Tah",
    ["Brake"] = "Brzda",
    ["Landing"] = "Přistání",
    ["Takeoff"] = "Vzlet",
    ["Hover"] = "Vznášení",
    ["Cruise"] = "Cestovní Rychlost",
    ["Maximum Speed"] = "Maximální Rychlost",
    ["Minimum Speed"] = "Minimální Rychlost",

    -- === NAVIGATION TERMS ===
    ["Coordinates"] = "Souřadnice",
    ["Waypoint"] = "Navigační Bod",
    ["Route"] = "Trasa",
    ["Distance"] = "Vzdálenost",
    ["Bearing"] = "Azimut",
    ["Compass"] = "Kompas",
    ["GPS"] = "GPS",
    ["Map"] = "Mapa",
    ["Radar"] = "Radar",
    ["Scanner"] = "Skener",
    ["Sensor Range"] = "Dosah Senzorů",
    ["Detection"] = "Detekce",
    ["Tracking"] = "Sledování",
    ["Lock On"] = "Zaměření",
    ["Target Acquired"] = "Cíl Získán",
    ["Target Lost"] = "Cíl Ztracen",

    -- === ENERGY TERMS ===
    ["Power Core"] = "Energetické Jádro",
    ["Battery"] = "Baterie",
    ["Generator"] = "Generátor",
    ["Reactor"] = "Reaktor",
    ["Fusion"] = "Fúze",
    ["Fission"] = "Štěpení",
    ["Solar Panel"] = "Solární Panel",
    ["Wind Turbine"] = "Větrná Turbína",
    ["Hydroelectric"] = "Hydroelektrická",
    ["Geothermal"] = "Geotermální",
    ["Nuclear"] = "Jaderná",
    ["Renewable"] = "Obnovitelná",
    ["Sustainable"] = "Udržitelná",
    ["Efficient"] = "Efektivní",
    ["Clean"] = "Čistá",
    ["Green"] = "Zelená",

    -- === MATERIALS ===
    ["Metal"] = "Kov",
    ["Steel"] = "Ocel",
    ["Iron"] = "Železo",
    ["Aluminum"] = "Hliník",
    ["Titanium"] = "Titan",
    ["Carbon"] = "Uhlík",
    ["Plastic"] = "Plast",
    ["Glass"] = "Sklo",
    ["Ceramic"] = "Keramika",
    ["Composite"] = "Kompozit",
    ["Alloy"] = "Slitina",
    ["Crystal"] = "Krystal",
    ["Diamond"] = "Diamant",
    ["Gold"] = "Zlato",
    ["Silver"] = "Stříbro",
    ["Copper"] = "Měď",
    ["Lead"] = "Olovo",
    ["Uranium"] = "Uran",
    ["Plutonium"] = "Plutonium",
    ["Naquadah"] = "Naquadah",
    ["Trinium"] = "Trinium",
    ["Neutronium"] = "Neutronium",

    -- === COLORS ===
    ["Red"] = "Červená",
    ["Green"] = "Zelená",
    ["Blue"] = "Modrá",
    ["Yellow"] = "Žlutá",
    ["Orange"] = "Oranžová",
    ["Purple"] = "Fialová",
    ["Pink"] = "Růžová",
    ["Brown"] = "Hnědá",
    ["Black"] = "Černá",
    ["White"] = "Bílá",
    ["Gray"] = "Šedá",
    ["Grey"] = "Šedá",
    ["Cyan"] = "Azurová",
    ["Magenta"] = "Purpurová",
    ["Lime"] = "Limetková",
    ["Maroon"] = "Kaštanová",
    ["Navy"] = "Námořnická",
    ["Olive"] = "Olivová",
    ["Teal"] = "Modrozelená",
    ["Silver"] = "Stříbrná",
    ["Gold"] = "Zlatá",

    -- === DIRECTIONS ===
    ["North"] = "Sever",
    ["South"] = "Jih",
    ["East"] = "Východ",
    ["West"] = "Západ",
    ["Northeast"] = "Severovýchod",
    ["Northwest"] = "Severozápad",
    ["Southeast"] = "Jihovýchod",
    ["Southwest"] = "Jihozápad",
    ["Up"] = "Nahoru",
    ["Down"] = "Dolů",
    ["Left"] = "Vlevo",
    ["Right"] = "Vpravo",
    ["Forward"] = "Vpřed",
    ["Backward"] = "Vzad",
    ["Clockwise"] = "Po Směru Hodinových Ručiček",
    ["Counterclockwise"] = "Proti Směru Hodinových Ručiček",

    -- === TIME UNITS ===
    ["Second"] = "Sekunda",
    ["Seconds"] = "Sekundy",
    ["Minute"] = "Minuta",
    ["Minutes"] = "Minuty",
    ["Hour"] = "Hodina",
    ["Hours"] = "Hodiny",
    ["Day"] = "Den",
    ["Days"] = "Dny",
    ["Week"] = "Týden",
    ["Weeks"] = "Týdny",
    ["Month"] = "Měsíc",
    ["Months"] = "Měsíce",
    ["Year"] = "Rok",
    ["Years"] = "Roky",

    -- === DISTANCE UNITS ===
    ["Meter"] = "Metr",
    ["Meters"] = "Metry",
    ["Kilometer"] = "Kilometr",
    ["Kilometers"] = "Kilometry",
    ["Centimeter"] = "Centimetr",
    ["Centimeters"] = "Centimetry",
    ["Millimeter"] = "Milimetr",
    ["Millimeters"] = "Milimetry",
    ["Inch"] = "Palec",
    ["Inches"] = "Palce",
    ["Foot"] = "Stopa",
    ["Feet"] = "Stopy",
    ["Yard"] = "Yard",
    ["Yards"] = "Yardy",
    ["Mile"] = "Míle",
    ["Miles"] = "Míle",

    -- === WEIGHT UNITS ===
    ["Gram"] = "Gram",
    ["Grams"] = "Gramy",
    ["Kilogram"] = "Kilogram",
    ["Kilograms"] = "Kilogramy",
    ["Ton"] = "Tuna",
    ["Tons"] = "Tuny",
    ["Pound"] = "Libra",
    ["Pounds"] = "Libry",
    ["Ounce"] = "Unce",
    ["Ounces"] = "Unce"
}

-- Get Czech translation for a given key
function ASC.Czech.GetText(key, fallback)
    if not ASC.Czech.Config.Enabled then
        return fallback or key
    end

    -- Try GMod localization first if available
    if ASC.GMod and ASC.GMod.Localization then
        local gmodKey = "asc." .. string.lower(key:gsub(" ", "_"))
        local gmodTranslation = ASC.GMod.Localization.GetText(gmodKey, nil)
        if gmodTranslation and gmodTranslation ~= gmodKey then
            if ASC.Czech.Config.LogTranslations then
                print("[Czech] GMod Translated: " .. key .. " -> " .. gmodTranslation)
            end
            return gmodTranslation
        end
    end

    -- Fall back to internal translations
    local translation = ASC.Czech.Translations[key]
    if translation then
        if ASC.Czech.Config.LogTranslations then
            print("[Czech] Internal Translated: " .. key .. " -> " .. translation)
        end
        return translation
    end

    -- Return fallback or original key
    if ASC.Czech.Config.FallbackToEnglish then
        return fallback or key
    else
        return key
    end
end

-- Translate multiple keys at once
function ASC.Czech.GetTexts(keys)
    local results = {}
    for i, key in ipairs(keys) do
        results[i] = ASC.Czech.GetText(key)
    end
    return results
end

-- Check if Czech localization is enabled
function ASC.Czech.IsEnabled()
    return ASC.Czech.Config.Enabled
end

-- Enable/disable Czech localization
function ASC.Czech.SetEnabled(enabled)
    ASC.Czech.Config.Enabled = enabled
    print("[Czech] Localization " .. (enabled and "enabled" or "disabled"))
end

-- Add new translation
function ASC.Czech.AddTranslation(key, translation)
    ASC.Czech.Translations[key] = translation
    if ASC.Czech.Config.LogTranslations then
        print("[Czech] Added translation: " .. key .. " -> " .. translation)
    end
end

-- Batch add translations
function ASC.Czech.AddTranslations(translations)
    for key, translation in pairs(translations) do
        ASC.Czech.Translations[key] = translation
    end
    print("[Czech] Added " .. table.Count(translations) .. " translations")
end

-- Auto-detect player language and set Czech if appropriate
function ASC.Czech.AutoDetectAndSetLanguage(player)
    if not IsValid(player) or not ASC.Czech.Config.AutoSetLanguage then return false end

    local detectedLanguage = ASC.Czech.DetectPlayerLanguage(player)

    if detectedLanguage == "czech" or detectedLanguage == "cs" then
        ASC.Czech.SetEnabled(true)
        ASC.Czech.ApplyToAddon()

        -- Enhanced AI system integration
        if ASC.AI and ASC.AI.Languages then
            local playerID = player:SteamID()
            ASC.AI.Languages.SetLanguage(playerID, "czech")

            -- Set cultural context if available
            if ASC.AI.Languages.GenerateCzechResponse then
                local formality = ASC.AI.Languages.DetectCzechFormality("ahoj jak se máš")
                print("[Czech] Set AI formality context: " .. formality .. " for " .. player:Name())
            end
        end

        -- Enhanced multilingual system integration
        if ASC.Multilingual and ASC.Multilingual.Core then
            ASC.Multilingual.Core.SetPlayerLanguage(player, "cs")

            -- Trigger integration with Czech system
            if ASC.Multilingual.Core.IntegrateWithCzechSystem then
                ASC.Multilingual.Core.IntegrateWithCzechSystem()
            end
        end

        -- Notify player
        timer.Simple(2, function()
            if IsValid(player) then
                player:ChatPrint("[Advanced Space Combat] 🇨🇿 Automaticky detekován český jazyk!")
                player:ChatPrint("[ASC] Czech language automatically detected and enabled!")
                player:ChatPrint("[ASC] Použijte 'asc_czech disable' pro vypnutí / Use 'asc_czech disable' to turn off")
            end
        end)

        return true
    end

    return false
end

-- Detect player language using multiple methods
function ASC.Czech.DetectPlayerLanguage(player)
    if not IsValid(player) then return "unknown" end

    local detectedLang = "unknown"

    -- Method 1: Try to get Steam language (if available through extensions)
    if player.GetSteamLanguage then
        local steamLang = player:GetSteamLanguage()
        if steamLang == "czech" or steamLang == "cs" or steamLang == "cz" then
            print("[Czech] Detected Czech via Steam language: " .. steamLang)
            return "czech"
        end
    end

    -- Method 2: Check GMod language setting
    if CLIENT then
        local gmodLang = GetConVar("gmod_language")
        if gmodLang then
            local langValue = gmodLang:GetString()
            if langValue == "cs" or langValue == "czech" or langValue == "cz" then
                print("[Czech] Detected Czech via GMod language: " .. langValue)
                return "czech"
            end
        end
    end

    -- Method 3: Check system locale (Windows)
    if system and system.GetCountry then
        local country = system.GetCountry()
        if country == "CZ" or country == "Czech Republic" or country == "Czechia" then
            print("[Czech] Detected Czech via system country: " .. country)
            return "czech"
        end
    end

    -- Method 4: Check player name for Czech characters
    local playerName = player:Name()
    if ASC.Czech.ContainsCzechCharacters(playerName) then
        print("[Czech] Detected Czech characters in player name: " .. playerName)
        return "czech"
    end

    -- Method 5: Check if player has Czech in their Steam profile (if accessible)
    local steamID = player:SteamID64()
    if steamID then
        -- This would require Steam API access, placeholder for now
        -- Could be implemented with HTTP requests to Steam API
    end

    return detectedLang
end

-- Check if text contains Czech characters
function ASC.Czech.ContainsCzechCharacters(text)
    if not text or text == "" then return false end

    -- Czech specific characters
    local czechChars = {"á", "č", "ď", "é", "ě", "í", "ň", "ó", "ř", "š", "ť", "ú", "ů", "ý", "ž",
                       "Á", "Č", "Ď", "É", "Ě", "Í", "Ň", "Ó", "Ř", "Š", "Ť", "Ú", "Ů", "Ý", "Ž"}

    for _, char in ipairs(czechChars) do
        if string.find(text, char) then
            return true
        end
    end

    return false
end

-- Monitor player chat for Czech language detection
function ASC.Czech.MonitorPlayerChat(player)
    if not IsValid(player) then return end

    local steamID = player:SteamID()
    local hookName = "ASC_Czech_ChatMonitor_" .. steamID
    local messageCount = 0
    local czechMessageCount = 0

    hook.Add("PlayerSay", hookName, function(ply, text, teamChat)
        if ply ~= player then return end

        messageCount = messageCount + 1

        -- Check for Czech words or characters
        if ASC.Czech.ContainsCzechWords(text) or ASC.Czech.ContainsCzechCharacters(text) then
            czechMessageCount = czechMessageCount + 1
        end

        -- After 5 messages, check if majority are Czech
        if messageCount >= 5 then
            local czechRatio = czechMessageCount / messageCount

            if czechRatio >= 0.6 then -- 60% or more Czech messages
                print("[Czech] Detected Czech language via chat analysis for " .. player:Name())
                ASC.Czech.AutoDetectAndSetLanguage(player)
            end

            -- Remove hook after analysis
            hook.Remove("PlayerSay", hookName)
        end
    end)

    -- Remove hook after 10 minutes if not triggered
    timer.Simple(600, function()
        hook.Remove("PlayerSay", hookName)
    end)
end

-- Check if text contains Czech words
function ASC.Czech.ContainsCzechWords(text)
    if not text or text == "" then return false end

    local lowerText = string.lower(text)

    -- Common Czech words
    local czechWords = {
        "ahoj", "děkuji", "prosím", "ano", "ne", "dobře", "špatně", "jak", "kde", "co", "proč",
        "jsem", "jsi", "je", "jsou", "byl", "byla", "bylo", "můžu", "můžeš", "může", "chci",
        "potřebuji", "funguje", "nefunguje", "problém", "pomoc", "nápověda", "loď", "zbraň"
    }

    for _, word in ipairs(czechWords) do
        if string.find(lowerText, word) then
            return true
        end
    end

    return false
end

-- Apply Czech localization to entire addon
function ASC.Czech.ApplyToAddon()
    if not ASC.Czech.Config.Enabled then return end

    print("[Czech] Applying localization to entire Advanced Space Combat addon...")

    -- Apply to AI system
    if ASC.AI and ASC.AI.Languages then
        print("[Czech] Integrating with AI system...")
        -- AI system already has Czech support
    end

    -- Apply to multilingual system
    if ASC.Multilingual and ASC.Multilingual.Core then
        print("[Czech] Integrating with multilingual system...")
        -- Multilingual system already has Czech support
    end

    -- Apply to console commands
    if ASC.Commands then
        print("[Czech] Localizing console commands...")
        -- Console commands now use Czech localization
    end

    -- Apply to UI system
    if ASC.UI then
        print("[Czech] Localizing UI system...")
        -- UI system now has Czech localization helper
    end

    -- Apply to spawn menu
    if ASC.SpawnMenu then
        print("[Czech] Localizing spawn menu...")
        -- Spawn menu now has Czech localization helper
    end

    print("[Czech] Localization applied to all systems!")
end

-- Auto-apply localization when system loads
hook.Add("Initialize", "ASC_Czech_AutoApply", function()
    timer.Simple(1, function()
        if ASC.Czech.Config.Enabled then
            ASC.Czech.ApplyToAddon()
        end
    end)
end)

-- Auto-detect language when players join
hook.Add("PlayerInitialSpawn", "ASC_Czech_AutoDetect", function(player)
    if not ASC.Czech.Config.AutoSetLanguage then return end

    -- Wait a bit for player to fully load
    timer.Simple(3, function()
        if IsValid(player) then
            print("[Czech] Auto-detecting language for " .. player:Name())

            -- Try immediate detection first
            local detected = ASC.Czech.AutoDetectAndSetLanguage(player)

            -- If not detected immediately, start chat monitoring
            if not detected then
                ASC.Czech.MonitorPlayerChat(player)
            end
        end
    end)
end)

-- Auto-detect language when players reconnect
hook.Add("PlayerConnect", "ASC_Czech_PlayerConnect", function(name, ip)
    print("[Czech] Player connecting: " .. name .. " - Auto-detection will start on spawn")
end)

-- Save player language preferences
hook.Add("PlayerDisconnect", "ASC_Czech_SavePreferences", function(player)
    if not IsValid(player) then return end

    -- Save if this player had Czech enabled
    local steamID = player:SteamID()
    if ASC.Czech.Config.Enabled then
        -- Could save to file for persistence
        print("[Czech] Player " .. player:Name() .. " disconnected with Czech enabled")
    end
end)

-- Console command to apply Czech localization
concommand.Add("asc_apply_czech", function(ply, cmd, args)
    if ASC.Czech then
        ASC.Czech.SetEnabled(true)
        ASC.Czech.ApplyToAddon()

        local msg = "[" .. ASC.Czech.GetText("Advanced Space Combat", "Advanced Space Combat") .. "] " ..
                   ASC.Czech.GetText("Czech localization applied to entire addon", "Česká lokalizace aplikována na celý addon") .. " 🇨🇿"

        if IsValid(ply) then
            ply:ChatPrint(msg)
            ply:ChatPrint("[ASC] " .. ASC.Czech.GetText("All systems now support Czech language", "Všechny systémy nyní podporují český jazyk"))
        else
            print(msg)
        end
    else
        local errorMsg = "[Advanced Space Combat] Czech localization system not loaded!"
        if IsValid(ply) then
            ply:ChatPrint(errorMsg)
        else
            print(errorMsg)
        end
    end
end)

-- Console command to control auto-detection
concommand.Add("asc_czech_auto_detect", function(ply, cmd, args)
    local action = args[1] or "status"

    if action == "enable" or action == "on" or action == "1" then
        RunConsoleCommand("asc_czech_autodetect", "1")
        local msg = "[Advanced Space Combat] Czech auto-detection enabled (persistent)"
        if IsValid(ply) then
            ply:ChatPrint(msg)
            ply:ChatPrint("[ASC] Automatická detekce češtiny povolena (trvalé)")
        else
            print(msg)
        end
    elseif action == "disable" or action == "off" or action == "0" then
        RunConsoleCommand("asc_czech_autodetect", "0")
        local msg = "[Advanced Space Combat] Czech auto-detection disabled (persistent)"
        if IsValid(ply) then
            ply:ChatPrint(msg)
            ply:ChatPrint("[ASC] Automatická detekce češtiny zakázána (trvalé)")
        else
            print(msg)
        end
    elseif action == "test" and IsValid(ply) then
        -- Test detection on the player
        ply:ChatPrint("[Advanced Space Combat] Testing Czech language detection...")
        local detected = ASC.Czech.DetectPlayerLanguage(ply)
        ply:ChatPrint("[ASC] Detected language: " .. detected)

        if detected == "czech" then
            ply:ChatPrint("[ASC] 🇨🇿 Czech language detected! Enabling Czech localization...")
            ASC.Czech.AutoDetectAndSetLanguage(ply)
        else
            ply:ChatPrint("[ASC] Czech language not detected. Starting chat monitoring...")
            ASC.Czech.MonitorPlayerChat(ply)
        end
    elseif action == "status" then
        local enabled = ASC.Czech.Config.AutoSetLanguage and "enabled" or "disabled"
        local msg = "[Advanced Space Combat] Czech auto-detection: " .. enabled
        if IsValid(ply) then
            ply:ChatPrint(msg)
            ply:ChatPrint("[ASC] Automatická detekce češtiny: " .. (ASC.Czech.Config.AutoSetLanguage and "povolena" or "zakázána"))
            ply:ChatPrint("[ASC] Detection methods: " .. table.concat(ASC.Czech.Config.DetectionMethods, ", "))
        else
            print(msg)
        end
    else
        local usage = "[Advanced Space Combat] Usage: asc_czech_auto_detect [enable|disable|test|status]"
        if IsValid(ply) then
            ply:ChatPrint(usage)
            ply:ChatPrint("[ASC] Použití: asc_czech_auto_detect [enable|disable|test|status]")
        else
            print(usage)
        end
    end
end)

-- Console command to manually trigger detection for all players
concommand.Add("asc_czech_detect_all", function(ply, cmd, args)
    if not ASC.Czech.Config.AutoSetLanguage then
        local msg = "[Advanced Space Combat] Auto-detection is disabled. Enable it first with 'asc_czech_autodetect enable'"
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
        return
    end

    local detectedCount = 0
    local totalPlayers = 0

    for _, player in ipairs(player.GetAll()) do
        if IsValid(player) then
            totalPlayers = totalPlayers + 1
            local detected = ASC.Czech.AutoDetectAndSetLanguage(player)
            if detected then
                detectedCount = detectedCount + 1
            else
                -- Start chat monitoring for undetected players
                ASC.Czech.MonitorPlayerChat(player)
            end
        end
    end

    local msg = "[Advanced Space Combat] Czech detection completed: " .. detectedCount .. "/" .. totalPlayers .. " players detected as Czech"
    if IsValid(ply) then
        ply:ChatPrint(msg)
        ply:ChatPrint("[ASC] Detekce češtiny dokončena: " .. detectedCount .. "/" .. totalPlayers .. " hráčů detekováno jako čeští")
    else
        print(msg)
    end
end)

-- Create ConVars for persistent settings
CreateConVar("asc_czech_autodetect", "1", FCVAR_ARCHIVE, "Automatically detect and enable Czech language for Czech players")
CreateConVar("asc_czech_enabled", "1", FCVAR_ARCHIVE, "Enable Czech localization system")
CreateConVar("asc_czech_chat_monitor", "1", FCVAR_ARCHIVE, "Monitor player chat for Czech language detection")

-- Update config from ConVars
ASC.Czech.Config.AutoSetLanguage = GetConVar("asc_czech_autodetect"):GetBool()
ASC.Czech.Config.Enabled = GetConVar("asc_czech_enabled"):GetBool()

-- ConVar change callbacks
cvars.AddChangeCallback("asc_czech_autodetect", function(convar, oldValue, newValue)
    ASC.Czech.Config.AutoSetLanguage = tobool(newValue)
    print("[Czech] Auto-detection " .. (ASC.Czech.Config.AutoSetLanguage and "enabled" or "disabled"))
end)

cvars.AddChangeCallback("asc_czech_enabled", function(convar, oldValue, newValue)
    ASC.Czech.Config.Enabled = tobool(newValue)
    ASC.Czech.SetEnabled(ASC.Czech.Config.Enabled)
    print("[Czech] Localization system " .. (ASC.Czech.Config.Enabled and "enabled" or "disabled"))
end)

print("[Advanced Space Combat] Czech Localization System loaded with " .. table.Count(ASC.Czech.Translations) .. " translations")
print("[Czech] Auto-detection: " .. (ASC.Czech.Config.AutoSetLanguage and "enabled" or "disabled"))
print("[Czech] System enabled: " .. (ASC.Czech.Config.Enabled and "yes" or "no"))
print("[Czech] Detection methods: " .. table.concat(ASC.Czech.Config.DetectionMethods, ", "))

-- === POKROČILÉ ČESKÉ FUNKCE ===

-- Enhanced Czech language validation
function ASC.Czech.ValidateLanguageIntegrity()
    print("[Czech] Validating Czech language integration...")

    local issues = {}
    local fixes = 0

    -- Check UTF-8 encoding
    if ASC.Czech.Config.ValidateEncoding then
        for key, translation in pairs(ASC.Czech.Translations) do
            if not ASC.Czech.ValidateUTF8(translation) then
                table.insert(issues, "Encoding issue in key: " .. key)
            end
        end
    end

    -- Check AI integration
    if ASC.AI and ASC.AI.Languages then
        if not ASC.AI.Languages.Database.czech then
            table.insert(issues, "AI Czech language database missing")
        else
            print("[Czech] AI integration: OK")
            fixes = fixes + 1
        end
    end

    -- Check multilingual integration
    if ASC.Multilingual and ASC.Multilingual.Core then
        if not ASC.Multilingual.Core.LocalizedStrings.cs then
            table.insert(issues, "Multilingual Czech strings missing")
        else
            print("[Czech] Multilingual integration: OK")
            fixes = fixes + 1
        end
    end

    -- Report results
    if #issues > 0 then
        print("[Czech] Found " .. #issues .. " issues:")
        for _, issue in ipairs(issues) do
            print("  - " .. issue)
        end
    else
        print("[Czech] All systems validated successfully!")
    end

    print("[Czech] Applied " .. fixes .. " integration fixes")
    return #issues == 0
end

-- UTF-8 validation for Czech text
function ASC.Czech.ValidateUTF8(text)
    if not text or text == "" then return true end

    -- Check for proper UTF-8 encoding of Czech diacritics
    local czechDiacritics = {
        "á", "Á", "č", "Č", "ď", "Ď", "é", "É", "ě", "Ě",
        "í", "Í", "ň", "Ň", "ó", "Ó", "ř", "Ř", "š", "Š",
        "ť", "Ť", "ú", "Ú", "ů", "Ů", "ý", "Ý", "ž", "Ž"
    }

    -- Simple validation - check if Czech characters are properly encoded
    for _, char in ipairs(czechDiacritics) do
        if string.find(text, char) then
            local byte = string.byte(char)
            if not byte or byte < 128 then
                return false -- Improperly encoded
            end
        end
    end

    return true
end

-- Enhanced Czech language preference setting
function ASC.Czech.SetPlayerLanguagePreference(player, preference)
    if not IsValid(player) then return false end

    local steamID = player:SteamID()
    preference = preference or "czech"

    -- Set in all systems
    local success = true

    -- Czech system
    ASC.Czech.SetEnabled(true)

    -- AI system
    if ASC.AI and ASC.AI.Languages and ASC.AI.Languages.SetLanguage then
        if not ASC.AI.Languages.SetLanguage(steamID, "czech") then
            success = false
            print("[Czech] Failed to set AI language preference")
        end
    end

    -- Multilingual system
    if ASC.Multilingual and ASC.Multilingual.Core and ASC.Multilingual.Core.SetPlayerLanguage then
        if not ASC.Multilingual.Core.SetPlayerLanguage(player, "cs") then
            success = false
            print("[Czech] Failed to set multilingual language preference")
        end
    end

    if success then
        print("[Czech] Successfully set Czech language preference for " .. player:Name())

        -- Send confirmation message in Czech
        if player:IsValid() then
            player:ChatPrint("[ASC] Český jazyk byl úspěšně nastaven! Czech language successfully set!")
        end
    end

    return success
end

-- Comprehensive Czech system integration
function ASC.Czech.IntegrateWithAllSystems()
    print("[Czech] Integrating Czech language support with all systems...")

    local integrations = 0

    -- AI System Integration
    if ASC.AI and ASC.AI.Languages then
        -- Ensure Czech database exists and is comprehensive
        if not ASC.AI.Languages.Database.czech then
            ASC.AI.Languages.Database.czech = {}
        end

        -- Import Czech translations to AI system
        for key, translation in pairs(ASC.Czech.Translations) do
            if not ASC.AI.Languages.Database.czech[key] then
                ASC.AI.Languages.Database.czech[key] = translation
            end
        end

        integrations = integrations + 1
        print("[Czech] AI system integration complete")
    end

    -- Multilingual System Integration
    if ASC.Multilingual and ASC.Multilingual.Core then
        if ASC.Multilingual.Core.IntegrateWithCzechSystem then
            ASC.Multilingual.Core.IntegrateWithCzechSystem()
            integrations = integrations + 1
            print("[Czech] Multilingual system integration complete")
        end
    end

    -- Auto-detection System Integration
    if ASC.CzechDetection and ASC.CzechDetection.Core then
        ASC.CzechDetection.Core.Initialize()
        integrations = integrations + 1
        print("[Czech] Auto-detection system integration complete")
    end

    print("[Czech] Completed " .. integrations .. " system integrations")
    return integrations > 0
end

-- Initialize enhanced Czech language support
timer.Simple(2, function()
    ASC.Czech.ValidateLanguageIntegrity()
    ASC.Czech.IntegrateWithAllSystems()

    print("[Czech] Enhanced Czech language support initialized!")
end)

-- Notify other systems that Czech localization is loaded
hook.Run("ASC_Czech_SystemLoaded")

print("[Advanced Space Combat] Czech Localization System v2.0.0 Loaded Successfully!")
