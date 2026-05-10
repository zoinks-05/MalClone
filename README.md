# MyAnimeArray
### A native iOS/iPadOS anime tracking built with SwiftUI. Browse seasonal and top anime, search the full catalogue, track your watchlist, write reviews, and score shows. All stored locally no account needed!
## Tech Stack
- SwiftUI: UI layer, iOS/iPadOS adaptive
- [Jikan API](api.jikan.moe/v4): anime data, search, seasonal, top charts
- [AniList GraphQL API](graphql.anilist.co): High-res banner images
- URLSession + async/await: All networking
- UserDefaults: Local persistence
## Features
### Home
- Auto Scrolling carousel of seasonal anime with Anilist banners
- Now airing, top animes and various generes horizontal sections with infinite load
### Top
- Browse top Animes by type (Anime, Movies, Ovas and All)
### Search
- Full text search with sort (asc/desc) and order by (score, popularity, rank etc)
- Infinite scroll pagination
- Grid base layout with device/orientation consideration
### AnimeView
- Banner from Anilist, poster from Jikan
- Synopsis. background and various stats (score, rank, episodes etc)
- Genre, themes, demographics, studios
- OP and ED themes' names
### Watchlist
- Add any with status (Watching, Completed, Plan to Watch or Dropped)
- Set episodes watched (if Jikan has the count) and score (1 - 10)
- Edit or remove entries 
### Reviews
- Write a titled review with spoiler tag toggle
- Edit and delete reviews
### Profile
- Set your display and bio
- View all reviews and watch entries
- All data stored locally, no login required
## Requirements
- Xcode 15+
- iOS 17+/ iPadOS 17+
- Internet Required
## Getting Started
```bash
git clone https://github.com/zoinks-05/MalClone.git
cd MalClone
open MalClone.xcodeproj
```
Then in Xcode:
1. Select a simulator or connected device (iOS 17+)
2. Hit Run (Cmd + R)
3. No API keys or enviroments needed, works out of box
## Data Sources
- [Jikan](https://jikan.moe/): Unoffical MyAnimeList REST API
- [AniList](https://anilist.co/graphiql): GraphQL API for banner images
