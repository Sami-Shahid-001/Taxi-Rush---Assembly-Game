INCLUDE Irvine32.inc 

; frequency in hz, duration in ms.
Beep PROTO stdcall :DWORD, :DWORD ; define the prototype for the windows beep function so we can use it


MAP_SIZE_CONSTANT           EQU 20   ;   size of map 20x20
MAXIMUM_PASSENGERS          EQU 5      ;maximum number of passengers that are allowed at once 
MAX_LEADERBOARD_ENTRIES     EQU 10   ; max number of high score at once 

;  characters that are defined to display on game board

Wall_board                 EQU ' '   
road_board                 EQU ' ' 
player_board               EQU 'T'
npc_board                  EQU 'C' 
passenger_board            EQU 'P'
destination_board          EQU 'D' 
bonus_on_board                 EQU '$' 
obstacle_on_board             EQU ' ' 

;foregroundcolor + (backgroundcolor * 16)
; define the background color and a text on it with the spesific formula
COLOR_ROAD                  EQU 0 + (15 * 16)       
COLOR_WALL                  EQU 0 + (0 * 16)        
COLOR_TAXI_YELLOW           EQU 0 + (14 * 16)       
COLOR_TAXI_RED              EQU 15 + (4 * 16)       ;4 = red 
COLOR_NPC                   EQU 0 + (3 * 16)       ;black text on cyan 
COLOR_PASSENGER             EQU 5 + (15 * 16)       ; magenta text on white 
COLOR_DESTINATION           EQU 15 + (2 * 16)       ; white text on green 
COLOR_BONUS                 EQU 2 + (15 * 16)       ;green text on white 
COLOR_OBSTACLE              EQU 15 + (4 * 16)       ;white text on red background
COLOR_GRID_LINE             EQU 7 + (15 * 16)    ;  grid line color ,lightgrey text on white background

; --- ui colors ---
COLOR_TITLE                 EQU 11 + (0 * 16)       ; set title text color to lightcyan
COLOR_EXIT                  EQU 12 + (0 * 16)    ; set exit text color to lightred
COLOR_ALERT                 EQU 12 + (15 * 16)        ; set alert message color: lightred on white
COLOR_HUD                   EQU 14 + (0 * 16)        ; set heads up display text color to yellow

.data
    
    isGameActive            DWORD 0   ;check if the game is currently running or not 
    playerNameBuffer        BYTE 21 DUP(0)  ; buffer to store the player name 
    currentScore            SDWORD 0        ;  store the player current score and use sighnes for negative numbers
    taxiTypeSelected        DWORD 1         ; stores which taxi color is selected ; yellow or red 
    
    ; --- game modes ---
    gameModeSelected        DWORD 0         ;  game mode  0=endless 1=career  2=time
    startTime               DWORD 0       ;use to  stores the system time when the game started
    currentTime             DWORD 0  ; stores the current system time during the loop
    timeLimitDuration       DWORD 30000     ; set the time limit for time mode means 30 secs
    
    playerXPosition         DWORD 1       ; it stores player current x coordinate
    playerYPosition         DWORD 1         ; it stores player current y coordinate
    
    ; --- passenger arrays ---
    passengerXPositions     DWORD MAXIMUM_PASSENGERS DUP(0)     ; array to store x coordinates of all passengers
    passengerYPositions     DWORD MAXIMUM_PASSENGERS DUP(0) ; array to store y coordinates of all the passengers
    passengerActiveStatus   DWORD MAXIMUM_PASSENGERS DUP(0) ; array to store if a passenger is currently on the map means 1 is active and 0 is not active
    
    isCarryingPassenger     DWORD 0         ; 1 if player has a passenger, 0 if empty , also it is a bool
    destinationX            DWORD 0     ; x coordinate of the current drop zone
    destinationY            DWORD 0     ; y coordinate of the current drop   zone

    passengersDeliveredCount DWORD 0         ; count for how many passengers have been drop
    gameSpeedDelay          DWORD 250       ; the delay in ms for the game loop to control the speed
    
    currentMessageString    DWORD 0         ; pointer to the string currently displayed in the alert area

    
    npcOneX                 DWORD 15   ; starting x position for npc 1
    npcOneY                 DWORD 2    ; starting y position for npc 1
    npcOneDirectionX        SDWORD -1   ; moving direction x for npc 1 and -1 means left
    npcOneDirectionY        SDWORD 0  ; moving direction y for npc 1 and 0 means no vertical movement

    npcTwoX                 DWORD 2    ; starting x position for npc 2
    npcTwoY                 DWORD 15   ; starting y position for npc 2
    npcTwoDirectionX        SDWORD 0    ; moving direction x for npc 2
    npcTwoDirectionY        SDWORD -1  ; moving direction y for npc 2 (-1 = up)

    npcThreeX               DWORD 10      ; starting x position for npc 3
    npcThreeY               DWORD 17     ; starting y position for npc 3
    npcThreeDirectionX      SDWORD 1      ; moving direction x for npc 3 (1 = right)
    npcThreeDirectionY      SDWORD 0    ; moving direction y for npc 3

    npcFourX                DWORD 17 ; starting x position for npc 4
    npcFourY                DWORD 5 ; starting y position for npc 4
    npcFourDirectionX       SDWORD 0    ; moving direction x for npc 4
    npcFourDirectionY       SDWORD 1  ; moving direction y for npc 4 (1 = down)
    
    ; --- strings ---
    stringHeader            BYTE "=== TAXI RUSH: ULTIMATE EDITION ===",0 
    stringOptionOne         BYTE "1. Start New Game",0 
    stringOptionTwo         BYTE "2. Continue Game",0
    stringOptionThree       BYTE "3. Game Settings (Taxi & Modes)",0
    stringOptionFour        BYTE "4. View Leaderboard",0 
    stringOptionFive        BYTE "5. Instructions",0 
    stringExit              BYTE "ESC. Exit Game",0
    stringPrompt            BYTE "Select Option: ",0 
    stringNamePrompt        BYTE "Enter your Name: ",0 
    
    ; --- settings otputs ---
    stringSettingsTitle     BYTE "=== GAME SETTINGS ===",0 
    stringSettingsSubtitle  BYTE "--- SELECT TAXI COLOR ---",0 
    stringSettingOne        BYTE "1. Yellow Taxi (Fast)",0 
    stringSettingTwo        BYTE "2. Red Taxi (Slow)",0 
    stringSettingThree      BYTE "3. Random Modes",0 
    stringSettingSelected   BYTE "Settings Updated!",0 
    
    ; --- mode strings ---
    stringModeTitle         BYTE "--- SELECT GAME MODE ---",0     ; title for mode selection
    stringModeOne           BYTE "1. Career Mode (Drop 5 Passengers)",0  ; mode option 1
    stringModeTwo           BYTE "2. Time Mode (30 Seconds)",0     ; mode option 2
    stringModeThree         BYTE "3. Endless Mode (Default)",0   ; mode option 3
    stringModeSelected      BYTE "Game Mode Set!",0

    ; --- instructions ---
    stringInstructionTitle  BYTE "=== INSTRUCTIONS ===",0
    stringInstructionOne    BYTE "1. Drive using W/A/S/D. Press SPACE to Pickup/Drop.",0 
    stringInstructionTwo    BYTE "2. To Pickup: Stop NEXT to passenger and press SPACE.",0 
    stringInstructionThree  BYTE "3. To Drop: Drive ONTO Green Dest (D) and press SPACE.",0 ; line 3
    stringInstructionFour   BYTE "4. DO NOT drive into passengers without picking them up (-5 PTS).",0 ; line 4
    stringInstructionFive   BYTE "5. Speed increases every 2 successful drop-offs.",0 ;  line 5
    stringInstructionSix    BYTE "6. Leaderboard saves top scores.",0 ;  line 6
    stringContinue    BYTE "Press any key to continue...",0 ; return to menu
    
    stringHUDScore          BYTE "Score: ",0 ;  for score display
    stringHUDDrops          BYTE " Drops: ",0    ;  for drop count display
    stringHUDTime           BYTE " Time: ",0 ;  for time display
    
    ; messages (40 chars for alignment)
    stringMessageNull       BYTE "                                        ",0 
    stringMessageWallYellow BYTE ">> HIT OBSTACLE! -4 PTS <<              ",0
    stringMessageWallRed    BYTE ">> HIT OBSTACLE! -2 PTS <<              ",0 
    stringMessageCarYellow  BYTE ">> HIT CAR! -2 PTS <<                   ",0 
    stringMessageCarRed     BYTE ">> HIT CAR! -3 PTS <<                   ",0 
    stringMessageBonus      BYTE ">> BONUS! +10 PTS <<                    ",0 
    stringMessageDrop       BYTE ">> DROPPED! +10 PTS <<                  ",0 
    stringMessagePickup     BYTE ">> PASSENGER PICKED UP! <<              ",0 
    stringMessageHitPassenger BYTE ">> HIT PASSENGER! -5 PTS <<              ",0 
    stringMessageFailDrop   BYTE ">> NOT AT DESTINATION! <<               ",0 
    stringMessageFailPickup BYTE ">> NO PASSENGER NEARBY! <<              ",0 
    stringGameOver          BYTE "GAME OVER! Crashed into Wall.",0 ; game over text
    stringCareerWin         BYTE "CAREER COMPLETE! You dropped 5 passengers!",0    ; win text in career mode
    stringTimeUp            BYTE "TIME'S UP! 30 Seconds Reached.",0 ;
    
    ; --- leaderboard data ---
    filenameString          BYTE "highscores.txt",0 ; the filename for saving scores
    fileHandle              HANDLE ? ; variable to store the file handle id
    
    scoresArray             SDWORD MAX_LEADERBOARD_ENTRIES DUP(0)       ; array to store the top 10 numeric scores
    namesArray              BYTE   MAX_LEADERBOARD_ENTRIES * 21 DUP(0) ; array to store the top 10 names (flat byte array)
    totalScoresCount        DWORD  0 ; counter for how many scores are currently loaded
    
    readBuffer              BYTE 5000 DUP(0)    ; buffer to hold data read from the file
    writeBuffer             BYTE 5000 DUP(0)  ; buffer to prepare data to write to the file
    temporaryNumberString   BYTE 20 DUP(0)        ; temp buffer for converting numbers to strings
    
    stringRankHeader        BYTE "NAME                  SCORE",0Dh,0Ah ; main header for leaderboard 
                            BYTE "--------------------------",0Dh,0Ah,0 
    stringNoScores          BYTE "No scores saved yet.",0 ; if file does not exist
    

    ; 0=road, 1=wall, 2=obstacle, 4=bonus

    mapGridArray BYTE 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                 BYTE 1,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,1,1,1,1 
                 BYTE 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 
                 BYTE 1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1 
                 BYTE 1,0,1,0,0,0,0,0,0,0,0,0,2,0,0,0,0,1,0,1 
                 BYTE 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1 
                 BYTE 1,1,1,0,1,1,1,0,0,1,0,0,0,0,0,1,0,0,0,1 
                 BYTE 1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,1  
                 BYTE 1,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,1  
                 BYTE 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1  
                 BYTE 1,0,1,0,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,1 
                 BYTE 1,0,0,0,1,4,0,0,0,0,0,0,0,0,1,1,1,1,0,1  
                 BYTE 1,1,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1  
                 BYTE 1,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,1 
                 BYTE 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 
                 BYTE 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 
                 BYTE 1,0,0,0,0,0,1,1,0,1,0,1,1,1,1,0,1,0,0,1  
                 BYTE 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1  
                 BYTE 1,0,2,0,0,0,0,4,0,0,0,0,0,0,2,0,0,0,2,1 
                 BYTE 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 

.code
main PROC
    call Randomize    ; it initialize the random number generator seed

MainMenuLoopLabel: ; label for the start of the main menu loop
    call Clrscr ; clear the console screen
    mov  eax, 11 + (0 * 16)   ; set text color to lightcyan on black 
    call SetTextColor ; apply the color
    mov  edx, OFFSET stringHeader ; move address of the title string to edx
    call WriteString ; print the title string
    call Crlf   ; print a new line
    call Crlf      ; print another new line
    
    mov  eax, 10 + (0 * 16)      ; set text color to lightgreen
    call SetTextColor   ; now apply the color
    mov  edx, OFFSET stringOptionOne ; move address of option 1 string to edx
    call WriteString   ; print option no 1
    call Crlf   ; print new line
    
    mov  edx, OFFSET stringOptionTwo    ;  move address of option 2 string to edx
    call WriteString    ; print option 2
    call Crlf ; print new line
    
    mov  eax, 14 + (0 * 16)   ; set text color to yellow
    call SetTextColor ; apply the color
    mov  edx, OFFSET stringOptionThree   ; now  move address of option 3 string to edx
    call WriteString ; print option 3
    call Crlf ; print new line
    
    mov  eax, 9 + (0 * 16)    ; set text color to lightblue
    call SetTextColor ; apply the color
    mov  edx, OFFSET stringOptionFour ; move address of option 4 string to edx
    call WriteString ; print option 4
    call Crlf ; print new line
    
    mov  eax, 13 + (0 * 16)   ; set text color to  purple
    call SetTextColor ; apply the color
    mov  edx, OFFSET stringOptionFive ; move address of option 5 string to edx
    call WriteString ; print option 5
    call Crlf ; print new line
    call Crlf ; print another new line
    
    mov  eax, 12 + (0 * 16)   ; set text color to lightred
    call SetTextColor ; apply the color
    mov  edx, OFFSET stringExit ; move address of exit string to edx
    call WriteString ; print exit string
    call Crlf ; print new line
    
    mov  eax, 15 + (0 * 16)   ; set text color to white
    call SetTextColor ; apply color
    call Crlf ; print new line
    mov  edx, OFFSET stringPrompt ; move address of prompt string to edx
    call WriteString ; print prompt
    call ReadChar    ; now waiting for user input 
    
    ; --- audio trigger: click ---
    push eax    ; save user input to stack so we don't lose it
    call PlaySoundClick   ; calling the sound procedure for a click
    pop eax      ; restore back eax from stack
    
    ; == compairing input and then jump to that spesific section if equal ==
  
    cmp  al, '1'
    je   NewGameLabel  
    cmp  al, '2'  
    je   ContinueGameLabel 
    cmp  al, '3' 
    je   SettingsLabel 
    cmp  al, '4' 
    je   LeaderboardLabel 
    cmp  al, '5' 
    je   InstructionsLabel 
    cmp  al, 27 ; asci of ecs
    je   ExitApplicationLabel 
    jmp  MainMenuLoopLabel      ; if nothing valid pressed, restart menu loop



NewGameLabel: ; start of new game setup
    call Clrscr ; clear the screen
    
    call ResetGameMap    ; call helper to clear old items from map
    
    mov  edx, OFFSET stringNamePrompt   ; prepare name prompt string
    call WriteString    ; print name prompt
    mov  edx, OFFSET playerNameBuffer      ; it point to the buffer to store name
    mov  ecx, 20 ; max 20 characters to read
    call ReadString ; read user name
    
    mov  currentScore, 0   ; reset score to 0
    mov  passengersDeliveredCount, 0    ; reset delivery count to 0
    mov  playerXPosition, 1    ; reset player x to start position
    mov  playerYPosition, 1  ; reset player y to start position
    mov  isCarryingPassenger, 0  ; reset carrying status to false as it is start
    mov  isGameActive, 1   ; set game active flag to true
    mov  gameSpeedDelay, 250    ; set initial game speed
    mov  currentMessageString, OFFSET stringMessageNull   ; clear any old messages that appears on the screen
    
    call GetMseconds   ; get current system time in ms
    mov  startTime, eax    ; save it as the game start time
    
    ; == initialize all the npc==
    mov npcOneX, 15 ; set npc 1 x start
    mov npcOneY, 2   ; set npc 1 y start
    mov npcOneDirectionX, -1   ; set npc 1 moving left
    mov npcOneDirectionY, 0 ; set npc 1 no vertical move

    mov npcTwoX, 2   ; set npc 2 x start
    mov npcTwoY, 15    ; set npc 2 y start
    mov npcTwoDirectionX, 0 ; set npc 2 no horizontal move
    mov npcTwoDirectionY, -1 ; set npc 2 moving up

    mov npcThreeX, 10   ; set npc 3 x start
    mov npcThreeY, 17  ; set npc 3 y start
    mov npcThreeDirectionX, 1 ; set npc 3 moving right
    mov npcThreeDirectionY, 0   ; set npc 3 no vertical move

    mov npcFourX, 17   ; set npc 4 x start
    mov npcFourY, 5  ; set npc 4 y start
    mov npcFourDirectionX, 0   ; set npc 4 no horizontal move
    mov npcFourDirectionY, 1 ; set npc 4 moving down

    ; make ncp on the map
    mov esi, OFFSET mapGridArray ; point esi to the map grid array
    
    ; npc 1
    mov eax, npcOneY    ; load y pos
    mov ebx, MAP_SIZE_CONSTANT  ; load map width
    mul ebx       ; now in this  eax = y * width
    add eax, npcOneX     ; eax = (y * width) + x (flat index)
    mov BYTE PTR [esi + eax], 3   ; set this grid cell to 3 (npc)

    ; npc 2

    mov eax, npcTwoY   ; load y pos
    mov ebx, MAP_SIZE_CONSTANT   ; load map width
    mul ebx   ; multiply
    add eax, npcTwoX ; add x
    mov BYTE PTR [esi + eax], 3  ; mark npc on grid

    ; npc 3
    mov eax, npcThreeY  ; load y pos
    mov ebx, MAP_SIZE_CONSTANT   ; load map width
    mul ebx ; multiply
    add eax, npcThreeX ; add x
    mov BYTE PTR [esi + eax], 3       ; mark npc on grid

    ; npc 4
    mov eax, npcFourY   ; load y pos
    mov ebx, MAP_SIZE_CONSTANT    ; load map width
    mul ebx ; multiply
    add eax, npcFourX ; add x
    mov BYTE PTR [esi + eax], 3    ;  mark npc on grid
    
    call InitializePassengers   ; place passengers on the map randomly
    call Clrscr  ; clear screen as  before loop starts
    call GameLoopProcedure    ; start the main game loop
    jmp  MainMenuLoopLabel ; when game ends, return to menu

ContinueGameLabel:   ; start of continue game logic
    cmp  isGameActive, 1   ; check if a game is currently running
    jne  MainMenuLoopLabel ; if not, go back to main menu
    call Clrscr ; clear screen
    call GameLoopProcedure ; resume the game loop
    jmp  MainMenuLoopLabel ; return to menu when done

SettingsLabel:   ; start of settings menu
    call Clrscr     ; clear screen
    mov  eax, 13 + (0 * 16) ; set color to purple
    call SetTextColor    ; apply color
    mov  edx, OFFSET stringSettingsTitle   ; load settings title
    call WriteString ; print title
    call Crlf 
    call Crlf ; new line
    
    mov  eax, 11 + (0 * 16)    ; set color to lightcyan
    call SetTextColor   ; apply color
    mov  edx, OFFSET stringSettingsSubtitle   ; load subtitle
    call WriteString  ; print subtitle
    call Crlf  ; new line
    
    mov  eax, 15 + (0 * 16)    ; set color to white
    call SetTextColor  ; apply color
    mov  edx, OFFSET stringSettingOne   ; load option 1
    call WriteString ; print it
    call Crlf ; new line
    mov  edx, OFFSET stringSettingTwo     ; load option 2
    call WriteString ; print it
    call Crlf ; new line
    mov  edx, OFFSET stringSettingThree ; load option 3
    call WriteString ; print it
    call Crlf 
    call Crlf ; new line
    
    mov  eax, 10 + (0 * 16)    ; this set color to green
    call SetTextColor ; apply color
    mov  edx, OFFSET stringPrompt ; load prompt
    call WriteString ; print prompt
    
    call ReadChar ; read user choice
    push eax ; save input
    call PlaySoundClick ; play sound
    pop eax ; restore input that save before

    ; check the option no 3 (game settings and mode, compare and if equal , if jump to set color)
    cmp  al, '1' 
    je   SettingSetYellow 
    cmp  al, '2' 
    je   SettingSetRed 
    cmp  al, '3'
    je   SettingSetRandomMode 
    jmp  MainMenuLoopLabel ; else return to menu
    
    SettingSetYellow: 
        mov taxiTypeSelected, 1    ; set variable to 1
        jmp SettingDone  ; go to finish
    SettingSetRed:  
        mov taxiTypeSelected, 2      ; set variable to 2
        jmp SettingDone ; go to finish
        
    SettingSetRandomMode: ; logic for random
        mov eax, 2 ; set range for random (0 to 1)
        call RandomRange ; generate random number
        inc eax ; make it 1 or 2
        mov taxiTypeSelected, eax     ; save it
        
        call Clrscr    ; clear screen for sub-menu
        mov  eax, 13 + (0 * 16) ; set color
        call SetTextColor ; apply
        mov  edx, OFFSET stringModeTitle ; load mode title
        call WriteString ; print
        call Crlf ; new line
        call Crlf ; new line
        mov  eax, 15 + (0 * 16) ; set color white
        call SetTextColor ; apply
        mov  edx, OFFSET stringModeOne ; load mode 1 text
        call WriteString ; print
        call Crlf ; new line
        mov  edx, OFFSET stringModeTwo ; load mode 2 text
        call WriteString ; print
        call Crlf ; new line
        mov  edx, OFFSET stringModeThree ; load mode 3 text
        call WriteString ; print
        call Crlf ; new line
        call Crlf ; new line
        
        mov  eax, 10 + (0 * 16) ; set color green
        call SetTextColor ; apply
        mov  edx, OFFSET stringPrompt ; load prompt
        call WriteString ; print
        
        call ReadChar ; read char
        push eax ; save char
        call PlaySoundClick ; sound
        pop eax ; restore char

        cmp al, '1' ; check 1
        je SettingSetCareer ; set career
        cmp al, '2' ; check 2
        je SettingSetTime ; set time
        jmp SettingSetEndless ; default endless
        
        SettingSetCareer:     ; career setup
            mov gameModeSelected, 1 ; set mode to 1
            jmp ModeSelectionDone ; done 
        SettingSetTime: ; time setup
            mov gameModeSelected, 2 ; set mode to 2
            jmp ModeSelectionDone    ; done 
        SettingSetEndless:       ; endless setup
            mov gameModeSelected, 0 ; set mode to 0
            jmp ModeSelectionDone ;done
            
        ModeSelectionDone:  ; confirm mode
            mov edx, OFFSET stringModeSelected    ; load confirmation string
            call WriteString ; print it
            mov eax, 500     ; set delay 500ms means .5 secs
            call Delay ; wait
            jmp MainMenuLoopLabel ; return to menu

    SettingDone:    ; confirm general setting
        mov  eax, 15 + (0 * 16)     ; set color white
        call SetTextColor ; apply
        call Crlf   ; new line
        mov edx, OFFSET stringSettingSelected   ; load success string
        call WriteString ; print
        mov eax, 500 ; delay time
        call Delay ; wait
        jmp MainMenuLoopLabel ; return to menu

LeaderboardLabel:     ; start of leaderboard
    call Clrscr ; clear screen
    mov  eax, 9 + (0 * 16) ; set color blue
    call SetTextColor ; apply
    mov  edx, OFFSET stringRankHeader   ; load header text
    call WriteString ; print header
    
    mov  eax, 15 + (0 * 16)    ; set color white
    call SetTextColor ; apply
    
    mov  edx, OFFSET filenameString    ; load filename
    call OpenInputFile    ; open the file for reading
    cmp  eax, INVALID_HANDLE_VALUE    ; check if file exists
    je   NoFileLabel    ; if error, jump to no file
    
    mov  fileHandle, eax   ; save file handle
    mov  edx, OFFSET readBuffer   ; point to buffer
    mov  ecx, 5000    ; max bytes to read
    call ReadFromFile    ; read file content
    mov  readBuffer[eax], 0    ; null terminate the string
    mov  eax, fileHandle  ; get handle
    call CloseFile  ; close file
    
    mov  edx, OFFSET readBuffer  ; point to buffer
    call WriteString ; print the file content
    jmp  LeaderboardDoneLabel     ; skip error message and done reading

    NoFileLabel:    ; if file missing
    mov  edx, OFFSET stringNoScores    ; load error string
    call WriteString      ; print that no score exist

    LeaderboardDoneLabel:    ; finish leaderboard
    call Crlf   ; new line
    call WaitMsg   ; wait for user key
    call PlaySoundClick    ; sound for click
    jmp  MainMenuLoopLabel    ; return to menu

InstructionsLabel:   ; start of instructions
    call Clrscr   ; clear screen
    mov  eax, 15 + (0 * 16) ; set color white
    call SetTextColor ; apply
    mov  edx, OFFSET stringInstructionTitle    ; load title
    call WriteString ; print
    call Crlf   ; new line
    call Crlf  ; new line
    
    mov  eax, 15 + (0 * 16) ; set color white
    call SetTextColor ; apply
    
    mov  edx, OFFSET stringInstructionOne ; load line 1
    call WriteString    
    call Crlf   
    mov  edx, OFFSET stringInstructionTwo ; load line 2
    call WriteString
    call Crlf 
    mov  edx, OFFSET stringInstructionThree ; load line 3
    call WriteString
    call Crlf 
    mov  edx, OFFSET stringInstructionFour ; load line 4
    call WriteString 
    call Crlf 
    mov  edx, OFFSET stringInstructionFive ; load line 5
    call WriteString 
    call Crlf 
    mov  edx, OFFSET stringInstructionSix ; load line 6
    call WriteString
    call Crlf
    call Crlf 

    mov  eax, 7 + (0 * 16) ; set color gray
    call SetTextColor ; apply
    mov  edx, OFFSET stringContinue ; load continue and move back 
    call WriteString ; print
    
    call WaitMsg    ; wait for user
    call PlaySoundClick ; sound
    jmp  MainMenuLoopLabel   ; return to menu

ExitApplicationLabel: ; exit logic
    exit ; call system exit
main ENDP ; end of main procedure



; helper procedures

ResetGameMap PROC     ; function to clean the map
    mov ecx, MAP_SIZE_CONSTANT * MAP_SIZE_CONSTANT     ; set loop count to total grid cells (400)
    mov esi, OFFSET mapGridArray     ; point to map array
    xor ebx, ebx    ; clear ebx which is the index counter
MapCleaningLoop:  ; loop start
    mov al, [esi + ebx]     ; get value at current cell
    cmp al, 3    ; check if it is an npc 
    je  CleanCellLabel    ; if yes, clean it  ; we do not clean (bonus) because we should keep bonuses
    jmp NextCellLabel ; skip to next

CleanCellLabel: ; clean logic
    mov byte ptr [esi + ebx], 0    ; set cell to 0 (road)
NextCellLabel:   ; increment logic
    inc ebx ; next index
    loop MapCleaningLoop   ; decrement ecx and repeat
    ret     ; return from procedure
ResetGameMap ENDP    ; end procedure

; realtime game loop

GameLoopProcedure PROC    ;  main game loop function
    PlayLabel:   ; label for loop start
        mov dl, 0    ; set cursor x to 0
        mov dh, 0  ; set cursor y to 0
        call Gotoxy ; move cursor to top-left corner

        call DrawBoardProcedure   ; draw the grid and all the ui 
        
        cmp gameModeSelected, 2   ; check if time mode is on
        jne SkipTimeCheckLabel  ;  if not, skip time logic
        
        call GetMseconds   ; get current time
        sub  eax, startTime    ; subtract start time  to get elapsed time
        cmp  eax, timeLimitDuration   ; compare elapsed with limit
        jae  GameOverTimeLabel    ; if greater than or equal, then time is up
        
        SkipTimeCheckLabel: ; label to skip time check

        mov eax, gameSpeedDelay    ; load current speed delay
        call Delay    ; wait for that duration 
        call UpdateNonPlayerCharacters ; move the npc
        call CheckNonPlayerCharacterCollision    ; check if npc hit player
        
        call ReadKey   ; check for keyboard input that is not blocking
        jz   NoInputLabel ; if zero flag set, no key pressed
        
        push playerXPosition   ; save current x to stack for backup
        push playerYPosition  ; save current y to stack for backup
        
        ; Now check all the character and compare and if equal , then call that label related to it

        cmp  al, 'w' 
        je   MoveUpLabel  
        cmp  al, 's'
        je   MoveDownLabel
        cmp  al, 'a' 
        je   MoveLeftLabel
        cmp  al, 'd' 
        je   MoveRightLabel
        cmp  al, ' ' 
        je   DoActionLabel
        cmp  al, 27 
        je   ReturnToMenuLabel ; exit to menu
        
        pop  playerYPosition    ; restore x as if invalid input
        pop  playerXPosition   ; restore y as if invalid input
        jmp  PlayLabel   ; restart loop

    MoveUpLabel: ; logic for moving up
        cmp  playerYPosition, 0  ; check if at top edge
        jle  IgnoreMoveLabel  ; if yes, don't move
        dec  playerYPosition    ; decrease y (move up)
        jmp  CheckCollisionLabel  ; physical movement check


    MoveDownLabel: ; logic for moving down
        cmp  playerYPosition, 19 ; check if at bottom edge
        jge  IgnoreMoveLabel; if yes then donot move
        inc  playerYPosition   ; increase y (move down)
        jmp  CheckCollisionLabel ; physical movement check


    MoveLeftLabel: ; logic for moving left
        cmp  playerXPosition, 0 ; check if at left edge
        jle  IgnoreMoveLabel ; if it is then donot move 
        dec  playerXPosition   ; decrease x (move left)
        jmp  CheckCollisionLabel; physical movement check


    MoveRightLabel: ; logic for moving right
        cmp  playerXPosition, 19 ; check if at right edge
        jge  IgnoreMoveLabel ; if it is then donot move 
        inc  playerXPosition ; increase x (move right)
        jmp  CheckCollisionLabel; physical movement check

    IgnoreMoveLabel:   ; logic to cancel move
        pop  playerYPosition    ; restore original y
        pop  playerXPosition   ; restore original x
        jmp  PlayLabel  ; restart loop
        
    DoActionLabel: ; logic for spacebar
        pop playerYPosition     ; clear stack backup
        pop playerXPosition  ; clear stack backup
        call HandleSpacebarAction    ; call interaction function
        jmp PlayLabel  ; restart loop

    CheckCollisionLabel: ; physical movement check
        cmp taxiTypeSelected, 2 ; check if red taxi (slow)
        jne CheckGridLabel ; if not, skip delay
        mov eax, 100 ; load extra delay
        call Delay ; wait to slow the red taxi 

    CheckGridLabel:   ; check what is on the grid
        ;collision with passenger
        mov edi, 0     ; to initialize the loop counter
    CheckPassengerHitLoop:    ; loop through the  passengers
        cmp edi, MAXIMUM_PASSENGERS   ; check if end of array
        je  CheckMapGridLabel  ; if done then check walls
        
        mov esi, OFFSET passengerActiveStatus    ; point to status array
        mov eax, [esi + edi*4]  ; get status
        cmp eax, 1 ; check if active
        jne NextPassengerHit   ; if not then skip
        
        mov esi, OFFSET passengerXPositions ; point to x array
        mov eax, [esi + edi*4]   ; get x
        cmp eax, playerXPosition    ; compare with player x
        jne NextPassengerHit   ; if different, skip
        
        mov esi, OFFSET passengerYPositions ; point to y array
        mov eax, [esi + edi*4] ; get y
        cmp eax, playerYPosition ; compare with player y
        jne NextPassengerHit ;   if different then skip
        
        ; ==    hit passenger logic    ==
        call PlaySoundCrash    ; audio feedback for crash
        pop playerYPosition       ; restore y means undo move of y pos
        pop playerXPosition     ; restore x means undo move of x pos)
        sub currentScore, 5    ; deduct 5 points
        mov currentMessageString, OFFSET stringMessageHitPassenger     ; set alert message
        jmp PlayLabel   ; restart loop

    NextPassengerHit: ; check next passenger
        inc edi  ; increment index
        jmp CheckPassengerHitLoop ; repeat loop

    CheckMapGridLabel:   ; check static map objects
        mov  eax,  playerYPosition ; load y
        mov  ebx, MAP_SIZE_CONSTANT    ; load width
        mul  ebx    ;   calculate the row offset
        add  eax,  playerXPosition ; add x to get index
        mov  esi, OFFSET mapGridArray   ; point to map
        mov  bl, [esi + eax]   ;  get value at map cell
        
        cmp  bl, 1    ; check if wall
        je   HitWallLabel ; jump to hit wall
        cmp  bl, 2    ; check if obstacle
        je   HitObstacleLabel ; jump to hit obstacle
        cmp  bl, 3    ; check if npc 
        je   HitNPCLabel  ; jump to hit npc
        cmp  bl, 4    ; check if bonus 
        je   GetBonusLabel   ; jump to get bonus
        
        mov currentMessageString, OFFSET stringMessageNull   ; clear message if safe
        pop  ebx      ; clear stack  old x 
        pop  ebx      ; clear stack means old y
        jmp  PlayLabel ; restart loop

    HitWallLabel:   ; logic for hitting wall
        call PlaySoundGameOver  ; play game over sound
        pop playerYPosition    ; restore y
        pop playerXPosition   ; restore x
        mov isGameActive, 0 ; stop game
        call SaveScoreToFileProcedure ; save score
        call Clrscr ; clear screen
        mov eax, 12 + (0 * 16)   ; set red color
        call SetTextColor ; apply
        mov dh, 10   ; set cursor y
        mov dl, 10  ; set cursor x
        call Gotoxy ; move cursor
        mov edx, OFFSET stringGameOver    ; load game over string
        call WriteString   ; print it
        jmp ShowWaitLabel   ; go to wait logic

    HitObstacleLabel: ; logic for obstacle
        call PlaySoundCrash    ; play crash sound
        pop playerYPosition   ; restore y 
        pop playerXPosition  ; restore x
        cmp taxiTypeSelected, 1   ; check if yellow taxi
        je  YellowTaxiHitObstacle    ; different penalty
        sub currentScore, 2   ; red taxi loses 2 points
        mov currentMessageString, OFFSET stringMessageWallRed    ; set message
        jmp PlayLabel  ; restart

    YellowTaxiHitObstacle:    ; yellow penalty
        sub currentScore, 4 ; yellow taxi loses 4 points
        mov currentMessageString, OFFSET stringMessageWallYellow ; set message
        jmp PlayLabel ; restart

    HitNPCLabel: ; logic for hitting car
        call PlaySoundCrash    ; play crash sound
        pop playerYPosition ; restore y
        pop playerXPosition ; restore x
        cmp taxiTypeSelected, 1 ; check if yellow taxi
        je  YellowTaxiHitCar ; different penalty
        sub currentScore, 3 ; red taxi loses 3 points
        mov currentMessageString, OFFSET stringMessageCarRed ; set message
        jmp PlayLabel   ; restart

    YellowTaxiHitCar: ; yellow penalty
        sub currentScore, 2 ; yellow taxi loses 2 points
        mov currentMessageString, OFFSET stringMessageCarYellow   ; set message
        jmp PlayLabel ; restart


    GetBonusLabel: ; logic for bonus
        call PlaySoundBonus    ; play bonus sound
        add  currentScore, 10 ; add 10 points
        mov  eax, playerYPosition ; calculate map index
        mov  ebx, MAP_SIZE_CONSTANT ; width
        mul  ebx ; row offset
        add  eax, playerXPosition   ; column offset
        mov  esi, OFFSET mapGridArray   ; point to map
        mov  BYTE PTR [esi + eax], 0 ; remove bonus and set it to road 
        mov  currentMessageString, OFFSET stringMessageBonus ; set message
        pop  ebx    ; clear stack
        pop  ebx   ; clear stack
        jmp  PlayLabel  ; restart

    NoInputLabel:   ; if no key pressed
        jmp PlayLabel  ; just loop again

    ReturnToMenuLabel:  ; exit loop
        pop  playerYPosition   ; clean stack
        pop  playerXPosition  ; clean stack
        ret    ; return to main menu
        
    GameOverTimeLabel:   ; time up logic
        call PlaySoundGameOver ; sound
        mov isGameActive, 0  ; stop game
        call SaveScoreToFileProcedure ; save
        call Clrscr   ; clear
        mov eax, 12 + (0 * 16)   ; red color
        call SetTextColor  ; apply
        mov dh, 10  ;  cursor y
        mov dl, 10   ; cursor x
        call Gotoxy ; move
        mov edx, OFFSET stringTimeUp ; load message
        call WriteString ; print
        jmp ShowWaitLabel ; wait
        
    GameOverCareerLabel:   ; career win logic
        call PlaySoundGameOver  ; sound
        mov isGameActive, 0 ; stop game
        call SaveScoreToFileProcedure ; save
        call Clrscr  ; clear
        mov eax, 10 + (0 * 16)  ; green color
        call SetTextColor ; apply
        mov dh, 10   ; cursor y
        mov dl, 10  ; cursor x
        call Gotoxy ; move
        mov edx, OFFSET stringCareerWin  ; load message
        call WriteString ; print
        
    ShowWaitLabel:   ; wait screen logic
        mov dh, 12 ; cursor y
        mov dl, 10 ; cursor x
        call Gotoxy ; move to that specific point  
        call WaitMsg     ; wait for input
        ret ; return to main 
GameLoopProcedure ENDP    ; end procedure

; sorted leaderboard logic

SaveScoreToFileProcedure PROC  ; function to save high scores
    mov totalScoresCount, 0   ; reset counter
    mov edx, OFFSET filenameString  ; load filename
    call OpenInputFile ; open file
    cmp eax, INVALID_HANDLE_VALUE  ; check validity
    je  AddCurrentOnlyLabel   ; if new file, just add current
    
    mov fileHandle, eax   ; save handle
    mov edx, OFFSET readBuffer   ; point to buffer
    mov ecx, 5000   ; read size
    call ReadFromFile ; read
    mov readBuffer[ eax], 0   ; null terminate
    mov eax, fileHandle    ; get handle
    call CloseFile ; close
    
    call ParseBufferToArrays   ; convert text to numbers/arrays

AddCurrentOnlyLabel:  ; adding new score
    mov eax, totalScoresCount   ; get count
    cmp eax, MAX_LEADERBOARD_ENTRIES ; check max
    jge SkipAddLabel ; if full, skip it
    
    mov ebx, currentScore ; get current score
    mov scoresArray[eax*4], ebx   ; save to array
    
    mov ebx, 21 ; name length
    mul ebx ; calculate offset
    mov edi, OFFSET namesArray   ; point to names
    add edi, eax   ; go to slot
    mov esi, OFFSET playerNameBuffer   ; point to player name
    mov ecx, 20 ; length
    CopyNameLoop2:   ; loop to copy name string
        mov al, [esi]    ; get char
        mov [edi], al   ; save char
        inc esi    ; next source
        inc edi  ; next dest
        loop CopyNameLoop2   ; repeat
        
    inc totalScoresCount ; increment count

SkipAddLabel:  ; done adding
    call SortScoresProcedure ; sort the list
    call WriteArraysToFile   ; save back to file
    ret ; return
SaveScoreToFileProcedure ENDP ; end procedure

SortScoresProcedure PROC   ; bubble sort for scores
    cmp totalScoresCount, 2   ; need at least 2 to sort
    jl  SortDoneLabel   ; if less, exit

    mov ecx, totalScoresCount   ; loop counter
    dec ecx ; n-1
    
    OuterSortLoop:    ; outer loop
        push ecx    ; save counter
        mov esi, 0    ; index 0
        
        InnerSortLoop:   ; inner loop
            mov eax, scoresArray[esi*4] ; get score a
            mov ebx, scoresArray[esi*4 + 4] ; get score b
            
            cmp eax, ebx   ; compare a and b
            jge NoSwapLabel ; if a >= b then dont swap 
            
            mov scoresArray[esi*4], ebx   ; swap score
            mov scoresArray[esi*4 + 4], eax   ; swap score
            
            push esi    ; save index
            push edi   ; save registers
            push ecx   ; again  save registers
            
            mov eax, esi ; index
            mov ebx, 21   ; name size
            mul ebx  ; offset
            mov edi, OFFSET namesArray   ; name array
            add edi, eax ; position a
            
            mov edx, edi ; copy position a
            add edx, 21  ; position b is a + 21
            
            mov ecx, 21 ; copy 21 bytes
            SwapNameBytesLoop: ; swap names byte by byte
                mov al, [edi]   ; get byte a
                mov bl, [edx]  ; get byte b
                mov [edx], al   ; store a in b
                mov [edi], bl    ; store b in a
                inc edi ; move next byte
                inc edx ;move  next byte
                loop SwapNameBytesLoop ; repeat
            
            pop ecx ; restore
            pop edi 
            pop esi 
            
        NoSwapLabel: ; skip swap
            inc esi ; next index
            mov eax, totalScoresCount ; get max
            dec eax ; max-1
            cmp esi, eax ; compare current with max
            jl  InnerSortLoop ; repeat inner
            
        pop ecx ; restore the  outer counter
        loop OuterSortLoop    ; repeat outer
        
    SortDoneLabel:
    ret ; return
SortScoresProcedure ENDP ; end procedure

ParseBufferToArrays PROC     ; parses text file into arrays
    mov esi, OFFSET readBuffer   ; point to buffer
    mov edi, 0   ; index 0

    ParseLoop: ; main parsing loop
        cmp byte ptr [esi], 0   ; check end of string
        je  ParseEnd ; exit
        
        cmp byte ptr [esi], 0Ah   ; check newline
        je  SkipCharLabel ; skip
        cmp byte ptr [esi], 0Dh   ; check carriage return
        je  SkipCharLabel ; skip
        cmp byte ptr [esi], ' '   ; check space
        je  SkipCharLabel ; skip
        
        push edi   ; save index
        mov eax, edi   ; index
        mov ebx, 21   ; name size
        mul ebx    ; offset
        mov edx, OFFSET namesArray   ; name array
        add edx, eax ; position
        
        mov ecx, 20   ; max chars
        NameCopyLoop: ; copy name logic
            mov al, [esi] ; get char
            cmp al, ' '   ; stop at space
            je  NameEndedLabel ; end name
            cmp al, 0Dh   ; stop at cr
            je  NameEndedLabel ; end name
            cmp al, 0     ; stop at null
            je  NameEndedLabel ; end name
            
            mov [edx], al ; store char
            inc esi ; next source
            inc edx ; next dest
            dec ecx ; dec counter
            jnz NameCopyLoop ; repeat
        NameEndedLabel: ; name done
        mov byte ptr [edx], 0 ; null terminate
        
        SkipSpacesLoop:   ; skip whitespace between name and score
            cmp byte ptr [esi], ' '   ; check space
            jne CheckScoreStart ; if not space, score starts
            inc esi ; next
            jmp SkipSpacesLoop  ; repeat
        CheckScoreStart:   ; score parsing
            cmp byte ptr [esi], 0Dh    ; check validity
            je  SkipLinePopLabel ; error or skip
            cmp byte ptr [esi], 0Ah ; check validity
            je  SkipLinePopLabel ; error or skip
            
        call ParseIntegerFromBuffer ; convert text number to integer
        
        pop edi ; restore index
        mov scoresArray[edi*4], eax ; save score
        inc edi ; increment count
        mov totalScoresCount, edi    ; update global count
        
        FindNextLineLoop: ; move pointer to next line
            cmp byte ptr [esi], 0 ; check end
            je  ParseEnd ; exit
            cmp byte ptr [esi], 0Ah ; check line feed
            je  NextLineFound ; found
            inc esi ; next
            jmp FindNextLineLoop ; repeat


        NextLineFound: ; found new line
            inc esi ; move past lf
            cmp edi, MAX_LEADERBOARD_ENTRIES ; check limit
            jge ParseEnd ; if full, stop
            jmp ParseLoop ; process next line
            
        SkipLinePopLabel:   ; error handling
            pop edi ; clean stack
            inc esi ; next
            jmp ParseLoop    ; retry
        SkipCharLabel:  ; skip char
            inc esi ; next
            jmp ParseLoop ; retry
            
    ParseEnd: ; done parsing 
    ret ; return
ParseBufferToArrays ENDP ; end procedure

WriteArraysToFile PROC  ; writes arrays back to text file
    mov edx, OFFSET filenameString   ; load filename
    call CreateOutputFile ; create or overwrite file
    mov fileHandle, eax  ; save handle
    
    mov ecx, totalScoresCount ; loop count
    mov esi, 0 ; index
    
    WriteLoop: ; main write loop
        push ecx ; save counter
        
        mov eax, esi     ; index
        mov ebx, 21  ; name size
        mul ebx   ; offset
        mov edi, OFFSET namesArray   ; name array
        add edi, eax   ; position
        
        mov edx, OFFSET writeBuffer  ; output buffer
        push esi ; save index
        mov esi, edi ; source which is name
        mov edi, edx ; dest that is buffer 
        mov ecx, 0  ; char counter
        
        CopyNameBackLoop:  ; copy name to buffer
            mov al, [esi] ; get char
            cmp al, 0 ; check null
            je NameDoneBackLabel ;   end
            mov [edi], al ; store
            inc esi ; next
            inc edi ; next
            inc ecx ; inc count
            jmp CopyNameBackLoop ; repeat
        NameDoneBackLabel:  ; name copied
        pop esi ; restore index
        
        mov ebx, 22   ; target padding
        sub ebx, ecx ; calculate spaces needed
        cmp ebx, 2 ; min spacing
        jge PadLoop   ; if enough, pad
        mov ebx, 2   ; force min spacing
        PadLoop:   ; padding loop
            mov byte ptr [edi], ' ' ; add space
            inc edi ; next
            dec ebx   ; dec count
            jnz PadLoop ; repeat
        
        mov eax, scoresArray[esi*4] ; get score
        push esi ; save index
        mov edx, OFFSET temporaryNumberString    ; temp buffer
        call IntegerToString   ; convert int to string
        push esi   ; save esi
        mov esi, OFFSET temporaryNumberString    ; source (string)
        CopyScoreBackLoop:  ; copy score string to buffer
            mov al, [esi] ; get char
            cmp al, 0 ; check null
            je ScoreDoneBackLabel ; end
            mov [edi], al   ; store
            inc esi ; next
            inc edi ; next
            jmp CopyScoreBackLoop ; repeat
        ScoreDoneBackLabel: ; score copied
        pop esi ; restore
        pop esi ; restore
        
        mov al, 0Dh   ; add cr
        mov [edi], al ; store
        inc edi ; next
        mov al, 0Ah ; add lf
        mov [edi], al ; store
        inc edi ; next
        
        push eax ; save eax
        mov eax, fileHandle   ; get handle
        mov edx, OFFSET writeBuffer   ; buffer start
        mov ecx, edi  ; end pointer
        sub ecx, OFFSET writeBuffer  ; calculate length
        call WriteToFile     ; write line to file
        pop eax  ; restore
        
        inc esi ; next score
        pop ecx ; restore counter
        dec ecx  ; dec counter
        jnz WriteLoop ; repeat
        
    mov eax, fileHandle ; get handle
    call CloseFile ; close
    ret ; return
WriteArraysToFile ENDP ; end procedure

IntegerToString PROC USES eax ebx ecx edx esi     ; helper to convert int to string
    mov esi, edx   ; point to buffer
    cmp eax, 0  ; check sign
    jge PositiveLabel   ; if positive, skip
    mov byte ptr [esi], '-'  ; add minus sign
    inc esi  ; move pointer
    neg eax   ; make positive
    PositiveLabel:  ; processing positive
    mov ebx, 10 ; divisor
    mov ecx, 0    ; stack counter
    DivisionLoop:   ; get digits
        mov edx, 0  ; clear remainder
        div ebx  ; divide by 10
        push edx  ; save remainder (digit)
        inc ecx  ; inc count
        cmp eax, 0    ; check if done
        jne DivisionLoop ; repeat
    PopCharactersLoop: ; reconstruct string
        pop eax ; get digit
        add al, '0'   ; convert to ascii
        mov [esi], al ; store
        inc esi ; next
        loop PopCharactersLoop   ; repeat
    mov byte ptr [esi], 0 ; null terminate
    ret ; return
IntegerToString ENDP ; end procedure

ParseIntegerFromBuffer PROC ; helper to parse string to int
    push ebx     ; save regs
    push ecx   ; same save regs
    push edx    ; save regs again
    mov eax, 0 ; result accumulator
    mov ebx, 0 ; sign flag
    cmp byte ptr [esi], '-' ; check negative
    jne PositiveNumber ; if not, skip
    inc ebx ; set negative flag
    inc esi ; skip '-'
    PositiveNumber: ; process digits
    ParseIntLoop: ; loop chars
        mov dl, [esi] ; get char
        cmp dl, '0'   ; check lower bound
        jl  ParseIntDone  ; if not digit, done
        cmp dl, '9'  ; check upper bound
        jg  ParseIntDone  ; if not digit, done
        sub dl, '0'    ; convert ascii to int
        imul eax, 10 ; shift current result
        movzx ecx, dl ; move digit to ecx
        add eax, ecx ; add digit
        inc esi    ; next char
        jmp ParseIntLoop ; repeat
         
    ParseIntDone: ; done parsing
        cmp ebx, 1   ; check sign flag
        jne ParseIntReturn ; if pos, return
        neg eax ; make negative
    ParseIntReturn: ; return
        pop edx ; restore regs
        pop ecx ; restore regs
        pop ebx ; restore regs
        ret ; return
ParseIntegerFromBuffer ENDP ; end procedure

; spacebar interaction logic

HandleSpacebarAction PROC ; logic for pickup and drop
    cmp isCarryingPassenger, 1 ; check if carrying
    je  CheckDrop    ; if yes then  try to drop
    
    ;check for pickup (must be distance 1) 
    mov edi, 0 ; index 0
ProximityCheckLoop: ; loop passengers
    cmp edi, MAXIMUM_PASSENGERS ; check end
    je  NoInteraction ; it found nothing
    
    ; check active
    mov esi, OFFSET passengerActiveStatus   ; point to status
    mov eax, [esi + edi*4]   ; get value
    cmp eax, 1 ; check active
    jne NextProximityCheck   ; if not, skip
    
    ; calculate distance x   (abs(passengerx - playerx)) must be 1 to pick 
    mov esi, OFFSET passengerXPositions ; point to x
    mov eax, [esi + edi*4] ; get x
    sub eax, playerXPosition    ; subtract player x
    jns PositiveXDiff ; if positive, skip neg
    neg eax ; absolute value
PositiveXDiff: ; result in eax
    mov ebx, eax ; save x dist to ebx
    
    ; calculate distance y (abs(passengery - playery))

    mov esi, OFFSET passengerYPositions ; point to y
    mov eax, [esi + edi*4]  ; get y
    sub eax, playerYPosition ; subtract player y
    jns PositiveYDiff ; if positive, skip neg
    neg eax ; absolute value
PositiveYDiff: ; result in eax
    add ebx, eax    ; ebx = total distance )
    
    ; if distance <= 1, pickup!
    cmp ebx, 1 ; check range
    jg NextProximityCheck ; if too far, skip
    
    ; perform pickup
    call PlaySoundPickup     ; audio sound of pick 
    mov isCarryingPassenger, 1  ; set flag
    mov esi, OFFSET passengerActiveStatus ; point to status
    mov DWORD PTR [esi + edi*4], 0    ; deactivate passenger from map
    mov currentMessageString, OFFSET stringMessagePickup   ; set message
    call SpawnDestination  ; create a drop point
    ret  ; return

NextProximityCheck:   ; loop increment
    inc edi   ; next index
    jmp ProximityCheckLoop ; repeat

CheckDrop: ; logic for drop
    ; check for drop (must be on the destination) 
    mov eax, playerXPosition ; load player x
    cmp eax, destinationX ; compare dest x
    jne NoInteraction ; if different, fail
    mov eax, playerYPosition ; load player y
    cmp eax, destinationY  ; compare dest y
    jne NoInteraction     ; if different then it fail
    
    ; perform drop
    call PlaySoundDrop    ; audio sound of drop
    mov isCarryingPassenger, 0    ; clear flag
    add currentScore, 10 ; add score
    inc passengersDeliveredCount ; add count
    mov currentMessageString, OFFSET stringMessageDrop    ; set message
    call SpawnPassenger ; spawn new passenger
    
    ; increase speed logic
    mov eax, passengersDeliveredCount ; get count
    test eax, 1        ; check if odd number
    jnz ProximityDone    ; if odd, don't speed up yet
    cmp gameSpeedDelay, 50   ; check max speed cap
    jle ProximityDone        ; if max speed, stop
    sub gameSpeedDelay, 40 ; decrease delay (speed up)
    
ProximityDone: ; done
    ret ; return

NoInteraction:   ; failed interaction
    ; optional: feedback if space pressed but nothing happened
    cmp isCarryingPassenger, 1  ; check if carrying
    je  MessageFailDrop  ; fail drop message
    mov currentMessageString, OFFSET stringMessageFailPickup ; fail pickup message
    ret ; return
MessageFailDrop:      ; set drop fail message
    mov currentMessageString, OFFSET stringMessageFailDrop ; set message
    ret ; return
HandleSpacebarAction ENDP ; end procedure

; collision & npc
CheckNonPlayerCharacterCollision PROC ; checks if player hit any npc
    mov eax, npcOneX ; get npc 1 x
    cmp eax, playerXPosition ; compare player x
    jne CheckNPC2Label ; if safe, check next
    mov eax, npcOneY      ; get npc 1 y
    cmp eax, playerYPosition   ; compare player y
    jne CheckNPC2Label   ; if safe, check next
    jmp ApplyCollisionPenalty   ; hit!

    CheckNPC2Label:    ; check npc 2
    mov eax, npcTwoX ; get npc 2 x
    cmp eax, playerXPosition    ; compare player x
    jne CheckNPC3Label    ; if safe, check next
    mov eax, npcTwoY ; get npc 2 y
    cmp eax, playerYPosition ; compare player y
    jne CheckNPC3Label ; if safe, check next
    jmp ApplyCollisionPenalty    ; hit

    CheckNPC3Label:    ; check npc 3
    mov eax, npcThreeX   ; get npc 3 x
    cmp eax, playerXPosition   ; compare player x
    jne CheckNPC4Label  ; if safe, check next
    mov eax, npcThreeY     ; get npc 3 y
    cmp eax, playerYPosition    ; compare player y
    jne CheckNPC4Label  ; if safe, check next
    jmp ApplyCollisionPenalty   ; hit

    CheckNPC4Label:    ; check npc 4
    mov eax, npcFourX   ; get npc 4 x
    cmp eax, playerXPosition   ; compare player x
    jne SafeLabel ; if safe, exit
    mov eax, npcFourY ; get npc 4 y
    cmp eax, playerYPosition ; compare player y
    jne SafeLabel    ; if safe, exit
    jmp ApplyCollisionPenalty   ; hit!

    ApplyCollisionPenalty:    ; logic for crash
    call PlaySoundCrash    ; audio for sounf
    cmp taxiTypeSelected, 1   ; check taxi type
    je  PassengerYellowCollision ; yellow logic
    sub currentScore, 3      ; red taxi penalty
    mov currentMessageString, OFFSET stringMessageCarRed    ; set message
    jmp MoveSafeLabel ; continue again 
    PassengerYellowCollision: ; yellow logic
    sub currentScore, 2      ; yellow taxi penalty (-2)
    mov currentMessageString, OFFSET stringMessageCarYellow ; set message
    
    MoveSafeLabel:   ; handling post-collision
    SafeLabel: ; no collision
    ret ; return
CheckNonPlayerCharacterCollision ENDP ; end procedure

UpdateNonPlayerCharacters PROC    ; moves all npcs
    ; npc 1
    mov eax, npcOneY ; get y
    mov ebx, MAP_SIZE_CONSTANT ; width
    mul ebx ; row offset
    add eax, npcOneX ; add x
    mov esi, OFFSET mapGridArray ; point to map
    mov BYTE PTR [esi + eax], 0 ; clear old position (road)
    mov eax, npcOneX ; get x
    add eax, npcOneDirectionX ; apply movement
    push eax ; save new x
    mov  ebx, npcOneY ; get y
    mov  ecx, MAP_SIZE_CONSTANT ; width
    xchg eax, ebx    ; swap for multiplication
    mul  ecx ; row offset
    pop  ebx ; restore new x
    add  eax, ebx ; calculate new index
    mov  dl, [esi + eax]    ; check what is at new index
    cmp  dl, 0  ; is it empty road?
    jne  ReverseNPC1 ; if not, reverse
    mov  npcOneX, ebx ; update x
    jmp  SetNPC1 ; draw
    ReverseNPC1: neg npcOneDirectionX ; flip direction
    SetNPC1: ; draw new position
    mov eax, npcOneY ; get y
    mov ebx, MAP_SIZE_CONSTANT    ; get width
    mul ebx ; row offset
    add eax, npcOneX ; add x
    mov BYTE PTR [esi + eax], 3 ; mark as npc 

    ; npc 2 
    mov eax, npcTwoY ; get y
    mov ebx, MAP_SIZE_CONSTANT ; width
    mul ebx ; row offset
    add eax, npcTwoX ; add x
    mov BYTE PTR [esi + eax], 0 ; clear old
    mov eax, npcTwoY ; get y
    add eax, npcTwoDirectionY ; apply move
    push eax ; save new y
    mov  ebx, MAP_SIZE_CONSTANT ; width
    mul  ebx ; row offset
    add  eax, npcTwoX ; add x
    mov  dl, [esi + eax] ; check target
    pop  eax ; restore new y
    cmp  dl, 0 ; is empty?
    jne  ReverseNPC2 ; no, reverse
    mov  npcTwoY, eax ; update y
    jmp  SetNPC2 ; draw
    ReverseNPC2: neg npcTwoDirectionY ; flip
    SetNPC2: ; draw
    mov eax, npcTwoY ; get y
    mov ebx, MAP_SIZE_CONSTANT ; width
    mul ebx ; offset
    add eax, npcTwoX ; add x
    mov BYTE PTR [esi + eax], 3 ; mark npc

    ;  npc 3 
    mov eax, npcThreeY ; get y
    mov ebx, MAP_SIZE_CONSTANT ; get  width
    mul ebx ; offset
    add eax, npcThreeX ; add x
    mov BYTE PTR [esi + eax], 0 ; clear
    mov eax, npcThreeX ; get x
    add eax, npcThreeDirectionX ; apply move
    push eax ; save new x
    mov  ebx, npcThreeY ; get y
    mov  ecx, MAP_SIZE_CONSTANT ; width
    xchg eax, ebx ; swap
    mul  ecx ; offset
    pop  ebx ; restore new x
    add  eax, ebx ; index
    mov  dl, [esi + eax] ; check target
    cmp  dl, 0 ; if empty
    jne  ReverseNPC3 ; no, reverse
    mov  npcThreeX, ebx ; update x
    jmp  SetNPC3 ; draw
    ReverseNPC3: neg npcThreeDirectionX ; then it flip
    SetNPC3: ; draw
    mov eax, npcThreeY ; get y
    mov ebx, MAP_SIZE_CONSTANT ; width
    mul ebx ; offset
    add eax, npcThreeX ; add x
    mov BYTE PTR [esi + eax], 3 ; mark npc
    
    ;  npc 4
    mov eax, npcFourY ; get y
    mov ebx, MAP_SIZE_CONSTANT ; width
    mul ebx ; offset
    add eax, npcFourX ; add x
    mov BYTE PTR [esi + eax], 0 ; clear
    mov eax, npcFourY ; get y
    add eax, npcFourDirectionY ; apply move
    push eax ; save new y
    mov  ebx, MAP_SIZE_CONSTANT ; width
    mul  ebx ; offset
    add  eax, npcFourX ; add x
    mov  dl, [esi + eax] ; check target
    pop  eax ; restore new y
    cmp  dl, 0 ; if this empty?
    jne  ReverseNPC4 ; no, reverse
    mov  npcFourY, eax ; update y
    jmp  SetNPC4   ; draw
    ReverseNPC4: ; reverse logic
    neg npcFourDirectionY ; flip
    SetNPC4: ; draw
    mov eax, npcFourY ; get y
    mov ebx, MAP_SIZE_CONSTANT ; width
    mul ebx ; offset
    add eax, npcFourX ; add x
    mov BYTE PTR [esi + eax], 3   ; mark npc

    ret ; return
UpdateNonPlayerCharacters ENDP ; end procedure

; drawing & logic

DrawBoardProcedure PROC     ; renders the game
    mov  eax, COLOR_HUD ; set hud color
    call SetTextColor ; apply
    mov  edx, OFFSET stringHUDScore  ; load score label
    call WriteString ; print
    mov  eax, currentScore ; load score value
    call WriteInt ; print integer
    mov  edx, OFFSET stringHUDDrops  ; load drops label
    call WriteString ; print
    mov  eax, passengersDeliveredCount ; load drops value
    call WriteInt ; print integer
    
    cmp gameModeSelected, 2 ; check time mode
    jne DrawAlertLabel ; skip if not time mode
    
    mov edx, OFFSET stringHUDTime ; load time label
    call WriteString ; print
    
    call GetMseconds    ; get current time
    sub eax, startTime     ; calc elapsed
    mov ebx, eax  ; save elapsed
    mov eax, timeLimitDuration    ; load limit
    sub eax, ebx   ; calc remaining
    
    mov edx, 0 ; clear dx for div
    mov ebx, 1000 ; divisor that convert ms to seconds
    div ebx ; divide
    call WriteDec ; print seconds
    
    DrawAlertLabel:    ; draw alert area
    call Crlf    ; new line
    mov  eax, COLOR_ALERT ; set alert color
    call SetTextColor   ; apply
    mov  edx, currentMessageString    ; load message pointer
    call WriteString ; print message
    call Crlf ; new line

    mov  ecx, 0 ; row counter
DrawLoopRows: ; loop rows
    cmp  ecx, MAP_SIZE_CONSTANT ; check limit
    je   DoneDrawLabel ; finish drawing
    mov  ebx, 0 ; col counter
    DrawLoopColumns: ; loop cols
        cmp  ebx, MAP_SIZE_CONSTANT ; check limit
        je   NextLineLabel ; new row
        mov  eax, COLOR_GRID_LINE ; grid color
        call SetTextColor ; apply
        mov  al, '|' ; separator
        call WriteChar ; print
        cmp  ecx, playerYPosition    ; check player y
        jne  CheckItemsLabel  ; if not, check other
        cmp  ebx, playerXPosition ; check player x
        jne  CheckItemsLabel ; if not, check other
        cmp  taxiTypeSelected, 1 ; check taxi color
        je   YellowTaxiPlayer ; select yellow
        mov  eax, COLOR_TAXI_RED ; select red
        jmp  DrawPlayerLabel ; draw
        YellowTaxiPlayer: ; yellow setup
        mov  eax, COLOR_TAXI_YELLOW ; select yellow
        DrawPlayerLabel: ; drawing player
        call SetTextColor ; apply
        mov  al, player_board ; load symbol
        call WriteChar ; print
        jmp  ContinueDrawLabel    ; next cell

    CheckItemsLabel: ; check grid content
        mov  eax, ecx ; row
        mov  edi, MAP_SIZE_CONSTANT ; width
        mul  edi ; offset
        add  eax, ebx ; col
        mov  esi, OFFSET mapGridArray ; map
        mov  dl, [esi+eax] ; get value
        push ecx ; save row
        push ebx ; save col
        push esi ; save map pointer
        mov  edi, 0 ; index
        PassDrawLoop: ; check passengers
        cmp edi, MAXIMUM_PASSENGERS ; limit
        je  NoPassengerHere ; none found
        mov eax, edi ; index
        mov esi, OFFSET passengerActiveStatus ; status
        mov eax, [esi + edi*4] ; get status
        cmp eax, 1 ; if active?
        jne NextPassengerDraw   ; no
        mov eax, edi ; index
        mov esi, OFFSET passengerYPositions  ; y array
        mov eax, [esi + edi*4]   ; get y
        cmp eax, ecx   ; if match row
        jne NextPassengerDraw ; no
        mov eax, edi ; index
        mov esi, OFFSET passengerXPositions ; x array
        mov eax, [esi + edi*4] ; get x
        cmp eax, ebx ; is match col?
        jne NextPassengerDraw ; no
        pop esi    ; restore map
        pop ebx ; restore col
        pop ecx      ; restore row
        mov  eax, COLOR_PASSENGER ; set color
        call SetTextColor ; apply
        mov  al, passenger_board ; set symbol
        call WriteChar ; print
        jmp  ContinueDrawLabel ; next
        NextPassengerDraw: ; next loop
        inc edi ; inc
        jmp PassDrawLoop ; repeat
        NoPassengerHere: ; not a passenger
        pop esi  ; restore
        pop ebx  ; restore
        pop ecx    ; restore

    CheckDestinationLabel:   ; check drop zone
        cmp  isCarryingPassenger, 0   ; check carrying
        je   DrawStaticItemsLabel  ; if empty, skip
        cmp  ecx, destinationY ; if  match row?
        jne  DrawStaticItemsLabel ; no
        cmp  ebx, destinationX ; if match col?
        jne  DrawStaticItemsLabel ; no
        mov  eax, COLOR_DESTINATION ; set color
        call SetTextColor ; apply
        mov  al, destination_board ; set symbol
        call WriteChar ; print
        jmp  ContinueDrawLabel ; next


        ; draew items by comoaring the value 
    DrawStaticItemsLabel: ; check map id
        cmp  dl, 1 ;   wall
        je   IsWallLabel ; draw wall
        cmp  dl, 2 ; obstacle
        je   IsObstacleLabel ; draw obstacle
        cmp  dl, 3 ; npc
        je   IsNPCLabel ; draw npc
        cmp  dl, 4 ; bonus
        je   IsBonusLabel ; draw bonus
        mov  eax, COLOR_ROAD ; road color
        call SetTextColor ; apply
        mov  al, road_board ; road symbol
        call WriteChar ; print
        jmp  ContinueDrawLabel ; next
        IsWallLabel: ; wall draw
        mov  eax, COLOR_WALL ; color
        call SetTextColor ; apply
        mov  al, Wall_board    ; make symbol
        call WriteChar ; print
        jmp  ContinueDrawLabel ; next
        IsObstacleLabel: ; obstacle draw
        mov  eax, COLOR_OBSTACLE ; color
        call SetTextColor ; apply
        mov  al, obstacle_on_board    ; symbol
        call WriteChar ; print
        jmp  ContinueDrawLabel ; next
        IsNPCLabel: ; npc draw
        mov  eax, COLOR_NPC   ; color
        call SetTextColor ; apply
        mov  al, npc_board ; symbol
        call WriteChar ; print
        jmp  ContinueDrawLabel ; next
        IsBonusLabel: ; bonus draw
        mov  eax, COLOR_BONUS   ; color
        call SetTextColor ; apply
        mov  al, bonus_on_board    ; symbol
        call WriteChar ; print

    ContinueDrawLabel: ; next loop iteration
        inc  ebx ; next col
        jmp  DrawLoopColumns    ; repeat
    NextLineLabel:  ; end of row
        mov  eax, COLOR_GRID_LINE   ; color
        call SetTextColor ; apply
        mov  al, '|'      ; border
        call WriteChar ; print
        call Crlf ; new line
        inc  ecx     ;  next row
        jmp  DrawLoopRows ; repeat
DoneDrawLabel:   ; finished drawing
    mov  eax, 15 + (0 * 16) ; white
    call SetTextColor ; reset color
    ret 
DrawBoardProcedure ENDP 

InitializePassengers PROC ; set up random passengers
    mov ecx, MAXIMUM_PASSENGERS ; loop count
    InitPassLoop: 
        push ecx ; save count
        call SpawnPassenger ; create one
        pop ecx ; restore count
        loop InitPassLoop ; repeat
    ret ; return
InitializePassengers ENDP ; end procedure

SpawnPassenger PROC ; create a single passenger
    mov edi, 0 ; index
    FindEmptySlotLabel:   ; find unused slot
    cmp edi, MAXIMUM_PASSENGERS ; limit
    je  EndSpawnLabel ; full
    mov esi, OFFSET passengerActiveStatus ; status
    mov eax, [esi + edi*4] ; get status
    cmp eax, 0 ; empty if 
    je  FoundSlotLabel ; yes
    inc edi ; next
    jmp FindEmptySlotLabel ; repeat
    FoundSlotLabel: ; slot found
    TryGenerateLabel: ; random coords
    mov eax, 18 ; range
    call RandomRange ; random
    inc eax ; 1-18 random range
    mov ebx, eax ; x
    mov eax, 18 ; range
    call RandomRange ; random
    inc eax ; 1 - 18
    mov ecx, eax ; y
    push ebx ; save x
    push ecx ; save y
    mov  eax, ecx ; y
    push ebx ; save x
    mov  ebx, MAP_SIZE_CONSTANT ; width
    mul  ebx ; row offset
    pop  ebx ; restore x
    add  eax, ebx ; index
    mov  esi, OFFSET mapGridArray ; map
    mov  dl, [esi + eax] ; check spot
    pop  ecx   ; restore y
    pop  ebx ; restore x
    cmp  dl, 0   ; road if 
    jne  TryGenerateLabel ; retry if blocked
    mov esi, OFFSET passengerXPositions ; x array
    mov [esi + edi*4], ebx ; set x
    mov esi, OFFSET passengerYPositions ; y array
    mov [esi + edi*4], ecx ; set y
    mov esi, OFFSET passengerActiveStatus ; status array
    mov DWORD PTR [esi + edi*4], 1 ; set active
    EndSpawnLabel: ; done
    ret ; return
SpawnPassenger ENDP ; end procedure

SpawnDestination PROC ; create drop zone
    TryDestLabel: ; random loop
    mov eax, 18    ; range
    call RandomRange ; random
    inc eax ; 1  -  18
    mov destinationX, eax   ; set dest x
    mov eax, 18 ; range
    call RandomRange ; random
    inc eax ; 1-18
    mov destinationY, eax ; set dest y
    mov  eax, destinationY ; y
    mov  ebx, MAP_SIZE_CONSTANT   ; width
    mul  ebx ; offset
    add  eax, destinationX ; index
    mov  esi, OFFSET mapGridArray ; map
    mov  bl, [esi + eax] ; check spot
    cmp  bl, 0 ; road if available
    jne  TryDestLabel ; retry if blocked
    ret ; return
SpawnDestination ENDP ; end procedure

; audio procedure

PlaySoundClick PROC ; sound for clicking
    INVOKE Beep, 1000, 150 ; 1000hz, 150ms this means high pitch 
    ret ; return
PlaySoundClick ENDP 

PlaySoundPickup PROC ; sound for pickup
    INVOKE Beep, 2000, 100 ; 2000hz, 100ms again high pitch
    ret ; return
PlaySoundPickup ENDP 

PlaySoundDrop PROC ; sound for drop off
    INVOKE Beep, 2000, 150 ; 2000hz, 150ms high pich 
    ret ; return
PlaySoundDrop ENDP 

PlaySoundCrash PROC ; sound for crash
    INVOKE Beep, 300, 300 ; 300hz, 300ms low pitch but a little mor sound
    ret ; return
PlaySoundCrash ENDP 

PlaySoundBonus PROC ; sound for bonus
    INVOKE Beep, 2500, 200 ; 2500hz, 200ms high pitch
    ret ; return
PlaySoundBonus ENDP

PlaySoundGameOver PROC ; sound for game over
    INVOKE Beep, 150, 800 ; 150hz, 800ms slow pitch but very long sound
    ret ; return
PlaySoundGameOver ENDP 

END main