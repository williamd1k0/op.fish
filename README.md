# op.fish

Web mining for the [One Piece Wiki/Fandom](https://onepiece.fandom.com/wiki/One_Piece_Wiki) site.

## Available data:

- Manga Chapter info
- Manga Volume info
- Anime Episode info
- Story Arcs info (wip)

## Dependencies

- [fish shell](https://fishshell.com/)
- [htmlq](https://github.com/mgdm/htmlq)

## Installation

```sh
curl -s https://raw.githubusercontent.com/williamd1k0/op.fish/main/op.fish > ~/.config/fish/functions/op.fish
```

## Usage

```sh
op -m 100 # manga chapter 100
op -a 200 # anime episode 100
op -v 30 # manga volume 30
```
