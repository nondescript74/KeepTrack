# KeepTrack

A lightweight iOS daily intake tracker designed for speed, consistency, and clarity.

## Highlights

- Fast daily logging with goal tracking
- Siri integration for hands-free capture
- Modern SwiftUI architecture (@Observable where applicable)
- Designed for low-friction behavior tracking

## Who it’s for

People who want a simple, reliable daily tracking workflow without heavy setup.

## Tech

- Swift / SwiftUI
- Siri integration
- Local-first data model (optionally extensible to cloud sync)

It also tracks your intake against goals you may wish to setup.  Goals can be such things as "once daily", "six times a day" for example.
When you enter something you take - 
> [!TIP]
> Try this out! Ask Siri "Siri, keeptrack add water" or "Siri, show water"
- it tracks it against any goals you may have set.
- 
Uses the new Swift @Observable, @Environment and @MainActor (instead of @ObservableObject, @Published, @EnvironmentObject)
