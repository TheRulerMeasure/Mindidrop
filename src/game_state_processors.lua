-- game_state_processors.lua
local gameConst = require("game_const")
local gameStates = require("game_states")

local updateBeginning = function (game, dt)
    game.stepDelay = game.stepDelay + dt
    if game.stepDelay < game.maxDelayBeforeNextShuffle then
        return gameStates.beginning
    end
    game.shuffledBlockerAmount = game.shuffledBlockerAmount + 1
    game.stepDelay = 0
    if game.shuffledBlockerAmount > gameConst.blockersAmount then
        game.stateLabel = "Player" .. game.curPlayerIndex .. "'s turn. [Left/Right] [Down]"
        for i, v in ipairs(game.playerBoxes) do
            v.maxProgress = gameConst.maxRoundScores[game.curRoundIndex]
            v:setProgress(0)
            v:setMaxNumProgress(game.curRoundIndex, gameConst.maxRoundScores[game.curRoundIndex])
        end
        game.centerLabel:displayLabel(1)
        love.audio.play(game.roundBeginSound)
        return gameStates.playerWaiting
    end
    local coord = gameConst.blockerCoords[game.shuffledBlockerAmount]
    local blockRight = love.math.random() > 0.5
    if blockRight then
        game:blockerBlockRight(coord.x, coord.y)
    else
        game:blockerBlockLeft(coord.x, coord.y)
    end
    return gameStates.beginning
end

local updatePlayerWaiting = function (game, dt)
    if #game.movingCoins <= 0 then
        if game.players[game.curPlayerIndex].isCPU then
            local slot = love.math.random() * 7
            slot = slot + 1
            slot = math.floor(slot + 0.5)
            game:insertCoinFromSlot(slot)
        end
        return gameStates.playerWaiting
    end
    game.stateLabel = "..."
    return gameStates.playerStepping
end

local updatePlayerStepping = function (game, dt)
    game.stepDelay = game.stepDelay + dt
    if game.stepDelay < game.maxDelayBeforeNextStep then
        return gameStates.playerStepping
    end
    game.stepDelay = 0
    if #game.movingCoins <= 0 then
        game.stateLabel = "Player" .. game.curPlayerIndex .. "'s turn ended."
        return gameStates.playerEnding
    end
    game:coinAllMoveDown()
    return gameStates.playerStepping
end

local updatePlayerEnding = function (game, dt)
    game.stepDelay = game.stepDelay + dt
    if game.stepDelay < 0.75 then
        return gameStates.playerEnding
    end
    game.stepDelay = 0
    local plScore = game.players[game.curPlayerIndex].scores
    local maxScore = gameConst.maxRoundScores[game.curRoundIndex]
    if plScore >= maxScore then
        game:changeToNextPlayer()
        game.stateLabel = "Player" .. game.curPlayerIndex .. "'s turn. [Left/Right] [Down]"
        return gameStates.playerWaitingRoundEnding
    end
    game:changeToNextPlayer()
    game.stateLabel = "Player" .. game.curPlayerIndex .. "'s turn. [Left/Right] [Down]"
    return gameStates.playerWaiting
end

local updatePlayerWaitingRoundEnding = function (game, dt)
    if #game.movingCoins <= 0 then
        if game.players[game.curPlayerIndex].isCPU then
            local slot = love.math.random() * 7
            slot = slot + 1
            slot = math.floor(slot + 0.5)
            game:insertCoinFromSlot(slot)
        end
        return gameStates.playerWaitingRoundEnding
    end
    game.stateLabel = "..."
    return gameStates.playerSteppingRoundEnding
end

local updatePlayerSteppingRoundEnding = function (game, dt)
    game.stepDelay = game.stepDelay + dt
    if game.stepDelay < game.maxDelayBeforeNextStep then
        return gameStates.playerSteppingRoundEnding
    end
    game.stepDelay = 0
    if #game.movingCoins <= 0 then
        game.stateLabel = "Player" .. game.curPlayerIndex .. "'s turn ended."
        return gameStates.playerEndingRoundEnding
    end
    game:coinAllMoveDown()
    return gameStates.playerSteppingRoundEnding
end

local updatePlayerEndingRoundEnding = function (game, dt)
    game.stepDelay = game.stepDelay + dt
    if game.stepDelay < 0.75 then
        return gameStates.playerEndingRoundEnding
    end
    game.stepDelay = 0
    if game.curRoundIndex >= gameConst.maxRounds then
        local winningPlayer = 1
        local highestScore = 0
        for i, v in ipairs(game.players) do
            if v.totalScores > highestScore then
                highestScore = v.totalScores
                winningPlayer = i
            end
        end
        game.centerLabel:displayLabel(math.min(math.max(winningPlayer + 4, 5), 6))
        love.audio.play(game.gameEndSound)
        game.stateLabel = "Game Over."
        return gameStates.concluding
    end
    game:changeToNextPlayer()
    game.curRoundIndex = game.curRoundIndex + 1
    game.centerLabel:displayLabel(game.curRoundIndex)
    game.stateLabel = "Going to Round " .. game.curRoundIndex .. "!"
    love.audio.play(game.roundBeginSound)
    return gameStates.goingToNewRound
end

local updateGoingToNewRound = function (game, dt)
    game.stepDelay = game.stepDelay + dt
    if game.stepDelay <= 0.2 then
        return gameStates.goingToNewRound
    end
    game.stepDelay = 0
    game.updatedScoreMulAmount = game.updatedScoreMulAmount + 1
    if game.updatedScoreMulAmount > gameConst.mapWidth then
        game.updatedScoreMulAmount = 0
        game.stateLabel = "Player" .. game.curPlayerIndex .. "'s turn. [Left/Right] [Down]"
        for i, v in ipairs(game.players) do
            v.scores = 0
        end
        for i, v in ipairs(game.playerBoxes) do
            v.maxProgress = gameConst.maxRoundScores[game.curRoundIndex]
            v:setProgress(0)
            v:setMaxNumProgress(game.curRoundIndex, gameConst.maxRoundScores[game.curRoundIndex])
        end
        return gameStates.playerWaiting
    end
    local scoreMul = gameConst.roundScoreMulSlots[game.curRoundIndex][game.updatedScoreMulAmount]
    game.scoreMulSlots[game.updatedScoreMulAmount]:setNum(scoreMul)
    return gameStates.goingToNewRound
end

local updateConcluding = function (game, dt)
    game.stepDelay = game.stepDelay + dt
    if game.stepDelay > 5.1 then
        game.gameOver = true
    end
    return gameStates.concluding
end

return function (game, dt)
    local state = game.curState
    if state == gameStates.playerWaiting then
        return updatePlayerWaiting(game, dt)
        
    elseif state == gameStates.playerStepping then
        return updatePlayerStepping(game, dt)
        
    elseif state == gameStates.playerEnding then
        return updatePlayerEnding(game, dt)
        
    elseif state == gameStates.playerWaitingRoundEnding then
        return updatePlayerWaitingRoundEnding(game, dt)
        
    elseif state == gameStates.playerSteppingRoundEnding then
        return updatePlayerSteppingRoundEnding(game, dt)
    
    elseif state == gameStates.playerEndingRoundEnding then
        return updatePlayerEndingRoundEnding(game, dt)
        
    elseif state == gameStates.goingToNewRound then
        return updateGoingToNewRound(game, dt)
        
    elseif state == gameStates.concluding then
        return updateConcluding(game, dt)
        
    else
        return updateBeginning(game, dt)
    end
end
