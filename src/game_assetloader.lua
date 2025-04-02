return function () 

    love.graphics.setBackgroundColor(love.math.colorFromBytes(117, 107, 95))
    local newFont = love.graphics.newImageFont("assets/fonts/dojmun_font_line_lv.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()_-+=[{]}\\|;:'\",<.>/?")
    love.graphics.setFont(newFont)


    return {
        ["blocker_sheet"] = love.graphics.newImage("assets/textures/blocker_sheet.png"),
        ["coin"] = love.graphics.newImage("assets/textures/coin.png"),
        ["insert_arrow_sheet"] = love.graphics.newImage("assets/textures/insert_arrow_sheet.png"),
        ["board_front"] = love.graphics.newImage("assets/textures/board_front.png"),
        ["board_back"] = love.graphics.newImage("assets/textures/board_back.png"),
        ["bubv_sheet"] = love.graphics.newImage("assets/textures/bubv_sheet.png"),
        ["mindi_tower_sheet"] = love.graphics.newImage("assets/textures/mindi_tower_sheet.png"),
        ["mindi_pgbar_bg"] = love.graphics.newImage("assets/textures/mindi_progbar_background.png"),
        ["mindi_pgbar_over"] = love.graphics.newImage("assets/textures/mindi_progbar_over.png"),
        ["label_sheet"] = love.graphics.newImage("assets/textures/label_sheet.png"),
        ["boom_sheet"] = love.graphics.newImage("assets/textures/small_boom_sheet.png"),
        
        ["coin_hit_coin"] = love.audio.newSource("assets/sounds/coin_hit_coin.wav", "static"),
        ["coin_scored"] = love.audio.newSource("assets/sounds/coin_scored.wav", "static"),
        ["explosion"] = love.audio.newSource("assets/sounds/explosion.wav", "static"),
        ["lever_move"] = love.audio.newSource("assets/sounds/lever_move.wav", "static"),
        ["game_end"] = love.audio.newSource("assets/sounds/game_end.wav", "static"),
        ["round_begin"] = love.audio.newSource("assets/sounds/round_begin.wav", "static"),
    } 


end