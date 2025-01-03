<div align="center">
    <picture>
      <img alt="Logo" src="https://github.com/user-attachments/assets/7954f15d-f730-47f8-a114-cc87a964e131" height="256">
    </picture>
  <h1>The Feed</h1>
This is an iOS app set up to fetch the latest data from my Contentful database that powers my website and display it for viewing and editing. Centered around the books and shows I've recently watched. It's a native Swift app.
</div>
  

## Architecture

- `Models` - contains `Codable`/`Decodable` models for use with network calls. Most models "refactor" the JSON structure into something much more palatable and discard the irrelevant information.
- `Networking` - contains `NetworkManager` to make network calls using `Combine` structure (publishers). Automatically caches all data and emits cached data first, then emits network data (and turns off loading). Handles all sorts of network errors automatically. Also handles pagination automatically, fetching all pages of a collection, making the rest of the calls for you until there's no more pages of data left.
- `ViewModels` - contains models that fetch and use the data, like `EntriesViewModel` to provide it for the views.
- `Views` - main view shown is the `EntriesSplitView` and it shows either a list view that when picked provides a default, or an error view if there's a network fetching problem. Uses SwiftUI throughout and Tasks to kick off data fetching when needed.
- `TheFeedApp.swift` - the main entry point into the app, responsible for showing the `EntriesSplitView` and setting up keyboard shortcuts/menu bar items.

## Features
Shows entries, and lets you view detail/edit them. Here are how the individual parts work.

### Secrets

The `SecretsProtocol.swift` file should be duplicated into `Secrets.swift` with a struct inside named `Secrets`. There are instructions for how to fill in the values.

### Searching

Each model  implements its own searchability, and the view model calls into all of the entries from the top level. There are search tokens for the different categories.

### Network data caching
There's a cache that persists between app launches so it can show data from last time. Every call is cached by default if you use the `UrlCachedSessionManager`. Each data task publisher emits two values each time it's called, once with cached data and once with network data. Each is tagged via `DataSource` and a `DataOrigin` to show where it comes from.

## TODO features
Goal is to have list of all media I've finished/currently consuming/wishlist, and allow for surfacing my best recommendations for others

### Milestone A - Basics
- Feed of all books in main screen
- Viewing book details
- Editing book details
- "Start reading" a new book (i.e. add a new book)

### Milestone B - Booksmarts
- Import from Goodreads CSV format (updating in place if needed, no dupes)
- Link to open Goodreads after marking book as done (and copy review) so I can paste there too
- Validation (i.e. can't mark as finished without review and rating filled out, etc)
- Fetch details automatically for image/etc when adding a new book
- Descriptions pulled from web for the book too - probably via a just in time API, and maybe use this for cover image
- Swap to using a different API method for images that doesn't result in too many request errors
- Fix the cover image spinner not disappearing in certain cases

### Milestone C - Organization
- Count/preview of currently in progress at top of sidebar list, maybe separated into thumbnails/counts by type?
- ^ show sections/ways to access done, in progress, wishlist - maybe also arbitrary lists?
- Show if somehing is in Contentful draft status (see `SysContent.fieldStatus`)
- Sorting (name/year/type of content, but also manual sorting within wishlist - maybe 5 people tell me about one thing and I want to move it up)
- Filtering (done/in progress/wishlist, and existing)
- Move to server-driven sort?
- Recommendations section

### Milestone D - Feed me more
- Add movies & TV shows to Contentful models & backfill as many as possible I can remember
- Editing/viewing of website things & a "website mode" vs "media mode" for whole app
- Quick switcher
