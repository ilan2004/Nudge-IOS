# Component Creation Rules

This guideline standardizes component styling across the project, specifically the shadow style and how it is applied to buttons, pills, and panels.

## Design Tokens
- Background (page/panel): `Color.defaultCream` (matches --color-cream rgb(249, 248, 244))
- Brand text and shadows: `Color.greenPrimary` (matches --color-green-900)
- Accent background for filled pills: `Nudge*Surface` named colors (e.g., `NudgeGreenSurface`, `NudgeCyanSurface`), or `Color(.systemBackground)` for neutral/outline

## Shadow System (Standard)
Apply a two-layer green shadow to the background shape (not to text or the whole view):
- Drop shadow: color = `greenPrimary`, radius = 0, x = 0, y = 4
- Soft shadow: color = `greenPrimary` with 0.2 opacity, radius = 12, x = 0, y = 8

Do not apply shadows on text or labels; scope them to the shape fill only.

### Correct application (shape-only shadow)
```swift path=null start=null
// Shadows live on the shape inside .background, NOT on the label
Button {
  // action
} label: {
  HStack(spacing: 8) {
    Image(systemName: "play.fill")
    Text("Start Timer")
      .foregroundColor(.greenPrimary)
  }
}
.background(
  RoundedRectangle(cornerRadius: 20, style: .continuous)
    .fill(Color("NudgeGreenSurface"))
    .shadow(color: .greenPrimary, radius: 0, x: 0, y: 4)
    .shadow(color: Color.greenPrimary.opacity(0.2), radius: 12, x: 0, y: 8)
)
.opacity(isPressed ? 0.85 : 1.0)
.scaleEffect(isPressed ? 0.98 : 1.0)
```

### Avoid (causes doubled text or harsh outlines)
```swift path=null start=null
// Don’t put shadows on the entire button view
Button { } label: { Text("Start") }
.shadow(color: .greenPrimary, radius: 0, x: 0, y: 4) // ❌

// Don’t combine fill + stroke for pills unless explicitly required
Capsule().fill(...).overlay(Capsule().stroke(...)) // ❌ double-outline look
```

## Pill/Button Variants
- Filled variants (primary/cyan/amber/accent): use the standard two-layer shadow on the shape.
- Outline variant (neutral): no shadow; keep a flat background to prevent a doubled look on glyphs.

Example:
```swift path=null start=null
enum Pill: Hashable { case primary, cyan, amber, accent, outline }

func pillBackground(for variant: Pill) -> some View {
  Group {
    switch variant {
    case .outline:
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(Color(.systemBackground)) // no shadow for outline
    default:
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(Color("NudgeGreenSurface"))
        .shadow(color: .greenPrimary, radius: 0, x: 0, y: 4)
        .shadow(color: Color.greenPrimary.opacity(0.2), radius: 12, x: 0, y: 8)
    }
  }
}
```

## Panel/Sheet Style
Panels (like FocusSettingsView) should use a cream container with the same two-layer brand shadow and green text:
```swift path=null start=null
VStack(spacing: 16) {
  // content (all labels in .greenPrimary)
}
.padding(20)
.background(
  RoundedRectangle(cornerRadius: 16, style: .continuous)
    .fill(Color.defaultCream)
    .shadow(color: .greenPrimary, radius: 0, x: 0, y: 4)
    .shadow(color: Color.greenPrimary.opacity(0.2), radius: 12, x: 0, y: 8)
)
```

## Text Color
- Component labels and headings: `.foregroundColor(.greenPrimary)`
- Avoid text shadows. Keep text clean and rely on shape shadows for depth.

## Placement Rules
- For footers over TabView, prefer `.overlay(alignment: .bottom)` with reserved bottom padding on the main content to avoid overlap (e.g., `.padding(.bottom, 88)`).
- Use `.zIndex` to ensure the component renders above the tab bar when necessary.

## Quick Checklist
- [ ] Shadows applied only to background shape, not the label
- [ ] Two-layer green shadow (0/4 and soft 12/8)
- [ ] No stroke overlays on pills by default
- [ ] Outline variant: no shadow
- [ ] Text color is greenPrimary; backgrounds use defaultCream or *Surface colors
- [ ] Panels follow the cream + green shadow pattern

