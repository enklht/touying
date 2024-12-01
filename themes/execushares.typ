// Execushares theme

// ! comments are not correct

#import "../src/exports.typ": *

/// Default slide function for the presentation.
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - repeat (int, auto): is the number of subslides. The default is `auto`, allowing touying to automatically calculate the number of subslides. The `repeat` argument is required when using `#slide(repeat: 3, self => [ .. ])` style code to create a slide, as touying cannot automatically detect callback-style `uncover` and `only`.
///
/// - setting (dictionary): is the setting of the slide, which can be used to apply set/show rules for the slide.
///
/// - composer (array, function): is the layout composer of the slide, allowing you to define the slide layout.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (arguments): is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = {
    set align(horizon)
    show: components.cell.with(fill: self.colors.primary, inset: 1em)
    grid(
      columns: (auto, 1fr, auto),
      gutter: 1em,
      text(
        fill: self.colors.neutral,
        weight: "bold",
        size: 1.2em,
        utils.fit-to-width(100%, grow: false, self.store.header),
      ),
      none,
      text(
        fill: self.colors.neutral,
        utils.call-or-display(self, self.store.header-right),
      ),
    )
  }
  let footer(self) = {
    set align(bottom)
    set text(size: 0.8em)
    pad(
      1em,
      components.left-and-right(
        text(
          fill: self.colors.neutral-darkest.lighten(65%),
          utils.call-or-display(self, self.store.footer-left),
        ),
        text(
          fill: self.colors.neutral-darkest.lighten(65%),
          utils.call-or-display(self, self.store.footer-right),
        ),
      ),
    )
    if self.store.progress-bar {
      place(
        bottom,
        components.progress-bar(
          height: .5em,
          self.colors.primary,
          self.colors.neutral-dark,
        ),
      )
    }
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral,
      header: header,
      footer: footer,
    ),
  )
  let new-setting = body => {
    set align(self.store.alignment)
    set text(fill: self.colors.neutral-darker)
    show: setting
    body
  }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: new-setting,
    composer: composer,
    ..bodies,
  )
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: university-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.school,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
///
/// - extra (string, none): is the extra information for the slide. This can be passed to the `title-slide` function to display additional information on the title slide.
#let title-slide(
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  let body = {
    set page(
      margin: 0cm,
      background: {
        place(rect(width: 100%, height: 60%, fill: self.colors.primary))
        if info.logo != none {
          place(
            right + top,
            dx: -1em,
            dy: 1em,
            text(fill: self.colors.primary, info.logo),
          )
        }
        if info.date != none {
          place(
            bottom + right,
            dx: -0.5em,
            dy: -0.5em,
            text(
              size: .8em,
              fill: self.colors.neutral-dark,
              utils.display-info-date(self),
            ),
          )
        }
      },
    )

    components.cell(
      inset: (x: 1em, top: 1em, bottom: 0.5em),
      height: 60%,
      {
        set align(left + bottom)
        set par(leading: 0.2em)
        text(2em, self.colors.neutral, weight: "bold", info.title)
      },
    )

    components.cell(
      height: 10%,
      {
        set align(right + top)
        if info.subtitle != none {
          show text: set align(right)
          pad(
            x: 1em,
            y: 0.5em,
            text(
              size: 0.6em,
              fill: self.colors.neutral-darker,
              info.subtitle,
            ),
          )
        }
      },
    )

    components.cell(
      height: 30%,
      {
        set align(center + horizon)
        if info.authors.len() > 0 {
          set par(spacing: 0.5em)
          if self.store.print-by-in-title-slide {
            text(0.5em, "by")
          }
          block(
            width: 20% * calc.min(info.authors.len(), 3),
            grid(
              columns: (1fr,) * calc.min(info.authors.len(), 3),
              column-gutter: 1em,
              row-gutter: 1em,
              ..info.authors.map(author => text(fill: self.colors.neutral-darkest, author))
            ),
          )
        }
        if info.institution != none {
          text(size: .8em, info.institution)
        }
      },
    )
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: self.colors.neutral,
      margin: 0cm,
    ),
  )
  touying-slide(self: self, body)
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - level (int, none): is the level of the heading.
///
/// - numbered (boolean): is whether the heading is numbered.
///
/// - body (auto): is the body of the section. This will be passed automatically by Touying.
#let new-section-slide(level: 1, numbered: true, body) = touying-slide-wrapper(self => {
  let slide-body = {
    set align(horizon + center)
    set text(
      size: 1.5em,
      fill: self.colors.neutral,
      weight: "bold",
    )
    components.cell(
      width: 100%,
      height: 2em,
      fill: self.colors.primary,
      utils.display-current-heading(level: level, numbered: numbered),
    )
    body
  }
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral,
      margin: (x: 0cm),
    ),
  )
  touying-slide(self: self, slide-body)
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - background-color (color, none): is the background color of the slide. Default is the primary color.
///
/// - background-img (string, none): is the background image of the slide. Default is none.
#let focus-slide(background-color: none, background-img: none, body) = touying-slide-wrapper(self => {
  let background-color = if background-img == none and background-color == none {
    rgb(self.colors.primary)
  } else {
    background-color
  }
  let args = (:)
  if background-color != none {
    args.fill = background-color
  }
  if background-img != none {
    args.background = {
      set image(fit: "stretch", width: 100%, height: 100%)
      background-img
    }
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 1em, ..args),
  )
  set text(
    fill: self.colors.neutral,
    weight: "bold",
    size: 2em,
  )
  touying-slide(self: self, align(horizon, body))
})


#let side-by-side-slide(columns: auto, gutter: auto, ..bodies) = slide(
  components.side-by-side(columns: columns, gutter: gutter, ..bodies),
)

/// Touying university theme.
///
/// Example:
///
/// ```typst
/// #show: university-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   primary: rgb("#04364A"),
///   secondary: rgb("#176B87"),
///   tertiary: rgb("#448C95"),
///   neutral-lightest: rgb("#ffffff"),
///   neutral-darkest: rgb("#000000"),
/// )
/// ```
///
/// - aspect-ratio (string): is the aspect ratio of the slides. Default is `16-9`.
///
/// - progress-bar (boolean): is whether to show the progress bar. Default is `true`.
///
/// - header (content, function): is the header of the slides. Default is `utils.display-current-heading(level: 2)`.
///
/// - header-right (content, function): is the right part of the header. Default is `self.info.logo`.
///
/// - footer-columns (tuple): is the columns of the footer. Default is `(25%, 1fr, 25%)`.
///
/// - footer-a (content, function): is the left part of the footer. Default is `self.info.author`.
///
/// - footer-b (content, function): is the middle part of the footer. Default is `self.info.short-title` or `self.info.title`.
///
/// - footer-c (content, function): is the right part of the footer. Default is `self => h(1fr) + utils.display-info-date(self) + h(1fr) + context utils.slide-counter.display() + " / " + utils.last-slide-number + h(1fr)`.
#let execushares-theme(
  aspect-ratio: "16-9",
  alignment: horizon,
  progress-bar: true,
  header: utils.display-current-heading(level: 2),
  header-right: self => self.info.logo,
  footer-left: self => self.info.author,
  footer-right: context utils.slide-counter.display() + "/" + utils.last-slide-number,
  print-by-in-title-slide: true,
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 2em, bottom: 1.25em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(fill: self.colors.neutral-darker, size: 25pt)
        show heading: set text(fill: self.colors.primary)
        set list(
          marker: (
            text(self.colors.secondary, "•"),
            text(self.colors.secondary, "‣"),
            text(self.colors.secondary, "–"),
          )
        )
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: rgb(230, 37, 52),
      secondary: rgb(22, 190, 207),
      neutral: rgb(255, 255, 243),
      neutral-dark:rgb(175, 170, 170),
      neutral-darker: rgb(43, 40, 40),
    ),
    // save the variables for later use
    config-store(
      alignment: alignment,
      progress-bar: progress-bar,
      header: header,
      header-right: header-right,
      footer-left: footer-left,
      footer-right: footer-right,
      print-by-in-title-slide: print-by-in-title-slide,
    ),
    ..args,
  )
  body
}
