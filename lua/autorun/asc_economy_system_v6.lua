-- Advanced Space Combat - Economy & Trading System v6.0.0
-- Dynamic market simulation, trading mechanics, and economic progression
-- Research-based implementation following 2025 game economy best practices

print("[Advanced Space Combat] Economy & Trading System v6.0.0 - Dynamic Market Simulation Loading...")

-- Initialize economy namespace
ASC = ASC or {}
ASC.Economy = ASC.Economy or {}

-- Economy configuration
ASC.Economy.Config = {
    Version = "6.0.0",
    
    -- Market settings
    Market = {
        DynamicPricing = true,
        SupplyDemandSimulation = true,
        MarketVolatility = 0.1,  -- 10% price fluctuation
        UpdateInterval = 60,     -- 1 minute
        InflationRate = 0.02     -- 2% per hour
    },
    
    -- Currency system
    Currency = {
        PrimaryCurrency = "Credits",
        SecondaryCurrency = "Energy Units",
        ExchangeRate = 10,  -- 1 Credit = 10 Energy Units
        StartingCredits = 1000,
        StartingEnergy = 500
    },
    
    -- Trading
    Trading = {
        TransactionFee = 0.05,   -- 5% fee
        MaxTradeDistance = 5000,
        TradeRoutes = true,
        AutoTrading = true,
        MarketAnalysis = true
    },
    
    -- Economic zones
    Zones = {
        Industrial = {priceMultiplier = 0.8, demandBonus = 1.2},
        Commercial = {priceMultiplier = 1.0, demandBonus = 1.0},
        Research = {priceMultiplier = 1.3, demandBonus = 0.7},
        Military = {priceMultiplier = 1.5, demandBonus = 1.5},
        Frontier = {priceMultiplier = 1.8, demandBonus = 0.5}
    }
}

-- Economy state
ASC.Economy.State = {
    PlayerWallets = {},
    MarketPrices = {},
    TradeHistory = {},
    MarketTrends = {},
    ActiveTrades = {},
    TradeRoutes = {},
    LastMarketUpdate = 0
}

-- Commodity definitions
ASC.Economy.Commodities = {
    -- Raw materials
    {
        id = "raw_metal",
        name = "Raw Metal",
        category = "materials",
        basePrice = 50,
        volatility = 0.15,
        supply = 1000,
        demand = 800
    },
    {
        id = "energy_crystals",
        name = "Energy Crystals",
        category = "energy",
        basePrice = 200,
        volatility = 0.25,
        supply = 300,
        demand = 500
    },
    {
        id = "rare_elements",
        name = "Rare Elements",
        category = "materials",
        basePrice = 500,
        volatility = 0.30,
        supply = 100,
        demand = 200
    },
    
    -- Manufactured goods
    {
        id = "ship_components",
        name = "Ship Components",
        category = "technology",
        basePrice = 1000,
        volatility = 0.20,
        supply = 200,
        demand = 300
    },
    {
        id = "weapon_systems",
        name = "Weapon Systems",
        category = "military",
        basePrice = 2000,
        volatility = 0.35,
        supply = 50,
        demand = 100
    },
    {
        id = "shield_generators",
        name = "Shield Generators",
        category = "technology",
        basePrice = 1500,
        volatility = 0.25,
        supply = 75,
        demand = 150
    },
    
    -- Information and services
    {
        id = "star_charts",
        name = "Star Charts",
        category = "information",
        basePrice = 300,
        volatility = 0.10,
        supply = 500,
        demand = 400
    },
    {
        id = "research_data",
        name = "Research Data",
        category = "information",
        basePrice = 800,
        volatility = 0.40,
        supply = 150,
        demand = 250
    }
}

-- Player wallet management
ASC.Economy.GetPlayerWallet = function(player)
    if not IsValid(player) then return nil end
    
    local steamId = player:SteamID()
    
    if not ASC.Economy.State.PlayerWallets[steamId] then
        ASC.Economy.State.PlayerWallets[steamId] = {
            credits = ASC.Economy.Config.Currency.StartingCredits,
            energy = ASC.Economy.Config.Currency.StartingEnergy,
            inventory = {},
            tradeHistory = {},
            reputation = 0
        }
    end
    
    return ASC.Economy.State.PlayerWallets[steamId]
end

ASC.Economy.AddCredits = function(player, amount)
    local wallet = ASC.Economy.GetPlayerWallet(player)
    if wallet then
        wallet.credits = wallet.credits + amount
        return true
    end
    return false
end

ASC.Economy.RemoveCredits = function(player, amount)
    local wallet = ASC.Economy.GetPlayerWallet(player)
    if wallet and wallet.credits >= amount then
        wallet.credits = wallet.credits - amount
        return true
    end
    return false
end

ASC.Economy.AddToInventory = function(player, commodityId, quantity)
    local wallet = ASC.Economy.GetPlayerWallet(player)
    if not wallet then return false end
    
    if not wallet.inventory[commodityId] then
        wallet.inventory[commodityId] = 0
    end
    
    wallet.inventory[commodityId] = wallet.inventory[commodityId] + quantity
    return true
end

ASC.Economy.RemoveFromInventory = function(player, commodityId, quantity)
    local wallet = ASC.Economy.GetPlayerWallet(player)
    if not wallet or not wallet.inventory[commodityId] then return false end
    
    if wallet.inventory[commodityId] >= quantity then
        wallet.inventory[commodityId] = wallet.inventory[commodityId] - quantity
        return true
    end
    
    return false
end

-- Market price calculation
ASC.Economy.CalculatePrice = function(commodityId)
    local commodity = nil
    for _, c in ipairs(ASC.Economy.Commodities) do
        if c.id == commodityId then
            commodity = c
            break
        end
    end
    
    if not commodity then return 0 end
    
    -- Supply and demand calculation
    local supplyDemandRatio = commodity.supply / math.max(1, commodity.demand)
    local priceModifier = 1.0
    
    if supplyDemandRatio > 1.5 then
        priceModifier = 0.7  -- Oversupply, lower prices
    elseif supplyDemandRatio < 0.5 then
        priceModifier = 1.5  -- High demand, higher prices
    else
        priceModifier = 1.0 / supplyDemandRatio
    end
    
    -- Add volatility
    local volatilityFactor = 1.0 + (math.random() - 0.5) * commodity.volatility * 2
    
    -- Calculate final price
    local finalPrice = commodity.basePrice * priceModifier * volatilityFactor
    
    return math.max(1, math.floor(finalPrice))
end

ASC.Economy.UpdateMarketPrices = function()
    for _, commodity in ipairs(ASC.Economy.Commodities) do
        local newPrice = ASC.Economy.CalculatePrice(commodity.id)
        local oldPrice = ASC.Economy.State.MarketPrices[commodity.id] or commodity.basePrice
        
        ASC.Economy.State.MarketPrices[commodity.id] = newPrice
        
        -- Track price trends
        if not ASC.Economy.State.MarketTrends[commodity.id] then
            ASC.Economy.State.MarketTrends[commodity.id] = {}
        end
        
        table.insert(ASC.Economy.State.MarketTrends[commodity.id], {
            price = newPrice,
            timestamp = os.time(),
            change = newPrice - oldPrice
        })
        
        -- Limit trend history
        if #ASC.Economy.State.MarketTrends[commodity.id] > 100 then
            table.remove(ASC.Economy.State.MarketTrends[commodity.id], 1)
        end
        
        -- Update supply and demand based on trading activity
        ASC.Economy.UpdateSupplyDemand(commodity.id)
    end
    
    ASC.Economy.State.LastMarketUpdate = CurTime()
end

ASC.Economy.UpdateSupplyDemand = function(commodityId)
    -- Find commodity
    local commodity = nil
    for _, c in ipairs(ASC.Economy.Commodities) do
        if c.id == commodityId then
            commodity = c
            break
        end
    end
    
    if not commodity then return end
    
    -- Simulate natural supply/demand changes
    local supplyChange = math.random(-10, 10)
    local demandChange = math.random(-10, 10)
    
    commodity.supply = math.max(10, commodity.supply + supplyChange)
    commodity.demand = math.max(10, commodity.demand + demandChange)
end

-- Trading functions
ASC.Economy.CreateTrade = function(seller, buyer, commodityId, quantity, pricePerUnit)
    if not IsValid(seller) or not IsValid(buyer) then return nil end
    
    local trade = {
        id = #ASC.Economy.State.ActiveTrades + 1,
        seller = seller,
        buyer = buyer,
        sellerId = seller:SteamID(),
        buyerId = buyer:SteamID(),
        commodityId = commodityId,
        quantity = quantity,
        pricePerUnit = pricePerUnit,
        totalPrice = quantity * pricePerUnit,
        status = "pending",
        timestamp = os.time()
    }
    
    table.insert(ASC.Economy.State.ActiveTrades, trade)
    
    return trade
end

ASC.Economy.ExecuteTrade = function(tradeId)
    local trade = ASC.Economy.State.ActiveTrades[tradeId]
    if not trade or trade.status ~= "pending" then return false end
    
    local seller = trade.seller
    local buyer = trade.buyer
    
    if not IsValid(seller) or not IsValid(buyer) then
        trade.status = "failed"
        return false
    end
    
    -- Check if seller has the commodity
    if not ASC.Economy.RemoveFromInventory(seller, trade.commodityId, trade.quantity) then
        trade.status = "failed"
        return false
    end
    
    -- Check if buyer has enough credits
    local totalCost = trade.totalPrice + (trade.totalPrice * ASC.Economy.Config.Trading.TransactionFee)
    if not ASC.Economy.RemoveCredits(buyer, totalCost) then
        -- Return commodity to seller
        ASC.Economy.AddToInventory(seller, trade.commodityId, trade.quantity)
        trade.status = "failed"
        return false
    end
    
    -- Execute trade
    ASC.Economy.AddToInventory(buyer, trade.commodityId, trade.quantity)
    ASC.Economy.AddCredits(seller, trade.totalPrice)
    
    trade.status = "completed"
    trade.completedTime = os.time()
    
    -- Add to trade history
    table.insert(ASC.Economy.State.TradeHistory, trade)
    
    -- Notify players
    seller:ChatPrint("[ASC Economy] Trade completed: Sold " .. trade.quantity .. " " .. trade.commodityId .. " for " .. trade.totalPrice .. " credits")
    buyer:ChatPrint("[ASC Economy] Trade completed: Bought " .. trade.quantity .. " " .. trade.commodityId .. " for " .. totalCost .. " credits")
    
    -- Track in analytics
    if ASC.Analytics then
        ASC.Analytics.TrackEvent("trade_completed", {
            tradeId = trade.id,
            commodityId = trade.commodityId,
            quantity = trade.quantity,
            totalPrice = trade.totalPrice,
            seller = seller:Name(),
            buyer = buyer:Name()
        })
    end
    
    return true
end

-- Market analysis
ASC.Economy.GetMarketAnalysis = function(commodityId)
    local trends = ASC.Economy.State.MarketTrends[commodityId]
    if not trends or #trends < 2 then return nil end
    
    local recentTrends = {}
    local currentTime = os.time()
    
    -- Get trends from last hour
    for _, trend in ipairs(trends) do
        if currentTime - trend.timestamp < 3600 then
            table.insert(recentTrends, trend)
        end
    end
    
    if #recentTrends < 2 then return nil end
    
    -- Calculate analysis
    local totalChange = 0
    local avgPrice = 0
    local minPrice = math.huge
    local maxPrice = 0
    
    for _, trend in ipairs(recentTrends) do
        totalChange = totalChange + trend.change
        avgPrice = avgPrice + trend.price
        minPrice = math.min(minPrice, trend.price)
        maxPrice = math.max(maxPrice, trend.price)
    end
    
    avgPrice = avgPrice / #recentTrends
    
    local analysis = {
        commodityId = commodityId,
        currentPrice = ASC.Economy.State.MarketPrices[commodityId],
        averagePrice = math.floor(avgPrice),
        minPrice = minPrice,
        maxPrice = maxPrice,
        totalChange = totalChange,
        trend = totalChange > 0 and "rising" or (totalChange < 0 and "falling" or "stable"),
        volatility = (maxPrice - minPrice) / avgPrice,
        recommendation = ""
    }
    
    -- Generate recommendation
    if analysis.trend == "rising" and analysis.volatility < 0.2 then
        analysis.recommendation = "BUY - Stable upward trend"
    elseif analysis.trend == "falling" and analysis.volatility < 0.2 then
        analysis.recommendation = "SELL - Stable downward trend"
    elseif analysis.volatility > 0.3 then
        analysis.recommendation = "HOLD - High volatility"
    else
        analysis.recommendation = "NEUTRAL - Stable market"
    end
    
    return analysis
end

-- Console commands
concommand.Add("asc_economy_wallet", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local wallet = ASC.Economy.GetPlayerWallet(ply)
    if not wallet then return end
    
    ply:ChatPrint("[ASC Economy] Wallet:")
    ply:ChatPrint("  Credits: " .. wallet.credits)
    ply:ChatPrint("  Energy: " .. wallet.energy)
    ply:ChatPrint("  Reputation: " .. wallet.reputation)
    
    if next(wallet.inventory) then
        ply:ChatPrint("  Inventory:")
        for commodityId, quantity in pairs(wallet.inventory) do
            if quantity > 0 then
                ply:ChatPrint("    " .. commodityId .. ": " .. quantity)
            end
        end
    end
end, nil, "Show player wallet and inventory")

concommand.Add("asc_economy_market", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("[ASC Economy] Market Prices:")
    
    for _, commodity in ipairs(ASC.Economy.Commodities) do
        local price = ASC.Economy.State.MarketPrices[commodity.id] or commodity.basePrice
        local analysis = ASC.Economy.GetMarketAnalysis(commodity.id)
        local trendText = analysis and (" (" .. analysis.trend .. ")") or ""
        
        ply:ChatPrint("  " .. commodity.name .. ": " .. price .. " credits" .. trendText)
    end
end, nil, "Show current market prices")

print("[Advanced Space Combat] Economy & Trading System v6.0.0 - Dynamic Market Simulation Loaded Successfully!")
