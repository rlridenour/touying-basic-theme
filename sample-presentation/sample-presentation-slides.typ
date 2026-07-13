// sample-presentation-slides.typ
// Entry point for the live slide deck: applies the Touying config and
// renders content.typ's content using the real Touying building blocks.

#import "config.typ": (
  project,
  live-title-slide,
  live-pause,
  live-speaker-note,
  live-handout-note,
  live-two-column-slide,
  live-full-slide,
  live-statement,
)
#import "content.typ": content

#show: project

#content(
  live-title-slide,
  live-pause,
  live-speaker-note,
  live-handout-note,
  live-two-column-slide,
  live-full-slide,
  live-statement,
)
