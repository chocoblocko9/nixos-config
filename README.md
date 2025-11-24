# Conor's NixOS + hyprland configuration!

This is my NixOS config! (quite self explanatory)

## To-do list

- [] Install waybar and make it look not horrible (23/11/25)
- [] Watch those 2 videos on flakes and actually use it JUST ONCE (23/11/25)
- [] Do some more dunst stuff! Discord notifs look really bad rn for example (23/11/25)
  - [x] Opacity has been edited to make stuff readable (24/11/25)
- [] Figure out what ACTUALLY made btop detect my GPU (don't you love when you try 100 billion solutions and none of them work so you try them all at once and then realise that you missed the super basic thing you did 3 hours ago so now it works and you don't know which of your said 100 million fixes did it? I DO THIS SO MUCH) (23/11/25)
- [] Read ly documentation again, it already looks sick but maybe I can change more stuff (23/11/25)
- [] Get Docker and WinApps running as an Experiment (23/11/25)
- [] Enable randomising wallpapers + get at least 1 more (23/11/25)
- [] Make hyprsunset work so my poor eyes can survive (23/11/25)
- [] Install and test Heroic Launcher + Rocket League (23/11/25)
- [] ~~Package discord-rpmpris myself (scary) (23/11/25 - 24/11/25)~~
  - [x] Switched to mpd and got rich presence working with that instead!
- [] Install a cursor theme to get rid of this Stupid Logo


## Background

### Why?

Because NixOS looked cool. I'd been using Arch + KDE for about 9 months but through some very silly mistakes (hypr*-git packages and I installed the big FULL experience plasma package with the KDE apps), I had accumulated a sizable amount of bloat on my pacman that tbh, if I sat down and gave it a couple hours I could've completely cleared and been able to install hyprland properly without it complaining, but I decided it was time for a new adventure.

This repository was created about 3 days into attempt #2 of using NixOS (home-manager looked cool and I wanted to follow LibrePhoenix's tutorials to the dot. Shoutout him btw he's the goat), about when I got hyprland to a purely functioning state so I could open firefox and sign into github. Why didn't I just commit everything the whole way through and push it after? IDK! (23/11/25)

### NixOS

I went with NixOS because: 
1. it's the other super-duper supported distro along with Arch for hyprland and,
2. I thought the declarative and reproducible aspect sounded VERY cool (even if I barely knew what that meant)

Yeah I have very very little coding experience, I know like a little bit of python and javascript. Honestly bro for me, going from Windows to Arch + KDE was a walk in the park compared to switching to NixOS + hyprland LOL like the initial install with Arch is famously kinda annoying with partition management and whatever but once you get past that Arch is genuinely really intuitive and easy and I will stand on that, any beginner with a desire to prove something to themselves will have no issues with it. 

But NixOS BEGINS once it's installed, especially when I knew I'd be in the TTY learning a new programming language for days without even stepping foot on the mountain that is hyprland ricing, it was definitely a lot. But yeah, a strong desire to make shit work and TONS of great documentation will get you anywhere!

All that is to say, this is gonna be awful awful spaghetti code that will absolutely not do the Nix language justice. I haven't even touched that flake and honestly I barely understand what they do. If I turn this into a blog it'll get moved out of the REAMDE I promise. (23/11/25)
