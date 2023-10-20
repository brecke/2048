# 2048

## I wanna play 2048

I know. Just do this:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000/new`](http://localhost:4000/new) from your browser.

The default grid size is 6 but you can change it on the URL like `localhost:4000/new?size=5`. Should work with other values but the layout might not cope :) Not sure what the bug is to be honest, it looks random.

Anyway, you can always go to `game_live.html.heex` and make sure `grid-cols-6` becomes `grid-cols-4` if looking to play on a 4x4 board.

## I'm a nerd

No worries. You can run some tests and build some dopamine with `mix test`. The coverage ain't high but it covers the most important part of the game: sliding tiles.

## I wanna play with my dog

I got you covered! Just launch another window and go to the same URL. Now you can all play!

But how does that work? you ask. Good question. I'm not sure. I guess all players need to cooperate until near the end... by the time there's a tile > 1024 every player should start thinking about winning on their turn. Does that make any sense? I'm not sure either.

## I can see obstacles in my way

> I can see clearly now, the rain is gone

> I can see all obstacles in my way

I digress. That's something I did to make things harder. I'm placing 3 obstacles randomly on the board placed to make everything harder. Not sure how much harder though. Good luck man. It should still be possible to win...

...I think.

## Can I have a preview?

![Screenshot 2023-10-20 at 16 22 36](https://github.com/brecke/2048/assets/19879/d273dfbf-eb7e-4dd0-9acc-a08691c96f79)
![Screenshot 2023-10-20 at 12 18 52](https://github.com/brecke/2048/assets/19879/76ab0876-b061-489d-8ba8-b745a4310ccc)

