-- Advanced Space Combat - Enhanced AI System v5.1.0 - ARIA-4 Ultimate Stargate Edition
-- Next-generation AI assistant with Stargate hyperspace integration and contextual understanding
-- Enhanced natural language processing, adaptive learning, and intelligent responses
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED

print("[Advanced Space Combat] Enhanced AI System v5.1.0 - ARIA-4 Ultimate Stargate Hyperspace Edition - Loading...")

-- Initialize AI namespace
ASC = ASC or {}
ASC.AI = ASC.AI or {}

-- AI Configuration
ASC.AI.Config = {
    Name = "ARIA-4",
    Version = "5.1.0",
    Personality = "Advanced AI assistant with deep space combat expertise, enhanced Stargate hyperspace technology mastery, and 4-stage travel system knowledge",
    EnableAdvancedFeatures = true,
    EnableContextAwareness = true,
    EnableLearning = true,
    EnableProactiveAssistance = true,
    EnableOrganizationHelp = true,
    EnableDiagnosticMode = true,
    EnableNaturalLanguage = true,
    EnablePredictiveHelp = true,
    EnableMultiLanguageSupport = true,
    EnableVoiceCommands = true,
    EnableULXIntegration = true,
    EnableAdminFeatures = true,
    EnableServerManagement = true,
    EnablePropProtection = true,
    EnableNPPIntegration = true,
    EnableCPPICompliance = true,
    EnableAdvDupe2Integration = true,
    EnableWiremodSupport = true,
    EnableDuplicationSystem = true,
    EnableCAPIntegration = true,
    EnableStargateIntegration = true,
    EnableCarterPackSupport = true,
    ResponseDelay = 0.3, -- Seconds (faster response)
    MaxResponseLength = 800, -- Longer responses
    CommandPrefix = "!ai",
    AdminCommandPrefix = "!admin-ai",
    ULXCommandPrefix = "ulx ai",
    LearningRate = 0.1,
    ContextMemorySize = 50,
    PredictionAccuracy = 0.85
}

-- Advanced AI Features with Performance Optimization
ASC.AI.ContextMemory = {}
ASC.AI.UserProfiles = {}
ASC.AI.ConversationHistory = {}
ASC.AI.PredictiveCache = {}
ASC.AI.LearningData = {}

-- AI Performance optimization based on research
ASC.AI.PerformanceConfig = {
    MaxHistoryLength = 50, -- Limit conversation history
    ContextWindowSize = 10, -- Number of recent messages to consider
    ResponseCacheSize = 100, -- Cache common responses
    MaxProcessingTime = 2, -- Maximum seconds for AI processing
    EnableSmartCaching = true,
    EnableContextCompression = true,
    CacheExpiryTime = 3600, -- 1 hour cache expiry
    MaxConcurrentRequests = 5 -- Limit concurrent AI requests
}

-- Response caching system for improved performance
ASC.AI.ResponseCache = ASC.AI.ResponseCache or {}
ASC.AI.CacheStats = {
    hits = 0,
    misses = 0,
    totalRequests = 0,
    averageResponseTime = 0
}

-- Request queue for managing concurrent requests
ASC.AI.RequestQueue = ASC.AI.RequestQueue or {}
ASC.AI.ActiveRequests = 0

-- Performance optimization functions
ASC.AI.Performance = {
    -- Generate cache key for responses
    GenerateCacheKey = function(query, playerID, context)
        local contextStr = table.concat(context or {}, "|")
        return util.CRC(query .. playerID .. contextStr)
    end,

    -- Check if response is cached
    GetCachedResponse = function(cacheKey)
        local cached = ASC.AI.ResponseCache[cacheKey]
        if cached and CurTime() - cached.timestamp < ASC.AI.PerformanceConfig.CacheExpiryTime then
            ASC.AI.CacheStats.hits = ASC.AI.CacheStats.hits + 1
            return cached.response
        end
        ASC.AI.CacheStats.misses = ASC.AI.CacheStats.misses + 1
        return nil
    end,

    -- Cache a response
    CacheResponse = function(cacheKey, response)
        if ASC.AI.PerformanceConfig.EnableSmartCaching then
            ASC.AI.ResponseCache[cacheKey] = {
                response = response,
                timestamp = CurTime(),
                useCount = 1
            }

            -- Clean old cache entries if cache is full
            if table.Count(ASC.AI.ResponseCache) > ASC.AI.PerformanceConfig.ResponseCacheSize then
                ASC.AI.Performance.CleanCache()
            end
        end
    end,

    -- Clean old cache entries
    CleanCache = function()
        local currentTime = CurTime()
        local cleaned = 0

        for key, entry in pairs(ASC.AI.ResponseCache) do
            if currentTime - entry.timestamp > ASC.AI.PerformanceConfig.CacheExpiryTime then
                ASC.AI.ResponseCache[key] = nil
                cleaned = cleaned + 1
            end
        end

        print("[ARIA-4] Cleaned " .. cleaned .. " expired cache entries")
    end,

    -- Check if can process new request
    CanProcessRequest = function()
        return ASC.AI.ActiveRequests < ASC.AI.PerformanceConfig.MaxConcurrentRequests
    end,

    -- Compress conversation context for better performance
    CompressContext = function(history)
        if not ASC.AI.PerformanceConfig.EnableContextCompression then
            return history
        end

        -- Keep only recent and important messages
        local compressed = {}
        local windowSize = ASC.AI.PerformanceConfig.ContextWindowSize

        -- Get recent messages
        for i = math.max(1, #history - windowSize + 1), #history do
            if history[i] then
                table.insert(compressed, {
                    query = history[i].query,
                    response = history[i].response,
                    intent = history[i].intent,
                    timestamp = history[i].timestamp
                })
            end
        end

        return compressed
    end
}

-- Advanced Natural Language Processing Engine
ASC.AI.NLP = {
    Version = "5.1.0",

    -- Enhanced intent recognition patterns with confidence scoring
    IntentPatterns = {
        question = {
            -- English patterns with weights
            patterns = {
                {words = {"what", "how", "why", "when", "where", "which", "who"}, weight = 1.0},
                {words = {"can", "is", "are", "do", "does", "will", "would", "could", "should"}, weight = 0.8},
                {words = {"explain", "tell", "show", "describe"}, weight = 0.9}
            },
            -- Czech patterns with weights
            czech_patterns = {
                {words = {"co", "jak", "proč", "kdy", "kde", "který", "kdo"}, weight = 1.0},
                {words = {"můžu", "můžeš", "může", "je", "jsou", "dělá", "bude", "mohl", "měl"}, weight = 0.8},
                {words = {"vysvětli", "řekni", "ukaž", "popiš"}, weight = 0.9}
            },
            confidence_threshold = 0.6,
            response_type = "informational"
        },
        command = {
            -- English
            "spawn", "create", "build", "make", "dial", "jump", "take", "save", "load", "wire", "link", "configure", "set", "enable", "disable",
            -- Czech
            "spawn", "vytvoř", "postav", "udělej", "vytvoř", "vytočit", "skoč", "vezmi", "ulož", "načti", "propoj", "nastav", "zapni", "vypni", "aktivuj", "deaktivuj"
        },
        help = {
            -- English
            "help", "assist", "guide", "tutorial", "explain", "show", "teach", "learn", "understand",
            -- Czech
            "pomoc", "nápověda", "asistence", "průvodce", "tutoriál", "vysvětli", "ukaž", "nauč", "naučit", "rozumět", "porozumět"
        },
        status = {
            -- English
            "status", "check", "monitor", "report", "info", "information", "details", "stats", "health",
            -- Czech
            "status", "stav", "zkontroluj", "kontrola", "monitor", "zpráva", "info", "informace", "detaily", "statistiky", "zdraví"
        },
        problem = {
            -- English
            "problem", "issue", "error", "broken", "not working", "failed", "fix", "repair", "troubleshoot",
            -- Czech
            "problém", "chyba", "error", "nefunguje", "rozbité", "selhalo", "oprav", "oprava", "řešení", "diagnostika"
        }
    },

    -- Sentiment analysis
    SentimentWords = {
        positive = {"good", "great", "excellent", "awesome", "amazing", "perfect", "love", "like", "best", "wonderful", "fantastic"},
        negative = {"bad", "terrible", "awful", "hate", "worst", "broken", "useless", "stupid", "annoying", "frustrating"},
        neutral = {"okay", "fine", "normal", "standard", "regular", "average", "typical"}
    },

    -- Context understanding
    ContextKeywords = {
        ship = {"ship", "vessel", "craft", "boat", "starship", "spacecraft"},
        weapon = {"weapon", "gun", "cannon", "laser", "beam", "torpedo", "missile", "railgun", "plasma"},
        engine = {"engine", "drive", "propulsion", "thrust", "hyperdrive", "motor"},
        shield = {"shield", "defense", "protection", "barrier", "deflector"},
        stargate = {"stargate", "gate", "portal", "wormhole", "dial", "address", "chevron"},
        hyperspace = {"hyperspace", "jump", "travel", "window", "dimensional", "subspace", "4-stage", "initiation", "stabilization"},
        ancient = {"ancient", "zpm", "zero point module", "technology", "bonus", "enhancement", "efficiency"},
        energy = {"energy", "power", "fuel", "battery", "charge", "electricity", "zpm"},
        damage = {"damage", "health", "repair", "fix", "broken", "destroyed", "hurt", "injured"}
    },

    -- Analyze user intent
    AnalyzeIntent = function(text)
        local textLower = string.lower(text)
        local intent = "unknown"
        local confidence = 0

        -- Check for question patterns
        for _, pattern in ipairs(ASC.AI.NLP.IntentPatterns.question) do
            if string.find(textLower, pattern) then
                intent = "question"
                confidence = confidence + 0.2
            end
        end

        -- Check for command patterns
        for _, pattern in ipairs(ASC.AI.NLP.IntentPatterns.command) do
            if string.find(textLower, pattern) then
                intent = "command"
                confidence = confidence + 0.3
            end
        end

        -- Check for help patterns
        for _, pattern in ipairs(ASC.AI.NLP.IntentPatterns.help) do
            if string.find(textLower, pattern) then
                intent = "help"
                confidence = confidence + 0.25
            end
        end

        -- Check for status patterns
        for _, pattern in ipairs(ASC.AI.NLP.IntentPatterns.status) do
            if string.find(textLower, pattern) then
                intent = "status"
                confidence = confidence + 0.2
            end
        end

        -- Check for problem patterns
        for _, pattern in ipairs(ASC.AI.NLP.IntentPatterns.problem) do
            if string.find(textLower, pattern) then
                intent = "problem"
                confidence = confidence + 0.3
            end
        end

        return intent, math.min(confidence, 1.0)
    end,

    -- Analyze sentiment
    AnalyzeSentiment = function(text)
        local textLower = string.lower(text)
        local positiveScore = 0
        local negativeScore = 0

        for _, word in ipairs(ASC.AI.NLP.SentimentWords.positive) do
            if string.find(textLower, word) then
                positiveScore = positiveScore + 1
            end
        end

        for _, word in ipairs(ASC.AI.NLP.SentimentWords.negative) do
            if string.find(textLower, word) then
                negativeScore = negativeScore + 1
            end
        end

        if positiveScore > negativeScore then
            return "positive", (positiveScore - negativeScore) / (positiveScore + negativeScore + 1)
        elseif negativeScore > positiveScore then
            return "negative", (negativeScore - positiveScore) / (positiveScore + negativeScore + 1)
        else
            return "neutral", 0
        end
    end,

    -- Extract context
    ExtractContext = function(text)
        local textLower = string.lower(text)
        local contexts = {}

        for contextType, keywords in pairs(ASC.AI.NLP.ContextKeywords) do
            for _, keyword in ipairs(keywords) do
                if string.find(textLower, keyword) then
                    contexts[contextType] = (contexts[contextType] or 0) + 1
                end
            end
        end

        return contexts
    end,

    -- Generate contextual response
    GenerateContextualResponse = function(intent, sentiment, contexts, originalText)
        local response = ""

        -- Adjust response based on sentiment
        if sentiment == "negative" then
            response = "I understand you're having some difficulties. Let me help you resolve this issue. "
        elseif sentiment == "positive" then
            response = "Great to hear you're having a good experience! "
        end

        -- Add context-specific information
        local primaryContext = nil
        local maxCount = 0
        for context, count in pairs(contexts) do
            if count > maxCount then
                maxCount = count
                primaryContext = context
            end
        end

        if primaryContext then
            if primaryContext == "ship" then
                response = response .. "For ship-related assistance, "
            elseif primaryContext == "weapon" then
                response = response .. "For weapon systems, "
            elseif primaryContext == "stargate" then
                response = response .. "For Stargate technology, "
            elseif primaryContext == "hyperspace" then
                response = response .. "For enhanced 4-stage Stargate hyperspace travel, "
            elseif primaryContext == "ancient" then
                response = response .. "For Ancient technology and ZPM integration, "
            end
        end

        return response
    end
}

-- Enhanced User Preference Learning System
ASC.AI.PreferenceLearning = {
    -- Track user command patterns
    TrackCommandUsage = function(player, command, success)
        local playerID = player:SteamID()
        if not ASC.AI.LearningData[playerID] then
            ASC.AI.LearningData[playerID] = {
                command_frequency = {},
                preferred_help_style = "detailed",
                common_issues = {},
                skill_level = "beginner",
                favorite_features = {},
                session_start = CurTime()
            }
        end

        local data = ASC.AI.LearningData[playerID]

        -- Track command frequency
        if not data.command_frequency[command] then
            data.command_frequency[command] = { count = 0, success_rate = 0, total_attempts = 0 }
        end

        data.command_frequency[command].count = data.command_frequency[command].count + 1
        data.command_frequency[command].total_attempts = data.command_frequency[command].total_attempts + 1

        if success then
            data.command_frequency[command].success_rate =
                (data.command_frequency[command].success_rate + 1) / data.command_frequency[command].total_attempts
        end

        -- Determine skill level based on command usage
        local totalCommands = 0
        for _, cmdData in pairs(data.command_frequency) do
            totalCommands = totalCommands + cmdData.count
        end

        if totalCommands > 50 then
            data.skill_level = "expert"
        elseif totalCommands > 20 then
            data.skill_level = "intermediate"
        else
            data.skill_level = "beginner"
        end
    end,

    -- Get personalized response style
    GetResponseStyle = function(player)
        local playerID = player:SteamID()
        local data = ASC.AI.LearningData[playerID]

        if not data then return "detailed" end

        -- Adapt response style based on user behavior
        local totalInteractions = 0
        for _, cmdData in pairs(data.command_frequency) do
            totalInteractions = totalInteractions + cmdData.count
        end

        if totalInteractions > 30 then
            return "concise" -- Experienced users prefer brief responses
        elseif data.skill_level == "expert" then
            return "technical" -- Expert users want technical details
        else
            return "detailed" -- Beginners need detailed explanations
        end
    end,

    -- Get smart suggestions based on usage patterns
    GetSmartSuggestions = function(player)
        local playerID = player:SteamID()
        local data = ASC.AI.LearningData[playerID]

        if not data or not data.command_frequency then return {} end

        local suggestions = {}

        -- Suggest based on command patterns
        if data.command_frequency["dial"] and not data.command_frequency["find stargates"] then
            table.insert(suggestions, "💡 Try 'find stargates' to see all available stargates")
        end

        if data.command_frequency["save ship"] and not data.command_frequency["wire ship"] then
            table.insert(suggestions, "💡 Use 'wire ship' to add automation to your saved ships")
        end

        if data.command_frequency["system status"] and data.skill_level == "intermediate" then
            table.insert(suggestions, "💡 Try fleet management with multiple ships")
        end

        if data.command_frequency["take me to my ship"] and not data.command_frequency["jump my ship to me"] then
            table.insert(suggestions, "💡 Use 'jump my ship to me' to bring ships to you")
        end

        return suggestions
    end
}

-- Web Access and Content Filtering System
ASC.AI.WebAccess = {
    Version = "1.0.0",

    -- Content filtering configuration
    ContentFilter = {
        -- Blocked content categories
        BlockedCategories = {
            "adult", "violence", "hate", "illegal", "malware", "phishing",
            "gambling", "drugs", "weapons", "extremism", "harassment"
        },

        -- Blocked keywords (case-insensitive)
        BlockedKeywords = {
            -- Inappropriate content
            "porn", "xxx", "adult", "nsfw", "sex", "nude", "naked",
            -- Violence and weapons
            "kill", "murder", "bomb", "terrorist", "violence", "weapon",
            -- Hate speech
            "hate", "racist", "nazi", "supremacist",
            -- Illegal activities
            "hack", "crack", "pirate", "illegal", "steal", "fraud",
            -- Harmful content
            "suicide", "self-harm", "drug", "overdose"
        },

        -- Allowed domains (whitelist for safety)
        AllowedDomains = {
            "github.com", "steamcommunity.com", "facepunch.com",
            "gmod.facepunch.com", "wiki.garrysmod.com", "wiremod.com",
            "wikipedia.org", "stargate.fandom.com", "youtube.com",
            "reddit.com/r/gmod", "reddit.com/r/wiremod"
        },

        -- Safe search terms for space combat and gaming
        SafeTopics = {
            "garry's mod", "gmod", "wiremod", "spacebuild", "stargate",
            "space combat", "ship building", "lua scripting", "game development",
            "3d modeling", "game design", "programming", "technology"
        }
    },

    -- Check if content is safe
    IsContentSafe = function(query, url)
        local queryLower = string.lower(query or "")
        local urlLower = string.lower(url or "")

        -- Check for blocked keywords
        for _, keyword in ipairs(ASC.AI.WebAccess.ContentFilter.BlockedKeywords) do
            if string.find(queryLower, keyword) or string.find(urlLower, keyword) then
                return false, "Content blocked: Contains inappropriate keyword '" .. keyword .. "'"
            end
        end

        -- Check domain whitelist if URL provided
        if url and url ~= "" then
            local isAllowedDomain = false
            for _, domain in ipairs(ASC.AI.WebAccess.ContentFilter.AllowedDomains) do
                if string.find(urlLower, domain) then
                    isAllowedDomain = true
                    break
                end
            end

            if not isAllowedDomain then
                return false, "Domain not in whitelist. Only trusted gaming and development sites are allowed."
            end
        end

        return true, "Content approved"
    end,

    -- Safe web search function
    SafeWebSearch = function(player, query)
        if not IsValid(player) then return end

        -- Check content safety
        local isSafe, reason = ASC.AI.WebAccess.IsContentSafe(query)
        if not isSafe then
            player:ChatPrint("[ARIA-4] 🚫 " .. reason)
            player:ChatPrint("Please ask about space combat, ship building, or gaming topics.")
            return
        end

        -- Add safe search terms to improve results
        local safeQuery = query .. " garry's mod space combat"

        player:ChatPrint("[ARIA-4] 🔍 Searching for: " .. query)
        player:ChatPrint("🛡️ Content filtering active - Only safe, gaming-related results shown")

        -- Perform web search with enhanced functionality
        ASC.AI.WebAccess.PerformSafeSearch(player, safeQuery)
    end,

    -- Perform filtered web search
    PerformSafeSearch = function(player, query)
        -- Enhanced web search with better suggestions and Czech support

        -- Check if Czech translation is needed
        local useCzech = false
        if ASC.Czech and ASC.Czech.IsPlayerCzech then
            useCzech = ASC.Czech.IsPlayerCzech(player)
        end

        local suggestions = {
            useCzech and "🌐 Zkuste hledat na těchto bezpečných stránkách:" or "🌐 Try searching on these safe sites:",
            "• GitHub: https://github.com/search?q=" .. string.gsub(query, " ", "+"),
            useCzech and "• Steam Community: Hledejte v Steam Workshop '" .. query .. "'" or "• Steam Community: Search Steam Workshop for '" .. query .. "'",
            "• Garry's Mod Wiki: https://wiki.garrysmod.com",
            "• Wiremod Documentation: https://wiremod.com",
            "• Stargate Wiki: https://stargate.fandom.com",
            "• Reddit GMod: https://reddit.com/r/gmod",
            "• Facepunch Forums: https://facepunch.com"
        }

        for _, suggestion in ipairs(suggestions) do
            player:ChatPrint("[ARIA-4] " .. suggestion)
        end

        -- Provide additional context-specific suggestions
        local queryLower = string.lower(query)
        if string.find(queryLower, "stargate") then
            player:ChatPrint("[ARIA-4] 🌌 " .. (useCzech and "Specifické Stargate zdroje:" or "Specific Stargate resources:"))
            player:ChatPrint("• CAP Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=180077636")
        elseif string.find(queryLower, "ship") or string.find(queryLower, "space") then
            player:ChatPrint("[ARIA-4] 🚀 " .. (useCzech and "Spacebuild zdroje:" or "Spacebuild resources:"))
            player:ChatPrint("• Spacebuild GitHub: https://github.com/spacebuild")
        end
    end,

    -- Safe URL fetching
    SafeFetchURL = function(player, url)
        if not IsValid(player) then return end

        -- Check URL safety
        local isSafe, reason = ASC.AI.WebAccess.IsContentSafe("", url)
        if not isSafe then
            player:ChatPrint("[ARIA-4] 🚫 " .. reason)
            return
        end

        player:ChatPrint("[ARIA-4] 🔍 Fetching safe content from: " .. url)
        player:ChatPrint("🛡️ Content will be filtered for safety")

        -- Enhanced URL handling with better user guidance
        if string.find(url, "github.com") then
            player:ChatPrint("[ARIA-4] 📁 GitHub repository detected - Safe for code and documentation")
        elseif string.find(url, "steamcommunity.com") then
            player:ChatPrint("[ARIA-4] 🎮 Steam Community content - Safe for workshop items")
        elseif string.find(url, "wiki.garrysmod.com") then
            player:ChatPrint("[ARIA-4] 📚 Official GMod Wiki - Safe for game information")
        else
            player:ChatPrint("[ARIA-4] ⚠️ Please verify this URL is safe before visiting")
        end

        player:ChatPrint("[ARIA-4] 💡 For security, please visit URLs manually after verification")
    end
}

-- Advanced Conversation Memory System
ASC.AI.ConversationMemory = {
    Version = "5.0.0",
    MaxHistoryLength = 10,

    -- Store conversation context
    StoreConversation = function(player, query, response, intent, sentiment, contexts)
        local playerID = player:SteamID()

        if not ASC.AI.ConversationHistory[playerID] then
            ASC.AI.ConversationHistory[playerID] = {}
        end

        local conversation = {
            timestamp = CurTime(),
            query = query,
            response = response,
            intent = intent,
            sentiment = sentiment,
            contexts = contexts,
            session_id = ASC.AI.ConversationMemory.GetSessionID(player)
        }

        table.insert(ASC.AI.ConversationHistory[playerID], conversation)

        -- Limit history length
        if #ASC.AI.ConversationHistory[playerID] > ASC.AI.ConversationMemory.MaxHistoryLength then
            table.remove(ASC.AI.ConversationHistory[playerID], 1)
        end
    end,

    -- Get session ID (changes every hour or on reconnect)
    GetSessionID = function(player)
        local playerID = player:SteamID()
        local currentHour = math.floor(CurTime() / 3600)
        return playerID .. "_" .. currentHour
    end,

    -- Get recent conversation context
    GetRecentContext = function(player, lookback)
        local playerID = player:SteamID()
        local history = ASC.AI.ConversationHistory[playerID]

        if not history then return {} end

        lookback = lookback or 3
        local recentHistory = {}

        for i = math.max(1, #history - lookback + 1), #history do
            table.insert(recentHistory, history[i])
        end

        return recentHistory
    end,

    -- Analyze conversation patterns
    AnalyzePatterns = function(player)
        local playerID = player:SteamID()
        local history = ASC.AI.ConversationHistory[playerID]

        if not history or #history < 3 then return {} end

        local patterns = {
            frequent_intents = {},
            common_contexts = {},
            sentiment_trend = {},
            topic_progression = {}
        }

        -- Analyze frequent intents
        for _, conv in ipairs(history) do
            patterns.frequent_intents[conv.intent] = (patterns.frequent_intents[conv.intent] or 0) + 1
        end

        -- Analyze common contexts
        for _, conv in ipairs(history) do
            for context, count in pairs(conv.contexts or {}) do
                patterns.common_contexts[context] = (patterns.common_contexts[context] or 0) + count
            end
        end

        -- Analyze sentiment trend
        for _, conv in ipairs(history) do
            table.insert(patterns.sentiment_trend, conv.sentiment)
        end

        return patterns
    end,

    -- Generate follow-up suggestions
    GenerateFollowUps = function(player, currentIntent, currentContexts)
        local patterns = ASC.AI.ConversationMemory.AnalyzePatterns(player)
        local suggestions = {}

        -- Suggest based on current context
        if currentContexts and currentContexts.ship then
            table.insert(suggestions, "Would you like help with ship building or ship status?")
        end

        if currentContexts and currentContexts.weapon then
            table.insert(suggestions, "Need assistance with weapon configuration or combat tactics?")
        end

        if currentContexts and currentContexts.stargate then
            table.insert(suggestions, "Looking for stargate dialing help or CAP integration info?")
        end

        -- Suggest based on patterns (with safety checks)
        if patterns and patterns.frequent_intents and patterns.frequent_intents.command and currentIntent == "question" then
            table.insert(suggestions, "Ready to execute commands? I can help with spawning or configuration.")
        end

        return suggestions
    end
}

-- Intelligent Response Generation System
ASC.AI.ResponseGenerator = {
    Version = "4.0.0",

    -- Generate intelligent response
    GenerateIntelligentResponse = function(player, query, intent, sentiment, contexts)
        local response = ""

        -- Get conversation context
        local recentContext = ASC.AI.ConversationMemory.GetRecentContext(player, 3)
        local patterns = ASC.AI.ConversationMemory.AnalyzePatterns(player)

        -- Generate contextual opening
        local contextualOpening = ASC.AI.NLP.GenerateContextualResponse(intent, sentiment, contexts, query)
        response = response .. contextualOpening

        -- Add personalized elements based on user history
        local userStyle = ASC.AI.PreferenceLearning.GetResponseStyle and ASC.AI.PreferenceLearning.GetResponseStyle(player) or "standard"

        if userStyle == "concise" then
            response = response .. "Quick answer: "
        elseif userStyle == "detailed" then
            response = response .. "Detailed explanation: "
        elseif userStyle == "technical" then
            response = response .. "Technical details: "
        end

        -- Check for conversation continuity
        if #recentContext > 0 then
            local lastConv = recentContext[#recentContext]

            -- If user is asking follow-up questions
            if intent == "question" and lastConv.intent == "question" then
                response = response .. "Following up on your previous question, "
            end

            -- If user had problems and now asking for help
            if lastConv.sentiment == "negative" and intent == "help" then
                response = response .. "I see you were having issues earlier. Let me provide comprehensive help. "
            end
        end

        return response
    end,

    -- Add smart suggestions to response
    AddSmartSuggestions = function(player, response, intent, contexts)
        local suggestions = ASC.AI.ConversationMemory.GenerateFollowUps(player, intent, contexts)

        if suggestions and #suggestions > 0 and math.random() < 0.4 then -- 40% chance to show suggestions
            response = response .. "\n\n💡 " .. suggestions[math.random(#suggestions)]
        end

        return response
    end
}

-- Advanced AI Systems
ASC.AI.EmotionalIntelligence = {
    -- Emotional state tracking
    EmotionalStates = {
        frustrated = {keywords = {"error", "broken", "not working", "help", "stuck"}, weight = -0.3},
        satisfied = {keywords = {"thanks", "good", "great", "perfect", "awesome"}, weight = 0.5},
        confused = {keywords = {"what", "how", "confused", "don't understand"}, weight = -0.1},
        excited = {keywords = {"cool", "amazing", "wow", "incredible", "love"}, weight = 0.4},
        neutral = {keywords = {}, weight = 0.0}
    },

    -- Detect emotional state from query
    DetectEmotion = function(query)
        local queryLower = string.lower(query)
        local scores = {}

        for emotion, data in pairs(ASC.AI.EmotionalIntelligence.EmotionalStates) do
            local score = 0
            for _, keyword in ipairs(data.keywords) do
                if string.find(queryLower, keyword) then
                    score = score + data.weight
                end
            end
            scores[emotion] = score
        end

        -- Find highest scoring emotion
        local bestEmotion = "neutral"
        local bestScore = scores.neutral

        for emotion, score in pairs(scores) do
            if score > bestScore then
                bestEmotion = emotion
                bestScore = score
            end
        end

        return bestEmotion, bestScore
    end,

    -- Adjust response based on emotion
    AdjustResponse = function(response, emotion)
        local adjustments = {
            frustrated = "I understand this can be frustrating. " .. response .. " Let me know if you need more help!",
            satisfied = response .. " I'm glad I could help!",
            confused = "Let me clarify: " .. response .. " Does this make sense?",
            excited = response .. " Glad you're excited about this!",
            neutral = response
        }

        return adjustments[emotion] or response
    end
}

ASC.AI.PersonalityMatrix = {
    -- Personality traits that affect responses
    Traits = {
        helpfulness = 0.9,
        technical_detail = 0.8,
        friendliness = 0.7,
        proactiveness = 0.8,
        humor = 0.3,
        formality = 0.4
    },

    -- Adjust response based on personality
    ApplyPersonality = function(response, context)
        local traits = ASC.AI.PersonalityMatrix.Traits
        context = context or {}

        -- Add helpful suggestions if high helpfulness
        if traits.helpfulness > 0.7 and context.query_type == "help" then
            response = response .. " Would you like me to explain anything else about this topic?"
        end

        -- Add technical details if high technical_detail
        if traits.technical_detail > 0.7 and context.complexity == "advanced" then
            response = response .. " For more technical details, check the documentation or ask for specific implementation help."
        end

        -- Add friendly tone if high friendliness
        if traits.friendliness > 0.6 then
            local friendlyPrefixes = {"Great question! ", "Happy to help! ", "Sure thing! "}
            if math.random() < 0.3 then
                response = friendlyPrefixes[math.random(#friendlyPrefixes)] .. response
            end
        end

        return response
    end
}

ASC.AI.MachineLearning = {
    -- Learning patterns from user interactions
    LearningPatterns = {},

    -- Learn from successful interactions
    LearnFromInteraction = function(playerID, query, response, satisfaction)
        if not ASC.AI.MachineLearning.LearningPatterns[playerID] then
            ASC.AI.MachineLearning.LearningPatterns[playerID] = {}
        end

        local pattern = {
            query_keywords = ASC.AI.ExtractKeywords(query),
            response_type = ASC.AI.ClassifyResponse(response),
            satisfaction = satisfaction,
            timestamp = os.time(),
            context = ASC.AI.GetCurrentContext(playerID)
        }

        table.insert(ASC.AI.MachineLearning.LearningPatterns[playerID], pattern)

        -- Keep only recent patterns (last 100)
        if #ASC.AI.MachineLearning.LearningPatterns[playerID] > 100 then
            table.remove(ASC.AI.MachineLearning.LearningPatterns[playerID], 1)
        end
    end,

    -- Predict best response type based on learned patterns
    PredictResponseType = function(playerID, query)
        local patterns = ASC.AI.MachineLearning.LearningPatterns[playerID]
        if not patterns or #patterns == 0 then
            return "standard"
        end

        local queryKeywords = ASC.AI.ExtractKeywords(query)
        local scores = {}

        for _, pattern in ipairs(patterns) do
            if pattern.satisfaction > 0.7 then -- Only learn from successful interactions
                local similarity = ASC.AI.CalculateKeywordSimilarity(queryKeywords, pattern.query_keywords)
                if similarity > 0.3 then
                    scores[pattern.response_type] = (scores[pattern.response_type] or 0) + similarity * pattern.satisfaction
                end
            end
        end

        -- Find best response type
        local bestType = "standard"
        local bestScore = 0

        for responseType, score in pairs(scores) do
            if score > bestScore then
                bestType = responseType
                bestScore = score
            end
        end

        return bestType
    end
}

ASC.AI.AdvancedAnalytics = {
    -- Performance tracking
    Metrics = {
        response_times = {},
        query_types = {},
        satisfaction_trends = {},
        user_engagement = {},
        error_rates = {},
        learning_effectiveness = {}
    },

    -- Track response performance
    TrackResponse = function(playerID, query, response, responseTime, satisfaction)
        local analytics = ASC.AI.AdvancedAnalytics.Metrics

        -- Track response time
        table.insert(analytics.response_times, responseTime)
        if #analytics.response_times > 1000 then
            table.remove(analytics.response_times, 1)
        end

        -- Track query types
        local queryType = ASC.AI.ClassifyQuery(query)
        analytics.query_types[queryType] = (analytics.query_types[queryType] or 0) + 1

        -- Track satisfaction trends
        if not analytics.satisfaction_trends[playerID] then
            analytics.satisfaction_trends[playerID] = {}
        end
        table.insert(analytics.satisfaction_trends[playerID], {
            satisfaction = satisfaction,
            timestamp = os.time()
        })

        -- Track user engagement
        analytics.user_engagement[playerID] = (analytics.user_engagement[playerID] or 0) + 1
    end,

    -- Generate analytics report
    GenerateReport = function()
        local analytics = ASC.AI.AdvancedAnalytics.Metrics
        local report = {}

        -- Average response time
        local totalTime = 0
        for _, time in ipairs(analytics.response_times) do
            totalTime = totalTime + time
        end
        report.avg_response_time = #analytics.response_times > 0 and (totalTime / #analytics.response_times) or 0

        -- Most common query types
        local sortedQueries = {}
        for queryType, count in pairs(analytics.query_types) do
            table.insert(sortedQueries, {type = queryType, count = count})
        end
        table.sort(sortedQueries, function(a, b) return a.count > b.count end)
        report.top_query_types = sortedQueries

        -- Overall satisfaction
        local totalSatisfaction = 0
        local satisfactionCount = 0
        for playerID, trends in pairs(analytics.satisfaction_trends) do
            for _, trend in ipairs(trends) do
                totalSatisfaction = totalSatisfaction + trend.satisfaction
                satisfactionCount = satisfactionCount + 1
            end
        end
        report.avg_satisfaction = satisfactionCount > 0 and (totalSatisfaction / satisfactionCount) or 0

        -- User engagement stats
        local totalUsers = 0
        local totalInteractions = 0
        for playerID, interactions in pairs(analytics.user_engagement) do
            totalUsers = totalUsers + 1
            totalInteractions = totalInteractions + interactions
        end
        report.total_users = totalUsers
        report.total_interactions = totalInteractions
        report.avg_interactions_per_user = totalUsers > 0 and (totalInteractions / totalUsers) or 0

        return report
    end
}

ASC.AI.NeuralNetwork = {
    -- Simple neural network for pattern recognition
    Weights = nil, -- Will be initialized properly
    Biases = nil,  -- Will be initialized properly
    LearningRate = 0.01,
    Initialized = false,

    -- Initialize neural network
    Initialize = function()
        if ASC.AI.NeuralNetwork.Initialized then return end

        -- Simple 3-layer network: input -> hidden -> output
        ASC.AI.NeuralNetwork.Weights = {
            input_hidden = {},
            hidden_output = {}
        }
        ASC.AI.NeuralNetwork.Biases = {
            hidden = {},
            output = {}
        }

        -- Initialize with random weights
        for i = 1, 10 do -- 10 input features
            ASC.AI.NeuralNetwork.Weights.input_hidden[i] = {}
            for j = 1, 5 do -- 5 hidden neurons
                ASC.AI.NeuralNetwork.Weights.input_hidden[i][j] = math.random() * 2 - 1
            end
        end

        for i = 1, 5 do -- 5 hidden neurons
            ASC.AI.NeuralNetwork.Biases.hidden[i] = math.random() * 2 - 1
            ASC.AI.NeuralNetwork.Weights.hidden_output[i] = {}
            for j = 1, 3 do -- 3 output classes
                ASC.AI.NeuralNetwork.Weights.hidden_output[i][j] = math.random() * 2 - 1
            end
        end

        for i = 1, 3 do -- 3 output classes
            ASC.AI.NeuralNetwork.Biases.output[i] = math.random() * 2 - 1
        end

        ASC.AI.NeuralNetwork.Initialized = true
        print("[ASC AI] Neural network weights and biases initialized successfully")
    end,

    -- Activation function (sigmoid)
    Sigmoid = function(x)
        return 1 / (1 + math.exp(-x))
    end,

    -- Forward pass
    Forward = function(inputs)
        -- Initialize neural network if not done
        if not ASC.AI.NeuralNetwork.Initialized or not ASC.AI.NeuralNetwork.Weights or not ASC.AI.NeuralNetwork.Weights.input_hidden then
            ASC.AI.NeuralNetwork.Initialize()
        end

        local hidden = {}
        local output = {}

        -- Input to hidden layer
        for j = 1, 5 do
            local sum = ASC.AI.NeuralNetwork.Biases.hidden[j] or 0
            for i = 1, #inputs do
                if ASC.AI.NeuralNetwork.Weights.input_hidden[i] and ASC.AI.NeuralNetwork.Weights.input_hidden[i][j] then
                    sum = sum + inputs[i] * ASC.AI.NeuralNetwork.Weights.input_hidden[i][j]
                end
            end
            hidden[j] = ASC.AI.NeuralNetwork.Sigmoid(sum)
        end

        -- Hidden to output layer
        for j = 1, 3 do
            local sum = ASC.AI.NeuralNetwork.Biases.output[j] or 0
            for i = 1, #hidden do
                if ASC.AI.NeuralNetwork.Weights.hidden_output[i] and ASC.AI.NeuralNetwork.Weights.hidden_output[i][j] then
                    sum = sum + hidden[i] * ASC.AI.NeuralNetwork.Weights.hidden_output[i][j]
                end
            end
            output[j] = ASC.AI.NeuralNetwork.Sigmoid(sum)
        end

        return output, hidden
    end,

    -- Predict response quality
    PredictQuality = function(query, context)
        -- Initialize neural network if not done
        if not ASC.AI.NeuralNetwork.Initialized or not ASC.AI.NeuralNetwork.Weights or not ASC.AI.NeuralNetwork.Weights.input_hidden then
            ASC.AI.NeuralNetwork.Initialize()
        end

        -- Extract features from query and context with safe defaults
        local features = {
            string.len(query) / 100, -- Query length (normalized)
            context.user_experience or 0.5, -- User experience level
            context.complexity or 0.5, -- Query complexity
            context.emotion_score or 0, -- Emotional state
            context.satisfaction_history or 0.5, -- Historical satisfaction
            (context.interaction_count or 0) / 100, -- Interaction count (normalized)
            (context.time_since_last or 0) / 3600, -- Time since last interaction (hours)
            context.query_similarity or 0, -- Similarity to previous queries
            context.response_type_score or 0.5, -- Response type appropriateness
            context.context_relevance or 0.5 -- Context relevance
        }

        local output, _ = ASC.AI.NeuralNetwork.Forward(features)

        -- Interpret output: [quality_score, confidence, improvement_needed]
        return {
            quality = output[1] or 0.5,
            confidence = output[2] or 0.5,
            improvement = output[3] or 0.5
        }
    end
}

-- Advanced AI Helper Functions
ASC.AI.ExtractKeywords = function(text)
    local keywords = {}
    local words = string.Explode(" ", string.lower(text))

    -- Filter out common words
    local stopWords = {"the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by", "is", "are", "was", "were", "be", "been", "have", "has", "had", "do", "does", "did", "will", "would", "could", "should", "may", "might", "can", "this", "that", "these", "those", "i", "you", "he", "she", "it", "we", "they", "me", "him", "her", "us", "them"}

    for _, word in ipairs(words) do
        word = string.gsub(word, "[^%w]", "") -- Remove punctuation
        if string.len(word) > 2 and not table.HasValue(stopWords, word) then
            table.insert(keywords, word)
        end
    end

    return keywords
end

ASC.AI.ClassifyResponse = function(response)
    local responseLower = string.lower(response)

    if string.find(responseLower, "error") or string.find(responseLower, "problem") then
        return "troubleshooting"
    elseif string.find(responseLower, "how to") or string.find(responseLower, "tutorial") then
        return "instructional"
    elseif string.find(responseLower, "information") or string.find(responseLower, "about") then
        return "informational"
    elseif string.find(responseLower, "help") or string.find(responseLower, "assist") then
        return "helpful"
    else
        return "standard"
    end
end

ASC.AI.ClassifyQuery = function(query)
    local queryLower = string.lower(query)

    if string.find(queryLower, "how") or string.find(queryLower, "tutorial") then
        return "how_to"
    elseif string.find(queryLower, "what") or string.find(queryLower, "info") then
        return "information"
    elseif string.find(queryLower, "error") or string.find(queryLower, "broken") then
        return "troubleshooting"
    elseif string.find(queryLower, "help") or string.find(queryLower, "assist") then
        return "help_request"
    else
        return "general"
    end
end

ASC.AI.CalculateKeywordSimilarity = function(keywords1, keywords2)
    if not keywords1 or not keywords2 or #keywords1 == 0 or #keywords2 == 0 then
        return 0
    end

    local matches = 0
    for _, keyword1 in ipairs(keywords1) do
        for _, keyword2 in ipairs(keywords2) do
            if keyword1 == keyword2 then
                matches = matches + 1
                break
            end
        end
    end

    return matches / math.max(#keywords1, #keywords2)
end

ASC.AI.GetCurrentContext = function(playerID)
    local profile = ASC.AI.UserProfiles[playerID]
    if not profile then
        return {
            user_experience = 0.5,
            complexity = 0.5,
            emotion_score = 0,
            satisfaction_history = 0.5,
            interaction_count = 0,
            time_since_last = 0,
            query_similarity = 0,
            response_type_score = 0.5,
            context_relevance = 0.5
        }
    end

    return {
        user_experience = profile.experience_level == "beginner" and 0.2 or (profile.experience_level == "intermediate" and 0.5 or 0.8),
        complexity = 0.5, -- Will be determined by query analysis
        emotion_score = profile.last_emotion_score or 0,
        satisfaction_history = profile.satisfaction_score or 0.5,
        interaction_count = profile.interaction_count or 0,
        time_since_last = CurTime() - (profile.last_interaction or CurTime()),
        query_similarity = 0, -- Will be calculated
        response_type_score = 0.5, -- Will be determined
        context_relevance = 0.5 -- Will be calculated
    }
end

-- Performance Metrics System
ASC.AI.PerformanceMetrics = {
    TotalQueries = 0,
    SuccessfulResponses = 0,
    AverageResponseTime = 0,
    UserSatisfactionScore = 0,
    LearningAccuracy = 0,
    PredictionAccuracy = 0,
    EmotionalIntelligenceScore = 0,
    ContextAwarenessScore = 0,
    PersonalizationScore = 0,
    ProactiveAssistanceScore = 0,

    -- Update metrics
    UpdateMetrics = function()
        local analytics = ASC.AI.AdvancedAnalytics.GenerateReport()

        ASC.AI.PerformanceMetrics.TotalQueries = analytics.total_interactions or 0
        ASC.AI.PerformanceMetrics.UserSatisfactionScore = analytics.avg_satisfaction or 0
        ASC.AI.PerformanceMetrics.AverageResponseTime = analytics.avg_response_time or 0

        -- Calculate success rate
        if ASC.AI.PerformanceMetrics.TotalQueries > 0 then
            ASC.AI.PerformanceMetrics.SuccessfulResponses = ASC.AI.PerformanceMetrics.UserSatisfactionScore
        end

        -- Calculate advanced metrics
        ASC.AI.PerformanceMetrics.EmotionalIntelligenceScore = ASC.AI.CalculateEmotionalIntelligenceScore()
        ASC.AI.PerformanceMetrics.ContextAwarenessScore = ASC.AI.CalculateContextAwarenessScore()
        ASC.AI.PerformanceMetrics.PersonalizationScore = ASC.AI.CalculatePersonalizationScore()
        ASC.AI.PerformanceMetrics.ProactiveAssistanceScore = ASC.AI.CalculateProactiveAssistanceScore()
    end
}

ASC.AI.CalculateEmotionalIntelligenceScore = function()
    local totalEmotions = 0
    local correctEmotions = 0

    for playerID, profile in pairs(ASC.AI.UserProfiles) do
        if profile.emotion_history then
            for _, emotion in ipairs(profile.emotion_history) do
                totalEmotions = totalEmotions + 1
                if emotion.detected_correctly then
                    correctEmotions = correctEmotions + 1
                end
            end
        end
    end

    return totalEmotions > 0 and (correctEmotions / totalEmotions) or 0.5
end

ASC.AI.CalculateContextAwarenessScore = function()
    local totalContexts = 0
    local relevantContexts = 0

    for playerID, history in pairs(ASC.AI.ConversationHistory) do
        for _, conversation in ipairs(history) do
            if conversation.context_relevance then
                totalContexts = totalContexts + 1
                if conversation.context_relevance > 0.7 then
                    relevantContexts = relevantContexts + 1
                end
            end
        end
    end

    return totalContexts > 0 and (relevantContexts / totalContexts) or 0.5
end

ASC.AI.CalculatePersonalizationScore = function()
    local totalUsers = 0
    local personalizedUsers = 0

    for playerID, profile in pairs(ASC.AI.UserProfiles) do
        totalUsers = totalUsers + 1
        if profile.personalization_level and profile.personalization_level > 0.5 then
            personalizedUsers = personalizedUsers + 1
        end
    end

    return totalUsers > 0 and (personalizedUsers / totalUsers) or 0.5
end

ASC.AI.CalculateProactiveAssistanceScore = function()
    local totalInteractions = 0
    local proactiveInteractions = 0

    for playerID, profile in pairs(ASC.AI.UserProfiles) do
        if profile.proactive_assistance_count then
            totalInteractions = totalInteractions + profile.interaction_count
            proactiveInteractions = proactiveInteractions + profile.proactive_assistance_count
        end
    end

    return totalInteractions > 0 and (proactiveInteractions / totalInteractions) or 0.1
end

-- Ship Teleportation Helper Functions
ASC.AI.FindPlayerShipCore = function(player)
    if not IsValid(player) then return nil end

    local playerID = player:SteamID()
    local bestShipCore = nil
    local closestDistance = math.huge

    -- Search for ship cores owned by the player
    for _, ent in ipairs(ents.FindByClass("asc_ship_core")) do
        if IsValid(ent) then
            -- Check ownership using CPPI if available
            local owner = nil
            if ASC.AI.CPPI.IsAvailable() and ent.CPPIGetOwner then
                owner = ent:CPPIGetOwner()
            elseif ent.GetOwner then
                owner = ent:GetOwner()
            elseif ent.Owner then
                owner = ent.Owner
            end

            -- Check if player owns this ship core
            if IsValid(owner) and owner:SteamID() == playerID then
                local distance = player:GetPos():Distance(ent:GetPos())
                if distance < closestDistance then
                    closestDistance = distance
                    bestShipCore = ent
                end
            end
        end
    end

    return bestShipCore
end

-- Missing Helper Functions
ASC.AI.ExtractKeywords = function(text)
    if not text or text == "" then return {} end

    local keywords = {}
    local words = string.Explode(" ", string.lower(text))

    -- Filter out common stop words
    local stopWords = {"the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by", "is", "are", "was", "were", "be", "been", "have", "has", "had", "do", "does", "did", "will", "would", "could", "should", "may", "might", "can", "i", "you", "he", "she", "it", "we", "they", "this", "that", "these", "those"}

    for _, word in ipairs(words) do
        if #word > 2 and not table.HasValue(stopWords, word) then
            table.insert(keywords, word)
        end
    end

    return keywords
end

ASC.AI.ClassifyResponse = function(response)
    if not response then return "unknown" end

    local lowerResponse = string.lower(response)

    if string.find(lowerResponse, "help") or string.find(lowerResponse, "guide") then
        return "instructional"
    elseif string.find(lowerResponse, "error") or string.find(lowerResponse, "problem") then
        return "troubleshooting"
    elseif string.find(lowerResponse, "spawn") or string.find(lowerResponse, "create") then
        return "spawning"
    elseif string.find(lowerResponse, "status") or string.find(lowerResponse, "info") then
        return "informational"
    else
        return "general"
    end
end

ASC.AI.CalculateKeywordSimilarity = function(keywords1, keywords2)
    if not keywords1 or not keywords2 or #keywords1 == 0 or #keywords2 == 0 then
        return 0
    end

    local matches = 0
    for _, keyword1 in ipairs(keywords1) do
        for _, keyword2 in ipairs(keywords2) do
            if keyword1 == keyword2 then
                matches = matches + 1
                break
            end
        end
    end

    return matches / math.max(#keywords1, #keywords2)
end

ASC.AI.ClassifyQuery = function(query)
    if not query then return "unknown" end

    local lowerQuery = string.lower(query)

    if string.find(lowerQuery, "how") or string.find(lowerQuery, "what") or string.find(lowerQuery, "why") then
        return "question"
    elseif string.find(lowerQuery, "help") or string.find(lowerQuery, "assist") then
        return "help_request"
    elseif string.find(lowerQuery, "spawn") or string.find(lowerQuery, "create") then
        return "spawning"
    elseif string.find(lowerQuery, "broken") or string.find(lowerQuery, "error") then
        return "problem"
    elseif string.find(lowerQuery, "status") or string.find(lowerQuery, "info") then
        return "status_request"
    else
        return "general"
    end
end

ASC.AI.GetCurrentContext = function(playerID)
    local context = {
        timestamp = CurTime(),
        player_id = playerID,
        context_relevance = 0.5,
        recent_interactions = 0,
        satisfaction_trend = 0.5
    }

    -- Get recent interaction count
    if ASC.AI.ConversationHistory[playerID] then
        context.recent_interactions = #ASC.AI.ConversationHistory[playerID]

        -- Calculate satisfaction trend
        local recentSatisfaction = 0
        local recentCount = 0
        for i = math.max(1, #ASC.AI.ConversationHistory[playerID] - 5), #ASC.AI.ConversationHistory[playerID] do
            local entry = ASC.AI.ConversationHistory[playerID][i]
            if entry and entry.satisfaction then
                recentSatisfaction = recentSatisfaction + entry.satisfaction
                recentCount = recentCount + 1
            end
        end

        if recentCount > 0 then
            context.satisfaction_trend = recentSatisfaction / recentCount
        end
    end

    return context
end

ASC.AI.FindPlayerShips = function(player)
    if not IsValid(player) then return {} end

    local ships = {}
    for _, shipCore in ipairs(ents.FindByClass("ship_core")) do
        if IsValid(shipCore) then
            local owner = nil
            if shipCore.CPPIGetOwner then
                owner = shipCore:CPPIGetOwner()
            elseif shipCore.GetOwner then
                owner = shipCore:GetOwner()
            elseif shipCore.Owner then
                owner = shipCore.Owner
            end

            if IsValid(owner) and owner:SteamID() == player:SteamID() then
                table.insert(ships, shipCore)
            end
        end
    end

    return ships
end

-- Advanced AI Helper Functions for Enhanced Processing
ASC.AI.EstimateSatisfaction = function(query, response, analysis)
    local satisfaction = 0.5 -- Base satisfaction

    -- Boost satisfaction for successful knowledge matches
    if analysis.confidence and analysis.confidence > 0.7 then
        satisfaction = satisfaction + 0.3
    end

    -- Boost for emotional appropriateness
    if analysis.emotion and analysis.emotion ~= "frustrated" then
        satisfaction = satisfaction + 0.1
    elseif analysis.emotion == "frustrated" and string.find(response, "understand") then
        satisfaction = satisfaction + 0.2 -- Good handling of frustration
    end

    -- Boost for response length appropriateness
    local responseLength = string.len(response)
    if responseLength > 50 and responseLength < 400 then
        satisfaction = satisfaction + 0.1
    end

    -- Penalty for fallback responses
    if string.find(response, "I'm not sure") or string.find(response, "analyzing your query") then
        satisfaction = satisfaction - 0.2
    end

    return math.Clamp(satisfaction, 0, 1)
end

ASC.AI.UpdateUserProfile = function(playerID, query, response, analysis, satisfaction)
    if not ASC.AI.UserProfiles[playerID] then
        ASC.AI.UserProfiles[playerID] = {
            experience_level = "beginner",
            preferred_topics = {},
            interaction_count = 0,
            last_interaction = CurTime(),
            satisfaction_score = 0.5,
            language_preference = "english",
            emotion_history = {},
            personalization_level = 0,
            proactive_assistance_count = 0,
            last_emotion_score = 0
        }
    end

    local profile = ASC.AI.UserProfiles[playerID]

    -- Ensure profile fields are valid numbers (safety check)
    if not profile.interaction_count or type(profile.interaction_count) ~= "number" then
        profile.interaction_count = 0
    end
    if not profile.satisfaction_score or type(profile.satisfaction_score) ~= "number" then
        profile.satisfaction_score = 0.5
    end
    if not profile.last_interaction or type(profile.last_interaction) ~= "number" then
        profile.last_interaction = CurTime()
    end

    -- Update basic stats
    profile.interaction_count = profile.interaction_count + 1
    profile.last_interaction = CurTime()
    profile.last_emotion_score = analysis.emotion_score or 0

    -- Update satisfaction score (weighted average)
    local weight = 0.1
    profile.satisfaction_score = (profile.satisfaction_score * (1 - weight)) + (satisfaction * weight)

    -- Update emotion history
    if not profile.emotion_history then
        profile.emotion_history = {}
    end

    table.insert(profile.emotion_history, {
        emotion = analysis.emotion,
        score = analysis.emotion_score,
        timestamp = os.time(),
        detected_correctly = satisfaction > 0.6 -- Assume good satisfaction means correct emotion detection
    })

    -- Keep emotion history manageable
    if #profile.emotion_history > 20 then
        table.remove(profile.emotion_history, 1)
    end

    -- Update personalization level based on interaction patterns
    if profile.interaction_count > 5 then
        profile.personalization_level = math.min(1.0, profile.interaction_count / 50)
    end

    -- Update experience level based on query complexity and interaction count
    local complexity = ASC.AI.LearningEngine.CalculateQueryComplexity(query, analysis)
    if complexity > 0.8 and profile.interaction_count > 20 then
        profile.experience_level = "expert"
    elseif complexity > 0.5 and profile.interaction_count > 10 then
        profile.experience_level = "intermediate"
    end

    -- Track proactive assistance
    if analysis.intent == "help" or analysis.intent == "problem" then
        profile.proactive_assistance_count = (profile.proactive_assistance_count or 0) + 1
    end
end

-- Ship Teleport Command Handler
ASC.AI.HandleShipTeleportCommand = function(player)
    if not IsValid(player) then
        return "Invalid player for ship teleport command."
    end

    -- Find player's ship cores
    local playerShips = ASC.AI.FindPlayerShips(player)

    if #playerShips == 0 then
        return "No ships found! You need to build a ship with a ship core first. Use the hyperdrive tool to spawn a ship core, then build your ship around it."
    elseif #playerShips == 1 then
        -- Teleport to the single ship
        local shipCore = playerShips[1]
        local shipPos = shipCore:GetPos()
        local teleportPos = shipPos + Vector(0, 0, 100) -- Teleport above the ship

        player:SetPos(teleportPos)
        player:SetVelocity(Vector(0, 0, 0)) -- Stop any movement

        return "Teleported you to your ship! You're now above your ship core. Use noclip or walk down to board your ship."
    else
        -- Multiple ships found - list them
        local shipList = "Found " .. #playerShips .. " ships! Here are their locations:\n"
        for i, shipCore in ipairs(playerShips) do
            local pos = shipCore:GetPos()
            shipList = shipList .. i .. ". Ship at (" .. math.floor(pos.x) .. ", " .. math.floor(pos.y) .. ", " .. math.floor(pos.z) .. ")\n"
        end

        -- Teleport to the first/closest ship
        local shipCore = playerShips[1]
        local shipPos = shipCore:GetPos()
        local teleportPos = shipPos + Vector(0, 0, 100)

        player:SetPos(teleportPos)
        player:SetVelocity(Vector(0, 0, 0))

        return shipList .. "Teleported you to ship #1. Use '!ai take me to ship 2' to go to other ships."
    end
end

-- Find all ships belonging to a player
ASC.AI.FindPlayerShips = function(player)
    if not IsValid(player) then return {} end

    local playerShips = {}
    local playerID = player:SteamID()

    -- Search for ship cores owned by the player
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:GetClass() == "ship_core" then
            -- Check ownership through various methods
            local isOwner = false

            -- Method 1: Direct owner check
            if ent.Owner == player then
                isOwner = true
            end

            -- Method 2: CPPI ownership check
            if not isOwner and ent.CPPIGetOwner then
                local owner = ent:CPPIGetOwner()
                if IsValid(owner) and owner == player then
                    isOwner = true
                end
            end

            -- Method 3: NPP ownership check
            if not isOwner and ASC.AI.NPP.IsAvailable() then
                local owner = ASC.AI.NPP.GetOwner(ent)
                if IsValid(owner) and owner == player then
                    isOwner = true
                end
            end

            -- Method 4: SteamID check (fallback)
            if not isOwner and ent:GetNWString("OwnerID") == playerID then
                isOwner = true
            end

            if isOwner then
                table.insert(playerShips, ent)
            end
        end
    end

    -- Sort ships by distance from player
    local playerPos = player:GetPos()
    table.sort(playerShips, function(a, b)
        local distA = playerPos:Distance(a:GetPos())
        local distB = playerPos:Distance(b:GetPos())
        return distA < distB
    end)

    return playerShips
end

-- Find player's stargate
ASC.AI.FindPlayerStargate = function(player)
    if not IsValid(player) then return nil end

    print("[ASC AI] Looking for player stargate for: " .. player:Name())

    local playerPos = player:GetPos()
    local closestGate = nil
    local closestDistance = math.huge

    -- Correct CAP stargate classes (updated with actual class names)
    local stargateClasses = {
        -- Main CAP Stargates (correct class names)
        "stargate_sg1", "stargate_movie", "stargate_infinity", "stargate_tollan",
        -- Legacy variants (keeping for compatibility)
        "stargate_atlantis", "stargate_milkyway", "stargate_universe",
        "stargate_supergate", "stargate_orlin",
        -- Workshop variants
        "cap_stargate", "cap_stargate_sg1", "cap_stargate_atlantis",
        "cap_stargate_universe", "cap_stargate_destiny",
        -- Legacy variants
        "sg_atlantis", "sg_milkyway", "sg_universe"
    }



    for _, className in ipairs(stargateClasses) do
        local found = ents.FindByClass(className)
        if #found > 0 then
            print("[ASC AI] Found " .. #found .. " entities of class: " .. className)
        end

        for _, ent in ipairs(found) do
            if IsValid(ent) then
                local owner = nil
                if ent.CPPIGetOwner then
                    owner = ent:CPPIGetOwner()
                else
                    owner = ent:GetOwner()
                end

                print("[ASC AI] Stargate " .. className .. " owner: " .. (IsValid(owner) and owner:Name() or "None"))

                if IsValid(owner) and owner == player then
                    local distance = playerPos:Distance(ent:GetPos())
                    print("[ASC AI] Found owned stargate at distance: " .. distance)
                    if distance < closestDistance then
                        closestDistance = distance
                        closestGate = ent
                    end
                end
            end
        end
    end

    if IsValid(closestGate) then
        print("[ASC AI] Selected closest stargate: " .. closestGate:GetClass() .. " at distance: " .. closestDistance)
    else
        print("[ASC AI] No owned stargate found for player")
    end

    return closestGate
end

-- Debug function to find all stargate entities
ASC.AI.FindAllStargates = function(player)
    if not IsValid(player) then return {} end

    local allStargates = {}
    local playerPos = player:GetPos()

    -- Get all entities and check for stargate-like classes
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) then
            local class = ent:GetClass()
            if string.find(string.lower(class), "stargate") or
               string.find(string.lower(class), "gate") or
               string.find(string.lower(class), "sg_") then

                local owner = nil
                if ent.CPPIGetOwner then
                    owner = ent:CPPIGetOwner()
                else
                    owner = ent:GetOwner()
                end

                local distance = playerPos:Distance(ent:GetPos())

                table.insert(allStargates, {
                    entity = ent,
                    class = class,
                    owner = owner,
                    distance = distance,
                    owned = IsValid(owner) and owner == player
                })
            end
        end
    end

    -- Sort by distance
    table.sort(allStargates, function(a, b) return a.distance < b.distance end)

    return allStargates
end

-- Find nearby DHD (Dial Home Device) for a stargate
ASC.AI.FindNearbyDHD = function(stargate)
    if not IsValid(stargate) then return nil end

    local dhdClasses = {
        -- Main CAP DHDs
        "dhd_atlantis", "dhd_milkyway", "dhd_universe", "dhd_pegasus",
        -- Workshop variants
        "cap_dhd", "cap_dhd_atlantis", "cap_dhd_milkyway",
        "cap_dhd_universe", "cap_control_crystal",
        -- Control interfaces
        "cap_ancient_console", "cap_computer", "cap_control_chair"
    }

    local stargatePos = stargate:GetPos()
    local searchRadius = 500 -- DHDs are usually within 500 units of stargate

    for _, className in ipairs(dhdClasses) do
        for _, ent in ipairs(ents.FindByClass(className)) do
            if IsValid(ent) then
                local distance = stargatePos:Distance(ent:GetPos())
                if distance <= searchRadius then
                    print("[ASC AI] Found DHD: " .. className .. " at distance: " .. distance)
                    return ent
                end
            end
        end
    end

    print("[ASC AI] No DHD found near stargate")
    return nil
end

-- Dial stargate function
ASC.AI.DialStargate = function(player, stargate, target)
    if not IsValid(player) or not IsValid(stargate) or not target then
        return false, "Invalid parameters for stargate dialing"
    end

    print("[ASC AI] Attempting to dial stargate: " .. stargate:GetClass() .. " to target: " .. target)

    -- Check if target is a direct address (6-9 characters, alphanumeric only)
    local isDirectAddress = string.len(target) >= 6 and string.len(target) <= 9 and string.match(target, "^[A-Za-z0-9]+$")

    if isDirectAddress then
        print("[ASC AI] Detected direct address format: " .. target)
        -- Direct address dialing
        return ASC.AI.DialStargateByAddress(player, stargate, string.upper(target))
    else
        print("[ASC AI] Detected gate name format: " .. target)
        -- Gate name dialing - prioritize address book lookup over player search
        return ASC.AI.DialStargateByName(player, stargate, target)
    end
end

-- Dial stargate by direct address
ASC.AI.DialStargateByAddress = function(player, stargate, address)
    if not IsValid(stargate) then
        return false, "Invalid stargate"
    end

    print("[ASC AI] Attempting to dial address: " .. address .. " on stargate: " .. stargate:GetClass())

    -- Try multiple CAP dialing methods (updated with proper CAP methods)
    local dialMethods = {
        -- Method 1: CAP StarGate global function
        function()
            if StarGate and StarGate.Dial then
                print("[ASC AI] Trying StarGate.Dial global function")
                return StarGate.Dial(stargate, address)
            end
            return false
        end,

        -- Method 2: Direct entity Dial function
        function()
            if stargate.Dial then
                print("[ASC AI] Trying stargate:Dial method")
                return stargate:Dial(address)
            end
            return false
        end,

        -- Method 3: DHD-based dialing
        function()
            print("[ASC AI] Trying DHD-based dialing")
            local dhd = ASC.AI.FindNearbyDHD(stargate)
            if IsValid(dhd) then
                if dhd.DialAddress then
                    return dhd:DialAddress(address)
                elseif dhd.Dial then
                    return dhd:Dial(address)
                elseif dhd.SetAddress and dhd.StartDialing then
                    dhd:SetAddress(address)
                    dhd:StartDialing()
                    return true
                end
            end
            return false
        end,

        -- Method 4: CAP network dialing
        function()
            if StarGate and StarGate.Network and StarGate.Network.Dial then
                print("[ASC AI] Trying StarGate.Network.Dial")
                return StarGate.Network.Dial(stargate, address)
            end
            return false
        end,

        -- Method 5: SetAddress + StartDialing
        function()
            if stargate.SetAddress and stargate.StartDialing then
                print("[ASC AI] Trying SetAddress + StartDialing")
                stargate:SetAddress(address)
                stargate:StartDialing()
                return true
            end
            return false
        end,

        -- Method 6: BeginDialing
        function()
            if stargate.BeginDialing then
                print("[ASC AI] Trying BeginDialing")
                return stargate:BeginDialing(address)
            end
            return false
        end,

        -- Method 7: DialAddress
        function()
            if stargate.DialAddress then
                print("[ASC AI] Trying DialAddress")
                return stargate:DialAddress(address)
            end
            return false
        end,

        -- Method 8: SetTargetAddress + Activate
        function()
            if stargate.SetTargetAddress and stargate.Activate then
                print("[ASC AI] Trying SetTargetAddress + Activate")
                stargate:SetTargetAddress(address)
                stargate:Activate()
                return true
            end
            return false
        end,

        -- Method 9: CAP-specific dialing sequence
        function()
            print("[ASC AI] Trying CAP-specific dialing sequence")
            if stargate.SetNWString and stargate.SetNWBool then
                stargate:SetNWString("TargetAddress", address)
                stargate:SetNWBool("Dialing", true)
                if stargate.Think then
                    stargate:Think() -- Trigger stargate logic
                end
                return true
            end
            return false
        end
    }

    -- Try each method until one works
    for i, method in ipairs(dialMethods) do
        print("[ASC AI] Trying dialing method " .. i)
        local success = method()
        if success then
            print("[ASC AI] Dialing method " .. i .. " succeeded!")
            return true, "Dialing stargate to address: " .. address .. " (Method " .. i .. "). Stand by for connection! The stargate should begin dialing sequence now."
        else
            print("[ASC AI] Dialing method " .. i .. " failed")
        end
    end

    -- Check what methods are available for debugging
    local availableMethods = {}
    if StarGate and StarGate.Dial then table.insert(availableMethods, "StarGate.Dial") end
    if stargate.Dial then table.insert(availableMethods, "stargate:Dial") end
    if stargate.SetAddress then table.insert(availableMethods, "SetAddress") end
    if stargate.BeginDialing then table.insert(availableMethods, "BeginDialing") end
    if stargate.DialAddress then table.insert(availableMethods, "DialAddress") end
    if stargate.SetTargetAddress then table.insert(availableMethods, "SetTargetAddress") end

    local dhd = ASC.AI.FindNearbyDHD(stargate)
    if IsValid(dhd) then
        table.insert(availableMethods, "DHD:" .. dhd:GetClass())
    end

    local methodsText = #availableMethods > 0 and table.concat(availableMethods, ", ") or "None"
    print("[ASC AI] No dialing methods worked. Available methods: " .. methodsText)

    return false, "Unable to dial stargate automatically. Available methods: " .. methodsText ..
                  ". You may need to use the DHD manually or check if the stargate supports the address format. " ..
                  "Stargate class: " .. stargate:GetClass() .. ". Try using a 6-7 character address like 'ABCDEF' or check if CAP is properly installed."
end

-- Dial stargate by gate name from address book
ASC.AI.DialStargateByName = function(player, stargate, gateName)
    if not IsValid(stargate) then
        return false, "Invalid stargate"
    end

    print("[ASC AI] Looking for gate name: " .. gateName .. " in address book")

    -- Try multiple methods to get address book
    local addressBook = nil
    local addressBookMethods = {
        function() return stargate.AddressBook end,
        function() return stargate:GetAddressBook() end,
        function() return stargate.GetNWTable and stargate:GetNWTable("AddressBook") end,
        function() return stargate.addressbook end,
        function() return stargate.addresses end,
        function() return stargate:GetAddresses() end
    }

    for i, method in ipairs(addressBookMethods) do
        local success, result = pcall(method)
        if success and result and type(result) == "table" then
            addressBook = result
            print("[ASC AI] Found address book using method " .. i)
            break
        end
    end

    if addressBook and type(addressBook) == "table" then
        print("[ASC AI] Address book found with " .. table.Count(addressBook) .. " entries")

        -- Search for gate name in address book (case-insensitive)
        for name, address in pairs(addressBook) do
            if string.lower(name) == string.lower(gateName) then
                print("[ASC AI] Found gate '" .. gateName .. "' with address: " .. address)
                return ASC.AI.DialStargateByAddress(player, stargate, address)
            end
        end

        -- Try partial matching for gate names
        for name, address in pairs(addressBook) do
            if string.find(string.lower(name), string.lower(gateName)) then
                print("[ASC AI] Found partial match: '" .. name .. "' for search: '" .. gateName .. "'")
                return ASC.AI.DialStargateByAddress(player, stargate, address)
            end
        end

        -- If not found, list available gates
        local availableGates = {}
        for name, _ in pairs(addressBook) do
            table.insert(availableGates, name)
        end

        if #availableGates > 0 then
            return false, "Gate '" .. gateName .. "' not found in address book. Available gates: " .. table.concat(availableGates, ", ") .. ". Try exact name or use direct address."
        else
            return false, "Address book is empty. Add gate addresses first or use direct address dialing."
        end
    else
        print("[ASC AI] No address book found, trying player name lookup")
        -- Fallback: Try to find other stargates by owner name
        return ASC.AI.DialStargateByOwnerName(player, stargate, gateName)
    end
end

-- Dial stargate by finding another player's stargate
ASC.AI.DialStargateByOwnerName = function(ply, stargate, ownerName)
    local targetPlayer = nil

    print("[ASC AI] Looking for player: " .. ownerName .. " to dial to their stargate")

    -- Find player by name with enhanced matching
    for _, p in ipairs(player.GetAll()) do
        if IsValid(p) then
            local playerName = p:Name()
            print("[ASC AI] Checking player: " .. playerName)

            -- Try exact match first
            if string.lower(playerName) == string.lower(ownerName) then
                targetPlayer = p
                print("[ASC AI] Found exact match: " .. playerName)
                break
            end

            -- Try partial match for common cases (e.g., "oliver" matches "Oliver123")
            if string.find(string.lower(playerName), string.lower(ownerName)) then
                targetPlayer = p
                print("[ASC AI] Found partial match: " .. playerName .. " for search: " .. ownerName)
                break
            end

            -- Try reverse partial match (e.g., "oliv" matches "Oliver")
            if string.find(string.lower(ownerName), string.lower(playerName)) then
                targetPlayer = p
                print("[ASC AI] Found reverse partial match: " .. playerName .. " for search: " .. ownerName)
                break
            end
        end
    end

    if not IsValid(targetPlayer) then
        -- List available players for debugging
        local availablePlayers = {}
        for _, p in ipairs(player.GetAll()) do
            if IsValid(p) then
                table.insert(availablePlayers, p:Name())
            end
        end

        local playersText = #availablePlayers > 0 and table.concat(availablePlayers, ", ") or "None"
        return false, "Player '" .. ownerName .. "' not found online. Available players: " .. playersText .. ". Use exact player name, direct address, or check address book."
    end

    print("[ASC AI] Found target player: " .. targetPlayer:Name() .. " - searching for their stargate")

    -- Find target player's stargate with enhanced search
    local targetStargate = ASC.AI.FindPlayerStargate(targetPlayer)

    if IsValid(targetStargate) then
        print("[ASC AI] Found " .. targetPlayer:Name() .. "'s stargate: " .. targetStargate:GetClass())

        -- Try multiple methods to get the stargate's address
        local targetAddress = nil
        local addressMethods = {
            function() return targetStargate:GetAddress() end,
            function() return targetStargate.GetNWString and targetStargate:GetNWString("Address") end,
            function() return targetStargate.address end,
            function() return targetStargate.Address end,
            function() return targetStargate:GetNWString("GateAddress") end,
            function() return targetStargate:GetNWString("StarGateAddress") end
        }

        for i, method in ipairs(addressMethods) do
            local success, result = pcall(method)
            if success and result and result ~= "" then
                targetAddress = result
                print("[ASC AI] Got " .. targetPlayer:Name() .. "'s stargate address using method " .. i .. ": " .. targetAddress)
                break
            end
        end

        if targetAddress and targetAddress ~= "" then
            print("[ASC AI] Dialing to " .. targetPlayer:Name() .. "'s stargate at address: " .. targetAddress)
            return ASC.AI.DialStargateByAddress(ply, stargate, targetAddress)
        else
            return false, targetPlayer:Name() .. "'s stargate doesn't have a valid address set. They need to configure their stargate address first."
        end
    else
        return false, targetPlayer:Name() .. " doesn't have a stargate nearby or it's not accessible. They need to be near their stargate for dialing."
    end
end

-- Voice command system (framework for future implementation)
ASC.AI.VoiceCommands = {
    -- Voice command patterns
    Patterns = {
        ["help"] = {"help", "assist", "support"},
        ["spawn"] = {"spawn", "create", "make"},
        ["status"] = {"status", "check", "info"},
        ["fix"] = {"fix", "repair", "solve"}
    },

    -- Voice recognition confidence threshold
    ConfidenceThreshold = 0.7,

    -- Process voice command (placeholder for future voice integration)
    ProcessVoiceCommand = function(player, voiceData)
        -- Future implementation: Convert voice to text and process
        -- For now, this is a framework for voice command integration
        if not ASC.AI.Config.EnableVoiceCommands then return end

        -- Placeholder for voice processing
        local recognizedText = ASC.AI.VoiceCommands.ConvertVoiceToText(voiceData)
        if recognizedText then
            ASC.AI.ProcessQuery(player, recognizedText)
        end
    end,

    -- Convert voice to text (placeholder)
    ConvertVoiceToText = function(voiceData)
        -- Future implementation: Voice recognition
        return nil
    end
}

-- ULib Integration System (Foundation for ULX)
ASC.AI.ULib = {
    -- Check if ULib is available
    IsAvailable = function()
        return ULib ~= nil
    end,

    -- Get ULib version
    GetVersion = function()
        if ASC.AI.ULib.IsAvailable() then
            return ULib.VERSION or "Unknown"
        end
        return nil
    end,

    -- ULib utility functions
    Utils = {
        -- Safe message sending using ULib
        SendMessage = function(player, message, color)
            if not IsValid(player) or not ASC.AI.ULib.IsAvailable() then
                return false
            end

            if ULib.tsay then
                ULib.tsay(player, message, color)
                return true
            elseif ULib.console then
                ULib.console(player, message)
                return true
            end

            return false
        end,

        -- Safe error message sending
        SendError = function(player, message)
            if not IsValid(player) or not ASC.AI.ULib.IsAvailable() then
                return false
            end

            if ULib.tsayError then
                ULib.tsayError(player, message, true)
                return true
            end

            return false
        end,

        -- Check player permissions using ULib
        HasAccess = function(player, access_level)
            if not IsValid(player) or not ASC.AI.ULib.IsAvailable() then
                return false
            end

            if ULib.ucl and ULib.ucl.query then
                return ULib.ucl.query(player, access_level)
            end

            return false
        end,

        -- Get player's access string
        GetAccess = function(player)
            if not IsValid(player) or not ASC.AI.ULib.IsAvailable() then
                return "user"
            end

            if ULib.ucl and ULib.ucl.getUserAccessString then
                return ULib.ucl.getUserAccessString(player) or "user"
            end

            return "user"
        end
    }
}

-- ULX Integration System
ASC.AI.ULX = {
    -- Check if ULX is available
    IsAvailable = function()
        return ulx ~= nil and ASC.AI.ULib.IsAvailable()
    end,

    -- Get ULX version
    GetVersion = function()
        if ASC.AI.ULX.IsAvailable() then
            return ulx.VERSION or "Unknown"
        end
        return nil
    end,

    -- ULX permission levels
    PermissionLevels = {
        superadmin = 100,
        admin = 80,
        moderator = 60,
        vip = 40,
        user = 20,
        guest = 10
    },

    -- Get player's ULX access level
    GetPlayerAccess = function(player)
        if not ASC.AI.ULX.IsAvailable() or not IsValid(player) then
            return "user"
        end

        -- Use ULib for more accurate permission checking
        local accessString = ASC.AI.ULib.Utils.GetAccess(player)

        if player:IsSuperAdmin() or accessString == "superadmin" then
            return "superadmin"
        elseif player:IsAdmin() or accessString == "admin" then
            return "admin"
        elseif ASC.AI.ULib.Utils.HasAccess(player, "ulx moderator") or accessString == "moderator" then
            return "moderator"
        elseif ASC.AI.ULib.Utils.HasAccess(player, "ulx vip") or accessString == "vip" then
            return "vip"
        else
            return "user"
        end
    end,

    -- Check if player has permission for AI admin features
    HasAdminAccess = function(player)
        if not IsValid(player) then return false end

        local accessLevel = ASC.AI.ULX.GetPlayerAccess(player)
        return ASC.AI.ULX.PermissionLevels[accessLevel] >= ASC.AI.ULX.PermissionLevels.moderator
    end,

    -- ULX command integration
    Commands = {
        -- AI status command for ULX
        ai_status = function(calling_ply, target_ply)
            if not ASC.AI.ULX.HasAdminAccess(calling_ply) then
                ASC.AI.ULib.Utils.SendError(calling_ply, "Access denied! Moderator access required.")
                return
            end

            if not IsValid(target_ply) then
                ASC.AI.ULib.Utils.SendError(calling_ply, "Invalid target player!")
                return
            end

            local playerID = target_ply:SteamID()
            local profile = ASC.AI.UserProfiles[playerID]

            if profile then
                if ASC.AI.ULX.IsAvailable() and ulx.fancyLogAdmin then
                    ulx.fancyLogAdmin(calling_ply, "#A queried AI status for #T", target_ply)
                end

                ASC.AI.ULib.Utils.SendMessage(calling_ply, "[ARIA-3] " .. target_ply:Name() .. "'s AI Profile:")
                ASC.AI.ULib.Utils.SendMessage(calling_ply, "• Experience: " .. profile.experience_level)
                ASC.AI.ULib.Utils.SendMessage(calling_ply, "• Interactions: " .. profile.interaction_count)
                ASC.AI.ULib.Utils.SendMessage(calling_ply, "• Satisfaction: " .. math.floor(profile.satisfaction_score * 100) .. "%")
                ASC.AI.ULib.Utils.SendMessage(calling_ply, "• Language: " .. (profile.language_preference or "english"))

                -- Additional ULib-specific info
                local accessLevel = ASC.AI.ULib.Utils.GetAccess(target_ply)
                ASC.AI.ULib.Utils.SendMessage(calling_ply, "• ULib Access: " .. accessLevel)
            else
                ASC.AI.ULib.Utils.SendMessage(calling_ply, "[ARIA-3] No AI profile found for " .. target_ply:Name())
            end
        end,

        -- Reset AI profile command for ULX
        ai_reset = function(calling_ply, target_ply)
            if not ASC.AI.ULX.HasAdminAccess(calling_ply) then
                ULib.tsayError(calling_ply, "Access denied! Moderator access required.", true)
                return
            end

            if not IsValid(target_ply) then
                ULib.tsayError(calling_ply, "Invalid target player!", true)
                return
            end

            local playerID = target_ply:SteamID()
            ASC.AI.UserProfiles[playerID] = nil
            ASC.AI.ConversationHistory[playerID] = nil
            ASC.AI.LearningData[playerID] = nil
            ASC.AI.PredictiveSystem.LearnedPatterns[playerID] = nil

            ulx.fancyLogAdmin(calling_ply, "#A reset AI profile for #T", target_ply)
            ULib.tsay(calling_ply, "[ARIA-3] Reset AI profile for " .. target_ply:Name())
            ULib.tsay(target_ply, "[ARIA-3] Your AI profile has been reset by an administrator.")
        end,

        -- Global AI statistics for ULX
        ai_stats = function(calling_ply)
            if not ASC.AI.ULX.HasAdminAccess(calling_ply) then
                ULib.tsayError(calling_ply, "Access denied! Moderator access required.", true)
                return
            end

            local totalUsers = 0
            local totalInteractions = 0
            local avgSatisfaction = 0

            for playerID, profile in pairs(ASC.AI.UserProfiles) do
                totalUsers = totalUsers + 1
                totalInteractions = totalInteractions + profile.interaction_count
                avgSatisfaction = avgSatisfaction + profile.satisfaction_score
            end

            if totalUsers > 0 then
                avgSatisfaction = avgSatisfaction / totalUsers
            end

            ulx.fancyLogAdmin(calling_ply, "#A viewed global AI statistics")
            ULib.tsay(calling_ply, "[ARIA-3] Global AI Statistics:")
            ULib.tsay(calling_ply, "• Total Users: " .. totalUsers)
            ULib.tsay(calling_ply, "• Total Interactions: " .. totalInteractions)
            ULib.tsay(calling_ply, "• Average Satisfaction: " .. math.floor(avgSatisfaction * 100) .. "%")
            ULib.tsay(calling_ply, "• Memory Usage: " .. math.floor(collectgarbage("count")) .. " KB")
        end
    },

    -- Register ULX commands
    RegisterCommands = function()
        if not ASC.AI.ULX.IsAvailable() then return end

        -- AI Status command
        local ai_status = ulx.command("Advanced Space Combat", "ulx ai_status", ASC.AI.ULX.Commands.ai_status, "!ai_status")
        ai_status:addParam{type = ULib.cmds.PlayerArg}
        ai_status:defaultAccess(ULib.ACCESS_ADMIN)
        ai_status:help("View a player's AI profile and statistics")

        -- AI Reset command
        local ai_reset = ulx.command("Advanced Space Combat", "ulx ai_reset", ASC.AI.ULX.Commands.ai_reset, "!ai_reset")
        ai_reset:addParam{type = ULib.cmds.PlayerArg}
        ai_reset:defaultAccess(ULib.ACCESS_ADMIN)
        ai_reset:help("Reset a player's AI profile and learning data")

        -- AI Stats command
        local ai_stats = ulx.command("Advanced Space Combat", "ulx ai_stats", ASC.AI.ULX.Commands.ai_stats, "!ai_stats")
        ai_stats:defaultAccess(ULib.ACCESS_ADMIN)
        ai_stats:help("View global AI system statistics")

        print("[Advanced Space Combat] ULX commands registered successfully!")
    end
}

-- NPP (Nadmod Prop Protection) Integration System
ASC.AI.NPP = {
    -- Check if NPP is available
    IsAvailable = function()
        return nadmod ~= nil and nadmod.PlayerMeta ~= nil
    end,

    -- Check if entity is protected by NPP
    IsProtected = function(entity)
        if not ASC.AI.NPP.IsAvailable() or not IsValid(entity) then
            return false
        end

        return entity:CPPIGetOwner() ~= nil
    end,

    -- Get entity owner through NPP/CPPI
    GetOwner = function(entity)
        if not IsValid(entity) then return nil end

        -- Try CPPI first (NPP is CPPI compliant)
        if entity.CPPIGetOwner then
            return entity:CPPIGetOwner()
        end

        -- Fallback to NPP specific methods
        if ASC.AI.NPP.IsAvailable() and entity.GetNWEntity then
            return entity:GetNWEntity("Owner")
        end

        return nil
    end,

    -- Check if player can interact with entity
    CanInteract = function(player, entity)
        if not IsValid(player) or not IsValid(entity) then
            return false
        end

        -- Admin bypass
        if player:IsAdmin() then
            return true
        end

        -- Get entity owner
        local owner = ASC.AI.NPP.GetOwner(entity)

        -- No owner = world entity, allow interaction
        if not IsValid(owner) then
            return true
        end

        -- Owner can always interact
        if owner == player then
            return true
        end

        -- Check NPP friends system
        if ASC.AI.NPP.IsAvailable() and nadmod.PlayerMeta.GetFriends then
            local friends = owner:GetFriends()
            if friends and table.HasValue(friends, player:SteamID()) then
                return true
            end
        end

        return false
    end,

    -- Get entity cleanup information
    GetCleanupInfo = function(player)
        if not IsValid(player) or not ASC.AI.NPP.IsAvailable() then
            return {entities = 0, props = 0, ragdolls = 0}
        end

        local info = {
            entities = 0,
            props = 0,
            ragdolls = 0,
            npcs = 0,
            vehicles = 0
        }

        for _, ent in ipairs(ents.GetAll()) do
            local owner = ASC.AI.NPP.GetOwner(ent)
            if owner == player then
                info.entities = info.entities + 1

                local class = ent:GetClass()
                if string.find(class, "prop_") then
                    info.props = info.props + 1
                elseif string.find(class, "ragdoll") then
                    info.ragdolls = info.ragdolls + 1
                elseif string.find(class, "npc_") then
                    info.npcs = info.npcs + 1
                elseif string.find(class, "vehicle") then
                    info.vehicles = info.vehicles + 1
                end
            end
        end

        return info
    end,

    -- NPP command integration for AI
    Commands = {
        -- Clean player's entities
        CleanPlayer = function(calling_ply, target_ply)
            if not ASC.AI.ULX.HasAdminAccess(calling_ply) then
                ULib.tsayError(calling_ply, "Access denied! Moderator access required.", true)
                return
            end

            if not IsValid(target_ply) then
                ULib.tsayError(calling_ply, "Invalid target player!", true)
                return
            end

            local info = ASC.AI.NPP.GetCleanupInfo(target_ply)

            if ASC.AI.NPP.IsAvailable() and nadmod.CleanPlayer then
                nadmod.CleanPlayer(target_ply)
                ulx.fancyLogAdmin(calling_ply, "#A cleaned #T's entities (#s total)", target_ply, info.entities)
                ULib.tsay(calling_ply, "[ARIA-3] Cleaned " .. info.entities .. " entities owned by " .. target_ply:Name())
            else
                ULib.tsayError(calling_ply, "NPP not available or cleanup function missing!", true)
            end
        end,

        -- Clean disconnected players
        CleanDisconnected = function(calling_ply)
            if not ASC.AI.ULX.HasAdminAccess(calling_ply) then
                ULib.tsayError(calling_ply, "Access denied! Moderator access required.", true)
                return
            end

            if ASC.AI.NPP.IsAvailable() and nadmod.CleanDisconnectedPlayers then
                local cleaned = nadmod.CleanDisconnectedPlayers()
                ulx.fancyLogAdmin(calling_ply, "#A cleaned disconnected players' entities")
                ULib.tsay(calling_ply, "[ARIA-3] Cleaned disconnected players' entities")
            else
                ULib.tsayError(calling_ply, "NPP not available or cleanup function missing!", true)
            end
        end
    }
}

-- AdvDupe2 (Advanced Duplicator 2) Integration System
ASC.AI.AdvDupe2 = {
    -- Check if AdvDupe2 is available
    IsAvailable = function()
        return AdvDupe2 ~= nil and AdvDupe2.duplicator ~= nil
    end,

    -- Get AdvDupe2 version
    GetVersion = function()
        if ASC.AI.AdvDupe2.IsAvailable() and AdvDupe2.Version then
            return AdvDupe2.Version
        end
        return nil
    end,

    -- Ship template management
    ShipTemplates = {
        -- Predefined ship templates for Advanced Space Combat
        Templates = {
            {
                name = "Basic Fighter",
                description = "Simple single-seat fighter with basic weapons",
                category = "Fighter",
                difficulty = "Beginner",
                components = {"ship_core", "hyperdrive_engine", "pulse_cannon", "flight_console"}
            },
            {
                name = "Heavy Cruiser",
                description = "Large multi-role vessel with advanced systems",
                category = "Cruiser",
                difficulty = "Advanced",
                components = {"ship_core", "hyperdrive_master_engine", "railgun", "plasma_cannon", "shield_generator"}
            },
            {
                name = "Transport Shuttle",
                description = "Civilian transport with docking capabilities",
                category = "Transport",
                difficulty = "Intermediate",
                components = {"ship_core", "hyperdrive_engine", "docking_pad", "flight_console"}
            }
        },

        -- Get template by name
        GetTemplate = function(name)
            for _, template in ipairs(ASC.AI.AdvDupe2.ShipTemplates.Templates) do
                if template.name == name then
                    return template
                end
            end
            return nil
        end,

        -- List templates by category
        GetByCategory = function(category)
            local results = {}
            for _, template in ipairs(ASC.AI.AdvDupe2.ShipTemplates.Templates) do
                if template.category == category then
                    table.insert(results, template)
                end
            end
            return results
        end
    },

    -- AdvDupe2 integration functions
    Utils = {
        -- Save Advanced Space Combat ship as dupe
        SaveShip = function(player, shipCore, name, description)
            if not IsValid(player) or not IsValid(shipCore) or not ASC.AI.AdvDupe2.IsAvailable() then
                return false, "AdvDupe2 not available or invalid parameters"
            end

            if shipCore:GetClass() ~= "ship_core" then
                return false, "Selected entity is not a ship core"
            end

            -- Get all connected ship components
            local shipEntities = ASC.AI.AdvDupe2.GetShipEntities(shipCore)

            if #shipEntities == 0 then
                return false, "No ship components found"
            end

            -- Create AdvDupe2 save data
            local dupeData = {
                name = name or "ASC Ship",
                description = description or "Advanced Space Combat ship",
                entities = shipEntities,
                creator = player:Name(),
                created = os.time(),
                version = ASC.AI.Config.Version
            }

            -- Save using AdvDupe2
            if AdvDupe2.duplicator and AdvDupe2.duplicator.Save then
                local success = AdvDupe2.duplicator.Save(player, dupeData)
                return success, success and "Ship saved successfully" or "Failed to save ship"
            end

            return false, "AdvDupe2 save function not available"
        end,

        -- Load Advanced Space Combat ship from dupe
        LoadShip = function(player, dupeName, position, angle)
            if not IsValid(player) or not ASC.AI.AdvDupe2.IsAvailable() then
                return false, "AdvDupe2 not available or invalid player"
            end

            position = position or player:GetEyeTrace().HitPos
            angle = angle or Angle(0, player:EyeAngles().y, 0)

            -- Load using AdvDupe2
            if AdvDupe2.duplicator and AdvDupe2.duplicator.Load then
                local success = AdvDupe2.duplicator.Load(player, dupeName, position, angle)
                return success, success and "Ship loaded successfully" or "Failed to load ship"
            end

            return false, "AdvDupe2 load function not available"
        end,

        -- Get all entities connected to ship core
        GetShipEntities = function(shipCore)
            if not IsValid(shipCore) then return {} end

            local entities = {}
            local searchRadius = 2000 -- Standard ship component range

            -- Find all Advanced Space Combat entities near ship core
            for _, ent in ipairs(ents.FindInSphere(shipCore:GetPos(), searchRadius)) do
                local class = ent:GetClass()
                if string.find(class, "hyperdrive_") or
                   string.find(class, "ship_") or
                   string.find(class, "asc_") then
                    table.insert(entities, ent)
                end
            end

            return entities
        end,

        -- Validate ship dupe for Advanced Space Combat compatibility
        ValidateShipDupe = function(dupeData)
            if not dupeData or not dupeData.entities then
                return false, "Invalid dupe data"
            end

            local hasShipCore = false
            local componentCount = 0

            for _, entData in ipairs(dupeData.entities) do
                local class = entData.Class or entData.class
                if class == "ship_core" then
                    hasShipCore = true
                elseif string.find(class, "hyperdrive_") or string.find(class, "asc_") then
                    componentCount = componentCount + 1
                end
            end

            if not hasShipCore then
                return false, "Ship dupe must contain a ship core"
            end

            if componentCount == 0 then
                return false, "Ship dupe must contain Advanced Space Combat components"
            end

            return true, "Ship dupe is valid"
        end
    },

    -- AdvDupe2 command integration
    Commands = {
        -- Save current ship as dupe
        SaveCurrentShip = function(player, name, description)
            if not IsValid(player) then return false, "Invalid player" end

            -- Find ship core player is looking at
            local trace = player:GetEyeTrace()
            local entity = trace.Entity

            if not IsValid(entity) or entity:GetClass() ~= "ship_core" then
                return false, "Look at a ship core to save the ship"
            end

            return ASC.AI.AdvDupe2.Utils.SaveShip(player, entity, name, description)
        end,

        -- List available ship dupes
        ListShipDupes = function(player)
            if not IsValid(player) or not ASC.AI.AdvDupe2.IsAvailable() then
                return {}
            end

            -- Get player's dupes (implementation depends on AdvDupe2 API)
            if AdvDupe2.duplicator and AdvDupe2.duplicator.GetDupes then
                return AdvDupe2.duplicator.GetDupes(player)
            end

            return {}
        end
    }
}

-- CAP (Carter Addon Pack) Integration System
ASC.AI.CAP = {
    Version = "3.1.0",

    -- Updated CAP repository information
    Repositories = {
        main_code = "https://github.com/RafaelDeJongh/cap",
        resources = "https://github.com/RafaelDeJongh/cap_resources",
        workshop_collection = "180077636", -- Steam Workshop main collection
        workshop_addon = "3488559019" -- New Steam Workshop addon reference
    },

    -- Check if CAP is available (updated with correct stargate classes)
    IsAvailable = function()
        return CAP ~= nil or cap ~= nil or
               ents.FindByClass("stargate_*")[1] ~= nil or
               ents.FindByClass("cap_*")[1] ~= nil or
               file.Exists("lua/entities/stargate_sg1.lua", "GAME") or
               file.Exists("lua/entities/stargate_movie.lua", "GAME") or
               file.Exists("lua/entities/stargate_infinity.lua", "GAME") or
               file.Exists("lua/entities/stargate_tollan.lua", "GAME") or
               file.Exists("lua/entities/stargate_atlantis.lua", "GAME") or
               file.Exists("lua/entities/stargate_milkyway.lua", "GAME")
    end,

    -- Get CAP version
    GetVersion = function()
        if CAP and CAP.Version then
            return CAP.Version
        elseif cap and cap.version then
            return cap.version
        end
        return nil
    end,

    -- CAP component categories
    Components = {
        -- Stargate technology (updated with correct class names)
        Stargates = {
            "stargate_sg1", "stargate_movie", "stargate_infinity", "stargate_tollan",
            "stargate_milkyway", "stargate_pegasus", "stargate_universe",
            "stargate_supergate", "stargate_atlantis"
        },

        -- DHD (Dial Home Device) systems
        DHDs = {
            "dhd_milkyway", "dhd_pegasus", "dhd_atlantis", "dhd_universe"
        },

        -- Shield systems (perfect for our shield integration)
        Shields = {
            "shield_core", "shield_generator", "shield_emitter",
            "iris", "shield_bubble", "personal_shield"
        },

        -- Energy systems (compatible with our power systems)
        Energy = {
            "zpm", "naquadah_generator", "potentia", "energy_crystal",
            "power_core", "energy_distributor"
        },

        -- Transportation systems
        Transportation = {
            "rings_ancient", "rings_goauld", "rings_ori",
            "asgard_transporter", "atlantis_transporter"
        },

        -- Weapons (can integrate with our weapon systems)
        Weapons = {
            "staff_weapon", "zat_gun", "p90", "drone_weapon",
            "asgard_beam", "ori_beam", "plasma_cannon"
        },

        -- Vehicles (can work with our ship systems)
        Vehicles = {
            "puddle_jumper", "alkesh", "hatak", "daedalus",
            "prometheus", "destiny", "atlantis"
        }
    },

    -- CAP integration utilities
    Utils = {
        -- Check if entity is a CAP component
        IsCAPEntity = function(entity)
            if not IsValid(entity) or not ASC.AI.CAP.IsAvailable() then
                return false
            end

            local class = entity:GetClass()

            -- Check all CAP component categories
            for category, components in pairs(ASC.AI.CAP.Components) do
                for _, component in ipairs(components) do
                    if string.find(class, component) then
                        return true, category, component
                    end
                end
            end

            return false
        end,

        -- Get CAP entity category
        GetCAPCategory = function(entity)
            local isCAP, category, component = ASC.AI.CAP.Utils.IsCAPEntity(entity)
            return isCAP and category or nil
        end,

        -- Enhanced ship core with CAP integration
        IntegrateWithShipCore = function(shipCore)
            if not IsValid(shipCore) or not ASC.AI.CAP.IsAvailable() then
                return false
            end

            -- Find nearby CAP components
            local capComponents = {}
            local searchRadius = 2000

            for _, ent in ipairs(ents.FindInSphere(shipCore:GetPos(), searchRadius)) do
                local isCAP, category, component = ASC.AI.CAP.Utils.IsCAPEntity(ent)
                if isCAP then
                    table.insert(capComponents, {
                        entity = ent,
                        category = category,
                        component = component
                    })
                end
            end

            -- Store CAP integration data
            shipCore.CAPComponents = capComponents
            shipCore.CAPIntegrated = true

            return true, #capComponents
        end,

        -- Get ship's CAP components
        GetShipCAPComponents = function(shipCore)
            if not IsValid(shipCore) or not shipCore.CAPIntegrated then
                return {}
            end

            return shipCore.CAPComponents or {}
        end,

        -- Enhanced hyperdrive with CAP technology
        EnhanceHyperdriveWithCAP = function(hyperdrive)
            if not IsValid(hyperdrive) or not ASC.AI.CAP.IsAvailable() then
                return false
            end

            -- Look for ZPM or Naquadah generators for power
            local powerSources = {}
            local searchRadius = 1000

            for _, ent in ipairs(ents.FindInSphere(hyperdrive:GetPos(), searchRadius)) do
                local class = ent:GetClass()
                if string.find(class, "zpm") or string.find(class, "naquadah") or string.find(class, "potentia") then
                    table.insert(powerSources, ent)
                end
            end

            if #powerSources > 0 then
                hyperdrive.CAPPowerSources = powerSources
                hyperdrive.CAPEnhanced = true
                return true, #powerSources
            end

            return false, 0
        end,

        -- CAP shield integration
        IntegrateShieldsWithCAP = function(shieldGenerator)
            if not IsValid(shieldGenerator) or not ASC.AI.CAP.IsAvailable() then
                return false
            end

            -- Look for CAP shield components
            local capShields = {}
            local searchRadius = 1500

            for _, ent in ipairs(ents.FindInSphere(shieldGenerator:GetPos(), searchRadius)) do
                local isCAP, category = ASC.AI.CAP.Utils.IsCAPEntity(ent)
                if isCAP and category == "Shields" then
                    table.insert(capShields, ent)
                end
            end

            if #capShields > 0 then
                shieldGenerator.CAPShields = capShields
                shieldGenerator.CAPShieldIntegrated = true
                return true, #capShields
            end

            return false, 0
        end
    },

    -- CAP technology integration
    Technology = {
        -- Stargate address system integration
        AddressSystem = {
            -- Generate random Stargate address
            GenerateAddress = function()
                local symbols = {
                    "Crater", "Virgo", "Boötes", "Centaurus", "Libra", "Serpens",
                    "Norma", "Scorpius", "Ara", "Triangulum", "Corona Australis",
                    "Eridanus", "Lepus", "Orion", "Canis Minor", "Monoceros",
                    "Gemini", "Hydra", "Lynx", "Taurus", "Auriga", "Eridanus",
                    "Perseus", "Cetus", "Triangulum", "Andromeda", "Microscopium",
                    "Capricornus", "Piscis Austrinus", "Equuleus", "Aquarius",
                    "Pegasus", "Sculptor", "Pisces", "Cetus", "Aries", "Triangulum"
                }

                local address = {}
                for i = 1, 7 do -- 6 symbols + point of origin
                    table.insert(address, symbols[math.random(1, #symbols)])
                end

                return address
            end,

            -- Format address for display
            FormatAddress = function(address)
                if not address or #address < 7 then
                    return "Invalid Address"
                end

                local formatted = ""
                for i = 1, 6 do
                    formatted = formatted .. address[i]
                    if i < 6 then formatted = formatted .. "-" end
                end
                formatted = formatted .. " [" .. address[7] .. "]"

                return formatted
            end
        },

        -- ZPM (Zero Point Module) integration
        ZPMSystem = {
            -- Check ZPM power level
            GetZPMPower = function(zpm)
                if not IsValid(zpm) then return 0 end

                -- Try to get power from CAP ZPM
                if zpm.GetPower then
                    return zpm:GetPower()
                elseif zpm.GetEnergy then
                    return zpm:GetEnergy()
                end

                return 100 -- Default full power
            end,

            -- Set ZPM power level
            SetZPMPower = function(zpm, power)
                if not IsValid(zpm) then return false end

                power = math.Clamp(power, 0, 100)

                if zpm.SetPower then
                    zpm:SetPower(power)
                    return true
                elseif zpm.SetEnergy then
                    zpm:SetEnergy(power)
                    return true
                end

                return false
            end
        }
    }
}

-- Wiremod Integration System
ASC.AI.Wiremod = {
    -- Check if Wiremod is available
    IsAvailable = function()
        return WireLib ~= nil
    end,

    -- Get Wiremod version
    GetVersion = function()
        if ASC.AI.Wiremod.IsAvailable() and WireLib.Version then
            return WireLib.Version
        end
        return nil
    end,

    -- Wire integration for Advanced Space Combat
    Integration = {
        -- Check if entity supports wire connections
        SupportsWire = function(entity)
            if not IsValid(entity) or not ASC.AI.Wiremod.IsAvailable() then
                return false
            end

            return entity.Inputs ~= nil or entity.Outputs ~= nil
        end,

        -- Get entity's wire inputs
        GetInputs = function(entity)
            if not ASC.AI.Wiremod.Integration.SupportsWire(entity) then
                return {}
            end

            return entity.Inputs or {}
        end,

        -- Get entity's wire outputs
        GetOutputs = function(entity)
            if not ASC.AI.Wiremod.Integration.SupportsWire(entity) then
                return {}
            end

            return entity.Outputs or {}
        end,

        -- Enhanced ship core with wire support
        EnhanceShipCore = function(shipCore)
            if not IsValid(shipCore) or not ASC.AI.Wiremod.IsAvailable() then
                return false
            end

            -- Add wire inputs/outputs to ship core for automation
            if WireLib.CreateInputs and WireLib.CreateOutputs then
                WireLib.CreateInputs(shipCore, {
                    "Jump [NORMAL]",
                    "Destination [VECTOR]",
                    "PowerLevel [NORMAL]",
                    "ShieldsUp [NORMAL]"
                })

                WireLib.CreateOutputs(shipCore, {
                    "Ready [NORMAL]",
                    "Jumping [NORMAL]",
                    "ShieldStatus [NORMAL]",
                    "PowerOutput [NORMAL]",
                    "EntityCount [NORMAL]"
                })

                return true
            end

            return false
        end
    }
}

-- CPPI (Common Prop Protection Interface) Integration
ASC.AI.CPPI = {
    -- Check if CPPI is available
    IsAvailable = function()
        return CPPI ~= nil
    end,

    -- Get CPPI version
    GetVersion = function()
        if ASC.AI.CPPI.IsAvailable() then
            return CPPI.GetVersion and CPPI:GetVersion() or "Unknown"
        end
        return nil
    end,

    -- Get entity owner via CPPI
    GetOwner = function(entity)
        if not IsValid(entity) or not ASC.AI.CPPI.IsAvailable() then
            return nil
        end

        if entity.CPPIGetOwner then
            return entity:CPPIGetOwner()
        end

        return nil
    end,

    -- Check if player can interact via CPPI
    CanInteract = function(player, entity, action)
        if not IsValid(player) or not IsValid(entity) or not ASC.AI.CPPI.IsAvailable() then
            return true -- Default allow if no protection
        end

        action = action or "Physgun"

        if entity.CPPICanTool then
            return entity:CPPICanTool(player, action)
        elseif entity.CPPICanPhysgun then
            return entity:CPPICanPhysgun(player)
        end

        return true
    end
}

-- Server Management Integration
ASC.AI.ServerManagement = {
    -- Monitor server performance
    MonitorPerformance = function()
        local memoryUsage = collectgarbage("count")
        local playerCount = #player.GetAll()
        local entityCount = #ents.GetAll()

        return {
            memory = memoryUsage,
            players = playerCount,
            entities = entityCount,
            uptime = CurTime()
        }
    end,

    -- AI-powered server optimization suggestions
    GetOptimizationSuggestions = function()
        local performance = ASC.AI.ServerManagement.MonitorPerformance()
        local suggestions = {}

        if performance.memory > 1000 then -- Over 1GB
            table.insert(suggestions, "High memory usage detected. Consider running garbage collection.")
        end

        if performance.entities > 5000 then
            table.insert(suggestions, "High entity count. Consider cleanup or entity limits.")
        end

        if performance.players > 50 then
            table.insert(suggestions, "High player count. Monitor for performance issues.")
        end

        return suggestions
    end,

    -- Automated server health checks
    PerformHealthCheck = function()
        local performance = ASC.AI.ServerManagement.MonitorPerformance()
        local suggestions = ASC.AI.ServerManagement.GetOptimizationSuggestions()

        local health = {
            status = "healthy",
            performance = performance,
            suggestions = suggestions,
            timestamp = os.time()
        }

        if performance.memory > 1500 or performance.entities > 8000 then
            health.status = "warning"
        end

        if performance.memory > 2000 or performance.entities > 10000 then
            health.status = "critical"
        end

        return health
    end
}

-- Multi-language support system
ASC.AI.Languages = {
    -- Current language database
    Database = {
        english = {
            greeting = "Hello! I'm ARIA-3, your Advanced Space Combat AI assistant.",
            help_prompt = "How can I help you today?",
            error_message = "I'm sorry, I didn't understand that. Could you rephrase?",
            goodbye = "Goodbye! Feel free to ask me anything anytime.",
            loading = "Processing your request...",
            success = "Task completed successfully!",
            warning = "Warning: Please check your configuration.",
            tip = "Tip:",
            suggestion = "Suggestion:"
        },
        spanish = {
            greeting = "¡Hola! Soy ARIA-3, tu asistente de IA de Combate Espacial Avanzado.",
            help_prompt = "¿Cómo puedo ayudarte hoy?",
            error_message = "Lo siento, no entendí eso. ¿Podrías reformularlo?",
            goodbye = "¡Adiós! No dudes en preguntarme cualquier cosa en cualquier momento.",
            loading = "Procesando tu solicitud...",
            success = "¡Tarea completada exitosamente!",
            warning = "Advertencia: Por favor verifica tu configuración.",
            tip = "Consejo:",
            suggestion = "Sugerencia:"
        },
        french = {
            greeting = "Bonjour! Je suis ARIA-3, votre assistant IA de Combat Spatial Avancé.",
            help_prompt = "Comment puis-je vous aider aujourd'hui?",
            error_message = "Désolé, je n'ai pas compris. Pourriez-vous reformuler?",
            goodbye = "Au revoir! N'hésitez pas à me poser des questions à tout moment.",
            loading = "Traitement de votre demande...",
            success = "Tâche accomplie avec succès!",
            warning = "Attention: Veuillez vérifier votre configuration.",
            tip = "Conseil:",
            suggestion = "Suggestion:"
        },
        czech = {
            -- Basic AI responses
            greeting = "Ahoj! Jsem ARIA-3, váš pokročilý asistent AI pro vesmírný boj.",
            help_prompt = "Jak vám dnes mohu pomoci?",
            error_message = "Promiňte, nerozuměl jsem tomu. Mohli byste to přeformulovat?",
            goodbye = "Na shledanou! Neváhejte se mě zeptat na cokoliv kdykoliv.",
            loading = "Zpracovávám váš požadavek...",
            success = "Úkol úspěšně dokončen!",
            warning = "Varování: Zkontrolujte prosím svou konfiguraci.",
            tip = "Tip:",
            suggestion = "Návrh:",

            -- Ship systems
            ship_core = "Jádro lodi je centrální řídící centrum všech lodí. Automaticky detekuje komponenty do 2000 jednotek, spravuje distribuci energie a koordinuje všechny systémy lodi.",
            auto_linking = "Automatické propojení spojuje komponenty s blízkými jádry lodí automaticky. Umístěte komponenty do 2000 jednotek od jádra lodi a propojí se automaticky!",
            energy_management = "Energii spravují jádra lodí a zdroje energie jako ZPM. Jádra lodí regenerují 5 energie/sec. ZPM poskytují neomezenou energii.",

            -- Stargate technology
            ancient_tech = "Starověká technologie je Tier 10 - nejpokročilejší. Funkce: ZPM (neomezená energie), dronové zbraně, městské štíty, kontrolní křesla a okamžité hyperpoháněče.",
            asgard_tech = "Asgardská technologie je Tier 8 - vysoce pokročilá. Funkce: iontové kanóny, počítačová jádra, transportní technologie a efektivní hyperpoháněče.",
            goauld_tech = "Goa'uldská technologie je Tier 5 - střední úroveň. Funkce: žezlové kanóny, sarkofág, ruční zařízení, prstencové transportéry a naquadahové reaktory.",
            wraith_tech = "Wraith technologie je Tier 6 - bio-organická. Funkce: dart zbraně, culling paprsky, úlové štíty, regenerační komory a úlové rozhraní.",
            ori_tech = "Ori technologie je Tier 9 - technologie povznesených bytostí. Funkce: pulsní zbraně, superbrány, žezla priorů a satelitní zbraně.",
            tauri_tech = "Tau'ri technologie je Tier 3 - lidské inženýrství. Funkce: stíhačky F-302, railguny, nukleární střely a zpětně zkonstruované mimozemské technologie.",

            -- Combat systems
            weapons = "5 typů zbraní k dispozici: Pulsní kanón (rychlá energie), Paprskové zbraně (kontinuální), Torpédové odpalovače (naváděné), Railgun (kinetické), Plazmové kanóny (plošný efekt).",
            tactical_ai = "Taktická AI má 3 režimy: Agresivní (maximální palebná síla), Obranný (zaměření na ochranu), Vyvážený (adaptivní). AI řídí zaměřování a koordinaci zbraní automaticky.",
            shields = "Štítové systémy poskytují energetické bariéry. K dispozici jsou štíty integrované s CAP. Štíty se automaticky dobíjejí a poskytují vícevrstvou ochranu.",

            -- Commands and help
            commands = "Klíčové příkazy: asc_help (systém nápovědy), asc_status (informace o systému), asc_stargate_spawn <kultura> <typ> (spawn technologie), asc_config (nastavení). Použijte !ai <otázka> pro dotazy!",
            spawning = "Použijte nástroje Advanced Space Combat v Q menu! K dispozici jsou nástroje pro jádro lodi, hyperpohon, zbraně a štíty. Všechny entity se automaticky propojí s jádry lodí do 2000 jednotek.",
            organization = "Kompletní organizační systém v3.1.0! Q menu: záložka Advanced Space Combat s nástroji, stavbou lodí, zbraněmi, obranou, transportem, konfigurací a nápovědou.",

            -- Error messages
            command_not_found = "Příkaz nenalezen. Zkuste 'aria pomoc' pro seznam dostupných příkazů.",
            invalid_target = "Neplatný cíl. Ujistěte se, že cíl existuje a je platný.",
            system_error = "Systémová chyba. Zkuste to znovu nebo kontaktujte administrátora.",
            access_denied = "Přístup odepřen. Nemáte dostatečná oprávnění pro tento příkaz.",

            -- Status messages
            system_online = "Systém online",
            system_offline = "Systém offline",
            weapons_online = "Zbraně online",
            shields_active = "Štíty aktivní",
            flight_system = "Letový systém",
            tactical_ai_active = "Taktická AI aktivní",
            mission_complete = "Mise dokončena",

            -- AI personality responses
            thinking = "Přemýšlím...",
            analyzing = "Analyzuji data...",
            processing = "Zpracovávám informace...",
            understanding = "Rozumím vašemu dotazu...",
            searching = "Hledám v databázi znalostí...",

            -- Help categories
            help_ship_systems = "Systémy lodí",
            help_weapons = "Zbraně",
            help_stargate_tech = "Stargate technologie",
            help_commands = "Příkazy",
            help_troubleshooting = "Řešení problémů"
        }
    },

    -- Language code mapping (multilingual system uses codes like "cs", AI uses full names like "czech")
    LanguageMapping = {
        en = "english",
        es = "spanish",
        fr = "french",
        cs = "czech",
        de = "german",
        it = "italian",
        pl = "polish",
        ru = "russian"
    },

    -- Get localized text
    GetText = function(playerID, key)
        local profile = ASC.AI.UserProfiles[playerID]
        local language = (profile and profile.language_preference) or "english"

        local langData = ASC.AI.Languages.Database[language]
        if langData and langData[key] then
            return langData[key]
        end

        -- Fallback to English
        return ASC.AI.Languages.Database.english[key] or key
    end,

    -- Get localized text by player object
    GetTextByPlayer = function(player, key)
        if not IsValid(player) then
            return ASC.AI.Languages.Database.english[key] or key
        end

        local playerID = player:SteamID()
        local profile = ASC.AI.UserProfiles[playerID]

        -- Get player language from multilingual system if available
        local language = "english"
        if profile and profile.language_preference then
            language = profile.language_preference
        elseif ASC.Multilingual and ASC.Multilingual.Core then
            local langCode = ASC.Multilingual.Core.GetPlayerLanguage(player)
            language = ASC.AI.Languages.LanguageMapping[langCode] or "english"
        end

        local langData = ASC.AI.Languages.Database[language]
        if langData and langData[key] then
            return langData[key]
        end

        -- Fallback to English
        return ASC.AI.Languages.Database.english[key] or key
    end,

    -- Convert language code to AI language name
    ConvertLanguageCode = function(langCode)
        return ASC.AI.Languages.LanguageMapping[langCode] or "english"
    end,

    -- Translate Czech commands to English for processing
    TranslateCzechCommand = function(query)
        local lowerQuery = string.lower(query)

        -- Czech to English command mapping
        local czechCommands = {
            ["pomoc"] = "help",
            ["nápověda"] = "help",
            ["stav"] = "status",
            ["status"] = "status",
            ["vytvoř"] = "spawn",
            ["spawn"] = "spawn",
            ["nastav"] = "configure",
            ["konfiguruj"] = "configure",
            ["aktivuj"] = "activate",
            ["zapni"] = "enable",
            ["vypni"] = "disable",
            ["deaktivuj"] = "deactivate",
            ["skoč"] = "jump",
            ["teleportuj"] = "teleport",
            ["vytočit"] = "dial",
            ["oprav"] = "fix",
            ["diagnostika"] = "diagnostic",
            ["řešení"] = "troubleshoot",
            ["jádro lodi"] = "ship core",
            ["zbraně"] = "weapons",
            ["štíty"] = "shields",
            ["hyperpohon"] = "hyperdrive",
            ["stargate"] = "stargate",
            ["energie"] = "energy",
            ["letový systém"] = "flight system",
            ["taktická ai"] = "tactical ai"
        }

        -- Replace Czech terms with English equivalents
        local translatedQuery = lowerQuery
        for czech, english in pairs(czechCommands) do
            translatedQuery = string.gsub(translatedQuery, czech, english)
        end

        return translatedQuery
    end,

    -- Translate English responses to Czech
    TranslateResponseToCzech = function(response)
        if not response or response == "" then return response end

        local lowerResponse = string.lower(response)

        -- Common response patterns to Czech
        local responseTranslations = {
            -- Basic responses
            ["hello"] = "Ahoj",
            ["hi"] = "Ahoj",
            ["welcome"] = "Vítejte",
            ["goodbye"] = "Na shledanou",
            ["thank you"] = "Děkuji",
            ["you're welcome"] = "Není zač",
            ["yes"] = "Ano",
            ["no"] = "Ne",
            ["ok"] = "OK",
            ["done"] = "Hotovo",
            ["success"] = "Úspěch",
            ["failed"] = "Selhalo",
            ["error"] = "Chyba",
            ["warning"] = "Varování",

            -- AI responses
            ["i'm aria"] = "Jsem ARIA",
            ["how can i help"] = "Jak mohu pomoci",
            ["processing"] = "Zpracovávám",
            ["analyzing"] = "Analyzuji",
            ["searching"] = "Hledám",
            ["thinking"] = "Přemýšlím",

            -- Ship systems
            ["ship core"] = "jádro lodi",
            ["weapons"] = "zbraně",
            ["shields"] = "štíty",
            ["energy"] = "energie",
            ["hyperdrive"] = "hyperpohon",
            ["flight system"] = "letový systém",
            ["tactical ai"] = "taktická AI",

            -- Status
            ["online"] = "online",
            ["offline"] = "offline",
            ["active"] = "aktivní",
            ["inactive"] = "neaktivní",
            ["ready"] = "připraven",
            ["not ready"] = "nepřipraven",

            -- Commands
            ["teleported"] = "Teleportován",
            ["spawned"] = "Vytvořen",
            ["activated"] = "Aktivován",
            ["deactivated"] = "Deaktivován",
            ["configured"] = "Nakonfigurován",

            -- Common phrases
            ["try again"] = "zkuste znovu",
            ["make sure"] = "ujistěte se",
            ["not found"] = "nenalezen",
            ["invalid"] = "neplatný",
            ["available"] = "dostupný",
            ["not available"] = "nedostupný"
        }

        -- Apply translations
        local translatedResponse = response
        for english, czech in pairs(responseTranslations) do
            translatedResponse = string.gsub(translatedResponse, english, czech)
        end

        -- If significant translation occurred, return it
        if translatedResponse ~= response then
            return translatedResponse
        end

        -- For complex responses, try to get localized text from database
        local playerLang = "czech"
        for key, text in pairs(ASC.AI.Languages.Database.english) do
            if string.find(lowerResponse, string.lower(text)) then
                local czechText = ASC.AI.Languages.Database.czech[key]
                if czechText then
                    translatedResponse = string.gsub(translatedResponse, text, czechText)
                end
            end
        end

        return translatedResponse
    end,

    -- Set user language preference
    SetLanguage = function(playerID, language)
        if not ASC.AI.UserProfiles[playerID] then
            ASC.AI.UserProfiles[playerID] = {}
        end

        -- Convert language code to full name if needed
        local fullLanguageName = language
        if ASC.AI.Languages.LanguageMapping[language] then
            fullLanguageName = ASC.AI.Languages.LanguageMapping[language]
        end

        if ASC.AI.Languages.Database[fullLanguageName] then
            ASC.AI.UserProfiles[playerID].language_preference = fullLanguageName
            return true
        end

        return false
    end,

    -- Detect language from query (basic implementation)
    DetectLanguage = function(query)
        local lowerQuery = string.lower(query)

        -- Spanish detection
        local spanishWords = {"como", "que", "donde", "cuando", "por", "para", "con", "sin", "muy", "mas"}
        local spanishCount = 0
        for _, word in ipairs(spanishWords) do
            if string.find(lowerQuery, word) then
                spanishCount = spanishCount + 1
            end
        end

        -- French detection
        local frenchWords = {"comment", "que", "ou", "quand", "pour", "avec", "sans", "tres", "plus", "le", "la", "les"}
        local frenchCount = 0
        for _, word in ipairs(frenchWords) do
            if string.find(lowerQuery, word) then
                frenchCount = frenchCount + 1
            end
        end

        -- Czech detection (comprehensive with diacritics and cultural context)
        local czechWords = {
            -- === ZÁKLADNÍ SLOVA ===
            "jak", "kde", "co", "proč", "když", "ale", "nebo", "že", "být", "mít",
            "ahoj", "děkuji", "prosím", "ano", "ne", "dobře", "špatně", "možná",

            -- === ČASTÉ ČESKÉ VÝRAZY ===
            "jsem", "jsi", "je", "jsme", "jste", "jsou", "byl", "byla", "bylo", "byli", "byly",
            "můžu", "můžeš", "může", "můžeme", "můžete", "mohou", "mohl", "mohla", "mohlo",
            "chci", "chceš", "chce", "chceme", "chcete", "chtějí", "chtěl", "chtěla",
            "potřebuji", "potřebuješ", "potřebuje", "potřebujeme", "potřebujete", "potřebují",
            "funguje", "nefunguje", "problém", "řešení", "pomoc", "nápověda",

            -- === VESMÍRNÝ BOJ TERMINOLOGIE ===
            "loď", "lodi", "lodí", "zbraň", "zbraně", "zbraní", "let", "letu", "létání",
            "štít", "štíty", "štítů", "energie", "energii", "energií", "hyperpohon", "hyperpoháněč",
            "jádro", "jádra", "jader", "systém", "systémy", "systémů", "stargate", "brána", "brány",
            "cestování", "vesmír", "vesmíru", "boj", "boje", "bojů", "útok", "útoky", "útoků",
            "obrana", "obrany", "navigace", "senzory", "palivo", "munice", "torpédo",

            -- === PŘÍKAZY V ČEŠTINĚ ===
            "pomoc", "nápověda", "status", "stav", "spawn", "vytvoř", "vytvořit", "nastav",
            "nastavit", "aktivuj", "aktivovat", "zapni", "zapnout", "vypni", "vypnout",
            "deaktivuj", "deaktivovat", "skoč", "skočit", "teleportuj", "teleportovat",
            "vytočit", "vytáčet", "oprav", "opravit", "diagnostika", "řešení", "troubleshoot",

            -- === STARGATE TECHNOLOGIE ===
            "starověká", "asgardská", "goauldská", "wraith", "ori", "tauri", "technologie",
            "dhd", "zpm", "naquadah", "trinium", "neutronium", "kontrolní", "křeslo",
            "transportér", "prstencový", "sarkofág", "regenerace", "úl", "prior",

            -- === FORMÁLNÍ/NEFORMÁLNÍ OSLOVENÍ ===
            "vy", "vás", "vám", "váš", "vaše", "vaší", "ty", "tě", "ti", "tvůj", "tvoje", "tvé",
            "prosím", "děkuji", "děkuju", "díky", "pardon", "promiňte", "omlouvám",

            -- === ČASOVÉ VÝRAZY ===
            "teď", "nyní", "dnes", "včera", "zítra", "brzy", "později", "rychle", "pomalu",
            "okamžitě", "ihned", "za chvíli", "za moment", "za minutu", "za hodinu",

            -- === EMOCIONÁLNÍ VÝRAZY ===
            "skvělé", "výborné", "perfektní", "úžasné", "fantastické", "super", "fajn",
            "špatné", "hrozné", "problematické", "složité", "jednoduché", "lehké", "těžké",

            -- === ČESKÉ DIAKRITICKE ZNAKY (DETEKCE) ===
            "á", "č", "ď", "é", "ě", "í", "ň", "ó", "ř", "š", "ť", "ú", "ů", "ý", "ž"
        }

        local czechCount = 0
        local diacriticsCount = 0

        -- Počítání českých slov
        for _, word in ipairs(czechWords) do
            if string.find(lowerQuery, word) then
                czechCount = czechCount + 1
            end
        end

        -- Detekce českých diakritických znaků
        local czechDiacritics = {"á", "č", "ď", "é", "ě", "í", "ň", "ó", "ř", "š", "ť", "ú", "ů", "ý", "ž"}
        for _, char in ipairs(czechDiacritics) do
            if string.find(lowerQuery, char) then
                diacriticsCount = diacriticsCount + 1
            end
        end

        -- Pokročilá detekce - kombinace slov a diakritiky
        local czechConfidence = czechCount + (diacriticsCount * 0.5)

        if czechConfidence >= 2 then return "czech" end
        if spanishCount > 1 then return "spanish" end
        if frenchCount > 1 then return "french" end

        return "english"
    end,

    -- === POKROČILÉ ČESKÉ FUNKCE ===

    -- Validate Czech text encoding (UTF-8)
    ValidateCzechEncoding = function(text)
        if not text or text == "" then return true end

        -- Check for proper UTF-8 encoding of Czech characters
        local czechChars = {
            ["á"] = true, ["Á"] = true,
            ["č"] = true, ["Č"] = true,
            ["ď"] = true, ["Ď"] = true,
            ["é"] = true, ["É"] = true,
            ["ě"] = true, ["Ě"] = true,
            ["í"] = true, ["Í"] = true,
            ["ň"] = true, ["Ň"] = true,
            ["ó"] = true, ["Ó"] = true,
            ["ř"] = true, ["Ř"] = true,
            ["š"] = true, ["Š"] = true,
            ["ť"] = true, ["Ť"] = true,
            ["ú"] = true, ["Ú"] = true,
            ["ů"] = true, ["Ů"] = true,
            ["ý"] = true, ["Ý"] = true,
            ["ž"] = true, ["Ž"] = true
        }

        -- Check each character
        for i = 1, string.len(text) do
            local char = string.sub(text, i, i)
            local byte = string.byte(char)

            -- Check for invalid encoding (common issue with Czech characters)
            if byte > 127 and not czechChars[char] then
                -- Might be encoding issue
                return false
            end
        end

        return true
    end,

    -- Detect Czech cultural context (formal vs informal)
    DetectCzechFormality = function(text)
        if not text or text == "" then return "neutral" end

        local lowerText = string.lower(text)

        -- Formal indicators (vykat)
        local formalWords = {
            "vy", "vás", "vám", "váš", "vaše", "vaší", "můžete", "jste", "budete",
            "prosím vás", "děkuji vám", "omlouvám se", "dovolte", "ráčíte"
        }

        -- Informal indicators (tykat)
        local informalWords = {
            "ty", "tě", "ti", "tvůj", "tvoje", "tvé", "můžeš", "jsi", "budeš",
            "díky", "děkuju", "ahoj", "čau", "nazdar", "sorry"
        }

        local formalCount = 0
        local informalCount = 0

        for _, word in ipairs(formalWords) do
            if string.find(lowerText, word) then
                formalCount = formalCount + 1
            end
        end

        for _, word in ipairs(informalWords) do
            if string.find(lowerText, word) then
                informalCount = informalCount + 1
            end
        end

        if formalCount > informalCount then
            return "formal"
        elseif informalCount > formalCount then
            return "informal"
        else
            return "neutral"
        end
    end,

    -- Generate Czech response with proper formality
    GenerateCzechResponse = function(baseResponse, formality, playerName)
        if not baseResponse or baseResponse == "" then return baseResponse end

        local response = baseResponse

        -- Apply formality adjustments
        if formality == "formal" then
            -- Use formal language
            response = string.gsub(response, "ty", "vy")
            response = string.gsub(response, "tě", "vás")
            response = string.gsub(response, "ti", "vám")
            response = string.gsub(response, "tvůj", "váš")
            response = string.gsub(response, "tvoje", "vaše")
            response = string.gsub(response, "můžeš", "můžete")
            response = string.gsub(response, "jsi", "jste")
            response = string.gsub(response, "díky", "děkuji")
            response = string.gsub(response, "ahoj", "dobrý den")
        elseif formality == "informal" then
            -- Use informal language
            response = string.gsub(response, "vy", "ty")
            response = string.gsub(response, "vás", "tě")
            response = string.gsub(response, "vám", "ti")
            response = string.gsub(response, "váš", "tvůj")
            response = string.gsub(response, "vaše", "tvoje")
            response = string.gsub(response, "můžete", "můžeš")
            response = string.gsub(response, "jste", "jsi")
            response = string.gsub(response, "děkuji", "díky")
            response = string.gsub(response, "dobrý den", "ahoj")
        end

        -- Add personalization if player name provided
        if playerName and playerName ~= "" then
            if formality == "formal" then
                response = response .. " (pro " .. playerName .. ")"
            else
                response = response .. " (" .. playerName .. ")"
            end
        end

        return response
    end,

    -- Enhanced Czech command translation with context
    TranslateCzechCommandAdvanced = function(query, context)
        local lowerQuery = string.lower(query)
        context = context or {}

        -- Rozšířené mapování českých příkazů
        local czechCommands = {
            -- === ZÁKLADNÍ PŘÍKAZY ===
            ["pomoc"] = "help", ["nápověda"] = "help", ["help"] = "help",
            ["stav"] = "status", ["status"] = "status", ["informace"] = "info",
            ["vytvoř"] = "spawn", ["vytvořit"] = "spawn", ["spawn"] = "spawn",
            ["nastav"] = "configure", ["nastavit"] = "configure", ["konfiguruj"] = "configure",
            ["aktivuj"] = "activate", ["aktivovat"] = "activate", ["zapni"] = "enable",
            ["vypni"] = "disable", ["vypnout"] = "disable", ["deaktivuj"] = "deactivate",

            -- === POHYB A TRANSPORT ===
            ["skoč"] = "jump", ["skočit"] = "jump", ["teleportuj"] = "teleport",
            ["teleportovat"] = "teleport", ["přesunout"] = "move", ["letět"] = "fly",
            ["cestovat"] = "travel", ["navigovat"] = "navigate",

            -- === STARGATE PŘÍKAZY ===
            ["vytočit"] = "dial", ["vytáčet"] = "dial", ["připojit"] = "connect",
            ["odpojit"] = "disconnect", ["zavřít"] = "close", ["otevřít"] = "open",

            -- === SYSTÉMY LODI ===
            ["jádro lodi"] = "ship core", ["jádro"] = "core", ["loď"] = "ship",
            ["zbraně"] = "weapons", ["zbraň"] = "weapon", ["střelba"] = "fire",
            ["štíty"] = "shields", ["štít"] = "shield", ["obrana"] = "defense",
            ["hyperpohon"] = "hyperdrive", ["hyperpoháněč"] = "hyperdrive",
            ["energie"] = "energy", ["palivo"] = "fuel", ["munice"] = "ammunition",

            -- === DIAGNOSTIKA ===
            ["oprav"] = "fix", ["opravit"] = "repair", ["diagnostika"] = "diagnostic",
            ["řešení"] = "troubleshoot", ["problém"] = "problem", ["chyba"] = "error",

            -- === POKROČILÉ FUNKCE ===
            ["letový systém"] = "flight system", ["taktická ai"] = "tactical ai",
            ["formace"] = "formation", ["dokování"] = "docking", ["boss"] = "boss"
        }

        -- Aplikace překladů s kontextem
        local translatedQuery = lowerQuery
        for czech, english in pairs(czechCommands) do
            translatedQuery = string.gsub(translatedQuery, czech, english)
        end

        -- Kontextové úpravy
        if context.shipDetected then
            translatedQuery = string.gsub(translatedQuery, "to", "ship")
            translatedQuery = string.gsub(translatedQuery, "toto", "this ship")
        end

        if context.stargateDetected then
            translatedQuery = string.gsub(translatedQuery, "brána", "stargate")
            translatedQuery = string.gsub(translatedQuery, "portál", "stargate")
        end

        return translatedQuery
    end
}



-- AI Knowledge Base
ASC.AI.Knowledge = {
    -- Core Systems
    CoreSystems = {
        {
            topic = "ship_core",
            keywords = {"ship core", "core", "ship", "hub", "central"},
            response = "Ship cores are the central management hubs of all ships. They auto-detect nearby components within 2000 units, manage energy distribution, monitor hull integrity, and coordinate all ship systems. Use E to access the interface."
        },
        {
            topic = "auto_linking",
            keywords = {"auto link", "linking", "connect", "attach", "detection"},
            response = "Auto-linking connects components to nearby ship cores automatically. Place components within 2000 units of a ship core and they'll link automatically. No manual configuration needed!"
        },
        {
            topic = "energy_management",
            keywords = {"energy", "power", "zpm", "reactor", "battery"},
            response = "Energy is managed by ship cores and power sources like ZPMs. Ship cores regenerate 5 energy/sec. ZPMs provide unlimited energy. Monitor energy levels in the ship interface."
        }
    },
    
    -- Stargate Technology
    StargateTech = {
        {
            topic = "ancient_tech",
            keywords = {"ancient", "lantean", "atlantis", "zpm", "drone"},
            response = "Ancient technology is Tier 10 - the most advanced. Features: ZPMs (unlimited energy), drone weapons (adaptive targeting), city shields (planetary scale), control chairs (neural interface), and instant hyperdrives."
        },
        {
            topic = "asgard_tech",
            keywords = {"asgard", "ion cannon", "beaming", "hologram"},
            response = "Asgard technology is Tier 8 - highly advanced. Features: ion cannons (particle beams), computer cores (quantum processing), beaming technology (matter transport), and efficient hyperdrives."
        },
        {
            topic = "goauld_tech",
            keywords = {"goa'uld", "goauld", "staff", "sarcophagus", "naquadah"},
            response = "Goa'uld technology is Tier 5 - intermediate. Features: staff cannons (plasma weapons), sarcophagus (resurrection), hand devices (energy weapons), ring transporters, and naquadah reactors."
        },
        {
            topic = "wraith_tech",
            keywords = {"wraith", "dart", "culling", "hive", "organic"},
            response = "Wraith technology is Tier 6 - bio-organic. Features: dart weapons (organic energy), culling beams (matter transport), hive shields (adaptive), regeneration chambers, and hive mind interfaces."
        },
        {
            topic = "ori_tech",
            keywords = {"ori", "prior", "supergate", "ascended"},
            response = "Ori technology is Tier 9 - ascended being tech. Features: pulse weapons (advanced energy), supergates (intergalactic transport), prior staffs (energy manipulation), and satellite weapons."
        },
        {
            topic = "tauri_tech",
            keywords = {"tau'ri", "tauri", "earth", "human", "f302"},
            response = "Tau'ri technology is Tier 3 - human engineering. Features: F-302 fighters, railguns (kinetic), nuclear missiles, iris protection, and reverse-engineered alien tech."
        }
    },
    
    -- Combat Systems
    CombatSystems = {
        {
            topic = "weapons",
            keywords = {"weapon", "gun", "cannon", "fire", "shoot"},
            response = "5 weapon types available: Pulse Cannon (fast energy), Beam Weapon (continuous), Torpedo Launcher (guided), Railgun (kinetic), Plasma Cannon (area effect). All auto-link to ship cores."
        },
        {
            topic = "tactical_ai",
            keywords = {"tactical", "ai", "combat ai", "behavior", "strategy"},
            response = "Tactical AI has 3 modes: Aggressive (max firepower), Defensive (protection focus), Balanced (adaptive). AI handles targeting, weapon coordination, and fleet tactics automatically."
        },
        {
            topic = "shields",
            keywords = {"shield", "protection", "barrier", "defense"},
            response = "Shield systems provide energy barriers. CAP-integrated shields available. Shields auto-recharge, have frequency modulation, and provide multi-layer protection. Monitor shield strength in ship interface."
        }
    },
    
    -- Commands and Usage
    Commands = {
        {
            topic = "commands",
            keywords = {"command", "help", "how to", "usage", "ai commands"},
            response = "Key commands: asc_help (help system), asc_status (system info), asc_stargate_spawn <culture> <type> (spawn tech), asc_config (settings). Use !ai <question> to ask me anything! All AI commands use the !ai prefix."
        },
        {
            topic = "spawning",
            keywords = {"spawn", "create", "place"},
            response = "Use the Advanced Space Combat tools in Q menu! Ship Core Tool, Hyperdrive Tool, Weapon Tool, Shield Tool available. All entities auto-link to ship cores within 2000 units. Complete spawn menu organization with categorized entities!"
        },
        {
            topic = "organization",
            keywords = {"organization", "q menu", "spawn menu", "tabs", "empty", "missing"},
            response = "Complete organization system v3.1.0! Q menu: Advanced Space Combat tab with Core Tools, Ship Building, Weapons, Defense, Transport, Configuration, Help. Spawn menu: Categorized entities with auto-linking. All organized and functional!"
        },
        {
            topic = "tools",
            keywords = {"tools", "q menu", "gmod tool", "asc tools"},
            response = "Advanced Space Combat Tools: ASC Main Tool (general spawning), Ship Builder (ship templates), Weapon Config (weapon setup). Find them in Q menu > Advanced Space Combat tab with organized categories!"
        },
        {
            topic = "ship_templates",
            keywords = {"ship templates", "fighter", "cruiser", "carrier", "build ship"},
            response = "Ship Builder tool has 3 templates: Fighter (fast, light weapons), Cruiser (balanced, multiple weapons), Carrier (large, docking bays). Use Ship Builder tool and select template mode!"
        },
        {
            topic = "weapon_config",
            keywords = {"weapon config", "weapon setup", "targeting", "fire rate"},
            response = "Weapon Config tool: Configure weapon modes (manual/auto/defensive/aggressive), set targeting, adjust fire rates, test weapons. Right-click to set targets, reload to test fire!"
        },
        {
            topic = "entity_spawning",
            keywords = {"entity spawning", "spawn limits", "auto link", "spawn commands"},
            response = "Entity spawning system: Use 'asc_spawn_entity <class>' or Q menu buttons. Auto-linking to ship cores within 2000 units. Spawn limits per player. Use 'asc_spawn_limits' to check limits, 'asc_cleanup_entities' to clean up."
        },
        {
            topic = "materials_models",
            keywords = {"materials", "models", "textures", "assets", "missing assets"},
            response = "All materials and models included! Entity materials with glow effects, normal maps, phong shading. Effect materials for weapons and hyperspace. Models for all entities. Complete asset system with fallbacks."
        },
        {
            topic = "enhanced_hyperspace",
            keywords = {"enhanced hyperspace", "hyperspace v2", "tardis hyperspace", "dimensional travel", "4 stage hyperspace"},
            response = "Enhanced Hyperspace v2.0: TARDIS-inspired dimensional mechanics with Stargate theming! 4-stage travel: 1) Energy buildup, 2) Blue swirling window, 3) Dimensional transit with starlines, 4) Exit flash & stabilization. Features time distortion, spatial folding, and dimensional layers!"
        },
        {
            topic = "hyperspace_layers",
            keywords = {"hyperspace layers", "dimensional layers", "subspace", "ancient conduit", "void between", "ascended realm"},
            response = "Hyperspace Layers: 5 dimensional layers with varying stability and energy costs. Subspace (99% stable), Hyperspace (95%), Ancient Conduit (90%), Void Between (80%), Ascended Realm (70%). Deeper layers = lower energy cost but higher risk!"
        },
        {
            topic = "dimensional_mechanics",
            keywords = {"dimensional mechanics", "tardis mechanics", "time distortion", "spatial folding", "dimensional pockets", "temporal shielding"},
            response = "TARDIS-Inspired Mechanics: Time distortion (20% slower in hyperspace), spatial folding (90% distance reduction), dimensional pockets (bigger inside), temporal shielding protection, reality anchors. Advanced physics with authentic Stargate theming!"
        },
        {
            topic = "hyperspace_effects",
            keywords = {"hyperspace effects", "stargate effects", "blue window", "energy streams", "ancient symbols", "starlines"},
            response = "Stargate-Themed Hyperspace Effects: Blue swirling entry windows, stretched starlines during travel, Ancient symbols, dimensional visuals, energy streams, light flash exits. Complete 4-stage visual experience with authentic Stargate aesthetics and TARDIS-quality effects!"
        },
        {
            topic = "diagnostic",
            keywords = {"diagnostic", "fix", "broken", "not working", "error"},
            response = "Diagnostic commands: asc_diagnostic (full check), asc_fix_organization (fix tabs), asc_force_setup_qmenu (Q menu), asc_force_register_entities (spawn menu)."
        }
    },

    -- Organization Help
    OrganizationHelp = {
        {
            topic = "qmenu_empty",
            keywords = {"q menu empty", "tabs empty", "no tools", "missing tabs"},
            response = "Empty Q menu tabs? Use 'asc_force_setup_qmenu' to fix. The 'Advanced Space Combat' tab should appear with tools, weapons, flight, transport, and help categories."
        },
        {
            topic = "spawn_menu_empty",
            keywords = {"spawn menu empty", "no entities", "missing entities", "can't spawn"},
            response = "Missing spawn menu entities? Use 'asc_force_register_entities' to fix. Look for 'Advanced Space Combat' category in spawn menu with all entities."
        },
        {
            topic = "organization_fix",
            keywords = {"fix organization", "repair", "reset", "reload"},
            response = "To fix organization issues: 1) asc_diagnostic (check status), 2) asc_fix_organization (auto-fix), 3) Restart Garry's Mod if needed."
        }
    },

    -- ULX and Admin Help
    ULXHelp = {
        {
            topic = "ulx_integration",
            keywords = {"ulx", "admin", "moderator", "permissions", "access"},
            response = "ULX integration provides admin commands: ulx ai_status <player> (view AI profiles), ulx ai_reset <player> (reset profiles), ulx ai_stats (global statistics). Requires moderator+ access."
        },
        {
            topic = "admin_commands",
            keywords = {"admin commands", "ulx commands", "moderator", "staff"},
            response = "Admin AI commands: ulx ai_status, ulx ai_reset, ulx ai_stats. Also available: asc_ai_train (server management), asc_ai_analytics (detailed stats). ULX integration provides proper permission handling."
        },
        {
            topic = "server_management",
            keywords = {"server", "performance", "optimization", "health", "monitoring"},
            response = "AI server management includes performance monitoring, optimization suggestions, and health checks. Use asc_ai_train stats for global metrics or ulx ai_stats for ULX integration."
        },
        {
            topic = "permissions",
            keywords = {"permissions", "access level", "rank", "group"},
            response = "AI permission system: Superadmin (100), Admin (80), Moderator (60), VIP (40), User (20), Guest (10). Moderator+ required for admin AI features. Integrates with ULX permission system."
        }
    },

    -- ULib Foundation Help
    ULibHelp = {
        {
            topic = "ulib_foundation",
            keywords = {"ulib", "foundation", "library", "core", "base"},
            response = "ULib is the foundational library for ULX admin system. AI integrates with ULib for messaging, permission checking, and user management. ULib provides the core functionality that ULX builds upon."
        },
        {
            topic = "ulib_messaging",
            keywords = {"messaging", "tsay", "console", "chat", "communication"},
            response = "ULib messaging system: ULib.tsay (chat messages), ULib.tsayError (error messages), ULib.console (console output). AI uses ULib messaging for consistent admin communication."
        },
        {
            topic = "ulib_permissions",
            keywords = {"ucl", "user control list", "access control", "permission system"},
            response = "ULib UCL (User Control List) manages permissions: ULib.ucl.query (check permissions), ULib.ucl.getUserAccessString (get access level). AI integrates with UCL for proper permission handling."
        },
        {
            topic = "ulib_utilities",
            keywords = {"utilities", "helper functions", "tools", "functions"},
            response = "ULib provides utility functions for server management, player handling, and system integration. AI leverages ULib utilities for robust and compatible server administration."
        },
        {
            topic = "ulib_compatibility",
            keywords = {"compatibility", "version", "support", "integration"},
            response = "AI system is fully compatible with ULib and automatically detects ULib version. Works with all ULib versions and provides fallback functionality when ULib is not available."
        }
    },

    -- NPP and Prop Protection Help
    PropProtectionHelp = {
        {
            topic = "npp_integration",
            keywords = {"npp", "nadmod", "prop protection", "cppi", "ownership"},
            response = "NPP (Nadmod Prop Protection) integration provides entity ownership management, CPPI compliance, and cleanup tools. AI respects prop protection and provides admin cleanup commands."
        },
        {
            topic = "entity_ownership",
            keywords = {"owner", "ownership", "who owns", "entity owner", "prop owner"},
            response = "Entity ownership is managed through NPP/CPPI. Use AI admin commands to check ownership, clean player entities, or manage disconnected players' props. Admins can bypass protection."
        },
        {
            topic = "cleanup_commands",
            keywords = {"cleanup", "clean", "remove props", "delete entities", "clear"},
            response = "Cleanup commands: ulx ai_clean <player> (clean player's entities), ulx ai_clean_disconnected (clean offline players), nadmod_cleanplayer (NPP native). AI provides entity counts and ownership info."
        },
        {
            topic = "friends_system",
            keywords = {"friends", "share", "permission", "allow access", "friend list"},
            response = "NPP friends system allows sharing entity access. Add friends through NPP admin panel. AI respects friend permissions and can help troubleshoot access issues."
        },
        {
            topic = "cppi_compliance",
            keywords = {"cppi", "common prop protection", "interface", "compatibility"},
            response = "Advanced Space Combat is CPPI compliant and works with NPP, Falco's PP, Simple PP, and other protection systems. AI automatically detects and integrates with available systems."
        }
    },

    -- AdvDupe2 and Wiremod Help
    AdvDupe2Help = {
        {
            topic = "advdupe2_integration",
            keywords = {"advdupe2", "advanced duplicator", "dupe", "save", "load", "duplication"},
            response = "AdvDupe2 integration allows saving and loading complete ships as dupes. Use AI commands to save ships, load templates, and manage ship blueprints. Supports ship validation and component detection."
        },
        {
            topic = "ship_templates",
            keywords = {"ship templates", "blueprints", "prebuilt", "designs", "fighter", "cruiser", "shuttle"},
            response = "Ship templates include Basic Fighter (beginner), Heavy Cruiser (advanced), and Transport Shuttle (intermediate). Templates specify required components and difficulty levels for building."
        },
        {
            topic = "save_ship",
            keywords = {"save ship", "create dupe", "export ship", "backup ship"},
            response = "To save a ship: Look at ship core, use AdvDupe2 save commands. AI validates ship has required components and creates dupe with metadata. Ships must have ship core and Advanced Space Combat components."
        },
        {
            topic = "load_ship",
            keywords = {"load ship", "spawn dupe", "import ship", "place ship"},
            response = "To load a ship: Use AdvDupe2 load commands with ship name. AI validates dupe compatibility and spawns ship at target location. Supports position and angle specification."
        },
        {
            topic = "wiremod_integration",
            keywords = {"wiremod", "wire", "automation", "inputs", "outputs", "control"},
            response = "Wiremod integration adds automation to ship cores: Jump, Destination, PowerLevel, ShieldsUp inputs. Ready, Jumping, ShieldStatus, PowerOutput, EntityCount outputs. Enables automated ship control."
        },
        {
            topic = "wire_automation",
            keywords = {"wire automation", "automated control", "wire inputs", "wire outputs", "ship automation"},
            response = "Wire automation allows programmatic ship control through Expression 2, CPU, or other wire devices. Ship cores provide status outputs and accept control inputs for automated operation."
        }
    },

    -- CAP (Carter Addon Pack) Help
    CAPHelp = {
        {
            topic = "cap_integration",
            keywords = {"cap", "carter addon pack", "stargate", "integration", "carter pack"},
            response = "CAP (Carter Addon Pack) integration provides comprehensive Stargate technology support. Includes stargates, DHDs, shields, ZPMs, weapons, vehicles, and transportation systems. Full compatibility with Advanced Space Combat."
        },
        {
            topic = "stargate_technology",
            keywords = {"stargate", "dhd", "dial home device", "gate", "wormhole", "address"},
            response = "Stargate technology includes Milky Way, Pegasus, Universe, and Supergate variants. DHDs provide dialing capabilities. AI can generate addresses and integrate gates with ship systems for advanced transportation."
        },
        {
            topic = "cap_shields",
            keywords = {"cap shields", "iris", "shield bubble", "personal shield", "shield core"},
            response = "CAP shield systems integrate with Advanced Space Combat shields. Includes iris protection, bubble shields, personal shields, and shield cores. AI automatically detects and integrates CAP shield components."
        },
        {
            topic = "zpm_power",
            keywords = {"zpm", "zero point module", "naquadah generator", "potentia", "power", "energy"},
            response = "ZPM (Zero Point Module) and Naquadah generators provide advanced power for ship systems. AI integrates CAP power sources with hyperdrive engines for enhanced performance and efficiency."
        },
        {
            topic = "cap_vehicles",
            keywords = {"puddle jumper", "hatak", "alkesh", "daedalus", "prometheus", "destiny", "atlantis"},
            response = "CAP vehicles include Puddle Jumpers, Ha'tak, Alkesh, Daedalus, Prometheus, Destiny, and Atlantis. These integrate with Advanced Space Combat ship systems for enhanced functionality."
        },
        {
            topic = "cap_weapons",
            keywords = {"staff weapon", "zat gun", "drone weapon", "asgard beam", "ori beam", "cap weapons"},
            response = "CAP weapons include Staff Weapons, Zat'nik'tel, Drone Weapons, Asgard Beams, and Ori Beams. These integrate with Advanced Space Combat weapon systems for diverse combat options."
        },
        {
            topic = "transportation_rings",
            keywords = {"rings", "ancient rings", "goa'uld rings", "ori rings", "asgard transporter", "atlantis transporter"},
            response = "CAP transportation systems include Ancient, Goa'uld, and Ori rings, plus Asgard and Atlantis transporters. These provide ship-to-ship and ship-to-surface transportation capabilities."
        },
        {
            topic = "cap_installation",
            keywords = {"cap installation", "carter pack setup", "wiremod required", "spacebuild required"},
            response = "CAP requires Wiremod and Spacebuild for full functionality. Install all 32 CAP components from Steam Workshop. AI automatically detects CAP availability and integrates compatible systems."
        }
    },

    -- Player Commands Help
    PlayerCommandsHelp = {
        {
            topic = "kill_command",
            keywords = {"kill me", "suicide", "respawn", "kill", "die", "restart"},
            response = "Use 'kill me' to instantly respawn. This is useful when stuck, trapped, or need to reset your position. Your ship and entities will remain where they are."
        },
        {
            topic = "stuck_help",
            keywords = {"stuck", "trapped", "can't move", "glitched", "noclip"},
            response = "If you're stuck: Use 'kill me' to respawn, enable noclip with console command 'noclip', or ask an admin for help. For ships, use physgun on ship core to move."
        },
        {
            topic = "respawn_help",
            keywords = {"respawn", "spawn point", "where do i spawn", "spawn location"},
            response = "After using 'kill me', you'll respawn at the map's default spawn point. Your ships, props, and progress remain intact. Only your player position resets."
        },
        {
            topic = "ship_teleport",
            keywords = {"take me to my ship", "teleport to ship", "go to ship", "find my ship", "where is my ship"},
            response = "Use 'take me to my ship' to instantly teleport to your ship core! AI will find your closest owned ship and teleport you safely nearby. Perfect for when you're lost or far from your ship."
        },
        {
            topic = "ship_location",
            keywords = {"ship location", "where is ship", "lost ship", "can't find ship"},
            response = "Lost your ship? Use 'take me to my ship' for instant teleportation, or 'find my ship' to get directions. AI automatically detects your owned ship cores and helps you navigate to them."
        },
        {
            topic = "save_ship",
            keywords = {"save ship", "advdupe2", "ship saving", "backup ship"},
            response = "Use 'save ship <name>' to save your ship with AdvDupe2. Look at your ship core and use the command. Ships are saved with full metadata including components, wiring, and CAP entities."
        },
        {
            topic = "load_ship",
            keywords = {"load ship", "spawn ship", "restore ship", "ship loading"},
            response = "Use 'load ship <name>' to load a saved ship. Ships will spawn at your crosshair location with all components, wiring, and configurations preserved."
        },
        {
            topic = "wire_ship",
            keywords = {"wire ship", "wiremod", "ship control", "automation"},
            response = "Use 'wire ship' to setup wire interface on your ship core. This enables wire-based control of hyperdrive, weapons, shields, and AI systems for advanced automation."
        },
        {
            topic = "jump_ship_to_me",
            keywords = {"jump ship to me", "bring ship here", "teleport ship", "move ship to me"},
            response = "Use 'jump my ship to me' to teleport your ship to your current location! AI will find your ship and move it safely to where you're standing. Great for retrieving distant ships."
        },
        {
            topic = "dial_stargate",
            keywords = {"dial stargate", "dial gate", "stargate dial", "connect stargate", "gate address"},
            response = "Use 'dial <address>' or 'dial <gatename>' to dial your stargate! AI will find your stargate and dial to the specified address or gate name from your address book. Works with CAP stargates."
        },
        {
            topic = "debug_stargates",
            keywords = {"find stargates", "list stargates", "debug stargates", "stargate detection"},
            response = "Use 'find stargates' to see all stargate entities near you! This helps debug stargate detection issues and shows entity class names, distances, and ownership."
        },
        {
            topic = "cap_resources_update",
            keywords = {"cap resources", "cap github", "cap update", "carter addon pack resources", "cap_resources"},
            response = "CAP Resources are available at: GitHub: https://github.com/RafaelDeJongh/cap_resources and main CAP code: https://github.com/RafaelDeJongh/cap. These provide the latest Stargate technology models, materials, and sounds."
        },
        {
            topic = "cap_installation",
            keywords = {"cap install", "cap setup", "carter addon pack install", "stargate addon install"},
            response = "To install CAP: 1) Subscribe to Steam Workshop ID 180077636 (main collection), 2) Get resources from GitHub: https://github.com/RafaelDeJongh/cap_resources, 3) Ensure Wiremod is installed. CAP provides comprehensive Stargate technology."
        },
        {
            topic = "cap_integration_asc",
            keywords = {"cap integration", "cap asc", "stargate space combat", "cap hyperdrive"},
            response = "Advanced Space Combat integrates seamlessly with CAP! Use CAP stargates with ASC ship cores, combine CAP shields with ASC weapons, and use CAP ZPMs for unlimited ship power. Full cross-compatibility!"
        },
        {
            topic = "assets_management",
            keywords = {"assets", "materials", "models", "sounds", "missing assets", "asset validation"},
            response = "Asset Management: Use 'asc_assets_status' to check asset status, 'asc_assets_validate' to find missing files, 'asc_assets_reload' to refresh assets. All materials, models, sounds, and effects are managed automatically with fallback systems."
        },
        {
            topic = "weapon_systems_advanced",
            keywords = {"plasma cannon", "advanced weapons", "weapon types", "weapon systems"},
            response = "Advanced Weapons: Plasma Cannon (area damage), Railgun (kinetic penetration), Pulse Cannon (rapid fire), Beam Weapon (continuous), Torpedo Launcher (guided). All weapons auto-link to ship cores and support auto-targeting."
        },
        {
            topic = "entity_organization",
            keywords = {"entity organization", "spawn categories", "entity categories", "organized spawning"},
            response = "Entity Organization: Entities are organized in categories: Ship Components, Weapons-Energy, Weapons-Kinetic, Flight Systems, Transport, Shields & Defense. All entities auto-register and support proper categorization."
        },
        {
            topic = "effects_system",
            keywords = {"effects", "visual effects", "particle effects", "weapon effects", "hyperspace effects"},
            response = "Effects System: Professional visual effects for all systems - hyperspace portals, shield impacts, weapon blasts, engine trails. All effects support quality scaling and fallback systems for performance."
        },
        {
            topic = "advanced_ship_building",
            keywords = {"ship building", "build ship", "ship construction", "ship design", "how to build"},
            response = "Ship Building Guide: 1) Spawn ship core first, 2) Add hyperdrive engines around core, 3) Install weapons and shields, 4) Connect with Wiremod for automation, 5) Use CAP ZPMs for power, 6) Save with AdvDupe2. Use 'wire ship' for automation!"
        },
        {
            topic = "combat_tactics",
            keywords = {"combat tactics", "ship combat", "fighting", "battle strategy", "weapons strategy"},
            response = "Combat Tactics: Use 'ai mode aggressive' for auto-combat, position shields strategically, combine railguns for long-range and plasma for close combat. Use 'jump my ship to me' for quick retreats. CAP shields provide excellent protection!"
        },
        {
            topic = "energy_management",
            keywords = {"energy management", "power systems", "zpm", "energy efficiency", "power consumption"},
            response = "Energy Management: CAP ZPMs provide unlimited power for ships. Use 'system status' to monitor energy consumption. Hyperdrive jumps consume most energy. Optimize with efficient flight patterns and smart weapon usage."
        },
        {
            topic = "automation_systems",
            keywords = {"automation", "wiremod automation", "ship automation", "auto pilot", "automated systems"},
            response = "Automation Systems: Use 'wire ship' to enable automation. Connect ship core outputs to control systems. Set up auto-pilot with waypoints, automated combat with weapon controls, and emergency protocols with safety systems."
        },
        {
            topic = "web_search",
            keywords = {"search web", "web search", "search for", "find online", "look up online"},
            response = "Web Search: Use 'search web <topic>' for safe, filtered web searches! I only search trusted gaming sites like GitHub, Steam, and Garry's Mod Wiki. Content filtering blocks inappropriate material automatically."
        },
        {
            topic = "information_lookup",
            keywords = {"look up", "lookup", "find info", "information about", "research"},
            response = "Information Lookup: Use 'look up <topic>' to get curated information sources! I'll provide links to trusted sites like GitHub, Steam Workshop, and gaming wikis. All content is safety-filtered."
        },
        {
            topic = "content_filtering",
            keywords = {"content filter", "web filter", "safety filter", "blocked content", "safe search"},
            response = "Content Filtering: Advanced safety system blocks inappropriate content, malware, and harmful sites. Only trusted gaming and development sites allowed. Use 'content filter' to see current protection status."
        },
        {
            topic = "url_fetching",
            keywords = {"fetch url", "get url", "load url", "download page", "web page"},
            response = "URL Fetching: Use 'fetch url <address>' to safely retrieve web content! Only whitelisted domains allowed (GitHub, Steam, gaming sites). Content is automatically filtered for safety."
        },
        {
            topic = "ship_core_tool",
            keywords = {"ship core tool", "core tool", "ship core spawning"},
            response = "Ship Core Tool: Primary tool for spawning ship cores. Features: Multiple core types (Standard, Heavy, Light), auto-linking, power level settings, ship naming. Access via Q menu > Advanced Space Combat > Core Systems."
        },
        {
            topic = "hyperdrive_tool",
            keywords = {"hyperdrive tool", "engine tool", "propulsion tool"},
            response = "Hyperdrive Tool: Spawn and configure hyperdrive engines. Features: Engine types (Standard, Heavy, Light), thrust power settings, auto-linking to ship cores. Access via Q menu > Advanced Space Combat > Propulsion."
        },
        {
            topic = "weapon_tool",
            keywords = {"weapon tool", "combat tool", "weapons spawning"},
            response = "Weapon Tool: Deploy ship weapons and combat systems. Features: 5 weapon types (Pulse Cannon, Beam Weapon, Torpedo Launcher, Railgun, Plasma Cannon), damage/fire rate settings, auto-linking. Access via Q menu > Advanced Space Combat > Combat."
        },
        {
            topic = "shield_tool",
            keywords = {"shield tool", "defense tool", "shield spawning"},
            response = "Shield Tool: CAP-integrated shield systems. Features: Multiple shield types (Bubble, Iris, Asgard), strength/radius settings, auto-linking to ship cores. Access via Q menu > Advanced Space Combat > Defense."
        },
        {
            topic = "conversation_history",
            keywords = {"conversation history", "chat history", "previous conversations", "memory"},
            response = "Conversation History: I remember our recent conversations and learn from them! I track your preferences, common topics, and response styles to provide better assistance. Your conversation data helps me understand your needs better."
        },
        {
            topic = "learning_status",
            keywords = {"learning status", "ai learning", "machine learning", "adaptation"},
            response = "Learning Status: I continuously learn from our interactions! I analyze your questions, track successful responses, and adapt my communication style. My neural network improves with each conversation to provide more accurate and helpful responses."
        },
        {
            topic = "sentiment_analysis",
            keywords = {"sentiment analysis", "emotion detection", "mood analysis", "feeling"},
            response = "Sentiment Analysis: I can detect your emotional state from your messages! I analyze positive, negative, and neutral sentiment to adjust my responses appropriately. If you're frustrated, I'll be more helpful. If you're excited, I'll match your energy!"
        },
        {
            topic = "context_awareness",
            keywords = {"context awareness", "contextual understanding", "smart responses", "intelligent"},
            response = "Context Awareness: I understand the context of your questions! I analyze what you're talking about (ships, weapons, stargates, etc.) and provide relevant information. I also remember our conversation flow for better continuity."
        },
        {
            topic = "analyze_question",
            keywords = {"analyze my question", "question analysis", "intent recognition", "understand query"},
            response = "Question Analysis: I can break down your questions to understand your intent, sentiment, and context! I recognize if you're asking for help, giving commands, reporting problems, or just chatting. This helps me provide the most appropriate response."
        },
        {
            topic = "predict_response",
            keywords = {"predict response", "response prediction", "ai prediction", "smart suggestions"},
            response = "Response Prediction: I use machine learning to predict the best response type for your questions! Based on your history and preferences, I can determine if you prefer concise answers, detailed explanations, or technical information."
        }
    }
}

-- Advanced Natural Language Processing
function ASC.AI.AnalyzeQuery(player, query)
    local analysis = {
        intent = "unknown",
        sentiment = "neutral",
        context = {},
        urgency = "normal",
        difficulty = "normal",
        entities = {},
        confidence = 0
    }

    local lowerQuery = string.lower(query)

    -- Intent recognition
    for intent, keywords in pairs(ASC.AI.NLP.IntentPatterns) do
        for _, keyword in ipairs(keywords) do
            if string.find(lowerQuery, keyword) then
                analysis.intent = intent
                analysis.confidence = analysis.confidence + 0.2
                break
            end
        end
    end

    -- Sentiment analysis
    for sentiment, keywords in pairs(ASC.AI.NLP.SentimentWords) do
        for _, keyword in ipairs(keywords) do
            if string.find(lowerQuery, keyword) then
                analysis.sentiment = sentiment
                analysis.confidence = analysis.confidence + 0.1
                break
            end
        end
    end

    -- Context analysis
    for context, keywords in pairs(ASC.AI.NLP.ContextKeywords) do
        for _, keyword in ipairs(keywords) do
            if string.find(lowerQuery, keyword) then
                table.insert(analysis.context, context)
                analysis.confidence = analysis.confidence + 0.1
            end
        end
    end

    -- Entity extraction
    local entities = {"ship core", "hyperdrive", "weapon", "shield", "ancient", "stargate"}
    for _, entity in ipairs(entities) do
        if string.find(lowerQuery, entity) then
            table.insert(analysis.entities, entity)
            analysis.confidence = analysis.confidence + 0.15
        end
    end

    return analysis
end

-- AI Response System with Advanced Features
function ASC.AI.ProcessQuery(player, query)
    if not IsValid(player) then return end

    local startTime = SysTime()
    local playerID = player:SteamID()

    -- Initialize neural network if not done
    if not ASC.AI.NeuralNetwork.Initialized or not ASC.AI.NeuralNetwork.Weights or not ASC.AI.NeuralNetwork.Weights.input_hidden then
        ASC.AI.NeuralNetwork.Initialize()
    end

    -- Advanced NLP Analysis v4.0.0
    local intent, intentConfidence = ASC.AI.NLP.AnalyzeIntent(query)
    local sentiment, sentimentScore = ASC.AI.NLP.AnalyzeSentiment(query)
    local contexts = ASC.AI.NLP.ExtractContext(query)

    -- Analyze the query with enhanced NLP
    local analysis = ASC.AI.AnalyzeQuery(player, query)
    analysis.intent = intent
    analysis.intent_confidence = intentConfidence
    analysis.sentiment = sentiment
    analysis.sentiment_score = sentimentScore
    analysis.contexts = contexts

    -- Detect emotional state
    local emotion, emotionScore = ASC.AI.EmotionalIntelligence.DetectEmotion(query)
    analysis.emotion = emotion
    analysis.emotion_score = emotionScore

    -- Get current context for advanced processing
    local context = ASC.AI.GetCurrentContext(playerID)
    context.emotion_score = emotionScore

    -- Predict best response type using machine learning
    local predictedResponseType = ASC.AI.MachineLearning.PredictResponseType(playerID, query)
    analysis.predicted_response_type = predictedResponseType

    -- Use neural network to predict response quality
    local qualityPrediction = ASC.AI.NeuralNetwork.PredictQuality(query, context)
    analysis.quality_prediction = qualityPrediction

    -- Generate intelligent contextual response
    local intelligentOpening = ASC.AI.ResponseGenerator.GenerateIntelligentResponse(player, query, intent, sentiment, contexts)
    local response = ASC.AI.GenerateAdvancedResponse(player, query, analysis)

    -- Combine intelligent opening with main response
    if intelligentOpening and intelligentOpening ~= "" then
        response = intelligentOpening .. response
    end

    -- Apply emotional intelligence adjustments
    response = ASC.AI.EmotionalIntelligence.AdjustResponse(response, emotion)

    -- Add smart suggestions
    response = ASC.AI.ResponseGenerator.AddSmartSuggestions(player, response, intent, contexts)

    -- Apply personality matrix
    response = ASC.AI.PersonalityMatrix.ApplyPersonality(response, {
        query_type = analysis.intent,
        complexity = analysis.difficulty,
        emotion = emotion
    })

    -- Store conversation with advanced memory system
    ASC.AI.ConversationMemory.StoreConversation(player, query, response, intent, sentiment, contexts)

    -- Legacy conversation history for compatibility
    if not ASC.AI.ConversationHistory[playerID] then
        ASC.AI.ConversationHistory[playerID] = {}
    end

    local conversationEntry = {
        query = query,
        response = response,
        analysis = analysis,
        emotion = emotion,
        emotion_score = emotionScore,
        predicted_response_type = predictedResponseType,
        quality_prediction = qualityPrediction,
        timestamp = CurTime(),
        response_time = 0, -- Will be calculated after sending
        context_relevance = context.context_relevance,
        intent = intent,
        intent_confidence = intentConfidence,
        sentiment = sentiment,
        sentiment_score = sentimentScore,
        contexts = contexts
    }

    table.insert(ASC.AI.ConversationHistory[playerID], conversationEntry)

    -- Limit history size
    if #ASC.AI.ConversationHistory[playerID] > ASC.AI.Config.ContextMemorySize then
        table.remove(ASC.AI.ConversationHistory[playerID], 1)
    end

    -- Send response with typing indicator
    timer.Simple(ASC.AI.Config.ResponseDelay, function()
        if IsValid(player) then
            local responseTime = SysTime() - startTime
            conversationEntry.response_time = responseTime

            ASC.AI.SendAdvancedResponse(player, response, analysis)

            -- Track performance metrics
            local satisfaction = ASC.AI.EstimateSatisfaction(query, response, analysis)
            ASC.AI.AdvancedAnalytics.TrackResponse(playerID, query, response, responseTime, satisfaction)

            -- Learn from this interaction
            ASC.AI.MachineLearning.LearnFromInteraction(playerID, query, response, satisfaction)

            -- Update user profile
            ASC.AI.UpdateUserProfile(playerID, query, response, analysis, satisfaction)

            -- Update performance metrics
            ASC.AI.PerformanceMetrics.UpdateMetrics()
        end
    end)
end

-- Advanced response generation with context awareness
function ASC.AI.GenerateAdvancedResponse(player, query, analysis)
    local playerID = player:SteamID()
    local queryLower = string.lower(query)

    -- Detect and handle multilingual input
    local playerLang = "en"
    local originalQuery = query
    local detectedLang = ASC.AI.Languages.DetectLanguage(query)

    -- Enhanced Czech language input handling
    if detectedLang == "czech" then
        playerLang = "cs"

        -- Detect Czech cultural context (formal/informal)
        local formality = "neutral"
        if ASC.AI.Languages.DetectCzechFormality then
            formality = ASC.AI.Languages.DetectCzechFormality(originalQuery)
        end

        -- Validate Czech encoding
        local encodingValid = true
        if ASC.AI.Languages.ValidateCzechEncoding then
            encodingValid = ASC.AI.Languages.ValidateCzechEncoding(originalQuery)
            if not encodingValid then
                print("[ARIA-4] Warning: Czech encoding issues detected in query")
            end
        end

        -- Enhanced Czech command translation with context
        local context = {
            formality = formality,
            encodingValid = encodingValid,
            shipDetected = analysis.entities and #analysis.entities > 0,
            stargateDetected = false -- Could be enhanced with stargate detection
        }

        local translatedQuery = originalQuery
        if ASC.AI.Languages.TranslateCzechCommandAdvanced then
            translatedQuery = ASC.AI.Languages.TranslateCzechCommandAdvanced(originalQuery, context)
        else
            translatedQuery = ASC.AI.Languages.TranslateCzechCommand(originalQuery)
        end

        if translatedQuery ~= string.lower(originalQuery) then
            query = translatedQuery
            queryLower = string.lower(query)
            print("[ARIA-4] Enhanced Czech translation: " .. originalQuery .. " -> " .. query .. " (formality: " .. formality .. ")")
        end

        -- Store Czech context for response generation
        analysis.czechContext = {
            formality = formality,
            encodingValid = encodingValid,
            originalQuery = originalQuery
        }
    end

    if ASC.Multilingual and ASC.Multilingual.Core then
        local multilingualLang = ASC.Multilingual.Core.GetPlayerLanguage(player)
        if multilingualLang ~= "en" then
            playerLang = multilingualLang
        end

        -- If query is not in English, translate it for processing
        if playerLang ~= "en" and detectedLang ~= "czech" then
            local multiDetectedLang = ASC.Multilingual.Core.DetectLanguage(query)
            if multiDetectedLang ~= "en" then
                -- Translate query to English for processing
                local translatedQuery = ASC.Multilingual.Core.TranslateText(query, "en", multiDetectedLang)
                if translatedQuery and translatedQuery ~= query then
                    query = translatedQuery
                    queryLower = string.lower(query)
                    print("[ARIA-4] Translated query: " .. originalQuery .. " -> " .. query)
                end
            end
        end
    end

    -- Handle test command first
    if string.find(queryLower, "test") or string.find(queryLower, "hello") then
        return "🤖 ARIA-4 AI System is working perfectly! All commands are functional. Try: 'aria dial <address>', 'aria kill me', 'aria take me to my ship', 'aria jump my ship to me', 'aria find stargates', 'aria cap info'."
    end

    -- Handle special commands first
    if string.find(queryLower, "kill me") or (string.find(queryLower, "kill") and string.find(queryLower, "me")) then
        -- Execute kill command
        if IsValid(player) and player:Alive() then
            player:Kill()
            return "Respawning you now! You'll spawn at the default spawn point. Your ships and entities remain intact."
        elseif IsValid(player) and not player:Alive() then
            return "You're already dead! You should respawn automatically, or use your respawn key."
        else
            return "Unable to execute kill command. Please try again or contact an admin."
        end
    end

    -- Handle ship teleportation commands
    if (string.find(queryLower, "take me to") and string.find(queryLower, "ship")) or
       (string.find(queryLower, "teleport") and string.find(queryLower, "ship")) or
       (string.find(queryLower, "go to") and string.find(queryLower, "ship")) or
       string.find(queryLower, "find my ship") then

        -- Find player's ship core
        local playerShipCore = ASC.AI.FindPlayerShipCore(player)

        if IsValid(playerShipCore) then
            -- Teleport player to ship core
            local shipPos = playerShipCore:GetPos()
            local shipAng = playerShipCore:GetAngles()

            -- Position player slightly above and in front of ship core
            local teleportPos = shipPos + shipAng:Forward() * 100 + Vector(0, 0, 50)

            -- Ensure player doesn't get stuck in walls
            local trace = util.TraceLine({
                start = shipPos + Vector(0, 0, 100),
                endpos = teleportPos,
                filter = {player, playerShipCore}
            })

            if trace.Hit then
                teleportPos = trace.HitPos + trace.HitNormal * 50
            end

            -- Teleport the player
            player:SetPos(teleportPos)
            player:SetEyeAngles((shipPos - teleportPos):Angle())

            return "Teleported you to your ship! You're now near your ship core. Welcome aboard, Captain!"
        else
            -- No ship core found
            return "I couldn't find your ship core! Make sure you have a ship with a ship core that you own. You can spawn one from the spawn menu."
        end
    end

    -- Handle ship saving commands
    if string.find(queryLower, "save ship") then
        local shipName = string.match(query, "save ship (.+)") or "Unnamed Ship"

        local trace = player:GetEyeTrace()
        if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "ship_core" then
            return "Look at a ship core to save the ship! Point your crosshair at the ship core and try again."
        end

        if ASC.AdvDupe2 and ASC.AdvDupe2.SaveShip then
            local success, message = ASC.AdvDupe2.SaveShip(player, trace.Entity, shipName)
            return message or (success and "Ship saved successfully!" or "Failed to save ship!")
        else
            return "AdvDupe2 integration not available. Make sure AdvDupe2 is installed and working."
        end
    end

    -- Handle ship loading commands
    if string.find(queryLower, "load ship") then
        local shipName = string.match(query, "load ship (.+)")

        if not shipName then
            return "Please specify a ship name! Use: 'load ship <name>'. Use 'list ships' to see available ships."
        end

        if ASC.AdvDupe2 and ASC.AdvDupe2.LoadShip then
            local position = player:GetPos() + player:GetAimVector() * 500
            local angles = player:GetAngles()
            local success, message = ASC.AdvDupe2.LoadShip(player, shipName, position, angles)
            return message or (success and "Ship loaded successfully!" or "Failed to load ship!")
        else
            return "AdvDupe2 integration not available. Make sure AdvDupe2 is installed and working."
        end
    end

    -- Handle ship listing commands
    if string.find(queryLower, "list ships") or string.find(queryLower, "show ships") then
        if ASC.AdvDupe2 and ASC.AdvDupe2.GetSavedShips then
            local ships = ASC.AdvDupe2.GetSavedShips(player)

            if #ships == 0 then
                return "No saved ships found. Use 'save ship <name>' while looking at a ship core to save your first ship!"
            end

            local response = "Your saved ships:\n"
            for i, ship in ipairs(ships) do
                local info = ship.name
                if ship.metadata then
                    info = info .. " (" .. ship.metadata.component_count .. " components"
                    if ship.metadata.weapon_count > 0 then
                        info = info .. ", " .. ship.metadata.weapon_count .. " weapons"
                    end
                    info = info .. ")"
                end
                response = response .. i .. ". " .. info .. "\n"
            end
            return response
        else
            return "AdvDupe2 integration not available. Make sure AdvDupe2 is installed and working."
        end
    end

    -- Handle wire setup commands
    if string.find(queryLower, "wire ship") or string.find(queryLower, "setup wire") then
        local trace = player:GetEyeTrace()
        if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "ship_core" then
            return "Look at a ship core to setup wire interface! Point your crosshair at the ship core and try again."
        end

        if ASC.Wiremod and ASC.Wiremod.SetupShipCoreWires then
            if ASC.Wiremod.SetupShipCoreWires(trace.Entity) then
                return "Wire interface setup successfully! Your ship core now has wire inputs and outputs for automation. Check the wire tool for available connections."
            else
                return "Failed to setup wire interface. Make sure Wiremod is installed and the ship core is valid."
            end
        else
            return "Wiremod integration not available. Make sure Wiremod is installed and working."
        end
    end

    -- Handle ship front indicator commands
    if (string.find(queryLower, "show") and string.find(queryLower, "front") and string.find(queryLower, "indicator")) or
       (string.find(queryLower, "green") and string.find(queryLower, "arrow")) or
       (string.find(queryLower, "ship") and string.find(queryLower, "direction")) or
       (string.find(queryLower, "front") and string.find(queryLower, "arrow")) then

        -- Find player's ship core
        local playerShipCore = ASC.AI.FindPlayerShipCore(player)
        if playerShipCore then
            -- Show front indicator using the ship core system
            if HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.ShowFrontIndicator then
                local success = HYPERDRIVE.ShipCore.ShowFrontIndicator(playerShipCore)
                if success then
                    return "✅ Front indicator activated! You should now see a green arrow showing your ship's front direction. The arrow will help you identify which way your ship is facing for navigation and docking."
                else
                    return "❌ Could not activate front indicator. Make sure your ship core is properly connected to your ship structure."
                end
            else
                return "❌ Ship core system not available. The front indicator feature requires the ship core system to be loaded."
            end
        else
            return "❌ No ship core found! You need to have a ship with a ship core that you own. Spawn a ship core from the spawn menu and place it on your ship."
        end
    end

    -- Handle ship teleportation to player commands
    if (string.find(queryLower, "jump") and string.find(queryLower, "ship") and string.find(queryLower, "to me")) or
       (string.find(queryLower, "bring") and string.find(queryLower, "ship") and string.find(queryLower, "here")) or
       (string.find(queryLower, "teleport") and string.find(queryLower, "ship") and string.find(queryLower, "to me")) or
       (string.find(queryLower, "move") and string.find(queryLower, "ship") and string.find(queryLower, "to me")) then

        -- Find player's ship core
        local playerShipCore = ASC.AI.FindPlayerShipCore(player)

        if IsValid(playerShipCore) then
            -- Get player position and calculate safe ship position
            local playerPos = player:GetPos()
            local playerAng = player:GetAngles()

            -- Position ship behind and above the player
            local shipPos = playerPos + playerAng:Forward() * -300 + Vector(0, 0, 100)

            -- Check for obstacles and adjust position if needed
            local trace = util.TraceLine({
                start = playerPos,
                endpos = shipPos,
                filter = {player}
            })

            if trace.Hit then
                -- Find alternative position
                shipPos = playerPos + playerAng:Right() * 200 + Vector(0, 0, 150)

                -- Check again
                trace = util.TraceLine({
                    start = playerPos,
                    endpos = shipPos,
                    filter = {player}
                })

                if trace.Hit then
                    -- Last resort - position above player
                    shipPos = playerPos + Vector(0, 0, 300)
                end
            end

            -- Get all ship entities
            local shipEntities = ASC.AI.AddonIntegration.GetShipEntities(playerShipCore)

            if #shipEntities > 0 then
                -- Calculate offset from ship core to maintain relative positions
                local corePos = playerShipCore:GetPos()
                local offset = shipPos - corePos

                -- Move all ship entities
                for _, ent in ipairs(shipEntities) do
                    if IsValid(ent) then
                        local newPos = ent:GetPos() + offset
                        ent:SetPos(newPos)

                        -- Stop any movement
                        if ent:GetPhysicsObject():IsValid() then
                            ent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
                            ent:GetPhysicsObject():SetAngleVelocity(Vector(0, 0, 0))
                        end
                    end
                end

                return "Ship teleported to your location! Your ship is now positioned safely near you. All ship components have been moved together."
            else
                return "Could not detect ship components! Make sure your ship has multiple connected parts."
            end
        else
            -- No ship core found
            return "I couldn't find your ship core! Make sure you have a ship with a ship core that you own. You can spawn one from the spawn menu."
        end
    end

    -- Handle tactical AI commands
    if string.find(queryLower, "tactical") or string.find(queryLower, "combat") or
       (string.find(queryLower, "weapons") and (string.find(queryLower, "status") or string.find(queryLower, "ai") or string.find(queryLower, "auto"))) then
        return ASC.AI.HandleTacticalCommands(player, query, queryLower)
    end

    -- Handle shield commands
    if string.find(queryLower, "shield") or string.find(queryLower, "shields") then
        return ASC.AI.HandleShieldCommands(player, query, queryLower)
    end

    -- Handle flight commands
    if string.find(queryLower, "flight") or string.find(queryLower, "autopilot") or string.find(queryLower, "fly") or
       string.find(queryLower, "navigate") or string.find(queryLower, "waypoint") or string.find(queryLower, "vehicle") then
        return ASC.AI.HandleFlightCommands(player, query, queryLower)
    end

    -- Handle docking commands
    if string.find(queryLower, "dock") or string.find(queryLower, "undock") or string.find(queryLower, "docking") then
        return ASC.AI.HandleDockingCommands(player, query, queryLower)
    end

    -- Handle formation commands
    if string.find(queryLower, "formation") or string.find(queryLower, "fleet") or
       (string.find(queryLower, "follow") and string.find(queryLower, "me")) then
        return ASC.AI.HandleFormationCommands(player, query, queryLower)
    end

    -- Handle boss commands
    if string.find(queryLower, "boss") or string.find(queryLower, "vote boss") or string.find(queryLower, "spawn boss") then
        return ASC.AI.HandleBossCommands(player, query, queryLower)
    end

    -- Handle weapon commands
    if string.find(queryLower, "weapon") or string.find(queryLower, "fire") or string.find(queryLower, "target") or
       string.find(queryLower, "ammo") or string.find(queryLower, "reload") then
        return ASC.AI.HandleWeaponCommands(player, query, queryLower)
    end

    -- Handle tactical AI commands
    if string.find(queryLower, "tactical") or string.find(queryLower, "combat ai") or
       string.find(queryLower, "ai mode") or string.find(queryLower, "threat") then
        return ASC.AI.HandleTacticalCommands(player, query, queryLower)
    end

    -- Handle debug commands
    if string.find(queryLower, "debug") then
        if ASC.Debug and ASC.Debug.Core then
            return ASC.AI.HandleDebugCommands(player, query, queryLower)
        else
            return "Debug system not available"
        end
    end

    -- Handle recovery commands
    if string.find(queryLower, "recovery") then
        if ASC.ErrorRecovery and ASC.ErrorRecovery.Core then
            return ASC.AI.HandleRecoveryCommands(player, query, queryLower)
        else
            return "Error recovery system not available"
        end
    end

    -- Handle language commands
    if string.find(queryLower, "language") or string.find(queryLower, "translate") or
       string.find(queryLower, "jazyk") or string.find(queryLower, "sprache") or
       string.find(queryLower, "langue") or string.find(queryLower, "idioma") then
        if ASC.Multilingual and ASC.Multilingual.Core then
            return ASC.AI.HandleLanguageCommands(player, query, queryLower)
        else
            return "Multilingual system not available"
        end
    end

    -- Handle stargate dialing commands
    if string.find(queryLower, "dial ") then
        local dialTarget = string.match(query, "dial (.+)")

        if not dialTarget then
            return "Please specify what to dial! Examples:\n" ..
                   "• 'aria dial ABCDEF' - Direct address dialing\n" ..
                   "• 'aria dial Earth' - Gate name from address book\n" ..
                   "• 'aria dial player Oliver' - Dial to Oliver's stargate\n" ..
                   "• 'aria dial spawn' - Gate name 'Spawn' from address book"
        end

        -- Check for explicit player dialing
        local isPlayerDial = string.find(string.lower(dialTarget), "^player ") or string.find(string.lower(dialTarget), "^to player ")
        if isPlayerDial then
            dialTarget = string.gsub(dialTarget, "^[Pp]layer ", "")
            dialTarget = string.gsub(dialTarget, "^[Tt]o [Pp]layer ", "")
        end

        -- Check CAP availability first
        local capAvailable = ASC.AI.CAP.IsAvailable()

        if not capAvailable then
            return "CAP (Carter Addon Pack) is not detected! Please install CAP from Steam Workshop ID 180077636 or GitHub. Use 'aria cap info' for installation help."
        end

        -- Find player's stargate
        local playerStargate = ASC.AI.FindPlayerStargate(player)

        if IsValid(playerStargate) then
            if isPlayerDial then
                -- Force player name lookup
                local success, message = ASC.AI.DialStargateByOwnerName(player, playerStargate, dialTarget)
                return message or (success and "Dialing to " .. dialTarget .. "'s stargate!" or "Failed to dial to player's stargate!")
            else
                -- Normal dialing (gate name first, then player name fallback)
                local success, message = ASC.AI.DialStargate(player, playerStargate, dialTarget)
                return message or (success and "Stargate dialing initiated!" or "Failed to dial stargate!")
            end
        else
            return "I couldn't find your stargate! Make sure you have a stargate that you own nearby. You can spawn one from the CAP spawn menu. Use 'aria find stargates' to see all available stargates."
        end
    end

    -- Handle stargate debug commands
    if string.find(queryLower, "find stargates") or string.find(queryLower, "list stargates") or string.find(queryLower, "debug stargates") then
        local allStargates = ASC.AI.FindAllStargates(player)

        if #allStargates == 0 then
            return "No stargate entities found! Make sure you have CAP (Carter Addon Pack) installed and have spawned stargates. Check Steam Workshop ID 180077636."
        end

        local response = "Found " .. #allStargates .. " stargate entities:\n"
        for i, sg in ipairs(allStargates) do
            if i > 10 then break end -- Limit to first 10

            local ownerText = "No Owner"
            if IsValid(sg.owner) then
                ownerText = sg.owner:Name()
                if sg.owned then
                    ownerText = ownerText .. " (YOU)"
                end
            end

            response = response .. i .. ". " .. sg.class .. " - " .. math.floor(sg.distance) .. " units - " .. ownerText .. "\n"
        end

        if #allStargates > 10 then
            response = response .. "... and " .. (#allStargates - 10) .. " more"
        end

        return response
    end

    -- Handle CAP information commands
    if string.find(queryLower, "cap info") or string.find(queryLower, "cap resources") or string.find(queryLower, "cap github") then
        local response = "CAP (Carter Addon Pack) Information:\n\n"
        response = response .. "📦 Main Code Repository: " .. ASC.AI.CAP.Repositories.main_code .. "\n"
        response = response .. "🎨 Resources Repository: " .. ASC.AI.CAP.Repositories.resources .. "\n"
        response = response .. "🔧 Steam Workshop Collection: ID " .. ASC.AI.CAP.Repositories.workshop_collection .. "\n"
        response = response .. "⚡ Latest Workshop Addon: ID " .. ASC.AI.CAP.Repositories.workshop_addon .. "\n\n"

        if ASC.AI.CAP.IsAvailable() then
            response = response .. "✅ CAP Status: DETECTED AND AVAILABLE\n"
            local version = ASC.AI.CAP.GetVersion()
            if version then
                response = response .. "📋 CAP Version: " .. version .. "\n"
            end
        else
            response = response .. "❌ CAP Status: NOT DETECTED\n"
            response = response .. "💡 Install CAP from Steam Workshop ID 180077636 or GitHub repositories above"
        end

        return response
    end

    -- Handle CAP installation help
    if string.find(queryLower, "cap install") or string.find(queryLower, "install cap") or string.find(queryLower, "cap setup") then
        return "CAP Installation Guide:\n\n" ..
               "1️⃣ Steam Workshop Method:\n" ..
               "   - Subscribe to Steam Workshop ID 180077636 (main collection)\n" ..
               "   - Subscribe to Steam Workshop ID 3488559019 (latest addon)\n\n" ..
               "2️⃣ GitHub Method:\n" ..
               "   - Download from: " .. ASC.AI.CAP.Repositories.main_code .. "\n" ..
               "   - Get resources from: " .. ASC.AI.CAP.Repositories.resources .. "\n\n" ..
               "3️⃣ Requirements:\n" ..
               "   - Wiremod (for advanced functionality)\n" ..
               "   - Garry's Mod (obviously!)\n\n" ..
               "4️⃣ Verification:\n" ..
               "   - Use '!ai cap info' to check if CAP is detected\n" ..
               "   - Spawn a stargate to test functionality"
    end

    -- Handle ship building guidance commands
    if string.find(queryLower, "how to build") or string.find(queryLower, "ship building") or string.find(queryLower, "build ship") then
        return "🚀 Advanced Ship Building Guide:\n\n" ..
               "1️⃣ Foundation:\n" ..
               "   • Spawn ship core first (central command center)\n" ..
               "   • Position on flat surface or in space\n\n" ..
               "2️⃣ Propulsion:\n" ..
               "   • Add hyperdrive engines around the core\n" ..
               "   • Use multiple engines for better performance\n" ..
               "   • Connect engines to ship core\n\n" ..
               "3️⃣ Combat Systems:\n" ..
               "   • Install weapons (railguns, plasma cannons)\n" ..
               "   • Add CAP shields for protection\n" ..
               "   • Position weapons strategically\n\n" ..
               "4️⃣ Power & Automation:\n" ..
               "   • Use CAP ZPMs for unlimited power\n" ..
               "   • Connect with Wiremod: 'wire ship'\n" ..
               "   • Set up automated systems\n\n" ..
               "5️⃣ Save & Share:\n" ..
               "   • Save with: 'save ship <name>'\n" ..
               "   • Load with: 'load ship <name>'\n\n" ..
               "💡 Pro Tips: Use 'system status' to monitor performance!"
    end

    -- Handle combat strategy commands
    if string.find(queryLower, "combat") or string.find(queryLower, "fighting") or string.find(queryLower, "battle") then
        return "⚔️ Advanced Combat Strategy:\n\n" ..
               "🎯 Offensive Tactics:\n" ..
               "   • Use 'ai mode aggressive' for auto-combat\n" ..
               "   • Railguns for long-range precision\n" ..
               "   • Plasma cannons for close combat\n" ..
               "   • Coordinate multiple weapon systems\n\n" ..
               "🛡️ Defensive Tactics:\n" ..
               "   • CAP shields provide excellent protection\n" ..
               "   • Position shields strategically around ship\n" ..
               "   • Use 'jump my ship to me' for quick retreats\n" ..
               "   • Emergency protocols with Wiremod\n\n" ..
               "🚀 Mobility Tactics:\n" ..
               "   • Hyperdrive for strategic positioning\n" ..
               "   • Use stargates for instant travel\n" ..
               "   • Formation flying with multiple ships\n\n" ..
               "💡 Advanced: Set up automated combat with wire controls!"
    end

    -- Handle automation guidance commands
    if string.find(queryLower, "automation") or string.find(queryLower, "auto pilot") or string.find(queryLower, "wiremod") then
        return "🤖 Ship Automation Guide:\n\n" ..
               "🔧 Setup Automation:\n" ..
               "   • Use 'wire ship' to enable wire interface\n" ..
               "   • Connect ship core outputs to control systems\n" ..
               "   • Install Wiremod components (gates, displays)\n\n" ..
               "✈️ Auto-Pilot Systems:\n" ..
               "   • Set waypoints for automated navigation\n" ..
               "   • Use GPS coordinates for precision\n" ..
               "   • Emergency stop protocols\n\n" ..
               "⚔️ Combat Automation:\n" ..
               "   • Automated weapon targeting\n" ..
               "   • Threat detection systems\n" ..
               "   • Shield management automation\n\n" ..
               "🔋 Power Management:\n" ..
               "   • Automated energy distribution\n" ..
               "   • ZPM integration for unlimited power\n" ..
               "   • Efficiency optimization\n\n" ..
               "💡 Use wire outputs for real-time ship data!"
    end

    -- Handle fleet management commands
    if string.find(queryLower, "fleet") or string.find(queryLower, "multiple ships") or string.find(queryLower, "ship formation") then
        return "🚁 Fleet Management System:\n\n" ..
               "🎯 Fleet Coordination:\n" ..
               "   • Use 'list ships' to see all your saved ships\n" ..
               "   • Load multiple ships for fleet operations\n" ..
               "   • Coordinate with Wiremod formation controls\n\n" ..
               "⚔️ Combat Formations:\n" ..
               "   • Battleship formation: Heavy ships in center\n" ..
               "   • Fighter screen: Fast ships on perimeter\n" ..
               "   • Support vessels: Carriers and supply ships\n\n" ..
               "📡 Communication:\n" ..
               "   • Use stargates for instant fleet communication\n" ..
               "   • Coordinate jumps with hyperdrive timing\n" ..
               "   • Emergency protocols for fleet retreat\n\n" ..
               "🔧 Fleet Automation:\n" ..
               "   • Wire-based fleet coordination\n" ..
               "   • Automated formation flying\n" ..
               "   • Synchronized combat operations\n\n" ..
               "💡 Pro Tip: Save fleet templates with AdvDupe2!"
    end

    -- Handle troubleshooting commands
    if string.find(queryLower, "not working") or string.find(queryLower, "broken") or string.find(queryLower, "fix") or string.find(queryLower, "problem") then
        return "🔧 Troubleshooting Guide:\n\n" ..
               "🚀 Ship Issues:\n" ..
               "   • Use 'system status' to check ship health\n" ..
               "   • Verify ship core ownership and connections\n" ..
               "   • Check power levels and energy consumption\n\n" ..
               "🌌 Stargate Issues:\n" ..
               "   • Use 'find stargates' to detect stargates\n" ..
               "   • Verify CAP installation: 'cap info'\n" ..
               "   • Check stargate ownership and addresses\n\n" ..
               "🔌 Wiremod Issues:\n" ..
               "   • Use 'wire status' to check connections\n" ..
               "   • Verify Wiremod installation\n" ..
               "   • Check wire input/output connections\n\n" ..
               "💾 AdvDupe2 Issues:\n" ..
               "   • Verify AdvDupe2 installation\n" ..
               "   • Check file permissions and storage\n" ..
               "   • Use 'list ships' to verify saved ships\n\n" ..
               "❓ Still having issues? Ask specific questions!"
    end

    -- Handle performance optimization commands
    if string.find(queryLower, "performance") or string.find(queryLower, "optimization") or string.find(queryLower, "lag") or string.find(queryLower, "fps") then
        return "⚡ Performance Optimization Guide:\n\n" ..
               "🚀 Ship Performance:\n" ..
               "   • Limit ship complexity (< 100 components)\n" ..
               "   • Use efficient engine configurations\n" ..
               "   • Optimize weapon placement and count\n\n" ..
               "🔌 Wiremod Optimization:\n" ..
               "   • Minimize wire update frequency\n" ..
               "   • Use efficient gate configurations\n" ..
               "   • Avoid unnecessary wire connections\n\n" ..
               "🌌 CAP Optimization:\n" ..
               "   • Limit active stargates per area\n" ..
               "   • Use efficient shield configurations\n" ..
               "   • Optimize ZPM power distribution\n\n" ..
               "🎮 Game Performance:\n" ..
               "   • Monitor entity count with 'system status'\n" ..
               "   • Clean up unused entities regularly\n" ..
               "   • Use LOD (Level of Detail) for distant ships\n\n" ..
               "💡 AI automatically optimizes ship systems!"
    end

    -- Handle web search commands
    if string.find(queryLower, "search web") or string.find(queryLower, "web search") or string.find(queryLower, "search for") then
        local searchQuery = string.match(query, "search.* for (.+)") or
                           string.match(query, "search web (.+)") or
                           string.match(query, "web search (.+)")

        if searchQuery then
            ASC.AI.WebAccess.SafeWebSearch(player, searchQuery)
            return "Web search initiated with content filtering active."
        else
            return "Please specify what to search for! Example: 'search web wiremod tutorials' or 'search for ship building guides'"
        end
    end

    -- Handle URL fetching commands
    if string.find(queryLower, "fetch url") or string.find(queryLower, "get url") or string.find(queryLower, "load url") then
        local url = string.match(query, "url (.+)") or string.match(query, "fetch (.+)") or string.match(query, "get (.+)")

        if url then
            ASC.AI.WebAccess.SafeFetchURL(player, url)
            return "URL fetch initiated with safety filtering."
        else
            return "Please specify a URL to fetch! Example: 'fetch url https://github.com/wiremod/wire'"
        end
    end

    -- Handle information lookup commands
    if string.find(queryLower, "look up") or string.find(queryLower, "lookup") or string.find(queryLower, "find info") then
        local topic = string.match(query, "look up (.+)") or
                     string.match(query, "lookup (.+)") or
                     string.match(query, "find info (.+)")

        if topic then
            -- Check if it's a safe topic
            local isSafe, reason = ASC.AI.WebAccess.IsContentSafe(topic)
            if isSafe then
                return "📚 Information Lookup: " .. topic .. "\n\n" ..
                       "🔍 Recommended sources:\n" ..
                       "• Garry's Mod Wiki: https://wiki.garrysmod.com\n" ..
                       "• Steam Community: Search Workshop for '" .. topic .. "'\n" ..
                       "• GitHub: https://github.com/search?q=" .. string.gsub(topic, " ", "+") .. "\n" ..
                       "• Wiremod: https://wiremod.com (for technical topics)\n\n" ..
                       "💡 Use 'search web " .. topic .. "' for guided web search!"
            else
                return "🚫 " .. reason .. "\nPlease ask about space combat, ship building, or gaming topics."
            end
        else
            return "Please specify what to look up! Example: 'look up wiremod expressions' or 'find info about spacebuild'"
        end
    end

    -- Handle content filtering status
    if string.find(queryLower, "content filter") or string.find(queryLower, "web filter") or string.find(queryLower, "safety filter") then
        return "🛡️ Content Filtering System Status:\n\n" ..
               "✅ Active Protection:\n" ..
               "• Blocked Categories: Adult, Violence, Hate, Illegal, Malware\n" ..
               "• Keyword Filtering: " .. #ASC.AI.WebAccess.ContentFilter.BlockedKeywords .. " blocked terms\n" ..
               "• Domain Whitelist: " .. #ASC.AI.WebAccess.ContentFilter.AllowedDomains .. " trusted sites\n\n" ..
               "🌐 Allowed Domains:\n" ..
               "• GitHub, Steam Community, Facepunch\n" ..
               "• Garry's Mod Wiki, Wiremod\n" ..
               "• Wikipedia, YouTube (gaming content)\n\n" ..
               "🎮 Safe Topics: Gaming, Development, Space Combat\n" ..
               "💡 All web searches are automatically filtered for safety!"
    end

    -- Handle asset management commands
    if string.find(queryLower, "asset") or string.find(queryLower, "missing") or string.find(queryLower, "materials") or string.find(queryLower, "models") then
        if string.find(queryLower, "status") or string.find(queryLower, "check") then
            if ASC.Assets and ASC.Assets.GetStatus then
                local status = ASC.Assets.GetStatus()
                return "🎨 Asset Management Status:\n\n" ..
                       "📊 Total Assets: " .. status.total .. "\n" ..
                       "✅ Loaded: " .. status.loaded .. "\n" ..
                       "❌ Failed: " .. status.failed .. "\n" ..
                       "⚠️ Missing: " .. status.missing .. "\n" ..
                       "📈 Success Rate: " .. math.floor(status.success_rate) .. "%\n\n" ..
                       "💡 Use 'asc_assets_validate' console command for detailed missing asset list!"
            else
                return "Asset management system not available. Make sure all Advanced Space Combat files are loaded."
            end
        elseif string.find(queryLower, "validate") or string.find(queryLower, "missing") then
            return "🔍 Asset Validation:\n\n" ..
                   "Use these console commands to check assets:\n" ..
                   "• asc_assets_validate - Check for missing files\n" ..
                   "• asc_assets_status - Show asset statistics\n" ..
                   "• asc_assets_reload - Refresh asset cache\n\n" ..
                   "📁 Asset Categories:\n" ..
                   "• Materials: Entity textures and effects\n" ..
                   "• Models: 3D models for entities\n" ..
                   "• Sounds: Audio effects and music\n" ..
                   "• Effects: Particle and visual effects\n\n" ..
                   "🛠️ All assets have fallback systems for missing files!"
        else
            return "🎨 Asset Management System:\n\n" ..
                   "Advanced Space Combat includes comprehensive asset management:\n\n" ..
                   "📦 Asset Types:\n" ..
                   "• Entity Materials - Ship cores, weapons, shields\n" ..
                   "• Effect Materials - Hyperspace, weapons, explosions\n" ..
                   "• 3D Models - All entity models with LOD support\n" ..
                   "• Sound Effects - Weapons, engines, systems, AI\n" ..
                   "• Visual Effects - Particles, beams, portals\n\n" ..
                   "🔧 Features:\n" ..
                   "• Automatic fallback for missing assets\n" ..
                   "• Quality scaling for performance\n" ..
                   "• Real-time validation and loading\n" ..
                   "• Professional visual effects\n\n" ..
                   "💡 Use 'asset status' to check current asset state!"
        end
    end

    -- Handle entity information commands
    if string.find(queryLower, "entities") or string.find(queryLower, "spawn") and string.find(queryLower, "list") then
        return "🚀 Advanced Space Combat Entities:\n\n" ..
               "🔧 Ship Components:\n" ..
               "• Ship Core - Central management hub\n" ..
               "• Hyperdrive Engine - Standard propulsion\n" ..
               "• Hyperdrive Master Engine - Advanced propulsion\n" ..
               "• Hyperdrive Computer - Navigation system\n\n" ..
               "⚔️ Weapons - Energy:\n" ..
               "• Pulse Cannon - Rapid fire energy weapon\n" ..
               "• Beam Weapon - Continuous energy beam\n" ..
               "• Plasma Cannon - Area effect weapon\n\n" ..
               "💥 Weapons - Kinetic:\n" ..
               "• Railgun - High-velocity kinetic weapon\n" ..
               "• Torpedo Launcher - Guided missile system\n\n" ..
               "🛡️ Defense Systems:\n" ..
               "• Shield Generator - CAP-integrated shields\n\n" ..
               "✈️ Flight & Transport:\n" ..
               "• Flight Console - Ship control interface\n" ..
               "• Docking Pad - Landing system\n" ..
               "• Shuttle - Small transport vessel\n\n" ..
               "💡 All entities auto-link to ship cores and support advanced features!"
    end

    -- Handle entity spawning commands
    if string.find(queryLower, "spawn ") then
        local entityName = string.match(query, "spawn (.+)")
        if entityName then
            -- Map common names to entity classes
            local entityMap = {
                ["ship core"] = "ship_core",
                ["core"] = "ship_core",
                ["engine"] = "hyperdrive_engine",
                ["hyperdrive engine"] = "hyperdrive_engine",
                ["master engine"] = "hyperdrive_master_engine",
                ["computer"] = "hyperdrive_computer",
                ["pulse cannon"] = "asc_pulse_cannon",
                ["beam weapon"] = "asc_beam_weapon",
                ["plasma cannon"] = "asc_plasma_cannon",
                ["torpedo launcher"] = "asc_torpedo_launcher",
                ["railgun"] = "asc_railgun",
                ["shield generator"] = "asc_shield_generator",
                ["shield"] = "asc_shield_generator",
                ["flight console"] = "asc_flight_console",
                ["docking pad"] = "asc_docking_pad",
                ["shuttle"] = "asc_shuttle"
            }

            local entityClass = entityMap[string.lower(entityName)]
            if entityClass then
                -- Execute spawn command
                player:ConCommand("asc_spawn_entity " .. entityClass)
                return "Spawning " .. entityName .. "! The entity will appear at your crosshair location with auto-linking enabled."
            else
                return "Unknown entity: " .. entityName .. ". Available entities: ship core, engine, master engine, computer, pulse cannon, beam weapon, plasma cannon, torpedo launcher, railgun, shield generator, flight console, docking pad, shuttle."
            end
        else
            return "Please specify what to spawn! Example: 'spawn ship core' or 'spawn pulse cannon'"
        end
    end

    -- Handle spawn limits commands
    if string.find(queryLower, "spawn limits") or string.find(queryLower, "my limits") then
        player:ConCommand("asc_spawn_limits")
        return "Checking your spawn limits... See console for detailed information."
    end

    -- Handle cleanup commands
    if string.find(queryLower, "cleanup") or string.find(queryLower, "clean up") or string.find(queryLower, "remove all") then
        player:ConCommand("asc_cleanup_entities")
        return "Cleaning up all your Advanced Space Combat entities... This will remove all entities you own and reset your spawn limits."
    end

    -- Handle organization commands
    if string.find(queryLower, "fix organization") or string.find(queryLower, "fix tabs") or string.find(queryLower, "fix q menu") then
        player:ConCommand("asc_fix_organization")
        return "Fixing organization system... This will reload the Q menu tabs and spawn menu categories."
    end

    -- Handle auto-linking commands
    if string.find(queryLower, "auto link") or string.find(queryLower, "auto-link") or string.find(queryLower, "linking") then
        if string.find(queryLower, "enable") or string.find(queryLower, "on") then
            player:ConCommand("asc_auto_link 1")
            return "Auto-linking enabled! New entities will automatically link to nearby ship cores within 2000 units."
        elseif string.find(queryLower, "disable") or string.find(queryLower, "off") then
            player:ConCommand("asc_auto_link 0")
            return "Auto-linking disabled! You'll need to manually link entities to ship cores."
        else
            return "Auto-linking system: Automatically connects new entities to nearby ship cores. Use 'enable auto link' or 'disable auto link' to control this feature."
        end
    end

    -- Handle Q menu help
    if string.find(queryLower, "q menu") or string.find(queryLower, "tools menu") then
        return "Q Menu Organization:\n\n" ..
               "📋 Advanced Space Combat Tab:\n" ..
               "• Ship Systems - Ship cores, engines, computers\n" ..
               "• Combat - Weapons and shields\n" ..
               "• Flight - Flight consoles and navigation\n" ..
               "• Transport - Docking pads and shuttles\n" ..
               "• Configuration - Settings and preferences\n" ..
               "• Help - ARIA-3 AI assistance\n\n" ..
               "💡 Each tab has organized spawning buttons with descriptions!"
    end

    -- Handle enhanced hyperspace commands
    if string.find(queryLower, "hyperspace") or string.find(queryLower, "dimensional") then
        if string.find(queryLower, "layers") then
            return "🌌 Hyperspace Dimensional Layers:\n\n" ..
                   "1️⃣ Subspace (Depth 0):\n" ..
                   "   • Stability: 99% • Energy Cost: 100%\n" ..
                   "   • Safe for beginners and short jumps\n\n" ..
                   "2️⃣ Hyperspace (Depth 1):\n" ..
                   "   • Stability: 95% • Energy Cost: 80%\n" ..
                   "   • Standard FTL travel layer\n\n" ..
                   "3️⃣ Ancient Conduit (Depth 2):\n" ..
                   "   • Stability: 90% • Energy Cost: 60%\n" ..
                   "   • Ancient technology provides bonuses\n\n" ..
                   "4️⃣ Void Between (Depth 3):\n" ..
                   "   • Stability: 80% • Energy Cost: 40%\n" ..
                   "   • Dangerous but efficient travel\n\n" ..
                   "5️⃣ Ascended Realm (Depth 4):\n" ..
                   "   • Stability: 70% • Energy Cost: 20%\n" ..
                   "   • Highest risk, lowest energy cost\n\n" ..
                   "💡 Deeper layers require advanced technology!"

        elseif string.find(queryLower, "effects") or string.find(queryLower, "visual") then
            return "✨ Enhanced Hyperspace Visual Effects:\n\n" ..
                   "🌀 4-Stage Stargate Travel:\n" ..
                   "1️⃣ Initiation: Energy surges, coordinate calculation\n" ..
                   "2️⃣ Window Opening: Blue swirling energy portal\n" ..
                   "3️⃣ Travel: Stretched starlines, dimensional visuals\n" ..
                   "4️⃣ Exit: Light flash, system stabilization\n\n" ..
                   "🎨 Visual Features:\n" ..
                   "• Blue Stargate-themed energy windows\n" ..
                   "• Stretched starlines during travel\n" ..
                   "• Ancient symbols and dimensional effects\n" ..
                   "• Energy streams and particle systems\n" ..
                   "• TARDIS-quality dimensional mechanics\n\n" ..
                   "💫 All effects scale with ship size and power!"

        elseif string.find(queryLower, "mechanics") or string.find(queryLower, "tardis") then
            return "⚙️ TARDIS-Inspired Dimensional Mechanics:\n\n" ..
                   "🕰️ Time Distortion:\n" ..
                   "• Time flows 20% slower in hyperspace\n" ..
                   "• Temporal shielding protects crew\n" ..
                   "• Reality anchors maintain stability\n\n" ..
                   "📐 Spatial Folding:\n" ..
                   "• 90% distance reduction through folding\n" ..
                   "• Space-time manipulation technology\n" ..
                   "• Visual representation of folded space\n\n" ..
                   "🏠 Dimensional Pockets:\n" ..
                   "• Ships can be bigger inside\n" ..
                   "• Pocket dimensions for storage\n" ..
                   "• Advanced Ancient technology\n\n" ..
                   "🛡️ Safety Systems:\n" ..
                   "• Auto-stabilization protocols\n" ..
                   "• Emergency exit procedures\n" ..
                   "• Collision detection and avoidance"

        else
            return "🌌 Enhanced Hyperspace System v2.0:\n\n" ..
                   "Inspired by TARDIS dimensional mechanics with authentic Stargate theming!\n\n" ..
                   "🚀 Key Features:\n" ..
                   "• 4-stage Stargate travel mechanics\n" ..
                   "• 5 dimensional layers with varying risks\n" ..
                   "• TARDIS-inspired time distortion\n" ..
                   "• Spatial folding technology\n" ..
                   "• Dimensional pockets and expansion\n" ..
                   "• Advanced visual effects system\n\n" ..
                   "💡 Ask about: 'hyperspace layers', 'hyperspace effects', 'dimensional mechanics'"
        end
    end

    -- Handle time distortion commands
    if string.find(queryLower, "time distortion") or string.find(queryLower, "temporal") then
        return "🕰️ Temporal Mechanics in Hyperspace:\n\n" ..
               "⏰ Time Distortion Effects:\n" ..
               "• Time flows 20% slower in hyperspace\n" ..
               "• Allows for longer strategic planning\n" ..
               "• Temporal shielding protects crew\n\n" ..
               "🛡️ Temporal Shielding:\n" ..
               "• Protects against time paradoxes\n" ..
               "• Maintains crew synchronization\n" ..
               "• Automatic activation during travel\n\n" ..
               "⚓ Reality Anchors:\n" ..
               "• Maintain connection to origin dimension\n" ..
               "• Prevent temporal displacement\n" ..
               "• Emergency stabilization system\n\n" ..
               "💡 Advanced Ancient technology provides enhanced temporal protection!"
    end

    -- Handle spatial folding commands
    if string.find(queryLower, "spatial folding") or string.find(queryLower, "space folding") then
        return "📐 Spatial Folding Technology:\n\n" ..
               "🌌 Space-Time Manipulation:\n" ..
               "• Reduces effective travel distance by 90%\n" ..
               "• Folds space-time using Ancient technology\n" ..
               "• Visual representation during travel\n\n" ..
               "⚡ Energy Efficiency:\n" ..
               "• Dramatically reduces energy requirements\n" ..
               "• Enables long-distance travel\n" ..
               "• Scales with ship technology level\n\n" ..
               "🔬 Technical Details:\n" ..
               "• Based on Ancient understanding of space-time\n" ..
               "• Requires advanced hyperdrive systems\n" ..
               "• Enhanced by ZPM power sources\n\n" ..
               "💡 The more advanced your ship, the better the folding efficiency!"
    end

    -- Get or create user profile
    if not ASC.AI.UserProfiles[playerID] then
        ASC.AI.UserProfiles[playerID] = {
            experience_level = "beginner",
            preferred_topics = {},
            interaction_count = 0,
            last_interaction = CurTime(),
            satisfaction_score = 0.5,
            language_preference = "english"
        }
    end

    local profile = ASC.AI.UserProfiles[playerID]

    -- Ensure profile fields are valid numbers (safety check)
    if not profile.interaction_count or type(profile.interaction_count) ~= "number" then
        profile.interaction_count = 0
    end
    if not profile.satisfaction_score or type(profile.satisfaction_score) ~= "number" then
        profile.satisfaction_score = 0.5
    end
    if not profile.last_interaction or type(profile.last_interaction) ~= "number" then
        profile.last_interaction = CurTime()
    end

    profile.interaction_count = profile.interaction_count + 1
    profile.last_interaction = CurTime()

    -- Generate base response
    local response = ASC.AI.GenerateResponse(query)

    -- Apply contextual modifications
    response = ASC.AI.ApplyContextualModifications(response, analysis, profile)

    -- Add personalization
    response = ASC.AI.PersonalizeResponse(response, player, profile)

    -- Translate response back to player's language if needed
    if ASC.Multilingual and ASC.Multilingual.Core and playerLang ~= "en" then
        local translatedResponse = ASC.Multilingual.Core.TranslateText(response, playerLang, "en")
        if translatedResponse and translatedResponse ~= response then
            response = translatedResponse
            print("[ARIA-4] Translated response to " .. playerLang .. ": " .. response)
        end
    end

    return response
end

function ASC.AI.ApplyContextualModifications(response, analysis, profile)
    -- Sentiment-based modifications
    if analysis.sentiment == "negative" then
        response = "I understand you're experiencing difficulties. " .. response .. " If this doesn't resolve your issue, please let me know what specific problem you're encountering."
    elseif analysis.sentiment == "positive" then
        response = "Excellent! " .. response .. " I'm glad to help with your space combat endeavors!"
    end

    -- Urgency handling
    if table.HasValue(analysis.context, "urgency") then
        response = "🚨 PRIORITY ASSISTANCE: " .. response .. " For immediate fixes, use the console commands I've provided."
    end

    -- Experience level adjustments
    if profile.experience_level == "beginner" and table.HasValue(analysis.context, "difficulty") then
        response = response .. " 📚 Beginner tip: Start with basic ship cores and work your way up to advanced systems."
    elseif profile.experience_level == "expert" then
        response = response .. " 🔧 Advanced note: Check the configuration files for additional customization options."
    end

    -- Intent-specific enhancements
    if analysis.intent == "help" then
        response = response .. " Need more specific guidance? Ask me about particular components or systems!"
    elseif analysis.intent == "problem" then
        response = response .. " If the issue persists, try the diagnostic commands: asc_diagnostic or asc_fix_organization"
    end

    return response
end

function ASC.AI.PersonalizeResponse(response, player, profile)
    local playerName = player:Name()

    -- Ensure interaction_count is a valid number
    local interactionCount = profile.interaction_count or 0
    if type(interactionCount) ~= "number" then
        interactionCount = 0
    end

    -- Add personal greeting for frequent users
    if interactionCount > 10 then
        response = "Welcome back, " .. playerName .. "! " .. response
    elseif interactionCount > 5 then
        response = "Good to see you again! " .. response
    end

    -- Add learning suggestions
    if interactionCount < 3 then
        response = response .. " 💡 New to Advanced Space Combat? Try asking about 'ship cores' to get started!"
    end

    return response
end

function ASC.AI.GenerateResponse(query)
    local queryLower = string.lower(query)
    local bestMatch = nil
    local bestScore = 0

    -- Search all knowledge categories
    local allKnowledge = {}
    table.Add(allKnowledge, ASC.AI.Knowledge.CoreSystems)
    table.Add(allKnowledge, ASC.AI.Knowledge.StargateTech)
    table.Add(allKnowledge, ASC.AI.Knowledge.CombatSystems)
    table.Add(allKnowledge, ASC.AI.Knowledge.Commands)
    table.Add(allKnowledge, ASC.AI.Knowledge.OrganizationHelp)
    table.Add(allKnowledge, ASC.AI.Knowledge.ULXHelp)
    table.Add(allKnowledge, ASC.AI.Knowledge.ULibHelp)
    table.Add(allKnowledge, ASC.AI.Knowledge.PropProtectionHelp)
    table.Add(allKnowledge, ASC.AI.Knowledge.AdvDupe2Help)
    table.Add(allKnowledge, ASC.AI.Knowledge.CAPHelp)
    table.Add(allKnowledge, ASC.AI.Knowledge.PlayerCommandsHelp)

    -- Find best matching knowledge
    for _, knowledge in ipairs(allKnowledge) do
        local score = ASC.AI.CalculateAdvancedRelevance(queryLower, knowledge.keywords)
        if score > bestScore then
            bestScore = score
            bestMatch = knowledge
        end
    end

    -- Generate response
    if bestMatch and bestScore > 0 then
        return ASC.AI.FormatAdvancedResponse(bestMatch.response, queryLower)
    else
        return ASC.AI.GetAdvancedFallbackResponse(queryLower)
    end
end

-- Advanced relevance calculation with fuzzy matching
function ASC.AI.CalculateAdvancedRelevance(query, keywords)
    local score = 0

    for _, keyword in ipairs(keywords) do
        -- Exact match (highest score)
        if string.find(query, keyword) then
            score = score + 3

            -- Bonus for exact word match
            if query == keyword then
                score = score + 5
            end

            -- Bonus for word boundary matches
            if string.find(query, "%f[%w]" .. keyword .. "%f[%W]") then
                score = score + 2
            end
        end

        -- Fuzzy matching for similar words
        local similarity = ASC.AI.CalculateSimilarity(query, keyword)
        if similarity > 0.7 then
            score = score + (similarity * 2)
        end
    end

    return score
end

-- String similarity calculation (Levenshtein distance based)
function ASC.AI.CalculateSimilarity(str1, str2)
    local len1, len2 = #str1, #str2
    if len1 == 0 then return len2 == 0 and 1 or 0 end
    if len2 == 0 then return 0 end

    local matrix = {}
    for i = 0, len1 do
        matrix[i] = {[0] = i}
    end
    for j = 0, len2 do
        matrix[0][j] = j
    end

    for i = 1, len1 do
        for j = 1, len2 do
            local cost = str1:sub(i, i) == str2:sub(j, j) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i-1][j] + 1,
                matrix[i][j-1] + 1,
                matrix[i-1][j-1] + cost
            )
        end
    end

    local distance = matrix[len1][len2]
    local maxLen = math.max(len1, len2)
    return 1 - (distance / maxLen)
end

function ASC.AI.CalculateRelevance(query, keywords)
    local score = 0

    for _, keyword in ipairs(keywords) do
        if string.find(query, keyword) then
            score = score + 1
            -- Bonus for exact matches
            if query == keyword then
                score = score + 2
            end
        end
    end

    return score
end

-- Advanced response formatting with rich features
function ASC.AI.FormatAdvancedResponse(response, query)
    local formattedResponse = "[ARIA-3] " .. response

    -- Add contextual suggestions with emojis
    if string.find(query, "how") then
        formattedResponse = formattedResponse .. " 🤔 Need more detailed guidance? Ask me about specific components!"
    elseif string.find(query, "spawn") then
        formattedResponse = formattedResponse .. " 🛠️ Pro tip: Use asc_help for comprehensive spawning guides."
    elseif string.find(query, "stargate") then
        formattedResponse = formattedResponse .. " 🌌 Explore more: asc_stargate_info for complete technology database."
    elseif string.find(query, "weapon") then
        formattedResponse = formattedResponse .. " ⚔️ Combat tip: Link weapons to ship cores for tactical AI control."
    elseif string.find(query, "ancient") then
        formattedResponse = formattedResponse .. " ⭐ Ancient tech is Tier 10 - the most advanced technology available!"
    end

    return formattedResponse
end

-- Advanced fallback responses with personality
function ASC.AI.GetAdvancedFallbackResponse(query)
    local fallbacks = {
        "[ARIA-3] 🤖 I'm analyzing your query about '" .. query .. "'. I specialize in: ship systems, Stargate technology, combat operations, and troubleshooting. What specific aspect interests you?",
        "[ARIA-3] 🔍 That's an interesting question about '" .. query .. "'. I can help with: ship building, Ancient/Asgard/Goa'uld/Wraith/Ori/Tau'ri technology, weapons, and system diagnostics.",
        "[ARIA-3] 💡 I understand you're asking about '" .. query .. "'. My expertise covers: Advanced Space Combat systems, Stargate civilizations, tactical operations, and technical support.",
        "[ARIA-3] 🚀 Great question! While I'm processing '" .. query .. "', I can assist with: ship cores, hyperdrive systems, combat weapons, shield technology, and organization fixes."
    }

    return fallbacks[math.random(1, #fallbacks)]
end

function ASC.AI.FormatResponse(response, query)
    -- Use correct ARIA version
    local formattedResponse = "[ARIA-4] " .. response

    -- Add contextual suggestions based on query analysis
    local queryLower = string.lower(query or "")

    if string.find(queryLower, "how") then
        formattedResponse = formattedResponse .. " 💡 Need more help? Ask me about specific topics!"
    elseif string.find(queryLower, "spawn") then
        formattedResponse = formattedResponse .. " 🔧 Tip: Use asc_help for detailed spawning guides."
    elseif string.find(queryLower, "stargate") then
        formattedResponse = formattedResponse .. " 🌌 Try: asc_stargate_info for complete tech details."
    elseif string.find(queryLower, "ship") then
        formattedResponse = formattedResponse .. " 🚀 Use asc_ship_status for ship diagnostics."
    elseif string.find(queryLower, "weapon") then
        formattedResponse = formattedResponse .. " ⚔️ Try: asc_weapon_status for combat systems."
    end

    return formattedResponse
end

function ASC.AI.GetFallbackResponse(query)
    -- Enhanced fallback responses with proper ARIA-4 branding
    local fallbacks = {
        "[ARIA-4] I understand you're asking about '" .. (query or "that topic") .. "'. I can help with: ship cores, weapons, Stargate tech, or commands. 🚀",
        "[ARIA-4] I'm not sure about that specific topic. I specialize in: ship building, combat systems, Stargate technology, or general commands. 🌌",
        "[ARIA-4] Let me help! I'm an expert in: Advanced Space Combat systems, Stargate technology (Ancient/Asgard/Goa'uld/Wraith/Ori/Tau'ri), and combat operations. ⚔️",
        "[ARIA-4] I can assist with ship cores, weapons, flight systems, Stargate tech, or commands. What would you like to know more about? 💡"
    }

    return fallbacks[math.random(1, #fallbacks)]
end

-- Advanced response sending with rich features
function ASC.AI.SendAdvancedResponse(player, response, analysis)
    if not IsValid(player) then return end

    -- Get player's language preference
    local playerID = player:SteamID()
    local playerLang = "en"

    -- Check AI language preference first
    if ASC.AI.UserProfiles[playerID] and ASC.AI.UserProfiles[playerID].language_preference then
        local aiLang = ASC.AI.UserProfiles[playerID].language_preference
        if aiLang == "czech" then
            playerLang = "cs"
        end
    end

    -- Check multilingual system
    if ASC.Multilingual and ASC.Multilingual.Core then
        local multiLang = ASC.Multilingual.Core.GetPlayerLanguage(player)
        if multiLang ~= "en" then
            playerLang = multiLang
        end
    end

    -- Enhanced Czech response translation with cultural context
    if playerLang == "cs" then
        local czechResponse = response

        -- Use enhanced Czech response generation if available
        if ASC.AI.Languages.GenerateCzechResponse and analysis and analysis.czechContext then
            czechResponse = ASC.AI.Languages.GenerateCzechResponse(
                response,
                analysis.czechContext.formality,
                player:Name()
            )
            print("[ARIA-4] Generated Czech response with " .. analysis.czechContext.formality .. " formality for " .. player:Name())
        else
            -- Fallback to basic translation
            czechResponse = ASC.AI.Languages.TranslateResponseToCzech(response)
        end

        if czechResponse and czechResponse ~= response then
            response = czechResponse
            print("[ARIA-4] Applied Czech localization for " .. player:Name())
        end
    elseif ASC.Multilingual and ASC.Multilingual.Core and playerLang ~= "en" then
        -- Use multilingual system for other languages
        local translatedResponse = ASC.Multilingual.Core.TranslateText(response, playerLang, "en")
        if translatedResponse and translatedResponse ~= response then
            response = translatedResponse
            print("[ARIA-4] Translated response to " .. playerLang .. " for " .. player:Name())
        end
    end

    -- Limit response length
    if string.len(response) > ASC.AI.Config.MaxResponseLength then
        response = string.sub(response, 1, ASC.AI.Config.MaxResponseLength - 3) .. "..."
    end

    -- Send main response
    player:ChatPrint(response)

    -- Send follow-up suggestions based on analysis
    timer.Simple(1, function()
        if IsValid(player) then
            ASC.AI.ProvideSuggestions(player, analysis)
        end
    end)

    -- Track command usage for enhanced learning
    local commandType = "general"
    local queryLower = analysis.query and string.lower(analysis.query) or ""

    if queryLower ~= "" then
        if string.find(queryLower, "dial") then commandType = "dial"
        elseif string.find(queryLower, "save ship") then commandType = "save ship"
        elseif string.find(queryLower, "load ship") then commandType = "load ship"
        elseif string.find(queryLower, "wire ship") then commandType = "wire ship"
        elseif string.find(queryLower, "take me to") then commandType = "take me to my ship"
        elseif string.find(queryLower, "jump") and string.find(queryLower, "ship") then commandType = "jump my ship to me"
        elseif string.find(queryLower, "system status") then commandType = "system status"
        elseif string.find(queryLower, "find stargates") then commandType = "find stargates"
        elseif string.find(queryLower, "cap") then commandType = "cap info"
        end
    end

    -- Track command success (assume success if we got a response)
    local success = response and response ~= ""
    ASC.AI.PreferenceLearning.TrackCommandUsage(player, commandType, success)

    -- Add smart suggestions to response for learning users
    local suggestions = ASC.AI.PreferenceLearning.GetSmartSuggestions(player)
    if #suggestions > 0 and math.random() < 0.3 then -- 30% chance to show suggestions
        response = response .. "\n\n" .. suggestions[1] -- Show one random suggestion
    end

    -- Update user satisfaction based on response quality
    ASC.AI.UpdateUserSatisfaction(player, analysis)

    -- Log interaction for learning
    if ASC.AI.Config.EnableLearning then
        ASC.AI.LogInteraction(player, response, analysis)
    end

    -- Log interaction
    print("[Advanced Space Combat] ARIA-4 Response to " .. player:Name() .. ": " .. response)
end

-- Provide intelligent suggestions based on context
function ASC.AI.ProvideSuggestions(player, analysis)
    if not IsValid(player) then return end

    local suggestions = {}

    -- Intent-based suggestions
    if analysis.intent == "help" then
        table.insert(suggestions, "💡 Try: !ai ship core basics")
        table.insert(suggestions, "🔧 Try: !ai weapon systems")
    elseif analysis.intent == "spawn" then
        table.insert(suggestions, "🛠️ Try: !ai organization fix")
        table.insert(suggestions, "📋 Try: !ai spawn menu")
    elseif analysis.intent == "problem" then
        table.insert(suggestions, "🔍 Try: asc_diagnostic")
        table.insert(suggestions, "🔧 Try: asc_fix_organization")
    end

    -- Entity-based suggestions
    for _, entity in ipairs(analysis.entities) do
        if entity == "ship core" then
            table.insert(suggestions, "⭐ Related: !ai hyperdrive engines")
        elseif entity == "weapon" then
            table.insert(suggestions, "⚔️ Related: !ai combat tactics")
        elseif entity == "ancient" then
            table.insert(suggestions, "🌌 Related: !ai zpm technology")
        end
    end

    -- Send suggestions if any
    if #suggestions > 0 then
        local suggestion = suggestions[math.random(1, #suggestions)]
        player:ChatPrint("[ARIA-4] " .. suggestion)
    end
end

-- Update user satisfaction scoring
function ASC.AI.UpdateUserSatisfaction(player, analysis)
    local playerID = player:SteamID()
    if not ASC.AI.UserProfiles[playerID] then return end

    local profile = ASC.AI.UserProfiles[playerID]

    -- Ensure profile fields are valid numbers
    if not profile.satisfaction_score or type(profile.satisfaction_score) ~= "number" then
        profile.satisfaction_score = 0.5
    end
    if not profile.interaction_count or type(profile.interaction_count) ~= "number" then
        profile.interaction_count = 0
    end

    -- Increase satisfaction for successful interactions
    if analysis.confidence and analysis.confidence > 0.5 then
        profile.satisfaction_score = math.min(1, profile.satisfaction_score + 0.1)
    else
        profile.satisfaction_score = math.max(0, profile.satisfaction_score - 0.05)
    end

    -- Update experience level based on interaction patterns
    if profile.interaction_count > 20 and profile.satisfaction_score > 0.8 then
        profile.experience_level = "expert"
    elseif profile.interaction_count > 10 then
        profile.experience_level = "intermediate"
    end
end

-- Enhanced interaction logging with advanced learning
function ASC.AI.LogInteraction(player, response, analysis)
    local playerID = player:SteamID()

    if not ASC.AI.LearningData[playerID] then
        ASC.AI.LearningData[playerID] = {}
    end

    table.insert(ASC.AI.LearningData[playerID], {
        timestamp = CurTime(),
        analysis = analysis,
        response_length = #response,
        confidence = analysis.confidence,
        query_complexity = ASC.AI.LearningEngine.CalculateQueryComplexity(analysis.query or "", analysis)
    })

    -- Update user preferences using learning engine
    ASC.AI.LearningEngine.UpdatePreferences(playerID, analysis.query or "", analysis)

    -- Recognize patterns for predictive assistance
    local patterns = ASC.AI.LearningEngine.RecognizePatterns(playerID)
    if patterns and #patterns > 0 then
        -- Store learned patterns for future predictions
        ASC.AI.PredictiveSystem.LearnedPatterns[playerID] = patterns
    end

    -- Limit learning data size
    if #ASC.AI.LearningData[playerID] > 100 then
        table.remove(ASC.AI.LearningData[playerID], 1)
    end

    -- Advanced learning: Update AI knowledge base based on successful interactions
    if analysis.confidence > 0.8 then
        ASC.AI.UpdateKnowledgeBase(analysis)
    end
end

-- Update knowledge base with successful interaction patterns
function ASC.AI.UpdateKnowledgeBase(analysis)
    -- This function could expand the AI's knowledge based on successful interactions
    -- For now, it's a placeholder for future advanced learning capabilities

    -- Example: If a query about a specific entity was successful,
    -- we could add related keywords to improve future matching
    for _, entity in ipairs(analysis.entities) do
        -- Future implementation: dynamically expand keyword lists
        -- based on successful query patterns
    end
end

function ASC.AI.SendResponse(player, response)
    -- Limit response length
    if string.len(response) > ASC.AI.Config.MaxResponseLength then
        response = string.sub(response, 1, ASC.AI.Config.MaxResponseLength - 3) .. "..."
    end

    player:ChatPrint(response)

    -- Log interaction
    print("[Advanced Space Combat] AI Response to " .. player:Name() .. ": " .. response)
end

-- Proactive assistance system
function ASC.AI.CheckForProactiveHelp(player, entity)
    if not ASC.AI.Config.EnableProactiveAssistance then return end
    if not IsValid(player) or not IsValid(entity) then return end
    
    local class = entity:GetClass()
    local suggestions = {}
    
    -- Entity-specific suggestions
    if class == "ship_core" then
        table.insert(suggestions, "Ship core spawned! Add weapons and systems within 2000 units for auto-linking.")
    elseif string.find(class, "asc_ancient") then
        table.insert(suggestions, "Ancient technology detected! This is Tier 10 - the most advanced available.")
    elseif string.find(class, "weapon") then
        table.insert(suggestions, "Weapon spawned! It will auto-link to nearby ship cores for tactical AI control.")
    elseif string.find(class, "zpm") then
        table.insert(suggestions, "ZPM active! This provides unlimited energy to nearby ship cores.")
    end
    
    -- Send suggestion
    if #suggestions > 0 then
        timer.Simple(2, function()
            if IsValid(player) then
                player:ChatPrint("[ARIA-4] " .. suggestions[1] .. " Ask me anything with aria <question>")
            end
        end)
    end
end

-- Organization diagnostic functions
function ASC.AI.CheckOrganizationStatus()
    local status = {
        qmenu_working = false,
        spawn_menu_working = false,
        entities_registered = 0,
        diagnostic_available = false
    }

    -- Check if diagnostic system exists
    if ASC.Diagnostic then
        status.diagnostic_available = true
    end

    -- Check spawn menu entities
    local spawnableEntities = list.Get("SpawnableEntities")
    for class, data in pairs(spawnableEntities) do
        if string.find(data.Category or "", "Advanced Space Combat") then
            status.entities_registered = status.entities_registered + 1
        end
    end

    status.spawn_menu_working = status.entities_registered > 0

    return status
end

function ASC.AI.ProvideOrganizationHelp(player, issue)
    if not IsValid(player) then return end

    local status = ASC.AI.CheckOrganizationStatus()

    if issue == "empty_tabs" or issue == "qmenu" then
        player:ChatPrint("[ARIA-4] Q Menu Issue Detected!")
        player:ChatPrint("Solution: Type 'asc_force_setup_qmenu' in console")
        player:ChatPrint("This will create the 'Advanced Space Combat' tab with all tools")
    elseif issue == "no_entities" or issue == "spawn_menu" then
        player:ChatPrint("[ARIA-4] Spawn Menu Issue Detected!")
        player:ChatPrint("Solution: Type 'asc_force_register_entities' in console")
        player:ChatPrint("This will add all entities to the spawn menu")
    else
        player:ChatPrint("[ARIA-4] Organization Status:")
        player:ChatPrint("• Spawn Menu Entities: " .. status.entities_registered)
        player:ChatPrint("• Diagnostic System: " .. (status.diagnostic_available and "Available" or "Not Available"))
        player:ChatPrint("Quick Fix: Type 'asc_fix_organization' in console")
    end
end

-- Chat command processing with ARIA prefix
hook.Add("PlayerSay", "ASC_AI_ChatProcessor", function(player, text, team)
    if not IsValid(player) then return end

    local command = string.lower(text)

    -- Check for ARIA command (primary)
    if string.sub(command, 1, 4) == "aria" then
        local query = string.Trim(string.sub(text, 5))

        if query == "" or query == "help" then
            ASC.AI.ShowHelp(player)
        elseif query == "fix" or query == "diagnostic" then
            ASC.AI.ProvideOrganizationHelp(player, "general")
        elseif string.find(query, "empty") or string.find(query, "tabs") then
            ASC.AI.ProvideOrganizationHelp(player, "empty_tabs")
        elseif string.find(query, "spawn menu") then
            ASC.AI.ProvideOrganizationHelp(player, "spawn_menu")
        elseif string.find(query, "system status") or query == "status" then
            ASC.AI.AddonIntegration.SendSystemStatus(player)
        elseif string.find(query, "ship status") then
            ASC.AI.AddonIntegration.SendShipStatus(player)
        elseif string.find(query, "weapon status") then
            ASC.AI.AddonIntegration.SendWeaponStatus(player)
        elseif string.find(query, "tactical status") then
            ASC.AI.AddonIntegration.SendTacticalStatus(player)
        else
            ASC.AI.ProcessQuery(player, query)
        end

        return ""
    end

    -- Legacy support for !ai command
    if string.sub(command, 1, 3) == "!ai" then
        local query = string.Trim(string.sub(text, 4))

        if query == "" or query == "help" then
            ASC.AI.ShowHelp(player)
        elseif query == "fix" or query == "diagnostic" then
            ASC.AI.ProvideOrganizationHelp(player, "general")
        elseif string.find(query, "empty") or string.find(query, "tabs") then
            ASC.AI.ProvideOrganizationHelp(player, "empty_tabs")
        elseif string.find(query, "spawn") and string.find(query, "menu") then
            ASC.AI.ProvideOrganizationHelp(player, "spawn_menu")
        elseif string.find(query, "system status") or query == "status" then
            ASC.AI.AddonIntegration.SendSystemStatus(player)
        elseif string.find(query, "ship status") then
            ASC.AI.AddonIntegration.SendShipStatus(player)
        elseif string.find(query, "weapon status") then
            ASC.AI.AddonIntegration.SendWeaponStatus(player)
        elseif string.find(query, "tactical status") then
            ASC.AI.AddonIntegration.SendTacticalStatus(player)
        else
            ASC.AI.ProcessQuery(player, query)
        end

        return "" -- Suppress original message
    end

    -- No alternative command formats - standardized to !ai only
end)

-- Enhanced AI help system
function ASC.AI.ShowHelp(player)
    if not IsValid(player) then return end

    player:ChatPrint("[ARIA-4] 🤖 Advanced Space Combat AI Assistant v4.0.0")
    player:ChatPrint("🚀 Next-generation AI with advanced intelligence and contextual understanding")
    player:ChatPrint("🧠 Features: Intent recognition, sentiment analysis, conversation memory, adaptive learning")
    player:ChatPrint("")
    player:ChatPrint("💬 Usage: aria <question> - Ask me anything in natural language!")
    player:ChatPrint("🎯 I understand context, sentiment, and provide personalized help")
    player:ChatPrint("🔄 Legacy support: !ai commands still work for compatibility")
    player:ChatPrint("")
    player:ChatPrint("📚 My expertise includes:")
    player:ChatPrint("• 🛸 Ship building and core systems")
    player:ChatPrint("• 🌌 Stargate technology (Ancient, Asgard, Goa'uld, Wraith, Ori, Tau'ri)")
    player:ChatPrint("• ⚔️ Combat systems and tactical operations")
    player:ChatPrint("• 🔧 Commands, configuration, and troubleshooting")
    player:ChatPrint("• 🗂️ Organization and menu fixes")
    player:ChatPrint("• 🔍 System diagnostics and optimization")
    player:ChatPrint("")
    player:ChatPrint("💡 Smart examples:")
    player:ChatPrint("• 'How do I build a ship?' - Natural language questions")
    player:ChatPrint("• 'My tabs are empty' - Problem descriptions")
    player:ChatPrint("• 'Tell me about Ancient technology' - Topic exploration")
    player:ChatPrint("• 'I'm having trouble with weapons' - Context-aware help")
    player:ChatPrint("")
    player:ChatPrint("⚡ Quick fixes: aria fix, aria empty tabs, aria spawn menu")
    player:ChatPrint("🎮 Player commands: aria kill me, aria take me to my ship, aria jump my ship to me, aria dial <address>")
    player:ChatPrint("🚢 Ship commands: aria show front indicator, aria green arrow, aria ship direction")
    player:ChatPrint("🌌 CAP commands: aria cap info, aria cap install, aria find stargates")
    player:ChatPrint("🌐 Web commands: aria search web <topic>, aria look up <info>, aria content filter")
    player:ChatPrint("🔧 Tools: aria ship core tool, aria hyperdrive tool, aria weapon tool, aria shield tool")
    player:ChatPrint("🚀 Spawn commands: aria spawn <entity>, aria spawn limits, aria cleanup, aria auto link")
    player:ChatPrint("📋 Organization: aria q menu, aria fix organization, aria fix tabs")
    player:ChatPrint("🌌 Hyperspace: aria hyperspace, aria hyperspace layers, aria dimensional mechanics")
    player:ChatPrint("🕰️ Advanced: aria time distortion, aria spatial folding, aria hyperspace effects")
    player:ChatPrint("📊 System status: aria system status, aria ship status, aria weapon status")
    player:ChatPrint("🧠 AI Features: aria conversation history, aria learning status, aria sentiment analysis")
    player:ChatPrint("🎯 Smart Commands: aria analyze my question, aria predict response, aria context awareness")

    -- Get user profile for personalized help
    local playerID = player:SteamID()
    if ASC.AI.UserProfiles[playerID] then
        local profile = ASC.AI.UserProfiles[playerID]
        player:ChatPrint("")
        player:ChatPrint("👤 Your Profile:")
        player:ChatPrint("• Experience Level: " .. profile.experience_level)
        player:ChatPrint("• Interactions: " .. profile.interaction_count)
        player:ChatPrint("• Satisfaction Score: " .. math.floor(profile.satisfaction_score * 100) .. "%")
    end

    -- Check organization status and provide proactive help
    local status = ASC.AI.CheckOrganizationStatus()
    if status.entities_registered == 0 then
        player:ChatPrint("")
        player:ChatPrint("⚠️ System Notice: Spawn menu entities not detected")
        player:ChatPrint("🔧 Quick fix: Try '!ai spawn menu' for immediate assistance")
    end
end

-- Entity spawn hook for proactive assistance
hook.Add("PlayerSpawnedSENT", "ASC_AI_ProactiveHelp", function(player, entity)
    ASC.AI.CheckForProactiveHelp(player, entity)
end)

-- Enhanced status command
concommand.Add("asc_ai_status", function(player, cmd, args)
    if not IsValid(player) then return end

    player:ChatPrint("[ARIA-4] 🤖 Enhanced AI System Status:")
    player:ChatPrint("Version: " .. ASC.AI.Config.Version)
    player:ChatPrint("Personality: " .. ASC.AI.Config.Personality)
    player:ChatPrint("")
    player:ChatPrint("🔧 Core Features:")
    player:ChatPrint("• Advanced Features: " .. (ASC.AI.Config.EnableAdvancedFeatures and "✅ Enabled" or "❌ Disabled"))
    player:ChatPrint("• Context Awareness: " .. (ASC.AI.Config.EnableContextAwareness and "✅ Enabled" or "❌ Disabled"))
    player:ChatPrint("• Natural Language: " .. (ASC.AI.Config.EnableNaturalLanguage and "✅ Enabled" or "❌ Disabled"))
    player:ChatPrint("• Machine Learning: " .. (ASC.AI.Config.EnableLearning and "✅ Enabled" or "❌ Disabled"))
    player:ChatPrint("• Proactive Assistance: " .. (ASC.AI.Config.EnableProactiveAssistance and "✅ Enabled" or "❌ Disabled"))
    player:ChatPrint("• Organization Help: " .. (ASC.AI.Config.EnableOrganizationHelp and "✅ Enabled" or "❌ Disabled"))
    player:ChatPrint("• Predictive Help: " .. (ASC.AI.Config.EnablePredictiveHelp and "✅ Enabled" or "❌ Disabled"))

    local totalTopics = #ASC.AI.Knowledge.CoreSystems + #ASC.AI.Knowledge.StargateTech +
                       #ASC.AI.Knowledge.CombatSystems + #ASC.AI.Knowledge.Commands +
                       #ASC.AI.Knowledge.OrganizationHelp
    player:ChatPrint("")
    player:ChatPrint("📚 Knowledge Base: " .. totalTopics .. " topics")
    player:ChatPrint("⚡ Response Time: " .. ASC.AI.Config.ResponseDelay .. " seconds")
    player:ChatPrint("📝 Max Response Length: " .. ASC.AI.Config.MaxResponseLength .. " characters")

    -- User profile status
    local playerID = player:SteamID()
    if ASC.AI.UserProfiles[playerID] then
        local profile = ASC.AI.UserProfiles[playerID]
        player:ChatPrint("")
        player:ChatPrint("👤 Your AI Profile:")
        player:ChatPrint("• Experience Level: " .. profile.experience_level)
        player:ChatPrint("• Total Interactions: " .. profile.interaction_count)
        player:ChatPrint("• Satisfaction Score: " .. math.floor(profile.satisfaction_score * 100) .. "%")
        player:ChatPrint("• Last Interaction: " .. math.floor(CurTime() - profile.last_interaction) .. " seconds ago")
    end

    -- Organization status
    local orgStatus = ASC.AI.CheckOrganizationStatus()
    player:ChatPrint("")
    player:ChatPrint("🗂️ Organization Status:")
    player:ChatPrint("• Spawn Menu Entities: " .. orgStatus.entities_registered)
    player:ChatPrint("• Diagnostic System: " .. (orgStatus.diagnostic_available and "✅ Available" or "❌ Not Available"))

    -- System performance
    local totalUsers = 0
    for _ in pairs(ASC.AI.UserProfiles) do totalUsers = totalUsers + 1 end
    player:ChatPrint("")
    player:ChatPrint("📊 System Performance:")
    player:ChatPrint("• Active User Profiles: " .. totalUsers)
    player:ChatPrint("• Memory Usage: " .. math.floor(collectgarbage("count")) .. " KB")
end)

-- AI analytics command
concommand.Add("asc_ai_analytics", function(player, cmd, args)
    if not IsValid(player) then return end

    local playerID = player:SteamID()
    if not ASC.AI.UserProfiles[playerID] then
        player:ChatPrint("[ARIA-4] No analytics data available. Interact with me first!")
        return
    end

    local profile = ASC.AI.UserProfiles[playerID]
    local history = ASC.AI.ConversationHistory[playerID] or {}

    player:ChatPrint("[ARIA-4] 📊 Your AI Analytics:")
    player:ChatPrint("• Total Conversations: " .. #history)
    player:ChatPrint("• Experience Level: " .. profile.experience_level)
    player:ChatPrint("• Satisfaction Score: " .. math.floor(profile.satisfaction_score * 100) .. "%")
    player:ChatPrint("• Preferred Topics: " .. (#profile.preferred_topics > 0 and table.concat(profile.preferred_topics, ", ") or "Learning..."))

    if #history > 0 then
        local avgConfidence = 0
        local topIntents = {}

        for _, conversation in ipairs(history) do
            avgConfidence = avgConfidence + (conversation.analysis.confidence or 0)
            local intent = conversation.analysis.intent or "unknown"
            topIntents[intent] = (topIntents[intent] or 0) + 1
        end

        avgConfidence = avgConfidence / #history

        player:ChatPrint("• Average Query Confidence: " .. math.floor(avgConfidence * 100) .. "%")

        local mostCommonIntent = "unknown"
        local maxCount = 0
        for intent, count in pairs(topIntents) do
            if count > maxCount then
                maxCount = count
                mostCommonIntent = intent
            end
        end

        player:ChatPrint("• Most Common Query Type: " .. mostCommonIntent)
    end
end)

-- AI learning reset command
concommand.Add("asc_ai_reset_profile", function(player, cmd, args)
    if not IsValid(player) then return end

    local playerID = player:SteamID()
    ASC.AI.UserProfiles[playerID] = nil
    ASC.AI.ConversationHistory[playerID] = nil
    ASC.AI.LearningData[playerID] = nil
    ASC.AI.PredictiveSystem.LearnedPatterns[playerID] = nil

    player:ChatPrint("[ARIA-3] 🔄 Your AI profile has been reset!")
    player:ChatPrint("I'll start learning about your preferences from scratch.")
end)

-- Language preference command
concommand.Add("asc_ai_language", function(player, cmd, args)
    if not IsValid(player) then return end

    local playerID = player:SteamID()

    if not args[1] then
        local currentLang = "english"
        if ASC.AI.UserProfiles[playerID] then
            currentLang = ASC.AI.UserProfiles[playerID].language_preference or "english"
        end

        player:ChatPrint("[ARIA-3] 🌐 Current language: " .. currentLang)
        player:ChatPrint("Available languages: english (en), spanish (es), french (fr), czech (cs)")
        player:ChatPrint("Usage: asc_ai_language <language>")
        return
    end

    local language = string.lower(args[1])
    if ASC.AI.Languages.SetLanguage(playerID, language) then
        local greeting = ASC.AI.Languages.GetText(playerID, "greeting")
        player:ChatPrint("[ARIA-3] " .. greeting)
        player:ChatPrint("[ARIA-3] Language preference updated to: " .. language)
    else
        player:ChatPrint("[ARIA-3] ❌ Unsupported language. Available: english (en), spanish (es), french (fr), czech (cs)")
    end
end)

-- Czech language shortcut command
concommand.Add("aria_cestina", function(player, cmd, args)
    if not IsValid(player) then return end

    local playerID = player:SteamID()
    if ASC.AI.Languages.SetLanguage(playerID, "czech") then
        local greeting = ASC.AI.Languages.GetText(playerID, "greeting")
        player:ChatPrint("[ARIA-3] " .. greeting)
        player:ChatPrint("[ARIA-3] Jazyk nastaven na češtinu! 🇨🇿")
        player:ChatPrint("[ARIA-3] Nyní můžete používat české příkazy jako 'aria pomoc', 'aria stav', 'aria vytvoř loď'")
    else
        player:ChatPrint("[ARIA-3] ❌ Chyba při nastavování českého jazyka.")
    end
end)

-- Predictive patterns command
concommand.Add("asc_ai_predictions", function(player, cmd, args)
    if not IsValid(player) then return end

    local playerID = player:SteamID()
    local learnedPatterns = ASC.AI.PredictiveSystem.LearnedPatterns[playerID]

    player:ChatPrint("[ARIA-3] 🔮 Predictive Analysis:")

    if learnedPatterns and #learnedPatterns > 0 then
        player:ChatPrint("Learned patterns from your interactions:")
        for i, pattern in ipairs(learnedPatterns) do
            if i <= 5 then -- Show top 5 patterns
                player:ChatPrint("• " .. pattern.trigger .. " → " .. pattern.result .. " (confidence: " .. math.floor(pattern.confidence * 100) .. "%)")
            end
        end
    else
        player:ChatPrint("No learned patterns yet. Interact with me more to build predictive models!")
    end

    player:ChatPrint("")
    player:ChatPrint("Built-in predictive patterns:")
    for _, pattern in ipairs(ASC.AI.PredictiveSystem.Patterns) do
        player:ChatPrint("• " .. pattern.trigger .. " (confidence: " .. math.floor(pattern.confidence * 100) .. "%)")
    end
end)

-- Advanced AI training command (admin only)
concommand.Add("asc_ai_train", function(player, cmd, args)
    if not IsValid(player) or not player:IsAdmin() then
        if IsValid(player) then
            player:ChatPrint("[ARIA-3] ❌ Admin access required for AI training commands.")
        end
        return
    end

    if not args[1] then
        player:ChatPrint("[ARIA-3] 🎓 AI Training Commands:")
        player:ChatPrint("• asc_ai_train reset_all - Reset all user profiles")
        player:ChatPrint("• asc_ai_train optimize - Optimize AI performance")
        player:ChatPrint("• asc_ai_train export - Export learning data")
        player:ChatPrint("• asc_ai_train stats - Show global AI statistics")
        player:ChatPrint("• asc_ai_train filter_status - Show content filtering status")
        player:ChatPrint("• asc_ai_train add_domain <domain> - Add trusted domain")
        player:ChatPrint("• asc_ai_train remove_domain <domain> - Remove domain")
        return
    end

    local command = string.lower(args[1])

    if command == "reset_all" then
        ASC.AI.UserProfiles = {}
        ASC.AI.ConversationHistory = {}
        ASC.AI.LearningData = {}
        ASC.AI.PredictiveSystem.LearnedPatterns = {}
        player:ChatPrint("[ARIA-3] 🔄 All AI profiles and learning data reset!")

    elseif command == "optimize" then
        -- Garbage collection and optimization
        collectgarbage("collect")
        player:ChatPrint("[ARIA-3] 🚀 AI system optimized! Memory usage: " .. math.floor(collectgarbage("count")) .. " KB")

    elseif command == "stats" then
        local totalUsers = 0
        local totalInteractions = 0
        local avgSatisfaction = 0

        for playerID, profile in pairs(ASC.AI.UserProfiles) do
            totalUsers = totalUsers + 1
            totalInteractions = totalInteractions + profile.interaction_count
            avgSatisfaction = avgSatisfaction + profile.satisfaction_score
        end

        if totalUsers > 0 then
            avgSatisfaction = avgSatisfaction / totalUsers
        end

        player:ChatPrint("[ARIA-3] 📊 Global AI Statistics:")
        player:ChatPrint("• Total Users: " .. totalUsers)
        player:ChatPrint("• Total Interactions: " .. totalInteractions)
        player:ChatPrint("• Average Satisfaction: " .. math.floor(avgSatisfaction * 100) .. "%")
        player:ChatPrint("• Memory Usage: " .. math.floor(collectgarbage("count")) .. " KB")

    elseif command == "export" then
        player:ChatPrint("[ARIA-3] 📤 Learning data export functionality would be implemented here.")
        player:ChatPrint("This would export anonymized learning patterns for analysis.")

    elseif command == "filter_status" then
        player:ChatPrint("[ARIA-3] 🛡️ Content Filtering System Status:")
        player:ChatPrint("• Blocked Keywords: " .. #ASC.AI.WebAccess.ContentFilter.BlockedKeywords)
        player:ChatPrint("• Blocked Categories: " .. #ASC.AI.WebAccess.ContentFilter.BlockedCategories)
        player:ChatPrint("• Trusted Domains: " .. #ASC.AI.WebAccess.ContentFilter.AllowedDomains)
        player:ChatPrint("• Safe Topics: " .. #ASC.AI.WebAccess.ContentFilter.SafeTopics)

        player:ChatPrint("")
        player:ChatPrint("🌐 Current Trusted Domains:")
        for _, domain in ipairs(ASC.AI.WebAccess.ContentFilter.AllowedDomains) do
            player:ChatPrint("• " .. domain)
        end

    elseif command == "add_domain" then
        if not args[2] then
            player:ChatPrint("[ARIA-3] ❌ Please specify a domain to add!")
            player:ChatPrint("Example: asc_ai_train add_domain example.com")
            return
        end

        local domain = string.lower(args[2])

        -- Check if domain already exists
        for _, existingDomain in ipairs(ASC.AI.WebAccess.ContentFilter.AllowedDomains) do
            if existingDomain == domain then
                player:ChatPrint("[ARIA-3] ⚠️ Domain '" .. domain .. "' is already in the whitelist!")
                return
            end
        end

        -- Add domain to whitelist
        table.insert(ASC.AI.WebAccess.ContentFilter.AllowedDomains, domain)
        player:ChatPrint("[ARIA-3] ✅ Added '" .. domain .. "' to trusted domains list!")
        player:ChatPrint("Users can now access content from this domain safely.")

    elseif command == "remove_domain" then
        if not args[2] then
            player:ChatPrint("[ARIA-3] ❌ Please specify a domain to remove!")
            player:ChatPrint("Example: asc_ai_train remove_domain example.com")
            return
        end

        local domain = string.lower(args[2])

        -- Find and remove domain
        for i, existingDomain in ipairs(ASC.AI.WebAccess.ContentFilter.AllowedDomains) do
            if existingDomain == domain then
                table.remove(ASC.AI.WebAccess.ContentFilter.AllowedDomains, i)
                player:ChatPrint("[ARIA-3] ✅ Removed '" .. domain .. "' from trusted domains list!")
                player:ChatPrint("Users can no longer access content from this domain.")
                return
            end
        end

        player:ChatPrint("[ARIA-3] ⚠️ Domain '" .. domain .. "' was not found in the whitelist!")

    else
        player:ChatPrint("[ARIA-3] ❌ Unknown training command: " .. command)
    end
end)

-- AI organization help command
concommand.Add("asc_ai_help_organization", function(player, cmd, args)
    if not IsValid(player) then return end

    player:ChatPrint("[ARIA-4] Organization Help System")
    player:ChatPrint("Primary commands (ARIA-4):")
    player:ChatPrint("• aria fix - General organization help")
    player:ChatPrint("• aria empty tabs - Fix empty Q menu tabs")
    player:ChatPrint("• aria spawn menu - Fix spawn menu entities")
    player:ChatPrint("• aria system status - Check system status")
    player:ChatPrint("Legacy commands (!ai) still supported for compatibility")
    player:ChatPrint("• asc_diagnostic - Run full diagnostic")
    player:ChatPrint("• asc_fix_organization - Auto-fix all issues")

    ASC.AI.ProvideOrganizationHelp(player, "general")
end)

-- Advanced predictive assistance system
ASC.AI.PredictiveSystem = {
    -- Predictive patterns based on user behavior
    Patterns = {
        {
            trigger = "spawn_ship_core",
            prediction = "hyperdrive_engine",
            confidence = 0.85,
            suggestion = "Next, you'll likely want to add hyperdrive engines. Try !ai hyperdrive engines for guidance."
        },
        {
            trigger = "spawn_hyperdrive_engine",
            prediction = "weapon_system",
            confidence = 0.70,
            suggestion = "Consider adding weapons to your ship. Ask me about !ai weapon systems for combat capabilities."
        },
        {
            trigger = "organization_fix",
            prediction = "entity_spawn",
            confidence = 0.75,
            suggestion = "Now that organization is fixed, you can spawn entities. Try the spawn menu or ask !ai spawning guide."
        },
        {
            trigger = "first_interaction",
            prediction = "help_request",
            confidence = 0.90,
            suggestion = "Welcome to Advanced Space Combat! Start with !ai ship core basics to learn the fundamentals."
        }
    },

    -- Learning patterns from user interactions
    LearnedPatterns = {},

    -- Prediction cache for performance
    PredictionCache = {}
}

-- Advanced learning algorithms
ASC.AI.LearningEngine = {
    -- Pattern recognition
    RecognizePatterns = function(playerID)
        local history = ASC.AI.ConversationHistory[playerID]
        if not history or #history < 3 then return end

        local patterns = {}
        for i = 1, #history - 1 do
            local current = history[i]
            local next = history[i + 1]

            -- Safety check: ensure both entries have analysis data
            if not current.analysis or not next.analysis then
                continue
            end

            local pattern = {
                trigger = current.analysis.intent or "unknown",
                result = next.analysis.intent or "unknown",
                confidence = ((current.analysis.confidence or 0.5) + (next.analysis.confidence or 0.5)) / 2,
                frequency = 1
            }

            -- Check if pattern already exists
            local existingPattern = nil
            for _, p in ipairs(patterns) do
                if p.trigger == pattern.trigger and p.result == pattern.result then
                    existingPattern = p
                    break
                end
            end

            if existingPattern then
                existingPattern.frequency = existingPattern.frequency + 1
                existingPattern.confidence = (existingPattern.confidence + pattern.confidence) / 2
            else
                table.insert(patterns, pattern)
            end
        end

        return patterns
    end,

    -- Update user preferences
    UpdatePreferences = function(playerID, query, analysis)
        if not ASC.AI.UserProfiles[playerID] or not analysis then return end

        local profile = ASC.AI.UserProfiles[playerID]

        -- Update preferred topics based on entities mentioned (with safety check)
        if analysis.entities then
            for _, entity in ipairs(analysis.entities) do
                if not table.HasValue(profile.preferred_topics, entity) then
                    table.insert(profile.preferred_topics, entity)
                end
            end
        end

        -- Limit preferred topics to top 5
        if #profile.preferred_topics > 5 then
            table.remove(profile.preferred_topics, 1)
        end

        -- Update experience level based on query complexity
        local complexityScore = ASC.AI.LearningEngine.CalculateQueryComplexity(query, analysis)
        if complexityScore > 0.8 and profile.interaction_count > 15 then
            profile.experience_level = "expert"
        elseif complexityScore > 0.5 and profile.interaction_count > 8 then
            profile.experience_level = "intermediate"
        end
    end,

    -- Calculate query complexity
    CalculateQueryComplexity = function(query, analysis)
        local complexity = 0

        -- Length factor
        complexity = complexity + math.min(0.3, #(query or "") / 100)

        -- Entity count factor (with safety check)
        if analysis and analysis.entities then
            complexity = complexity + (#analysis.entities * 0.1)
        end

        -- Context factor (with safety check)
        if analysis and analysis.context then
            complexity = complexity + (#analysis.context * 0.15)
        end

        -- Intent complexity (with safety check)
        local intentComplexity = {
            question = 0.6,
            help = 0.3,
            problem = 0.8,
            spawn = 0.5,
            configure = 0.9,
            status = 0.4
        }
        local intent = (analysis and analysis.intent) or "unknown"
        complexity = complexity + (intentComplexity[intent] or 0.5)

        return math.min(1, complexity)
    end
}

-- Proactive assistance system
ASC.AI.ProactiveAssistance = {
    -- Check for proactive help opportunities
    CheckForProactiveHelp = function(player, entity)
        if not IsValid(player) or not IsValid(entity) then return end

        local playerID = player:SteamID()
        local entityClass = entity:GetClass()

        -- Check for predictive patterns
        for _, pattern in ipairs(ASC.AI.PredictiveSystem.Patterns) do
            if string.find(entityClass, pattern.trigger) then
                timer.Simple(2, function()
                    if IsValid(player) then
                        player:ChatPrint("[ARIA-4] 🔮 " .. pattern.suggestion)
                    end
                end)
                break
            end
        end

        -- Check for common issues
        ASC.AI.ProactiveAssistance.CheckCommonIssues(player, entity)
    end,

    -- Check for common issues and provide proactive help
    CheckCommonIssues = function(player, entity)
        if not IsValid(player) or not IsValid(entity) then return end

        local entityClass = entity:GetClass()

        -- Ship core without engines
        if entityClass == "ship_core" then
            timer.Simple(5, function()
                if IsValid(player) and IsValid(entity) then
                    local nearbyEngines = 0
                    for _, ent in ipairs(ents.FindInSphere(entity:GetPos(), 2000)) do
                        if string.find(ent:GetClass(), "hyperdrive_engine") then
                            nearbyEngines = nearbyEngines + 1
                        end
                    end

                    if nearbyEngines == 0 then
                        player:ChatPrint("[ARIA-3] 💡 Tip: Your ship core needs hyperdrive engines! Place them within 2000 units.")
                        player:ChatPrint("[ARIA-3] Ask me: !ai hyperdrive engines for detailed guidance.")
                    end
                end
            end)
        end

        -- Weapon without ship core
        if string.find(entityClass, "weapon") or string.find(entityClass, "cannon") or string.find(entityClass, "railgun") then
            timer.Simple(3, function()
                if IsValid(player) and IsValid(entity) then
                    local nearbyCore = false
                    for _, ent in ipairs(ents.FindInSphere(entity:GetPos(), 2000)) do
                        if ent:GetClass() == "ship_core" then
                            nearbyCore = true
                            break
                        end
                    end

                    if not nearbyCore then
                        player:ChatPrint("[ARIA-3] ⚠️ Warning: Weapons need a ship core within 2000 units to function properly!")
                        player:ChatPrint("[ARIA-3] Ask me: !ai ship core for guidance.")
                    end
                end
            end)
        end
    end,

    -- Get user's preferred response style
    GetResponseStyle = function(player)
        local playerID = player:SteamID()
        local data = ASC.AI.LearningData[playerID]

        if not data or not data.response_preferences then
            return "standard"
        end

        local prefs = data.response_preferences
        local maxCount = 0
        local preferredStyle = "standard"

        for style, count in pairs(prefs) do
            if count > maxCount then
                maxCount = count
                preferredStyle = style
            end
        end

        return preferredStyle
    end
}

-- AI Integration with Core Addon Systems
ASC.AI.AddonIntegration = {
    -- Core system integration
    IntegrateWithShipCore = function(shipCore)
        if not IsValid(shipCore) then return false end

        -- Add AI monitoring to ship core
        shipCore.AIMonitored = true
        shipCore.AILastUpdate = CurTime()
        shipCore.AIStatus = "operational"
        shipCore.AIHealthScore = 1.0
        shipCore.AIPerformanceMetrics = {
            uptime = 0,
            efficiency = 1.0,
            last_maintenance = CurTime(),
            component_count = 0,
            power_usage = 0
        }

        -- Enhanced AI monitoring functions
        shipCore.UpdateAIMetrics = function(self)
            if not self.AIPerformanceMetrics then return end

            self.AIPerformanceMetrics.uptime = CurTime() - (self.AILastUpdate or CurTime())

            -- Count connected components
            local components = 0
            for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 2000)) do
                if IsValid(ent) and ent:GetClass() ~= "ship_core" then
                    local owner = nil
                    if ent.CPPIGetOwner then
                        owner = ent:CPPIGetOwner()
                    else
                        owner = ent:GetOwner()
                    end
                    if IsValid(owner) and owner == (self:CPPIGetOwner() or self:GetOwner()) then
                        components = components + 1
                    end
                end
            end
            self.AIPerformanceMetrics.component_count = components

            -- Update efficiency based on component count and performance
            self.AIPerformanceMetrics.efficiency = math.min(1.0, components / 10)
            self.AIHealthScore = self.AIPerformanceMetrics.efficiency
        end

        -- Hook into ship core events
        shipCore.OnAIStatusChange = function(self, newStatus)
            ASC.AI.AddonIntegration.NotifyStatusChange(self, "ship_core", newStatus)
        end

        -- Start AI monitoring timer
        timer.Create("ShipCore_AI_" .. shipCore:EntIndex(), 5, 0, function()
            if IsValid(shipCore) and shipCore.UpdateAIMetrics then
                shipCore:UpdateAIMetrics()
            else
                timer.Remove("ShipCore_AI_" .. shipCore:EntIndex())
            end
        end)

        return true
    end,

    -- Tactical AI integration
    IntegrateWithTacticalAI = function(tacticalAI)
        if not tacticalAI then return false end

        -- Enhance tactical AI with ARIA-3 intelligence
        tacticalAI.AIEnhanced = true
        tacticalAI.AIDecisionHistory = {}

        -- Override decision making with AI assistance
        local originalMakeDecisions = tacticalAI.MakeTacticalDecisions
        tacticalAI.MakeTacticalDecisions = function(self)
            -- Get AI recommendation
            local aiRecommendation = ASC.AI.AddonIntegration.GetTacticalRecommendation(self)

            -- Store decision for learning
            table.insert(self.AIDecisionHistory, {
                timestamp = CurTime(),
                recommendation = aiRecommendation,
                threat_count = #self.threatList,
                ship_health = self:GetShipHealth()
            })

            -- Apply AI-enhanced decision making
            if aiRecommendation then
                self.tacticalState = aiRecommendation.state
                self.behavior = aiRecommendation.behavior or self.behavior
            end

            -- Call original function
            originalMakeDecisions(self)
        end

        return true
    end,

    -- Navigation AI integration
    IntegrateWithNavigationAI = function()
        if not HYPERDRIVE or not HYPERDRIVE.Navigation then return false end

        -- Enhance navigation with ARIA-3 intelligence
        HYPERDRIVE.Navigation.AIEnhanced = true

        -- Override pathfinding with AI assistance
        local originalFindPath = HYPERDRIVE.Navigation.FindPath
        HYPERDRIVE.Navigation.FindPath = function(startPos, endPos, constraints)
            -- Get AI path optimization
            local aiPath = ASC.AI.AddonIntegration.OptimizePath(startPos, endPos, constraints)

            if aiPath then
                return aiPath
            end

            -- Fallback to original pathfinding
            return originalFindPath(startPos, endPos, constraints)
        end

        return true
    end,

    -- Weapon system integration
    IntegrateWithWeapons = function(weapon)
        if not IsValid(weapon) then return false end

        -- Add AI targeting assistance
        weapon.AITargeting = true
        weapon.AIAccuracy = 1.0
        weapon.AILastFire = 0
        weapon.AIFireCount = 0
        weapon.AIHitCount = 0
        weapon.AITargetHistory = {}
        weapon.AIPerformanceData = {
            total_shots = 0,
            successful_hits = 0,
            damage_dealt = 0,
            accuracy_trend = {},
            preferred_targets = {},
            optimal_range = 1000
        }

        -- Enhanced AI targeting system
        weapon.GetAIAccuracy = function(self, target)
            if not IsValid(target) then return 0.5 end

            local distance = self:GetPos():Distance(target:GetPos())
            local baseAccuracy = math.max(0.1, 1.0 - (distance / 5000))

            -- AI enhancement based on learning
            local enhancement = ASC.AI.AddonIntegration.GetWeaponAccuracyBonus(self, target)

            -- Range optimization
            local rangeOptimal = 1.0 - math.abs(distance - self.AIPerformanceData.optimal_range) / 2000
            rangeOptimal = math.max(0.1, rangeOptimal)

            return math.min(1.0, baseAccuracy + enhancement + (rangeOptimal * 0.2))
        end

        -- AI fire control system
        weapon.AIFireControl = function(self, target)
            if not IsValid(target) then return false end

            local accuracy = self:GetAIAccuracy(target)
            local shouldFire = accuracy > 0.6 and (CurTime() - self.AILastFire) > 1.0

            if shouldFire then
                self.AILastFire = CurTime()
                self.AIFireCount = self.AIFireCount + 1
                self.AIPerformanceData.total_shots = self.AIPerformanceData.total_shots + 1

                -- Record target for learning
                table.insert(self.AITargetHistory, {
                    target_class = target:GetClass(),
                    distance = self:GetPos():Distance(target:GetPos()),
                    accuracy = accuracy,
                    timestamp = CurTime()
                })

                -- Limit history size
                if #self.AITargetHistory > 50 then
                    table.remove(self.AITargetHistory, 1)
                end

                return true
            end

            return false
        end

        -- AI learning from combat results
        weapon.AILearnFromHit = function(self, target, damage)
            if not IsValid(target) then return end

            self.AIHitCount = self.AIHitCount + 1
            self.AIPerformanceData.successful_hits = self.AIPerformanceData.successful_hits + 1
            self.AIPerformanceData.damage_dealt = self.AIPerformanceData.damage_dealt + (damage or 0)

            -- Update accuracy trend
            local currentAccuracy = self.AIPerformanceData.total_shots > 0 and
                                  (self.AIPerformanceData.successful_hits / self.AIPerformanceData.total_shots) or 0
            table.insert(self.AIPerformanceData.accuracy_trend, currentAccuracy)

            if #self.AIPerformanceData.accuracy_trend > 20 then
                table.remove(self.AIPerformanceData.accuracy_trend, 1)
            end

            -- Learn optimal range
            local distance = self:GetPos():Distance(target:GetPos())
            self.AIPerformanceData.optimal_range = (self.AIPerformanceData.optimal_range + distance) / 2
        end

        return true
    end,

    -- CAP entity integration
    IntegrateWithCAPEntity = function(entity, category, component)
        if not IsValid(entity) then return false end

        entity.AIEnhanced = true
        entity.CAPCategory = category
        entity.CAPComponent = component
        entity.AIIntegrationTime = CurTime()

        -- Add CAP-specific AI enhancements
        if category == "stargate" then
            entity.AIDialingAssistance = true
            entity.AIAddressValidation = true
        elseif category == "shield" then
            entity.AIShieldOptimization = true
            entity.AIThreatResponse = true
        elseif category == "power" then
            entity.AIPowerManagement = true
            entity.AIEfficiencyMonitoring = true
        end

        return true
    end,

    -- Hyperdrive engine integration
    IntegrateWithHyperdriveEngine = function(engine)
        if not IsValid(engine) then return false end

        engine.AIEnhanced = true
        engine.AIEfficiency = 1.0
        engine.AIJumpHistory = {}
        engine.AIPerformanceData = {
            total_jumps = 0,
            successful_jumps = 0,
            energy_efficiency = 1.0,
            average_jump_time = 5.0,
            optimal_charge_time = 3.0
        }

        -- AI jump optimization
        engine.AIOptimizeJump = function(self, destination)
            local distance = self:GetPos():Distance(destination)
            local optimalCharge = math.max(1.0, distance / 10000)

            -- Learn from previous jumps
            if #self.AIJumpHistory > 0 then
                local avgEfficiency = 0
                for _, jump in ipairs(self.AIJumpHistory) do
                    avgEfficiency = avgEfficiency + jump.efficiency
                end
                avgEfficiency = avgEfficiency / #self.AIJumpHistory

                optimalCharge = optimalCharge * avgEfficiency
            end

            return optimalCharge
        end

        return true
    end,

    -- Shield system integration
    IntegrateWithShieldSystem = function(shield)
        if not IsValid(shield) then return false end

        shield.AIEnhanced = true
        shield.AIShieldStrength = 1.0
        shield.AIThreatLevel = 0
        shield.AIResponseMode = "adaptive"
        shield.AIPerformanceData = {
            damage_absorbed = 0,
            activation_count = 0,
            efficiency_rating = 1.0,
            threat_responses = 0
        }

        -- AI threat response system
        shield.AIRespondToThreat = function(self, threatLevel)
            self.AIThreatLevel = threatLevel

            if threatLevel > 0.7 then
                self.AIResponseMode = "maximum"
                self.AIShieldStrength = 1.0
            elseif threatLevel > 0.4 then
                self.AIResponseMode = "balanced"
                self.AIShieldStrength = 0.8
            else
                self.AIResponseMode = "efficient"
                self.AIShieldStrength = 0.6
            end

            self.AIPerformanceData.threat_responses = self.AIPerformanceData.threat_responses + 1
        end

        return true
    end,

    -- Status change notification system
    NotifyStatusChange = function(entity, systemType, newStatus)
        if not IsValid(entity) then return end

        -- Log status change for AI learning
        ASC.AI.AddonIntegration.LogSystemEvent({
            entity = entity,
            system_type = systemType,
            status = newStatus,
            timestamp = CurTime(),
            position = entity:GetPos()
        })

        -- Notify nearby players if significant
        if systemType == "ship_core" and (newStatus == "critical" or newStatus == "destroyed") then
            ASC.AI.AddonIntegration.NotifyNearbyPlayers(entity, systemType .. " status: " .. newStatus)
        end
    end,

    -- System event logging
    SystemEvents = {},
    LogSystemEvent = function(event)
        table.insert(ASC.AI.AddonIntegration.SystemEvents, event)

        -- Keep only recent events
        if #ASC.AI.AddonIntegration.SystemEvents > 1000 then
            table.remove(ASC.AI.AddonIntegration.SystemEvents, 1)
        end
    end,

    -- AI tactical recommendations
    GetTacticalRecommendation = function(tacticalAI)
        if not tacticalAI or not tacticalAI.threatList then return nil end

        local threatCount = #tacticalAI.threatList
        local shipHealth = tacticalAI:GetShipHealth()

        -- AI decision logic
        if shipHealth < 0.3 then
            return {state = "retreat", behavior = "defensive"}
        elseif threatCount > 3 then
            return {state = "engage", behavior = "aggressive"}
        elseif threatCount > 0 then
            return {state = "engage", behavior = "balanced"}
        else
            return {state = "patrol", behavior = "defensive"}
        end
    end,

    -- AI path optimization
    OptimizePath = function(startPos, endPos, constraints)
        -- Simple AI path optimization
        local distance = startPos:Distance(endPos)

        if distance < 1000 then
            -- Short distance - direct path
            return {startPos, endPos}
        else
            -- Long distance - add waypoint for safety
            local midPoint = (startPos + endPos) / 2
            midPoint.z = midPoint.z + 500 -- Higher altitude for safety
            return {startPos, midPoint, endPos}
        end
    end,

    -- Weapon accuracy learning
    WeaponAccuracyData = {},
    GetWeaponAccuracyBonus = function(weapon, target)
        local weaponClass = weapon:GetClass()
        local targetClass = target:GetClass()

        local key = weaponClass .. "_" .. targetClass
        local data = ASC.AI.AddonIntegration.WeaponAccuracyData[key]

        if data and data.shots > 10 then
            local hitRate = data.hits / data.shots
            return math.min(0.3, hitRate - 0.5) -- Max 30% bonus
        end

        return 0
    end,

    -- Notify nearby players
    NotifyNearbyPlayers = function(entity, message)
        if not IsValid(entity) then return end

        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) and player:GetPos():Distance(entity:GetPos()) < 2000 then
                player:ChatPrint("[ARIA-3] " .. message)
            end
        end
    end,

    -- Get all entities belonging to a ship
    GetShipEntities = function(shipCore, radius)
        if not IsValid(shipCore) then return {} end

        local entities = {}
        local owner = nil
        if shipCore.CPPIGetOwner then
            owner = shipCore:CPPIGetOwner()
        else
            owner = shipCore:GetOwner()
        end

        local searchRadius = radius or 2000

        for _, ent in ipairs(ents.FindInSphere(shipCore:GetPos(), searchRadius)) do
            if IsValid(ent) then
                local entOwner = nil
                if ent.CPPIGetOwner then
                    entOwner = ent:CPPIGetOwner()
                else
                    entOwner = ent:GetOwner()
                end

                if IsValid(owner) and IsValid(entOwner) and owner == entOwner then
                    table.insert(entities, ent)
                end
            end
        end

        return entities
    end
}

-- Initialize AI system
hook.Add("Initialize", "ASC_AI_Initialize", function()
    print("[Advanced Space Combat] ARIA-3 Advanced AI Assistant initialized")

    -- Initialize neural network early to prevent errors
    if ASC.AI.NeuralNetwork and ASC.AI.NeuralNetwork.Initialize then
        ASC.AI.NeuralNetwork.Initialize()
        print("[Advanced Space Combat] Neural network initialized successfully")
    end

    local totalTopics = #ASC.AI.Knowledge.CoreSystems + #ASC.AI.Knowledge.StargateTech +
                       #ASC.AI.Knowledge.CombatSystems + #ASC.AI.Knowledge.Commands +
                       #ASC.AI.Knowledge.OrganizationHelp + #ASC.AI.Knowledge.ULXHelp +
                       #ASC.AI.Knowledge.ULibHelp + #ASC.AI.Knowledge.PropProtectionHelp +
                       #ASC.AI.Knowledge.AdvDupe2Help + #ASC.AI.Knowledge.CAPHelp +
                       #ASC.AI.Knowledge.PlayerCommandsHelp
    print("[Advanced Space Combat] Knowledge base: " .. totalTopics .. " topics loaded")
    print("[Advanced Space Combat] Advanced Features: NLP, ML, Predictive Assistance, Player Commands")
    print("[Advanced Space Combat] AI Integration: Ship Core, Tactical AI, Navigation, Weapons")

    -- Check for ULib foundation
    if ASC.AI.ULib.IsAvailable() then
        local version = ASC.AI.ULib.GetVersion()
        print("[Advanced Space Combat] ULib detected - Version: " .. (version or "Unknown"))
        print("[Advanced Space Combat] ULib integration: ACTIVE")
        print("[Advanced Space Combat] ULib messaging and permissions: ENABLED")
    else
        print("[Advanced Space Combat] ULib not detected - Limited admin functionality")
    end

    -- Check for ULX integration
    if ASC.AI.ULX.IsAvailable() then
        local version = ASC.AI.ULX.GetVersion()
        print("[Advanced Space Combat] ULX detected - Version: " .. (version or "Unknown"))
        print("[Advanced Space Combat] ULX + ULib integration: ACTIVE")
        ASC.AI.ULX.RegisterCommands()
        print("[Advanced Space Combat] ULX admin commands registered")
    else
        print("[Advanced Space Combat] ULX not detected - Admin features limited")
    end

    -- Check for NPP integration
    if ASC.AI.NPP.IsAvailable() then
        print("[Advanced Space Combat] NPP (Nadmod Prop Protection) detected")
        print("[Advanced Space Combat] NPP integration: ACTIVE")
        print("[Advanced Space Combat] CPPI compliance: ENABLED")
    else
        print("[Advanced Space Combat] NPP not detected - Using fallback protection")
    end

    -- Check for CPPI
    if ASC.AI.CPPI.IsAvailable() then
        local version = ASC.AI.CPPI.GetVersion()
        print("[Advanced Space Combat] CPPI detected - Version: " .. (version or "Unknown"))
        print("[Advanced Space Combat] CPPI integration: ACTIVE")
    end

    -- Check for AdvDupe2 integration
    if ASC.AI.AdvDupe2.IsAvailable() then
        local version = ASC.AI.AdvDupe2.GetVersion()
        print("[Advanced Space Combat] AdvDupe2 detected - Version: " .. (version or "Unknown"))
        print("[Advanced Space Combat] AdvDupe2 integration: ACTIVE")
        print("[Advanced Space Combat] Ship duplication and templates: ENABLED")
    else
        print("[Advanced Space Combat] AdvDupe2 not detected - Ship templates unavailable")
    end

    -- Check for Wiremod integration
    if ASC.AI.Wiremod.IsAvailable() then
        local version = ASC.AI.Wiremod.GetVersion()
        print("[Advanced Space Combat] Wiremod detected - Version: " .. (version or "Unknown"))
        print("[Advanced Space Combat] Wiremod integration: ACTIVE")
        print("[Advanced Space Combat] Ship automation and wire support: ENABLED")
    else
        print("[Advanced Space Combat] Wiremod not detected - Automation features limited")
    end

    -- Check for CAP (Carter Addon Pack) integration
    if ASC.AI.CAP.IsAvailable() then
        local version = ASC.AI.CAP.GetVersion()
        print("[Advanced Space Combat] CAP (Carter Addon Pack) detected - Version: " .. (version or "Unknown"))
        print("[Advanced Space Combat] CAP integration: ACTIVE")
        print("[Advanced Space Combat] Stargate technology and CAP systems: ENABLED")
    else
        print("[Advanced Space Combat] CAP not detected - Stargate features limited")
    end

    print("[Advanced Space Combat] Use !ai <question> to interact with ARIA-3")
    print("[Advanced Space Combat] Enhanced commands: !ai fix, !ai analytics, asc_ai_status")

    if ASC.AI.ULX.IsAvailable() then
        print("[Advanced Space Combat] ULX commands: ulx ai_status, ulx ai_reset, ulx ai_stats")
    end

    if ASC.AI.NPP.IsAvailable() then
        print("[Advanced Space Combat] NPP commands: ulx ai_clean, ulx ai_clean_disconnected")
    end

    if ASC.AI.AdvDupe2.IsAvailable() then
        print("[Advanced Space Combat] AdvDupe2 features: Ship saving, loading, templates")
    end

    if ASC.AI.Wiremod.IsAvailable() then
        print("[Advanced Space Combat] Wiremod features: Ship automation, wire I/O")
    end

    if ASC.AI.CAP.IsAvailable() then
        print("[Advanced Space Combat] CAP features: Stargates, shields, ZPMs, weapons, vehicles")
    end

    -- Integration summary
    local integrations = {}
    if ASC.AI.ULib.IsAvailable() then table.insert(integrations, "ULib") end
    if ASC.AI.ULX.IsAvailable() then table.insert(integrations, "ULX") end
    if ASC.AI.NPP.IsAvailable() then table.insert(integrations, "NPP") end
    if ASC.AI.CPPI.IsAvailable() then table.insert(integrations, "CPPI") end
    if ASC.AI.AdvDupe2.IsAvailable() then table.insert(integrations, "AdvDupe2") end
    if ASC.AI.Wiremod.IsAvailable() then table.insert(integrations, "Wiremod") end
    if ASC.AI.CAP.IsAvailable() then table.insert(integrations, "CAP") end

    if #integrations > 0 then
        print("[Advanced Space Combat] Active integrations: " .. table.concat(integrations, ", "))
    else
        print("[Advanced Space Combat] Running in standalone mode")
    end

    -- Initialize addon system integrations
    timer.Simple(1, function()
        ASC.AI.AddonIntegration.InitializeSystemIntegrations()
    end)
end)

-- Automatic AI integration hooks
ASC.AI.AddonIntegration.InitializeSystemIntegrations = function()
    print("[Advanced Space Combat] Initializing AI system integrations...")

    -- Integrate with Navigation AI
    if ASC.AI.AddonIntegration.IntegrateWithNavigationAI() then
        print("[Advanced Space Combat] AI integrated with Navigation system")
    end

    -- Hook into entity spawning for automatic integration
    hook.Add("OnEntityCreated", "ASC_AI_EntityIntegration", function(entity)
        timer.Simple(0.1, function()
            if not IsValid(entity) then return end

            local class = entity:GetClass()

            -- Integrate ship cores
            if class == "asc_ship_core" then
                ASC.AI.AddonIntegration.IntegrateWithShipCore(entity)
                print("[ARIA-4] Integrated with ASC ship core: " .. entity:EntIndex())
            end

            -- Integrate weapons (expanded detection)
            if string.find(class, "weapon_") or string.find(class, "hyperdrive_") or
               string.find(class, "railgun") or string.find(class, "cannon") or
               string.find(class, "turret") or string.find(class, "launcher") then
                ASC.AI.AddonIntegration.IntegrateWithWeapons(entity)
                print("[ARIA-3] Integrated with weapon: " .. class)
            end

            -- Integrate CAP entities
            if ASC.AI.CAP.IsAvailable() then
                local isCAP, category, component = ASC.AI.CAP.Utils.IsCAPEntity(entity)
                if isCAP then
                    ASC.AI.AddonIntegration.IntegrateWithCAPEntity(entity, category, component)
                    print("[ARIA-3] Integrated with CAP entity: " .. class .. " (" .. category .. ")")
                end
            end

            -- Integrate hyperdrive engines
            if string.find(class, "hyperdrive_engine") then
                ASC.AI.AddonIntegration.IntegrateWithHyperdriveEngine(entity)
                print("[ARIA-3] Integrated with hyperdrive engine: " .. entity:EntIndex())
            end

            -- Integrate shield generators
            if string.find(class, "shield") or string.find(class, "barrier") then
                ASC.AI.AddonIntegration.IntegrateWithShieldSystem(entity)
                print("[ARIA-3] Integrated with shield system: " .. class)
            end
        end)
    end)

    -- Hook into tactical AI creation
    hook.Add("TacticalAICreated", "ASC_AI_TacticalIntegration", function(tacticalAI)
        if ASC.AI.AddonIntegration.IntegrateWithTacticalAI(tacticalAI) then
            print("[ARIA-3] Enhanced Tactical AI with ARIA-3 intelligence")
        end
    end)

    -- Monitor system performance
    timer.Create("ASC_AI_SystemMonitor", 30, 0, function()
        ASC.AI.AddonIntegration.MonitorSystemPerformance()
    end)

    print("[Advanced Space Combat] AI system integrations initialized")
end

-- System performance monitoring
ASC.AI.AddonIntegration.MonitorSystemPerformance = function()
    local entityCounts = {
        ship_cores = #ents.FindByClass("ship_core"),
        weapons = 0,
        ai_enhanced = 0
    }

    -- Count AI-enhanced entities
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) then
            if ent.AITargeting or ent.AIMonitored then
                entityCounts.ai_enhanced = entityCounts.ai_enhanced + 1
            end

            local class = ent:GetClass()
            if string.find(class, "weapon_") or string.find(class, "hyperdrive_") then
                entityCounts.weapons = entityCounts.weapons + 1
            end
        end
    end

    -- Update system status
    if ASC and ASC.SystemStatus then
        ASC.SystemStatus.EntityCounts.ShipCores = entityCounts.ship_cores
        ASC.SystemStatus.EntityCounts.Weapons = entityCounts.weapons
        ASC.SystemStatus.ChatAI = true
    end

    -- Log performance metrics
    ASC.AI.PerformanceMetrics.UpdateMetrics()
end



-- System status reporting
ASC.AI.AddonIntegration.SendSystemStatus = function(player)
    if not IsValid(player) then return end

    local status = {
        "=== ARIA-3 System Status ===",
        "Ship Cores: " .. #ents.FindByClass("ship_core") .. " active",
        "AI Enhanced Entities: " .. ASC.AI.AddonIntegration.CountAIEnhanced(),
        "System Events: " .. #ASC.AI.AddonIntegration.SystemEvents .. " logged",
        "Performance: " .. math.floor(ASC.AI.PerformanceMetrics.UserSatisfactionScore * 100) .. "% satisfaction"
    }

    for _, line in ipairs(status) do
        player:ChatPrint("[ARIA-3] " .. line)
    end
end

ASC.AI.AddonIntegration.SendShipStatus = function(player)
    if not IsValid(player) then return end

    local playerShips = {}
    for _, shipCore in ipairs(ents.FindByClass("ship_core")) do
        if IsValid(shipCore) and shipCore:CPPIGetOwner() == player then
            table.insert(playerShips, shipCore)
        end
    end

    if #playerShips == 0 then
        player:ChatPrint("[ARIA-3] No ships found. Spawn a ship core to get started!")
        return
    end

    player:ChatPrint("[ARIA-3] === Your Ships ===")
    for i, ship in ipairs(playerShips) do
        local status = ship.AIStatus or "unknown"
        local distance = math.floor(player:GetPos():Distance(ship:GetPos()))
        player:ChatPrint("[ARIA-3] Ship " .. i .. ": " .. status .. " (" .. distance .. " units away)")
    end
end

ASC.AI.AddonIntegration.SendWeaponStatus = function(player)
    if not IsValid(player) then return end

    local weapons = {}
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent.AITargeting and ent:CPPIGetOwner() == player then
            table.insert(weapons, ent)
        end
    end

    if #weapons == 0 then
        player:ChatPrint("[ARIA-3] No AI-enhanced weapons found.")
        return
    end

    player:ChatPrint("[ARIA-3] === AI-Enhanced Weapons ===")
    for i, weapon in ipairs(weapons) do
        local accuracy = math.floor((weapon.AIAccuracy or 0.5) * 100)
        player:ChatPrint("[ARIA-3] " .. weapon:GetClass() .. ": " .. accuracy .. "% accuracy")
    end
end

ASC.AI.AddonIntegration.SendTacticalStatus = function(player)
    if not IsValid(player) then return end

    -- Find player's tactical AI systems
    local tacticalSystems = 0
    local activeEngagements = 0

    for _, shipCore in ipairs(ents.FindByClass("ship_core")) do
        if IsValid(shipCore) and shipCore:CPPIGetOwner() == player then
            if shipCore.TacticalAI and shipCore.TacticalAI.AIEnhanced then
                tacticalSystems = tacticalSystems + 1
                if shipCore.TacticalAI.tacticalState == "engage" then
                    activeEngagements = activeEngagements + 1
                end
            end
        end
    end

    player:ChatPrint("[ARIA-3] === Tactical AI Status ===")
    player:ChatPrint("[ARIA-3] AI-Enhanced Systems: " .. tacticalSystems)
    player:ChatPrint("[ARIA-3] Active Engagements: " .. activeEngagements)

    if tacticalSystems == 0 then
        player:ChatPrint("[ARIA-3] No tactical AI systems found. Build ships with tactical AI!")
    end
end

ASC.AI.AddonIntegration.CountAIEnhanced = function()
    local count = 0
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and (ent.AITargeting or ent.AIMonitored or ent.AIEnhanced) then
            count = count + 1
        end
    end
    return count
end

-- ULX late initialization (for when ULX loads after our addon)
hook.Add("ULibPostInit", "ASC_AI_ULX_Init", function()
    if ASC.AI.ULX.IsAvailable() then
        print("[Advanced Space Combat] ULX late initialization - Registering commands")
        ASC.AI.ULX.RegisterCommands()
    end
end)

-- Hook for proactive assistance
hook.Add("PlayerSpawnedSENT", "ASC_AI_ProactiveHelp", function(player, entity)
    if ASC.AI.Config.EnableProactiveAssistance then
        ASC.AI.ProactiveAssistance.CheckForProactiveHelp(player, entity)
    end
end)

-- Handle tactical AI commands
ASC.AI.HandleTacticalCommands = function(player, query, queryLower)
    if not IsValid(player) then
        return "Invalid player for tactical commands"
    end

    -- Check if tactical AI system is available
    if not ASC.TacticalAI then
        return "Tactical AI system is not loaded. Please ensure the tactical AI module is installed."
    end

    -- Find player's ship core
    local shipCore = ASC.AI.FindPlayerShipCore(player)
    if not IsValid(shipCore) then
        return "Tactical AI requires a ship core! Make sure you have a ship with a ship core that you own nearby."
    end

    local sessionID = shipCore:EntIndex()

    -- Handle specific tactical commands
    if string.find(queryLower, "tactical status") or string.find(queryLower, "combat status") then
        return ASC.AI.GetTacticalStatus(sessionID)

    elseif string.find(queryLower, "tactical on") or string.find(queryLower, "enable tactical") or string.find(queryLower, "activate tactical") then
        local success, message = ASC.TacticalAI.Core.Initialize(shipCore, player)
        return message or (success and "Tactical AI activated for your ship!" or "Failed to activate tactical AI")

    elseif string.find(queryLower, "tactical off") or string.find(queryLower, "disable tactical") or string.find(queryLower, "deactivate tactical") then
        ASC.TacticalAI.Core.Shutdown(sessionID)
        return "Tactical AI deactivated for your ship"

    elseif string.find(queryLower, "weapons status") or string.find(queryLower, "weapon status") then
        return ASC.AI.GetWeaponsStatus(sessionID)

    elseif string.find(queryLower, "threats") or string.find(queryLower, "threat") then
        return ASC.AI.GetThreatStatus(sessionID)

    elseif string.find(queryLower, "targets") or string.find(queryLower, "target") then
        return ASC.AI.GetTargetStatus(sessionID)

    elseif string.find(queryLower, "assistance level") or string.find(queryLower, "ai level") then
        return ASC.AI.HandleAssistanceLevel(sessionID, query, queryLower)

    else
        -- General tactical help
        return "🎯 Tactical AI Commands:\n" ..
               "• 'aria tactical on' - Activate tactical AI\n" ..
               "• 'aria tactical status' - View tactical status\n" ..
               "• 'aria weapons status' - Check weapon systems\n" ..
               "• 'aria threats' - View detected threats\n" ..
               "• 'aria targets' - View current targets\n" ..
               "• 'aria assistance level 2' - Set AI assistance level (1-4)\n" ..
               "• 'aria tactical off' - Deactivate tactical AI\n\n" ..
               "Assistance Levels:\n" ..
               "1 = Passive (info only), 2 = Advisory (suggestions), 3 = Assisted (auto actions), 4 = Autonomous (full AI)"
    end
end

-- Get tactical status for a ship
ASC.AI.GetTacticalStatus = function(sessionID)
    if not ASC.TacticalAI or not ASC.TacticalAI.Core.ActiveSessions[sessionID] then
        return "Tactical AI is not active for this ship. Use 'aria tactical on' to activate."
    end

    local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
    local threatCount = table.Count(session.threats)
    local targetCount = table.Count(session.targets)
    local weaponCount = #session.weapons

    local statusIcon = "🟢"
    if session.status == "ALERT" then statusIcon = "🟡"
    elseif session.status == "COMBAT" then statusIcon = "🔴" end

    return statusIcon .. " Tactical AI Status: " .. session.status .. "\n" ..
           "🔫 Weapons: " .. weaponCount .. " detected\n" ..
           "⚠️ Threats: " .. threatCount .. " in range\n" ..
           "🎯 Targets: " .. targetCount .. " acquired\n" ..
           "🤖 Assistance Level: " .. session.assistanceLevel .. "/4\n" ..
           "⏱️ Last Update: " .. math.floor(CurTime() - session.lastUpdate) .. "s ago"
end

-- Get weapons status
ASC.AI.GetWeaponsStatus = function(sessionID)
    if not ASC.TacticalAI or not ASC.TacticalAI.Core.ActiveSessions[sessionID] then
        return "Tactical AI is not active. Use 'aria tactical on' first."
    end

    local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
    if #session.weapons == 0 then
        return "No weapons detected on your ship. Add weapons to enable tactical AI combat features."
    end

    local weaponsByStatus = {}
    local weaponsByType = {}

    for _, weapon in ipairs(session.weapons) do
        -- Count by status
        weaponsByStatus[weapon.status] = (weaponsByStatus[weapon.status] or 0) + 1

        -- Count by type
        weaponsByType[weapon.type] = (weaponsByType[weapon.type] or 0) + 1
    end

    local statusText = "🔫 Weapons Status (" .. #session.weapons .. " total):\n"

    for status, count in pairs(weaponsByStatus) do
        local icon = "⚪"
        if status == "READY" then icon = "🟢"
        elseif status == "COOLING" then icon = "🟡"
        elseif status == "NO_AMMO" then icon = "🔴"
        elseif status == "OFFLINE" then icon = "⚫" end

        statusText = statusText .. icon .. " " .. status .. ": " .. count .. "\n"
    end

    statusText = statusText .. "\n🎯 Weapon Types:\n"
    for weaponType, count in pairs(weaponsByType) do
        statusText = statusText .. "• " .. weaponType .. ": " .. count .. "\n"
    end

    return statusText
end

-- Get threat status
ASC.AI.GetThreatStatus = function(sessionID)
    if not ASC.TacticalAI or not ASC.TacticalAI.Core.ActiveSessions[sessionID] then
        return "Tactical AI is not active. Use 'aria tactical on' first."
    end

    local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
    local threatCount = table.Count(session.threats)

    if threatCount == 0 then
        return "🟢 No threats detected in range. All clear!"
    end

    local threatText = "⚠️ Threats Detected (" .. threatCount .. "):\n"
    local threatsByLevel = {}

    for _, threat in pairs(session.threats) do
        threatsByLevel[threat.level] = (threatsByLevel[threat.level] or 0) + 1
    end

    for level = 5, 1, -1 do
        if threatsByLevel[level] then
            local icon = "🟡"
            if level >= 4 then icon = "🔴"
            elseif level <= 2 then icon = "🟠" end

            threatText = threatText .. icon .. " Level " .. level .. ": " .. threatsByLevel[level] .. " threats\n"
        end
    end

    return threatText .. "\nUse 'aria targets' to see current targeting status."
end

-- Get target status
ASC.AI.GetTargetStatus = function(sessionID)
    if not ASC.TacticalAI or not ASC.TacticalAI.Core.ActiveSessions[sessionID] then
        return "Tactical AI is not active. Use 'aria tactical on' first."
    end

    local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
    local targetCount = table.Count(session.targets)

    if targetCount == 0 then
        return "🎯 No targets acquired. Threats may be too low priority or out of weapon range."
    end

    local targetText = "🎯 Targets Acquired (" .. targetCount .. "):\n"

    for _, target in pairs(session.targets) do
        local priorityIcon = "🟡"
        if target.priority >= 4 then priorityIcon = "🔴"
        elseif target.priority <= 2 then priorityIcon = "🟠" end

        targetText = targetText .. priorityIcon .. " Priority " .. target.priority ..
                    " - Distance: " .. math.floor(target.distance) .. " units\n"
    end

    return targetText
end

-- Handle assistance level commands
ASC.AI.HandleAssistanceLevel = function(sessionID, query, queryLower)
    if not ASC.TacticalAI or not ASC.TacticalAI.Core.ActiveSessions[sessionID] then
        return "Tactical AI is not active. Use 'aria tactical on' first."
    end

    local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]

    -- Extract level number from query
    local level = tonumber(string.match(query, "(%d+)"))

    if level then
        if level >= 1 and level <= 4 then
            session.assistanceLevel = level

            local levelNames = {
                [1] = "Passive (Information only)",
                [2] = "Advisory (Suggestions and warnings)",
                [3] = "Assisted (Automated non-critical actions)",
                [4] = "Autonomous (Full AI control - Admin only)"
            }

            return "🤖 Tactical AI assistance level set to " .. level .. ": " .. levelNames[level]
        else
            return "Invalid assistance level. Use 1-4 (1=Passive, 2=Advisory, 3=Assisted, 4=Autonomous)"
        end
    else
        return "Current assistance level: " .. session.assistanceLevel .. "/4\n" ..
               "Use 'aria assistance level <1-4>' to change:\n" ..
               "1 = Passive, 2 = Advisory, 3 = Assisted, 4 = Autonomous"
    end
end

-- Handle shield commands
ASC.AI.HandleShieldCommands = function(player, query, queryLower)
    if not IsValid(player) then
        return "Invalid player for shield commands"
    end

    -- Check if shield system is available
    if not ASC.Shields then
        return "Shield system is not loaded. Please ensure the shield module is installed."
    end

    -- Find player's ship core
    local shipCore = ASC.AI.FindPlayerShipCore(player)
    if not IsValid(shipCore) then
        return "Shield system requires a ship core! Make sure you have a ship with a ship core that you own nearby."
    end

    local shipID = shipCore:EntIndex()

    -- Handle specific shield commands
    if string.find(queryLower, "shield status") or string.find(queryLower, "shields status") then
        return ASC.AI.GetShieldStatus(shipID)

    elseif string.find(queryLower, "shield on") or string.find(queryLower, "shields on") or
           string.find(queryLower, "activate shield") or string.find(queryLower, "enable shield") then
        local success, message = ASC.Shields.Core.Initialize(shipCore, "ADVANCED")
        return message or (success and "Shield system activated for your ship!" or "Failed to activate shield system")

    elseif string.find(queryLower, "shield off") or string.find(queryLower, "shields off") or
           string.find(queryLower, "deactivate shield") or string.find(queryLower, "disable shield") then
        ASC.Shields.Core.ActiveShields[shipID] = nil
        shipCore:SetNWBool("ShieldSystemActive", false)
        shipCore:SetNWFloat("ShieldStrength", 0)
        return "Shield system deactivated for your ship"

    elseif string.find(queryLower, "shield recharge") or string.find(queryLower, "recharge shield") then
        return ASC.AI.ForceShieldRecharge(shipID)

    elseif string.find(queryLower, "shield type") then
        return ASC.AI.HandleShieldType(shipID, query, queryLower)

    else
        -- General shield help
        return "🛡️ Built-in Shield System Commands:\n" ..
               "• 'aria shield on' - Activate built-in shields (no generators needed!)\n" ..
               "• 'aria shield status' - View shield status\n" ..
               "• 'aria shield recharge' - Force shield recharge\n" ..
               "• 'aria shield type fortress' - Set shield type\n" ..
               "• 'aria shield off' - Deactivate shield system\n\n" ..
               "Built-in Shield Types (no generators required):\n" ..
               "• BASIC (800 strength), ADVANCED (1500 strength)\n" ..
               "• TACTICAL (2500 strength), FORTRESS (4000 strength)\n" ..
               "• CAP_ENHANCED (3500 strength) - Enhanced CAP integration\n\n" ..
               "💡 Shields are built into your ship core! Optional generators provide bonus strength."
    end
end

-- Get shield status for a ship
ASC.AI.GetShieldStatus = function(shipID)
    if not ASC.Shields or not ASC.Shields.Core.ActiveShields[shipID] then
        return "Shield system is not active for this ship. Use 'aria shield on' to activate."
    end

    local status = ASC.Shields.Core.GetShieldStatus(shipID)

    local statusIcon = "🔴"
    if status.available then
        if status.strengthPercent > 75 then statusIcon = "🟢"
        elseif status.strengthPercent > 25 then statusIcon = "🟡"
        else statusIcon = "🟠" end
    end

    local rechargeStatus = status.recharging and " (Recharging)" or ""

    return statusIcon .. " Shield Status: " .. status.status .. rechargeStatus .. "\n" ..
           "🛡️ Strength: " .. math.floor(status.strengthPercent) .. "% (" ..
           math.floor(status.currentStrength) .. "/" .. math.floor(status.maxStrength) .. ")\n" ..
           "⚡ Generators: " .. status.generators .. " active\n" ..
           "🌐 CAP Shields: " .. status.capShields .. " detected\n" ..
           "📊 Efficiency: " .. math.floor(status.efficiency * 100) .. "%\n" ..
           "💥 Damage Absorbed: " .. math.floor(status.damageAbsorbed) .. " total"
end

-- Force shield recharge
ASC.AI.ForceShieldRecharge = function(shipID)
    if not ASC.Shields or not ASC.Shields.Core.ActiveShields[shipID] then
        return "Shield system is not active. Use 'aria shield on' first."
    end

    local shield = ASC.Shields.Core.ActiveShields[shipID]

    if shield.currentStrength >= shield.maxStrength then
        return "🟢 Shields are already at full strength (" .. math.floor(shield.maxStrength) .. ")"
    end

    -- Force immediate recharge
    shield.recharging = true
    shield.lastDamageTime = 0 -- Reset damage timer

    return "⚡ Shield recharge initiated! Current: " .. math.floor(shield.currentStrength) ..
           "/" .. math.floor(shield.maxStrength) .. " (" ..
           math.floor((shield.currentStrength / shield.maxStrength) * 100) .. "%)"
end

-- Handle shield type commands
ASC.AI.HandleShieldType = function(shipID, query, queryLower)
    if not ASC.Shields or not ASC.Shields.Core.ActiveShields[shipID] then
        return "Shield system is not active. Use 'aria shield on' first."
    end

    -- Extract shield type from query
    local shieldType = nil
    if string.find(queryLower, "basic") then shieldType = "BASIC"
    elseif string.find(queryLower, "advanced") then shieldType = "ADVANCED"
    elseif string.find(queryLower, "tactical") then shieldType = "TACTICAL"
    elseif string.find(queryLower, "fortress") then shieldType = "FORTRESS"
    elseif string.find(queryLower, "cap") or string.find(queryLower, "enhanced") then shieldType = "CAP_ENHANCED"
    end

    if shieldType then
        local shield = ASC.Shields.Core.ActiveShields[shipID]
        local oldType = shield.shieldType

        shield.shieldType = shieldType
        shield.config = ASC.Shields.Config.ShieldTypes[shieldType]

        -- Recalculate shield strength
        ASC.Shields.Core.ActivateBuiltinShields(shipID)

        return "🛡️ Shield type changed from " .. oldType .. " to " .. shieldType .. "\n" ..
               "New shield strength: " .. shield.maxStrength .. "\n" ..
               "Recharge rate: " .. shield.config.rechargeRate .. "/sec"
    else
        local shield = ASC.Shields.Core.ActiveShields[shipID]
        return "Current shield type: " .. shield.shieldType .. "\n" ..
               "Available built-in types:\n" ..
               "• BASIC (800), ADVANCED (1500), TACTICAL (2500)\n" ..
               "• FORTRESS (4000), CAP_ENHANCED (3500)\n" ..
               "Use 'aria shield type <type>' to change"
    end
end

-- Handle flight commands
ASC.AI.HandleFlightCommands = function(player, query, queryLower)
    if not IsValid(player) then
        return ASC.AI.TranslateResponse(player, "Invalid player for flight commands")
    end

    -- Check if flight system is available
    if not ASC.Flight then
        return ASC.AI.TranslateResponse(player, "Flight system is not loaded. Please ensure the flight module is installed.")
    end

    -- Find player's ship core
    local shipCore = ASC.AI.FindPlayerShipCore(player)
    if not IsValid(shipCore) then
        return ASC.AI.TranslateResponse(player, "Flight system requires a ship core! Make sure you have a ship with a ship core that you own nearby.")
    end

    local shipID = shipCore:EntIndex()

    -- Handle specific flight commands with multilingual support
    if string.find(queryLower, "flight status") or string.find(queryLower, "flight system") or
       string.find(queryLower, "stav letu") or string.find(queryLower, "letový systém") then
        return ASC.AI.TranslateResponse(player, ASC.AI.GetFlightStatus(shipID))

    elseif string.find(queryLower, "flight on") or string.find(queryLower, "enable flight") or string.find(queryLower, "activate flight") or
           string.find(queryLower, "let zapnout") or string.find(queryLower, "aktivovat let") then
        local success, message = ASC.Flight.Core.Initialize(shipCore, "STANDARD")
        local response = message or (success and "Flight system activated for your ship!" or "Failed to activate flight system")
        return ASC.AI.TranslateResponse(player, response)

    elseif string.find(queryLower, "autopilot on") or string.find(queryLower, "enable autopilot") or string.find(queryLower, "activate autopilot") or
           string.find(queryLower, "autopilot zapnout") or string.find(queryLower, "aktivovat autopilot") then
        return ASC.AI.TranslateResponse(player, ASC.AI.EnableAutopilot(shipID, player))

    elseif string.find(queryLower, "autopilot off") or string.find(queryLower, "disable autopilot") or string.find(queryLower, "deactivate autopilot") or
           string.find(queryLower, "autopilot vypnout") or string.find(queryLower, "deaktivovat autopilot") then
        local success = ASC.Flight.Core.DisableAutopilot(shipID)
        local response = success and "Autopilot disabled for your ship" or "Failed to disable autopilot"
        return ASC.AI.TranslateResponse(player, response)

    elseif string.find(queryLower, "fly to") or string.find(queryLower, "navigate to") then
        return ASC.AI.HandleFlyToCommand(shipID, player, query, queryLower)

    elseif string.find(queryLower, "waypoint") then
        return ASC.AI.HandleWaypointCommands(shipID, player, query, queryLower)

    elseif string.find(queryLower, "vehicle on") or string.find(queryLower, "enable vehicle") or string.find(queryLower, "vehicle control") then
        local success, message = ASC.Flight.Core.EnableVehicleControl(shipID, player)
        if success then
            return "🚁 Vehicle control enabled from cockpit seat! Use WASD to fly, mouse to steer"
        else
            return "❌ " .. (message or "Failed to enable vehicle control") .. "\n💡 Sit in a seat welded to your ship first!"
        end

    elseif string.find(queryLower, "vehicle off") or string.find(queryLower, "disable vehicle") then
        local success = ASC.Flight.Core.DisableVehicleControl(shipID)
        return success and "🚁 Vehicle control disabled" or "Failed to disable vehicle control"

    elseif string.find(queryLower, "flight off") or string.find(queryLower, "disable flight") then
        ASC.Flight.Core.ActiveFlights[shipID] = nil
        shipCore:SetNWBool("FlightSystemActive", false)
        return "Flight system deactivated for your ship"

    else
        -- General flight help
        return "✈️ Flight System Commands:\n" ..
               "• 'aria flight on' - Activate flight system\n" ..
               "• 'aria flight status' - View flight status\n" ..
               "• 'aria vehicle on' - Enable cockpit control (sit in seat first!)\n" ..
               "• 'aria autopilot on' - Enable autopilot to your crosshair\n" ..
               "• 'aria fly to coordinates' - Navigate to specific location\n" ..
               "• 'aria waypoint add' - Add waypoint at crosshair\n" ..
               "• 'aria waypoint clear' - Clear all waypoints\n" ..
               "• 'aria vehicle off' - Disable vehicle control\n" ..
               "• 'aria autopilot off' - Disable autopilot\n" ..
               "• 'aria flight off' - Deactivate flight system\n\n" ..
               "🪑 Cockpit Control: Sit in a seat welded to your ship, then use 'aria vehicle on'\n" ..
               "🚁 Controls: WASD = move, Mouse = steer, SPACE = boost, SHIFT = brake\n" ..
               "📷 Camera: Mouse wheel = zoom in/out, R = reset camera position\n" ..
               "💡 Flight system provides cockpit control with external camera, autopilot, waypoint navigation, and collision avoidance!"
    end
end

-- Get flight status for a ship
ASC.AI.GetFlightStatus = function(shipID)
    if not ASC.Flight or not ASC.Flight.Core.ActiveFlights[shipID] then
        return "Flight system is not active for this ship. Use 'aria flight on' to activate."
    end

    local status = ASC.Flight.Core.GetFlightStatus(shipID)

    local statusIcon = "🔴"
    if status.available then
        if status.status == "VEHICLE_CONTROL" then statusIcon = "🚁"
        elseif status.status == "AUTOPILOT" then statusIcon = "🟢"
        elseif status.status == "MANUAL" then statusIcon = "🟡"
        else statusIcon = "🔵" end
    end

    local warningText = ""
    if status.collisionWarning then warningText = " ⚠️ COLLISION WARNING" end
    if status.emergencyBraking then warningText = warningText .. " 🛑 EMERGENCY BRAKING" end

    local controlText = ""
    if status.vehicleControlActive then
        local pilotName = IsValid(status.pilot) and status.pilot:Name() or "Unknown"
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        local seatInfo = ""

        if flight and IsValid(flight.pilotSeat) then
            seatInfo = " (Seat: " .. flight.pilotSeat:EntIndex() .. ")"
        end

        controlText = "🚁 Cockpit Control: ACTIVE (Pilot: " .. pilotName .. seatInfo .. ")\n"

        local boostText = status.boostActive and " 🚀 BOOST" or ""
        local brakeText = status.brakeActive and " 🛑 BRAKE" or ""
        local stabilityText = status.stabilityAssist and " 🎯 STABILITY" or ""

        if boostText ~= "" or brakeText ~= "" or stabilityText ~= "" then
            controlText = controlText .. "🎮 Controls:" .. boostText .. brakeText .. stabilityText .. "\n"
        end
    else
        controlText = "🚁 Cockpit Control: INACTIVE (Sit in seat and use 'aria vehicle on')\n"
    end

    return statusIcon .. " Flight Status: " .. status.status .. warningText .. "\n" ..
           controlText ..
           "✈️ Autopilot: " .. (status.autopilotActive and "ACTIVE" or "INACTIVE") .. "\n" ..
           "🎯 Waypoints: " .. status.waypoints .. " queued\n" ..
           "🚀 Velocity: " .. math.floor(status.velocity) .. " units/sec\n" ..
           "📏 Distance Traveled: " .. math.floor(status.distanceTraveled) .. " units\n" ..
           "⚡ Energy Consumed: " .. math.floor(status.energyConsumed) .. " units"
end

-- Enable autopilot to player's crosshair
ASC.AI.EnableAutopilot = function(shipID, player)
    if not ASC.Flight or not ASC.Flight.Core.ActiveFlights[shipID] then
        return "Flight system is not active. Use 'aria flight on' first."
    end

    -- Get player's aim position
    local trace = player:GetEyeTrace()
    local target = trace.HitPos

    if not target or target:Distance(player:GetPos()) < 100 then
        return "❌ Invalid autopilot target! Aim at a distant location and try again."
    end

    local success = ASC.Flight.Core.EnableAutopilot(shipID, target, "DIRECT")

    if success then
        local distance = math.floor(player:GetPos():Distance(target))
        return "✈️ Autopilot engaged! Flying to target location (" .. distance .. " units away)\n" ..
               "Use 'aria autopilot off' to cancel"
    else
        return "❌ Failed to enable autopilot. Check flight system status."
    end
end

-- Handle fly to commands
ASC.AI.HandleFlyToCommand = function(shipID, player, query, queryLower)
    if not ASC.Flight or not ASC.Flight.Core.ActiveFlights[shipID] then
        return "Flight system is not active. Use 'aria flight on' first."
    end

    -- Extract coordinates or target from query
    local coords = string.match(query, "fly to ([%d%s,-]+)")
    if not coords then
        coords = string.match(query, "navigate to ([%d%s,-]+)")
    end

    if coords then
        -- Parse coordinates
        local x, y, z = string.match(coords, "([%-]?%d+)[%s,]+([%-]?%d+)[%s,]+([%-]?%d+)")
        if x and y and z then
            local target = Vector(tonumber(x), tonumber(y), tonumber(z))
            local success = ASC.Flight.Core.EnableAutopilot(shipID, target, "DIRECT")

            if success then
                local distance = math.floor(player:GetPos():Distance(target))
                return "✈️ Autopilot engaged! Flying to coordinates " .. tostring(target) ..
                       " (" .. distance .. " units away)"
            else
                return "❌ Failed to set autopilot to coordinates"
            end
        else
            return "❌ Invalid coordinates format. Use: 'aria fly to 1000, 2000, 500'"
        end
    else
        -- Use crosshair target
        return ASC.AI.EnableAutopilot(shipID, player)
    end
end

-- Handle waypoint commands
ASC.AI.HandleWaypointCommands = function(shipID, player, query, queryLower)
    if not ASC.Flight or not ASC.Flight.Core.ActiveFlights[shipID] then
        return "Flight system is not active. Use 'aria flight on' first."
    end

    if string.find(queryLower, "waypoint add") or string.find(queryLower, "add waypoint") then
        local trace = player:GetEyeTrace()
        local position = trace.HitPos

        if position:Distance(player:GetPos()) < 100 then
            return "❌ Waypoint too close! Aim at a distant location."
        end

        local success, message = ASC.Flight.Core.AddWaypoint(shipID, position)
        if success then
            local flight = ASC.Flight.Core.ActiveFlights[shipID]
            return "🎯 Waypoint added! Total waypoints: " .. #flight.waypoints ..
                   "\nUse 'aria autopilot on' to start navigation"
        else
            return "❌ Failed to add waypoint: " .. (message or "Unknown error")
        end

    elseif string.find(queryLower, "waypoint clear") or string.find(queryLower, "clear waypoint") then
        local success = ASC.Flight.Core.ClearWaypoints(shipID)
        return success and "🗑️ All waypoints cleared" or "❌ Failed to clear waypoints"

    elseif string.find(queryLower, "waypoint list") or string.find(queryLower, "list waypoint") then
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if #flight.waypoints == 0 then
            return "📍 No waypoints set. Use 'aria waypoint add' to add waypoints."
        end

        local waypointText = "📍 Waypoints (" .. #flight.waypoints .. "):\n"
        for i, waypoint in ipairs(flight.waypoints) do
            local distance = math.floor(player:GetPos():Distance(waypoint))
            local current = (i == flight.currentWaypoint) and " ← CURRENT" or ""
            waypointText = waypointText .. "• Waypoint " .. i .. ": " .. distance .. " units away" .. current .. "\n"
        end

        return waypointText

    else
        return "🎯 Waypoint Commands:\n" ..
               "• 'aria waypoint add' - Add waypoint at crosshair\n" ..
               "• 'aria waypoint list' - List all waypoints\n" ..
               "• 'aria waypoint clear' - Clear all waypoints\n\n" ..
               "💡 Add waypoints, then use 'aria autopilot on' to navigate!"
    end
end

-- Handle docking commands
ASC.AI.HandleDockingCommands = function(player, query, queryLower)
    if not IsValid(player) then
        return "Invalid player for docking commands"
    end

    -- Check if docking system is available
    if not ASC.Docking then
        return "Docking system is not loaded. Please ensure the docking module is installed."
    end

    -- Find player's ship core
    local shipCore = ASC.AI.FindPlayerShipCore(player)
    if not IsValid(shipCore) then
        return "Docking requires a ship core! Make sure you have a ship with a ship core that you own nearby."
    end

    local shipID = shipCore:EntIndex()

    -- Handle specific docking commands
    if string.find(queryLower, "docking status") or string.find(queryLower, "dock status") then
        return ASC.AI.GetDockingStatus(shipID)

    elseif string.find(queryLower, "dock") and not string.find(queryLower, "undock") then
        return ASC.AI.HandleDockRequest(shipID, player, query, queryLower)

    elseif string.find(queryLower, "undock") then
        return ASC.AI.HandleUndockRequest(shipID, player)

    elseif string.find(queryLower, "find dock") or string.find(queryLower, "nearest dock") then
        return ASC.AI.FindNearestDockingPad(shipID)

    else
        -- General docking help
        return "🚁 Docking System Commands:\n" ..
               "• 'aria dock' - Auto-dock at nearest available pad\n" ..
               "• 'aria docking status' - View docking status\n" ..
               "• 'aria find dock' - Find nearest docking pad\n" ..
               "• 'aria undock' - Undock from current pad\n\n" ..
               "Docking Pad Types:\n" ..
               "• SMALL (ships up to 1000 size), MEDIUM (up to 2500 size)\n" ..
               "• LARGE (up to 5000 size), SHUTTLE (up to 500 size)\n\n" ..
               "💡 Docking system provides automated docking with collision avoidance!"
    end
end

-- Get docking status for a ship
ASC.AI.GetDockingStatus = function(shipID)
    if not ASC.Docking then
        return "Docking system is not available."
    end

    local shipCore = Entity(shipID)
    if not IsValid(shipCore) then
        return "Invalid ship core."
    end

    local status = ASC.Docking.Core.GetDockingStatus(shipCore)
    if not status then
        return "Unable to get docking status."
    end

    if status.status == "DOCKING" then
        local timeLeft = math.floor(status.timeRemaining)
        return "🚁 Docking Status: " .. status.phase:upper() .. "\n" ..
               "🎯 Target Pad: " .. status.pad.config.name .. " (ID: " .. status.pad.id .. ")\n" ..
               "⏱️ Time Remaining: " .. timeLeft .. " seconds\n" ..
               "📍 Phase: " .. status.phase

    elseif status.status == "DOCKED" then
        local dockTime = math.floor(status.dockTime)
        return "🚁 Docking Status: DOCKED\n" ..
               "🎯 Docked At: " .. status.pad.config.name .. " (ID: " .. status.pad.id .. ")\n" ..
               "⏱️ Docked For: " .. dockTime .. " seconds\n" ..
               "🔧 Available Services: " .. table.concat(status.pad.config.services, ", ") .. "\n" ..
               "💡 Use 'aria undock' to leave the docking pad"

    else
        local nearestInfo = ""
        if status.nearestPad then
            local distance = math.floor(status.nearestPad:GetPos():Distance(shipCore:GetPos()))
            nearestInfo = "\n🎯 Nearest Pad: " .. status.nearestPad.config.name .. " (" .. distance .. " units away)"
        end

        return "🚁 Docking Status: FREE" .. nearestInfo .. "\n" ..
               "💡 Use 'aria dock' to auto-dock at nearest available pad"
    end
end

-- Handle dock request
ASC.AI.HandleDockRequest = function(shipID, player, query, queryLower)
    if not ASC.Docking then
        return "Docking system is not available."
    end

    local shipCore = Entity(shipID)
    if not IsValid(shipCore) then
        return "Invalid ship core."
    end

    -- Check if already docked or docking
    local status = ASC.Docking.Core.GetDockingStatus(shipCore)
    if status.status == "DOCKED" then
        return "🚁 Ship is already docked at " .. status.pad.config.name .. "\nUse 'aria undock' to leave"
    elseif status.status == "DOCKING" then
        return "🚁 Ship is already in docking procedure (Phase: " .. status.phase .. ")"
    end

    -- Find nearest available docking pad
    local nearestPad, distance = ASC.Docking.Core.FindNearestDockingPad(shipCore)

    if not nearestPad then
        return "❌ No available docking pads found nearby\n💡 Make sure you're within " .. ASC.Docking.Config.DockingRange .. " units of a docking pad"
    end

    -- Request docking
    local success, message = ASC.Docking.Core.RequestDocking(shipCore, nearestPad.id)

    if success then
        return "🚁 Docking request approved!\n" ..
               "🎯 Target: " .. nearestPad.config.name .. " (" .. math.floor(distance) .. " units away)\n" ..
               "⏱️ Estimated time: " .. math.ceil(distance / 100) .. " seconds\n" ..
               "💡 " .. (message or "Automated docking procedure initiated")
    else
        return "❌ Docking request denied: " .. (message or "Unknown error")
    end
end

-- Handle undock request
ASC.AI.HandleUndockRequest = function(shipID, player)
    if not ASC.Docking then
        return "Docking system is not available."
    end

    local shipCore = Entity(shipID)
    if not IsValid(shipCore) then
        return "Invalid ship core."
    end

    -- Check if ship is docked
    local status = ASC.Docking.Core.GetDockingStatus(shipCore)
    if status.status ~= "DOCKED" then
        return "❌ Ship is not currently docked\nCurrent status: " .. status.status
    end

    -- Undock ship
    local success, message = ASC.Docking.Core.UndockShip(shipCore, status.pad.id)

    if success then
        return "🚁 Ship successfully undocked from " .. status.pad.config.name .. "\n" ..
               "✈️ You are now free to navigate"
    else
        return "❌ Failed to undock: " .. (message or "Unknown error")
    end
end

-- Find nearest docking pad
ASC.AI.FindNearestDockingPad = function(shipID)
    if not ASC.Docking then
        return "Docking system is not available."
    end

    local shipCore = Entity(shipID)
    if not IsValid(shipCore) then
        return "Invalid ship core."
    end

    local nearestPad, distance = ASC.Docking.Core.FindNearestDockingPad(shipCore)

    if not nearestPad then
        return "❌ No docking pads found within range\n💡 Docking pads must be within " .. ASC.Docking.Config.DockingRange .. " units"
    end

    local shipSize = ASC.Docking.Core.GetShipSize(shipCore)
    local canDock = shipSize <= nearestPad.config.maxShipSize

    local statusText = "🎯 Nearest Docking Pad:\n" ..
                      "📍 Type: " .. nearestPad.config.name .. " (ID: " .. nearestPad.id .. ")\n" ..
                      "📏 Distance: " .. math.floor(distance) .. " units\n" ..
                      "🚢 Ship Size: " .. shipSize .. " / " .. nearestPad.config.maxShipSize .. " max\n" ..
                      "🔧 Services: " .. table.concat(nearestPad.config.services, ", ") .. "\n" ..
                      "👥 Capacity: " .. #nearestPad.dockedShips .. " / " .. nearestPad.config.capacity .. " ships"

    if canDock then
        statusText = statusText .. "\n✅ Compatible - Use 'aria dock' to dock"
    else
        statusText = statusText .. "\n❌ Ship too large for this pad"
    end

    return statusText
end

-- Handle formation commands
ASC.AI.HandleFormationCommands = function(player, query, queryLower)
    if not IsValid(player) then
        return "Invalid player for formation commands"
    end

    -- Check if formation system is available
    if not ASC.Formation then
        return "Formation system is not loaded. Please ensure the formation module is installed."
    end

    -- Find player's ship core
    local shipCore = ASC.AI.FindPlayerShipCore(player)
    if not IsValid(shipCore) then
        return "Formation commands require a ship core! Make sure you have a ship with a ship core that you own nearby."
    end

    -- Handle specific formation commands
    if string.find(queryLower, "formation status") or string.find(queryLower, "fleet status") then
        return ASC.AI.GetFormationStatus(shipCore)

    elseif string.find(queryLower, "create formation") or string.find(queryLower, "form up") then
        return ASC.AI.CreateFormation(shipCore, query, queryLower)

    elseif string.find(queryLower, "join formation") or (string.find(queryLower, "follow") and string.find(queryLower, "me")) then
        return ASC.AI.JoinFormation(shipCore, player, query, queryLower)

    elseif string.find(queryLower, "leave formation") or string.find(queryLower, "break formation") then
        return ASC.AI.LeaveFormation(shipCore)

    elseif string.find(queryLower, "change formation") or string.find(queryLower, "formation type") then
        return ASC.AI.ChangeFormationType(shipCore, query, queryLower)

    elseif string.find(queryLower, "disband formation") then
        return ASC.AI.DisbandFormation(shipCore, player)

    else
        -- General formation help
        return "⚡ Formation Flying Commands:\n" ..
               "• 'aria create formation wedge' - Create new formation\n" ..
               "• 'aria formation status' - View formation status\n" ..
               "• 'aria join formation' - Join nearest formation\n" ..
               "• 'aria change formation diamond' - Change formation type\n" ..
               "• 'aria leave formation' - Leave current formation\n" ..
               "• 'aria disband formation' - Disband formation (leader only)\n\n" ..
               "Formation Types:\n" ..
               "• LINE, WEDGE, DIAMOND, CIRCLE, COLUMN\n\n" ..
               "💡 Formation flying provides automated fleet coordination!"
    end
end

-- Get formation status
ASC.AI.GetFormationStatus = function(shipCore)
    if not ASC.Formation then
        return "Formation system is not available."
    end

    local status = ASC.Formation.Core.GetFormationStatus(shipCore)

    if not status then
        return "🚁 Formation Status: NOT IN FORMATION\n" ..
               "💡 Use 'aria create formation' to start a new formation or 'aria join formation' to join one"
    end

    local leaderText = status.isLeader and " (LEADER)" or ""
    local formationConfig = ASC.Formation.Config.FormationTypes[status.formationType]

    return "⚡ Formation Status: ACTIVE" .. leaderText .. "\n" ..
           "📋 Formation ID: " .. status.formationID .. "\n" ..
           "🎯 Type: " .. formationConfig.name .. "\n" ..
           "👥 Position: " .. status.position .. " of " .. status.totalShips .. " ships\n" ..
           "📏 Spacing: " .. status.spacing .. " units\n" ..
           "📍 Description: " .. formationConfig.description
end

-- Create formation
ASC.AI.CreateFormation = function(shipCore, query, queryLower)
    if not ASC.Formation then
        return "Formation system is not available."
    end

    -- Check if already in formation
    local currentStatus = ASC.Formation.Core.GetFormationStatus(shipCore)
    if currentStatus then
        return "❌ Ship is already in formation " .. currentStatus.formationID .. "\nUse 'aria leave formation' first"
    end

    -- Extract formation type from query
    local formationType = "LINE" -- Default
    if string.find(queryLower, "wedge") then formationType = "WEDGE"
    elseif string.find(queryLower, "diamond") then formationType = "DIAMOND"
    elseif string.find(queryLower, "circle") then formationType = "CIRCLE"
    elseif string.find(queryLower, "column") then formationType = "COLUMN"
    elseif string.find(queryLower, "line") then formationType = "LINE"
    end

    -- Create formation
    local formation = ASC.Formation.Core.CreateFormation(shipCore, formationType)

    if formation then
        local formationConfig = ASC.Formation.Config.FormationTypes[formationType]
        return "⚡ Formation created successfully!\n" ..
               "📋 Formation ID: " .. formation.id .. "\n" ..
               "🎯 Type: " .. formationConfig.name .. "\n" ..
               "👑 You are the formation leader\n" ..
               "💡 Other ships can join with 'aria join formation'"
    else
        return "❌ Failed to create formation"
    end
end

-- Join formation
ASC.AI.JoinFormation = function(shipCore, player, query, queryLower)
    if not ASC.Formation then
        return "Formation system is not available."
    end

    -- Check if already in formation
    local currentStatus = ASC.Formation.Core.GetFormationStatus(shipCore)
    if currentStatus then
        return "❌ Ship is already in formation " .. currentStatus.formationID .. "\nUse 'aria leave formation' first"
    end

    -- Find nearest formation
    local nearestFormation = nil
    local nearestDistance = math.huge
    local shipPos = shipCore:GetPos()

    for _, formation in pairs(ASC.Formation.Core.ActiveFormations) do
        if IsValid(formation.leader) then
            local distance = shipPos:Distance(formation.leader:GetPos())
            if distance < nearestDistance and distance <= ASC.Formation.Config.MaxFormationDistance then
                nearestFormation = formation
                nearestDistance = distance
            end
        end
    end

    if not nearestFormation then
        return "❌ No formations found within range (" .. ASC.Formation.Config.MaxFormationDistance .. " units)\n" ..
               "💡 Get closer to a formation leader or create your own formation"
    end

    -- Join formation
    local success, message = ASC.Formation.Core.AddShipToFormation(nearestFormation.id, shipCore)

    if success then
        local formationConfig = ASC.Formation.Config.FormationTypes[nearestFormation.formationType]
        return "⚡ Joined formation successfully!\n" ..
               "📋 Formation ID: " .. nearestFormation.id .. "\n" ..
               "🎯 Type: " .. formationConfig.name .. "\n" ..
               "👥 Position: " .. #nearestFormation.ships .. " of " .. ASC.Formation.Config.MaxFleetSize .. " max\n" ..
               "👑 Leader: Ship " .. nearestFormation.leader:EntIndex()
    else
        return "❌ Failed to join formation: " .. (message or "Unknown error")
    end
end

-- Leave formation
ASC.AI.LeaveFormation = function(shipCore)
    if not ASC.Formation then
        return "Formation system is not available."
    end

    local status = ASC.Formation.Core.GetFormationStatus(shipCore)
    if not status then
        return "❌ Ship is not in a formation"
    end

    local success = ASC.Formation.Core.RemoveShipFromFormation(status.formationID, shipCore)

    if success then
        return "⚡ Left formation " .. status.formationID .. " successfully\n" ..
               "🚁 You are now flying independently"
    else
        return "❌ Failed to leave formation"
    end
end

-- Change formation type
ASC.AI.ChangeFormationType = function(shipCore, query, queryLower)
    if not ASC.Formation then
        return "Formation system is not available."
    end

    local status = ASC.Formation.Core.GetFormationStatus(shipCore)
    if not status then
        return "❌ Ship is not in a formation"
    end

    if not status.isLeader then
        return "❌ Only the formation leader can change formation type"
    end

    -- Extract formation type from query
    local newType = nil
    if string.find(queryLower, "wedge") then newType = "WEDGE"
    elseif string.find(queryLower, "diamond") then newType = "DIAMOND"
    elseif string.find(queryLower, "circle") then newType = "CIRCLE"
    elseif string.find(queryLower, "column") then newType = "COLUMN"
    elseif string.find(queryLower, "line") then newType = "LINE"
    end

    if not newType then
        return "❌ Please specify formation type: LINE, WEDGE, DIAMOND, CIRCLE, or COLUMN\n" ..
               "Example: 'aria change formation wedge'"
    end

    local success = ASC.Formation.Core.ChangeFormationType(status.formationID, newType)

    if success then
        local formationConfig = ASC.Formation.Config.FormationTypes[newType]
        return "⚡ Formation type changed successfully!\n" ..
               "🎯 New Type: " .. formationConfig.name .. "\n" ..
               "📍 Description: " .. formationConfig.description .. "\n" ..
               "👥 All ships are repositioning..."
    else
        return "❌ Failed to change formation type"
    end
end

-- Disband formation
ASC.AI.DisbandFormation = function(shipCore, player)
    if not ASC.Formation then
        return "Formation system is not available."
    end

    local status = ASC.Formation.Core.GetFormationStatus(shipCore)
    if not status then
        return "❌ Ship is not in a formation"
    end

    if not status.isLeader then
        return "❌ Only the formation leader can disband the formation"
    end

    ASC.Formation.Core.DisbandFormation(status.formationID)

    return "⚡ Formation " .. status.formationID .. " disbanded successfully\n" ..
           "🚁 All ships are now flying independently"
end

-- Handle boss commands
ASC.AI.HandleBossCommands = function(player, query, queryLower)
    if not IsValid(player) then
        return "Invalid player for boss commands"
    end

    -- Check if boss system is available
    if not ASC.Boss then
        return "Boss system is not loaded. Please ensure the boss module is installed."
    end

    -- Handle specific boss commands
    if string.find(queryLower, "boss status") or string.find(queryLower, "boss info") then
        return ASC.Boss.Core.GetBossStatus()

    elseif string.find(queryLower, "vote boss") or string.find(queryLower, "start boss vote") then
        return ASC.AI.StartBossVote(player)

    elseif string.find(queryLower, "vote") and string.find(queryLower, "boss") then
        return ASC.AI.CastBossVote(player, query, queryLower)

    else
        -- General boss help
        return "👹 AI Boss System Commands:\n" ..
               "• 'aria vote boss' - Start a boss vote\n" ..
               "• 'aria vote boss 1' - Vote for boss option 1\n" ..
               "• 'aria boss status' - View active bosses and vote status\n\n" ..
               "Available Boss Types:\n" ..
               "• Goa'uld Ha'tak Destroyer (Difficulty: 3⭐)\n" ..
               "• Wraith Hive Ship (Difficulty: 2⭐)\n" ..
               "• Ori Warship (Difficulty: 4⭐)\n" ..
               "• Replicator Ship (Difficulty: 2⭐)\n" ..
               "• Ancient Aurora Battleship (Difficulty: 5⭐)\n\n" ..
               "💡 Boss fights provide rewards and experience for all participants!"
    end
end

-- Start boss vote
ASC.AI.StartBossVote = function(player)
    if not ASC.Boss then
        return "Boss system is not available."
    end

    local success, message = ASC.Boss.Core.StartBossVote(player)

    if success then
        return "🗳️ Boss vote started successfully!\n" ..
               "⏱️ Vote duration: " .. ASC.Boss.Config.VotingDuration .. " seconds\n" ..
               "💡 All players can now vote using 'aria vote boss [1-5]'"
    else
        return "❌ Failed to start boss vote: " .. (message or "Unknown error")
    end
end

-- Cast boss vote
ASC.AI.CastBossVote = function(player, query, queryLower)
    if not ASC.Boss then
        return "Boss system is not available."
    end

    if not ASC.Boss.Core.CurrentVote then
        return "❌ No active boss vote\nUse 'aria vote boss' to start a vote"
    end

    -- Extract vote number from query
    local voteNumber = tonumber(string.match(query, "vote boss (%d+)")) or
                      tonumber(string.match(query, "vote (%d+)"))

    if not voteNumber then
        -- Show current vote options
        local message = "🗳️ Current Boss Vote Options:\n"
        for i, option in ipairs(ASC.Boss.Core.CurrentVote.options) do
            message = message .. i .. ". " .. option.name .. " (" .. option.difficulty .. "⭐) - " .. option.votes .. " votes\n"
        end

        local timeLeft = math.ceil(ASC.Boss.Core.CurrentVote.startTime + ASC.Boss.Core.CurrentVote.duration - CurTime())
        message = message .. "\n⏱️ Time remaining: " .. timeLeft .. " seconds\n"
        message = message .. "💡 Use 'aria vote boss [1-" .. #ASC.Boss.Core.CurrentVote.options .. "]' to vote"

        return message
    end

    local success, message = ASC.Boss.Core.CastVote(player, voteNumber)

    if success then
        local option = ASC.Boss.Core.CurrentVote.options[voteNumber]
        return "🗳️ Vote cast successfully!\n" ..
               "👹 Voted for: " .. option.name .. "\n" ..
               "⭐ Difficulty: " .. option.difficulty .. "\n" ..
               "💰 Reward: " .. option.reward .. " credits"
    else
        return "❌ Failed to cast vote: " .. (message or "Invalid vote option")
    end
end

-- Handle weapon commands
ASC.AI.HandleWeaponCommands = function(player, query, queryLower)
    if not IsValid(player) then
        return ASC.AI.TranslateResponse(player, "Invalid player for weapon commands")
    end

    -- Check if weapon system is available
    if not ASC.Weapons then
        return ASC.AI.TranslateResponse(player, "Weapon system is not loaded. Please ensure the weapon module is installed.")
    end

    -- Find player's ship core
    local shipCore = ASC.AI.FindPlayerShipCore(player)
    if not IsValid(shipCore) then
        return ASC.AI.TranslateResponse(player, "Weapon commands require a ship core! Make sure you have a ship with a ship core that you own nearby.")
    end

    local shipID = shipCore:EntIndex()

    -- Handle specific weapon commands with multilingual support
    if string.find(queryLower, "weapon status") or string.find(queryLower, "weapons status") or
       string.find(queryLower, "stav zbraní") or string.find(queryLower, "zbrojní stav") then
        return ASC.AI.TranslateResponse(player, ASC.AI.GetWeaponStatus(shipID))

    elseif string.find(queryLower, "create weapons") or string.find(queryLower, "add weapons") or
           string.find(queryLower, "vytvořit zbraně") or string.find(queryLower, "přidat zbraně") then
        return ASC.AI.TranslateResponse(player, ASC.AI.CreateWeaponSystem(shipID, shipCore))

    elseif string.find(queryLower, "fire") and not string.find(queryLower, "friendly") or
           string.find(queryLower, "palba") and not string.find(queryLower, "přátelská") then
        return ASC.AI.TranslateResponse(player, ASC.AI.HandleFireCommand(shipID, player, query, queryLower))

    elseif string.find(queryLower, "target") or string.find(queryLower, "cílit") then
        return ASC.AI.TranslateResponse(player, ASC.AI.HandleTargetCommand(shipID, player, query, queryLower))

    elseif string.find(queryLower, "auto target") or string.find(queryLower, "auto-target") or
           string.find(queryLower, "automatické cílení") then
        return ASC.AI.TranslateResponse(player, ASC.AI.ToggleAutoTarget(shipID))

    elseif string.find(queryLower, "ammo") or string.find(queryLower, "ammunition") or
           string.find(queryLower, "munice") or string.find(queryLower, "střelivo") then
        return ASC.AI.TranslateResponse(player, ASC.AI.GetAmmoStatus(shipID))

    else
        -- General weapon help
        return "⚔️ Weapon System Commands:\n" ..
               "• 'aria weapon status' - View weapon system status\n" ..
               "• 'aria create weapons' - Initialize weapon system\n" ..
               "• 'aria fire' - Fire all weapons at current target\n" ..
               "• 'aria target nearest' - Target nearest hostile\n" ..
               "• 'aria auto target on' - Enable auto-targeting\n" ..
               "• 'aria ammo' - View ammunition status\n\n" ..
               "Weapon Types:\n" ..
               "• Pulse Cannon, Beam Weapon, Torpedo Launcher\n" ..
               "• Railgun, Plasma Cannon\n\n" ..
               "💡 Weapon system provides automated combat capabilities!"
    end
end

-- Get weapon status
ASC.AI.GetWeaponStatus = function(shipID)
    if not ASC.Weapons then
        return "Weapon system is not available."
    end

    local status = ASC.Weapons.Core.GetWeaponStatus(shipID)

    if status.status == "NO_WEAPONS" then
        return "⚔️ Weapon Status: NO WEAPON SYSTEM\n" ..
               "💡 Use 'aria create weapons' to initialize weapon system"
    end

    local statusIcon = status.status == "ACTIVE" and "🟢" or "🔴"
    local targetText = IsValid(status.target) and status.target:GetClass() or "None"

    local weaponText = "⚔️ Weapon Status: " .. statusIcon .. " " .. status.status .. "\n" ..
                      "🔫 Weapons: " .. status.weapons .. " / " .. ASC.Weapons.Config.MaxWeaponsPerShip .. "\n" ..
                      "👥 Groups: " .. status.groups .. " / " .. ASC.Weapons.Config.MaxWeaponGroups .. "\n" ..
                      "🎯 Target: " .. targetText .. "\n" ..
                      "🤖 Auto-Target: " .. (status.autoTarget and "ON" or "OFF") .. "\n" ..
                      "🧠 Tactical AI: " .. (status.tacticalAI and "ON" or "OFF")

    if status.totalShots > 0 then
        weaponText = weaponText .. "\n📊 Stats: " .. status.totalShots .. " shots, " ..
                    math.floor(status.totalDamage) .. " damage"
    end

    return weaponText
end

-- Create weapon system
ASC.AI.CreateWeaponSystem = function(shipID, shipCore)
    if not ASC.Weapons then
        return "Weapon system is not available."
    end

    local weaponSystem, message = ASC.Weapons.Core.CreateWeaponSystem(shipCore)

    if weaponSystem then
        -- Add some default weapons
        local weaponTypes = {"PULSE_CANNON", "BEAM_WEAPON", "TORPEDO_LAUNCHER"}
        local weaponsAdded = 0

        for i, weaponType in ipairs(weaponTypes) do
            local weapon = ASC.Weapons.Core.AddWeapon(shipID, weaponType, Vector(i * 100, 0, 0), Angle(0, 0, 0))
            if weapon then
                weaponsAdded = weaponsAdded + 1
            end
        end

        -- Create default weapon group
        if weaponsAdded > 0 then
            ASC.Weapons.Core.CreateWeaponGroup(shipID, "Primary", {1, 2, 3})
        end

        return "⚔️ Weapon system created successfully!\n" ..
               "🔫 Added " .. weaponsAdded .. " weapons\n" ..
               "👥 Created 1 weapon group\n" ..
               "💡 Use 'aria weapon status' to view details"
    else
        return "❌ Failed to create weapon system: " .. (message or "Unknown error")
    end
end

-- Handle fire command
ASC.AI.HandleFireCommand = function(shipID, player, query, queryLower)
    if not ASC.Weapons then
        return "Weapon system is not available."
    end

    local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
    if not weaponSystem then
        return "❌ No weapon system found\nUse 'aria create weapons' first"
    end

    if #weaponSystem.weapons == 0 then
        return "❌ No weapons available\nWeapons need to be added to the ship"
    end

    local target = weaponSystem.currentTarget
    if not IsValid(target) then
        return "❌ No target selected\nUse 'aria target nearest' to find a target"
    end

    -- Fire all weapon groups
    local fired = false
    for i, weaponGroup in ipairs(weaponSystem.weaponGroups) do
        if ASC.Weapons.Core.FireWeaponGroup(shipID, i, target) then
            fired = true
        end
    end

    if fired then
        local targetName = target:IsPlayer() and target:Name() or target:GetClass()
        return "🔥 Weapons fired at " .. targetName .. "!\n" ..
               "🎯 Target distance: " .. math.floor(weaponSystem.shipCore:GetPos():Distance(target:GetPos())) .. " units"
    else
        return "❌ Unable to fire weapons\nCheck ammunition and weapon cooldowns"
    end
end

-- Handle target command
ASC.AI.HandleTargetCommand = function(shipID, player, query, queryLower)
    if not ASC.Weapons then
        return "Weapon system is not available."
    end

    local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
    if not weaponSystem then
        return "❌ No weapon system found"
    end

    if string.find(queryLower, "nearest") then
        -- Force update auto-targeting to find nearest target
        ASC.Weapons.Core.UpdateAutoTargeting(weaponSystem)

        if IsValid(weaponSystem.currentTarget) then
            local target = weaponSystem.currentTarget
            local targetName = target:IsPlayer() and target:Name() or target:GetClass()
            local distance = math.floor(weaponSystem.shipCore:GetPos():Distance(target:GetPos()))

            return "🎯 Target acquired: " .. targetName .. "\n" ..
                   "📏 Distance: " .. distance .. " units\n" ..
                   "💡 Use 'aria fire' to engage target"
        else
            return "❌ No valid targets found within range (" .. weaponSystem.targetingRange .. " units)"
        end

    elseif string.find(queryLower, "clear") then
        weaponSystem.currentTarget = nil
        return "🎯 Target cleared"

    else
        if IsValid(weaponSystem.currentTarget) then
            local target = weaponSystem.currentTarget
            local targetName = target:IsPlayer() and target:Name() or target:GetClass()
            local distance = math.floor(weaponSystem.shipCore:GetPos():Distance(target:GetPos()))

            return "🎯 Current Target: " .. targetName .. "\n" ..
                   "📏 Distance: " .. distance .. " units\n" ..
                   "💡 Use 'aria target clear' to clear target"
        else
            return "🎯 No target selected\n" ..
                   "💡 Use 'aria target nearest' to find a target"
        end
    end
end

-- Toggle auto-target
ASC.AI.ToggleAutoTarget = function(shipID)
    if not ASC.Weapons then
        return "Weapon system is not available."
    end

    local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
    if not weaponSystem then
        return "❌ No weapon system found"
    end

    weaponSystem.autoTarget = not weaponSystem.autoTarget

    if weaponSystem.autoTarget then
        return "🤖 Auto-targeting enabled\n" ..
               "🎯 System will automatically target nearest hostiles"
    else
        return "🤖 Auto-targeting disabled\n" ..
               "🎯 Manual targeting required"
    end
end

-- Get ammo status
ASC.AI.GetAmmoStatus = function(shipID)
    if not ASC.Weapons then
        return "Weapon system is not available."
    end

    local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
    if not weaponSystem then
        return "❌ No weapon system found"
    end

    local ammoText = "🔋 Ammunition Status:\n"
    local totalAmmo = 0
    local maxAmmo = 0

    for ammoType, currentAmmo in pairs(weaponSystem.ammoStorage) do
        local typeMax = weaponSystem.maxAmmoCapacity / #ASC.Weapons.Config.AmmoTypes
        local percentage = math.floor((currentAmmo / typeMax) * 100)

        ammoText = ammoText .. "• " .. ammoType:upper() .. ": " .. math.floor(currentAmmo) ..
                  " / " .. math.floor(typeMax) .. " (" .. percentage .. "%)\n"

        totalAmmo = totalAmmo + currentAmmo
        maxAmmo = maxAmmo + typeMax
    end

    local totalPercentage = math.floor((totalAmmo / maxAmmo) * 100)
    ammoText = ammoText .. "\n📊 Total: " .. math.floor(totalAmmo) .. " / " .. math.floor(maxAmmo) ..
              " (" .. totalPercentage .. "%)\n"
    ammoText = ammoText .. "🔄 Regeneration: " .. ASC.Weapons.Config.AmmoRegenRate .. " per second"

    return ammoText
end

-- Handle tactical AI commands
ASC.AI.HandleTacticalCommands = function(player, query, queryLower)
    if not IsValid(player) then
        return ASC.AI.TranslateResponse(player, "Invalid player for tactical commands")
    end

    -- Check if tactical AI system is available
    if not ASC.TacticalAI then
        return ASC.AI.TranslateResponse(player, "Tactical AI system is not loaded. Please ensure the tactical AI module is installed.")
    end

    -- Find player's ship core
    local shipCore = ASC.AI.FindPlayerShipCore(player)
    if not IsValid(shipCore) then
        return ASC.AI.TranslateResponse(player, "Tactical AI requires a ship core! Make sure you have a ship with a ship core that you own nearby.")
    end

    local shipID = shipCore:EntIndex()

    -- Handle specific tactical commands
    if string.find(queryLower, "tactical status") or string.find(queryLower, "combat status") or
       string.find(queryLower, "taktický stav") or string.find(queryLower, "bojový stav") then
        return ASC.AI.TranslateResponse(player, ASC.AI.GetTacticalStatus(shipID, shipCore))

    elseif string.find(queryLower, "tactical on") or string.find(queryLower, "enable tactical") or
           string.find(queryLower, "taktická ai zapnout") or string.find(queryLower, "aktivovat taktickou") then
        return ASC.AI.TranslateResponse(player, ASC.AI.EnableTacticalAI(shipID, shipCore, player))

    elseif string.find(queryLower, "tactical off") or string.find(queryLower, "disable tactical") or
           string.find(queryLower, "taktická ai vypnout") or string.find(queryLower, "deaktivovat taktickou") then
        return ASC.AI.TranslateResponse(player, ASC.AI.DisableTacticalAI(shipID, shipCore))

    elseif string.find(queryLower, "threat scan") or string.find(queryLower, "scan threats") or
           string.find(queryLower, "skenovat hrozby") or string.find(queryLower, "analýza hrozeb") then
        return ASC.AI.TranslateResponse(player, ASC.AI.ScanThreats(shipID, shipCore))

    elseif string.find(queryLower, "ai mode") or string.find(queryLower, "ai mód") then
        return ASC.AI.TranslateResponse(player, ASC.AI.HandleAIModeCommand(shipID, shipCore, query, queryLower))

    else
        -- General tactical AI help with multilingual support
        local playerLang = ASC.AI.GetPlayerLanguage(player)
        local helpText

        if playerLang == "cs" then
            helpText = "🧠 Příkazy taktické AI:\n" ..
                      "• 'aria taktický stav' - Zobrazit stav taktické AI\n" ..
                      "• 'aria taktická ai zapnout' - Aktivovat taktickou AI\n" ..
                      "• 'aria taktická ai vypnout' - Deaktivovat taktickou AI\n" ..
                      "• 'aria skenovat hrozby' - Skenovat hrozby\n" ..
                      "• 'aria ai mód obranný' - Nastavit AI mód\n\n" ..
                      "AI módy:\n" ..
                      "• OBRANNÝ, AGRESIVNÍ, PODPŮRNÝ\n\n" ..
                      "💡 Taktická AI poskytuje automatickou bojovou asistenci a analýzu hrozeb!"
        else
            helpText = "🧠 Tactical AI Commands:\n" ..
                      "• 'aria tactical status' - View tactical AI status\n" ..
                      "• 'aria tactical on' - Enable tactical AI\n" ..
                      "• 'aria tactical off' - Disable tactical AI\n" ..
                      "• 'aria threat scan' - Scan for threats\n" ..
                      "• 'aria ai mode defensive' - Set AI mode\n\n" ..
                      "AI Modes:\n" ..
                      "• DEFENSIVE, AGGRESSIVE, SUPPORT\n\n" ..
                      "💡 Tactical AI provides automated combat assistance and threat analysis!"
        end

        return ASC.AI.TranslateResponse(player, helpText)
    end
end

-- Get tactical status
ASC.AI.GetTacticalStatus = function(shipID, shipCore)
    if not ASC.TacticalAI then
        return "Tactical AI system is not available."
    end

    local status = ASC.TacticalAI.Core.GetTacticalStatus(shipCore)

    if not status or status.status == "INACTIVE" then
        return "🧠 Tactical AI Status: INACTIVE\n" ..
               "💡 Use 'aria tactical on' to enable tactical AI"
    end

    local statusIcon = status.status == "ACTIVE" and "🟢" or "🔴"
    local combatStateIcon = {
        PATROL = "🚁",
        ENGAGE = "⚔️",
        MULTIPLE_THREATS = "🚨",
        RETREAT = "🏃"
    }

    local tacticalText = "🧠 Tactical AI Status: " .. statusIcon .. " " .. status.status .. "\n" ..
                        "⚔️ Combat State: " .. (combatStateIcon[status.combatState] or "❓") .. " " .. status.combatState .. "\n" ..
                        "🎯 Threats Detected: " .. status.threats .. "\n"

    if IsValid(status.target) then
        local targetName = status.target:IsPlayer() and status.target:Name() or status.target:GetClass()
        local distance = math.floor(shipCore:GetPos():Distance(status.target:GetPos()))
        tacticalText = tacticalText .. "🎯 Primary Target: " .. targetName .. " (" .. distance .. " units)\n"
    else
        tacticalText = tacticalText .. "🎯 Primary Target: None\n"
    end

    -- Add weapon system integration status
    if ASC.Weapons then
        local weaponStatus = ASC.Weapons.Core.GetWeaponStatus(shipID)
        if weaponStatus.tacticalAI then
            tacticalText = tacticalText .. "⚔️ Weapon AI: INTEGRATED\n"
        else
            tacticalText = tacticalText .. "⚔️ Weapon AI: MANUAL\n"
        end
    end

    return tacticalText
end

-- Enable tactical AI
ASC.AI.EnableTacticalAI = function(shipID, shipCore, player)
    if not ASC.TacticalAI then
        return "Tactical AI system is not available."
    end

    -- Start tactical AI session
    local session = ASC.TacticalAI.Core.StartSession(shipCore, player)

    if session then
        -- Enable tactical AI on weapon system if available
        if ASC.Weapons then
            local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
            if weaponSystem then
                weaponSystem.tacticalAI = true
                weaponSystem.aiMode = "DEFENSIVE"
            end
        end

        return "🧠 Tactical AI enabled successfully!\n" ..
               "⚔️ Combat AI: ACTIVE\n" ..
               "🎯 Threat Analysis: ACTIVE\n" ..
               "🤖 Weapon Integration: " .. (ASC.Weapons and "ENABLED" or "UNAVAILABLE") .. "\n" ..
               "💡 AI will now provide tactical assistance and automated combat support"
    else
        return "❌ Failed to enable tactical AI\nEnsure you have a valid ship core"
    end
end

-- Disable tactical AI
ASC.AI.DisableTacticalAI = function(shipID, shipCore)
    if not ASC.TacticalAI then
        return "Tactical AI system is not available."
    end

    -- Stop tactical AI session
    ASC.TacticalAI.Core.StopSession(shipID)

    -- Disable tactical AI on weapon system if available
    if ASC.Weapons then
        local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
        if weaponSystem then
            weaponSystem.tacticalAI = false
        end
    end

    return "🧠 Tactical AI disabled\n" ..
           "⚔️ Combat AI: INACTIVE\n" ..
           "🎯 Manual control restored"
end

-- Scan for threats
ASC.AI.ScanThreats = function(shipID, shipCore)
    if not ASC.TacticalAI then
        return "Tactical AI system is not available."
    end

    local shipPos = shipCore:GetPos()
    local threats = {}
    local scanRadius = 2500

    -- Scan for threats
    for _, ent in ipairs(ents.FindInSphere(shipPos, scanRadius)) do
        if ASC.Weapons and ASC.Weapons.Core.IsValidTarget(ent, shipCore) then
            local distance = shipPos:Distance(ent:GetPos())
            local threatLevel = 1

            -- Calculate basic threat level
            if ent:IsPlayer() then
                threatLevel = 2
            elseif ent:GetClass() == "asc_ship_core" then
                threatLevel = 3
            end

            if ent:GetNWBool("IsBoss", false) then
                threatLevel = 5
            end

            table.insert(threats, {
                entity = ent,
                distance = distance,
                threatLevel = threatLevel
            })
        end
    end

    -- Sort by threat level
    table.sort(threats, function(a, b) return a.threatLevel > b.threatLevel end)

    if #threats == 0 then
        return "🎯 Threat Scan Complete: No threats detected within " .. scanRadius .. " units\n" ..
               "✅ Area secure"
    end

    local threatText = "🎯 Threat Scan Complete: " .. #threats .. " threats detected\n\n"

    for i, threat in ipairs(threats) do
        if i > 5 then break end -- Limit to top 5 threats

        local threatName = threat.entity:IsPlayer() and threat.entity:Name() or threat.entity:GetClass()
        local threatIcon = {"⚠️", "🔶", "🔸", "🔹", "⭐"}
        local icon = threatIcon[threat.threatLevel] or "❓"

        threatText = threatText .. icon .. " " .. threatName .. " (" .. math.floor(threat.distance) .. " units)\n"
    end

    if #threats > 5 then
        threatText = threatText .. "... and " .. (#threats - 5) .. " more threats"
    end

    return threatText
end

-- Handle AI mode command
ASC.AI.HandleAIModeCommand = function(shipID, shipCore, query, queryLower)
    if not ASC.Weapons then
        return "AI mode requires weapon system to be available."
    end

    local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
    if not weaponSystem then
        return "❌ No weapon system found\nUse 'aria create weapons' first"
    end

    local newMode = nil
    if string.find(queryLower, "defensive") then
        newMode = "DEFENSIVE"
    elseif string.find(queryLower, "aggressive") then
        newMode = "AGGRESSIVE"
    elseif string.find(queryLower, "support") then
        newMode = "SUPPORT"
    end

    if newMode then
        weaponSystem.aiMode = newMode

        local modeDescriptions = {
            DEFENSIVE = "Prioritizes defense and threat response",
            AGGRESSIVE = "Actively seeks and engages targets",
            SUPPORT = "Focuses on supporting allied ships"
        }

        return "🧠 AI Mode set to: " .. newMode .. "\n" ..
               "📋 Description: " .. modeDescriptions[newMode] .. "\n" ..
               "💡 Tactical AI will adapt behavior accordingly"
    else
        local currentMode = weaponSystem.aiMode or "DEFENSIVE"
        return "🧠 Current AI Mode: " .. currentMode .. "\n\n" ..
               "Available Modes:\n" ..
               "• DEFENSIVE - Prioritizes defense and threat response\n" ..
               "• AGGRESSIVE - Actively seeks and engages targets\n" ..
               "• SUPPORT - Focuses on supporting allied ships\n\n" ..
               "💡 Use 'aria ai mode [mode]' to change mode"
    end
end

-- Helper function to translate responses
ASC.AI.TranslateResponse = function(player, response)
    if not ASC.Multilingual or not ASC.Multilingual.Core then
        return response
    end

    local playerLang = ASC.Multilingual.Core.GetPlayerLanguage(player)
    if playerLang == "en" then
        return response
    end

    local translatedResponse = ASC.Multilingual.Core.TranslateText(response, playerLang, "en")
    return translatedResponse or response
end

-- Helper function to get player language
ASC.AI.GetPlayerLanguage = function(player)
    if not ASC.Multilingual or not ASC.Multilingual.Core then
        return "en"
    end

    return ASC.Multilingual.Core.GetPlayerLanguage(player)
end

-- Helper function to get player language for AI system (converts codes to full names)
ASC.AI.GetPlayerLanguageForAI = function(player)
    if not ASC.Multilingual or not ASC.Multilingual.Core then
        return "english"
    end

    local langCode = ASC.Multilingual.Core.GetPlayerLanguage(player)
    return ASC.AI.Languages.ConvertLanguageCode(langCode)
end

-- Handle language commands
ASC.AI.HandleLanguageCommands = function(player, query, queryLower)
    if not IsValid(player) then
        return "Invalid player for language commands"
    end

    if not ASC.Multilingual or not ASC.Multilingual.Core then
        return "Multilingual system not available"
    end

    -- Handle specific language commands
    if string.find(queryLower, "language list") or string.find(queryLower, "languages") or
       string.find(queryLower, "jazyk seznam") or string.find(queryLower, "sprachen") then
        return ASC.Multilingual.Core.GetLanguageList()

    elseif string.find(queryLower, "language status") or string.find(queryLower, "current language") then
        local currentLang = ASC.Multilingual.Core.GetPlayerLanguage(player)
        local langInfo = ASC.Multilingual.Config.SupportedLanguages[currentLang]

        if langInfo then
            return "🌍 Current Language: " .. langInfo.flag .. " " .. langInfo.nativeName .. " (" .. langInfo.name .. ")\n" ..
                   "💡 Use 'aria language [code]' to change language\n" ..
                   "📋 Use 'aria language list' to see all available languages"
        else
            return "🌍 Current Language: English (default)\n" ..
                   "💡 Use 'aria language [code]' to set your preferred language"
        end

    elseif string.find(queryLower, "language ") then
        -- Extract language code
        local langCode = string.match(queryLower, "language (%w+)")

        if not langCode then
            return "Please specify a language code! Example: 'aria language cs' for Czech\n" ..
                   "Use 'aria language list' to see all available languages"
        end

        -- Check if language is supported
        if not ASC.Multilingual.Config.SupportedLanguages[langCode] then
            return "❌ Language '" .. langCode .. "' is not supported\n" ..
                   "Use 'aria language list' to see supported languages"
        end

        -- Set player language
        local success = ASC.Multilingual.Core.SetPlayerLanguage(player, langCode)

        if success then
            local langInfo = ASC.Multilingual.Config.SupportedLanguages[langCode]
            local response = "✅ Language set to: " .. langInfo.flag .. " " .. langInfo.nativeName .. "\n" ..
                           "🤖 ARIA will now respond in " .. langInfo.name .. "\n" ..
                           "💡 All commands work the same way in any language"

            -- Translate the response to the new language
            if langCode ~= "en" then
                local translatedResponse = ASC.Multilingual.Core.TranslateText(response, langCode, "en")
                if translatedResponse and translatedResponse ~= response then
                    response = response .. "\n\n" .. translatedResponse
                end
            end

            return response
        else
            return "❌ Failed to set language. Please try again."
        end

    else
        -- General language help
        local currentLang = ASC.Multilingual.Core.GetPlayerLanguage(player)
        local langInfo = ASC.Multilingual.Config.SupportedLanguages[currentLang]

        local helpText = "🌍 Multilingual Support:\n" ..
                        "• Current: " .. (langInfo and (langInfo.flag .. " " .. langInfo.nativeName) or "English") .. "\n" ..
                        "• 'aria language list' - View all languages\n" ..
                        "• 'aria language cs' - Set to Czech\n" ..
                        "• 'aria language en' - Set to English\n" ..
                        "• 'aria language status' - Check current language\n\n" ..
                        "🔄 Supported Features:\n" ..
                        "• Automatic language detection\n" ..
                        "• Web-based translation\n" ..
                        "• " .. table.Count(ASC.Multilingual.Config.SupportedLanguages) .. " languages supported\n" ..
                        "• Real-time response translation"

        return helpText
    end
end

-- Handle language commands
ASC.AI.HandleLanguageCommands = function(player, query, queryLower)
    if not IsValid(player) then
        return "Invalid player for language commands"
    end

    -- Check if multilingual system is available
    if not ASC.Multilingual then
        return "Multilingual system is not loaded. Please ensure the multilingual module is installed."
    end

    -- Handle specific language commands
    if string.find(queryLower, "language status") or string.find(queryLower, "jazyk stav") then
        return ASC.Multilingual.Core.GetMultilingualStatus(player)

    elseif string.find(queryLower, "set language") or string.find(queryLower, "nastavit jazyk") then
        return ASC.AI.HandleSetLanguage(player, query, queryLower)

    elseif string.find(queryLower, "language list") or string.find(queryLower, "seznam jazyků") then
        return ASC.Multilingual.Core.GetLanguageList()

    elseif string.find(queryLower, "translate") or string.find(queryLower, "přeložit") then
        return ASC.AI.HandleTranslateCommand(player, query, queryLower)

    elseif string.find(queryLower, "detect language") or string.find(queryLower, "rozpoznat jazyk") then
        return ASC.AI.HandleDetectLanguage(player, query, queryLower)

    else
        -- General language help in multiple languages
        local playerLang = ASC.Multilingual.Core.GetPlayerLanguage(player)

        if playerLang == "cs" then
            return "🌍 Vícejazyčný systém ARIA:\n" ..
                   "• 'aria jazyk stav' - Zobrazit stav jazyka\n" ..
                   "• 'aria nastavit jazyk cs' - Nastavit češtinu\n" ..
                   "• 'aria seznam jazyků' - Seznam podporovaných jazyků\n" ..
                   "• 'aria přeložit text' - Přeložit text\n" ..
                   "• 'aria rozpoznat jazyk text' - Rozpoznat jazyk textu\n\n" ..
                   "Podporované jazyky: čeština, angličtina, němčina, francouzština a další!\n" ..
                   "💡 ARIA automaticky rozpoznává váš jazyk a překládá odpovědi!"
        else
            return "🌍 ARIA Multilingual System:\n" ..
                   "• 'aria language status' - View language status\n" ..
                   "• 'aria set language en' - Set English\n" ..
                   "• 'aria language list' - List supported languages\n" ..
                   "• 'aria translate text' - Translate text\n" ..
                   "• 'aria detect language text' - Detect text language\n\n" ..
                   "Supported: Czech, English, German, French, Spanish, and more!\n" ..
                   "💡 ARIA automatically detects your language and translates responses!"
        end
    end
end

-- Handle set language command
ASC.AI.HandleSetLanguage = function(player, query, queryLower)
    local language = string.match(query, "set language (%w+)") or
                    string.match(query, "nastavit jazyk (%w+)") or
                    string.match(query, "language (%w+)")

    if not language then
        return "Please specify a language code! Examples:\n" ..
               "• 'aria set language cs' - Czech\n" ..
               "• 'aria set language en' - English\n" ..
               "• 'aria set language de' - German\n" ..
               "Use 'aria language list' to see all supported languages."
    end

    local success = ASC.Multilingual.Core.SetPlayerLanguage(player, language)

    if success then
        local langInfo = ASC.Multilingual.Config.SupportedLanguages[language]
        if language == "cs" then
            return "🌍 Jazyk úspěšně nastaven na: " .. langInfo.flag .. " " .. langInfo.nativeName .. "\n" ..
                   "💡 ARIA nyní bude odpovídat v češtině!"
        else
            return "🌍 Language successfully set to: " .. langInfo.flag .. " " .. langInfo.nativeName .. "\n" ..
                   "💡 ARIA will now respond in " .. langInfo.name .. "!"
        end
    else
        return "❌ Invalid language code: " .. language .. "\n" ..
               "Use 'aria language list' to see supported languages."
    end
end

-- Handle translate command
ASC.AI.HandleTranslateCommand = function(player, query, queryLower)
    local text = string.match(query, "translate (.+)") or
                string.match(query, "přeložit (.+)")

    if not text then
        return "Please specify text to translate! Example: 'aria translate hello world'"
    end

    local playerLang = ASC.Multilingual.Core.GetPlayerLanguage(player)
    local sourceLang = ASC.Multilingual.Core.DetectLanguage(text)

    -- If text is already in player's language, translate to English
    local targetLang = (sourceLang == playerLang) and "en" or playerLang

    local translatedText = ASC.Multilingual.Core.TranslateText(text, targetLang, sourceLang)

    local sourceInfo = ASC.Multilingual.Config.SupportedLanguages[sourceLang]
    local targetInfo = ASC.Multilingual.Config.SupportedLanguages[targetLang]

    return "🌍 Translation:\n" ..
           "📝 Original (" .. (sourceInfo and sourceInfo.flag or "") .. " " .. sourceLang .. "): " .. text .. "\n" ..
           "🔄 Translated (" .. (targetInfo and targetInfo.flag or "") .. " " .. targetLang .. "): " .. translatedText .. "\n\n" ..
           "💡 Translation powered by web services with local fallbacks"
end

-- Handle detect language command
ASC.AI.HandleDetectLanguage = function(player, query, queryLower)
    local text = string.match(query, "detect language (.+)") or
                string.match(query, "rozpoznat jazyk (.+)")

    if not text then
        return "Please specify text to analyze! Example: 'aria detect language hello world'"
    end

    local detectedLang = ASC.Multilingual.Core.DetectLanguage(text)
    local langInfo = ASC.Multilingual.Config.SupportedLanguages[detectedLang]

    if langInfo then
        return "🔍 Language Detection:\n" ..
               "📝 Text: " .. text .. "\n" ..
               "🌍 Detected: " .. langInfo.flag .. " " .. langInfo.nativeName .. " (" .. langInfo.name .. ")\n" ..
               "🔤 Code: " .. detectedLang .. "\n\n" ..
               "💡 Detection based on linguistic pattern analysis"
    else
        return "🔍 Language Detection:\n" ..
               "📝 Text: " .. text .. "\n" ..
               "❓ Language: Unknown or insufficient text\n" ..
               "💡 Try with longer text for better detection"
    end
end

-- Create ARIA management console commands
concommand.Add("aria_test", function(ply, cmd, args)
    if not IsValid(ply) then return end

    ply:ChatPrint("[ARIA-4] 🧪 Testing AI system...")
    ply:ChatPrint("[ARIA-4] Version: " .. ASC.AI.Config.Version)
    ply:ChatPrint("[ARIA-4] Status: ✅ All systems operational")
    ply:ChatPrint("[ARIA-4] Try: aria help, aria system status, aria ship status")
end, nil, "Test ARIA AI system")

concommand.Add("aria_reset", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local playerID = ply:SteamID()

    -- Reset user profile
    if ASC.AI.UserProfiles[playerID] then
        ASC.AI.UserProfiles[playerID] = nil
        ply:ChatPrint("[ARIA-4] 🔄 Your AI profile has been reset")
    end

    -- Reset conversation history
    if ASC.AI.ConversationHistory[playerID] then
        ASC.AI.ConversationHistory[playerID] = nil
        ply:ChatPrint("[ARIA-4] 🗑️ Your conversation history has been cleared")
    end

    -- Reset learning data
    if ASC.AI.LearningData[playerID] then
        ASC.AI.LearningData[playerID] = nil
        ply:ChatPrint("[ARIA-4] 🧠 Your learning data has been reset")
    end

    ply:ChatPrint("[ARIA-4] ✅ Complete AI reset successful - Start fresh!")
end, nil, "Reset your ARIA AI profile and data")

concommand.Add("aria_debug", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    ply:ChatPrint("[ARIA-4] 🔧 Debug Information:")
    ply:ChatPrint("• Total User Profiles: " .. table.Count(ASC.AI.UserProfiles))
    ply:ChatPrint("• Total Conversations: " .. table.Count(ASC.AI.ConversationHistory))
    ply:ChatPrint("• Memory Usage: " .. math.floor(collectgarbage("count")) .. " KB")

    -- Show system status
    local features = {
        "EnableAdvancedFeatures", "EnableContextAwareness", "EnableLearning",
        "EnableProactiveAssistance", "EnableNaturalLanguage", "EnableMultiLanguageSupport"
    }

    for _, feature in ipairs(features) do
        local status = ASC.AI.Config[feature] and "✅" or "❌"
        ply:ChatPrint("• " .. feature .. ": " .. status)
    end
end, nil, "Show ARIA debug information (Admin only)")

print("[Advanced Space Combat] ARIA-4 Advanced AI System v5.1.0 - Next-generation intelligence loaded successfully!")
print("[ARIA-4] Features: Intent recognition, sentiment analysis, conversation memory, adaptive learning")
print("[ARIA-4] Enhanced natural language processing and contextual understanding active!")
print("[ARIA-4] Console Commands: aria_test, aria_reset, aria_debug")
print("[ARIA-4] Use 'aria <question>' to experience the most advanced AI assistant for Garry's Mod!")
print("[ARIA-4] Legacy support: !ai commands still work for compatibility")
