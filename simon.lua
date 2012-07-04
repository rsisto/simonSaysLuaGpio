require ("gpio")

-- CONFIG
-- gpio id's used. Must look the datasheet to find the corresponding pin on the expansion bus.
local botones = {139,138,137}
local leds = {158,162,161}
local ledsTotalNr = #leds
-- mapping between buttons to led (e.g.: the player must press button buttonLedMap[i] when i was lit)
local bottonLedMap = {[139]=158, [138]=162, [137]=161}

-- END CONFIG

-- array which holds the current sequence, empty at the beginning of the game
local nowArray ={}

-- configure input and output gpios (buttons and leds)
function exportLedsAndBottons()
    -- set up leds
    for i,ledId in ipairs(leds) do
        configureOutGPIO(ledId)
        -- turn off leds
        writeGPIO(ledId, '0')
    end
    -- set up buttons
    for i,botonId in ipairs(botones) do
        configureInGPIO(botonId)
    end
end

-- add an item to the list
function add(list, element)
    list[#list+1] = element
end

-- adds an element to the game array and plays the sequence so far.
function addElementAndPlay()
    -- random number between 1 and ledsTotalNr
    randomLed = math.random(ledsTotalNr)
    add(nowArray,leds[randomLed])
    for i,ledId in ipairs(nowArray) do
        onOffLed(ledId)
        sleep(0.2)
    end
end

----- turn led on for a second
function onOffLed (ledId)
    -- turn on
    writeGPIO(ledId, '1')
    sleep(1)
    -- turn off
    writeGPIO(ledId, '0')
end


function play()
    exportLedsAndBottons()
    
	 -- main loop
    while true do
        -- play the sequence so far
        addElementAndPlay()
        -- wait for player's move
        local seqIndex = 1
        local seqLength = #nowArray
        while seqIndex <= seqLength do
            for i,botonId in ipairs(botones) do
                local val = readGPIO(botonId)
                if val.."" == '1' then
                    -- if the pressed button is ok, continue with the next
                    if bottonLedMap[botonId] == nowArray[seqIndex] then
                        seqIndex = seqIndex + 1
                        --Turn on led to indicate player is still winning!
                        onOffLed(bottonLedMap[botonId] )
                    else
                        return seqLength-1
                    end
                end
            end
        end
        --Sleep for a second and start next sequence
        sleep(1)
    end

end

function playGameOver()
    --turn all the leds on and off in a sequence several times to indicate game over.
    for j=1,10 do
		for i,ledId in ipairs(leds) do
			writeGPIO(ledId,'1')
			sleep(0.1)
			writeGPIO(ledId,'0')
		end
	end
end


function simonStart()
    local successNumber = play()
    print("well played, number of rounds : "..successNumber)
    playGameOver()
end

-- generate random seed and start the game.
math.randomseed( os.time() )
simonStart()

