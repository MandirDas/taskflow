# TaskFlow UI Redesign & Motion Specification

## 1. Purpose

This document defines the proposed visual, interaction, motion, responsive, and accessibility redesign for TaskFlow **before implementation begins**. It is based on:

- The current TaskFlow Flutter implementation.
- The provided assignment pages, especially Task 09 UI/UX, simulated offline/error requirements, dark mode, tablet layout, animations, skeleton loading, and accessibility bonuses.
- Current official Flutter guidance for [animation](https://docs.flutter.dev/ui/animations), [implicit animations](https://docs.flutter.dev/ui/animations/implicit-animations), [Hero/shared-element transitions](https://docs.flutter.dev/ui/animations/hero-animations), [custom route transitions](https://docs.flutter.dev/cookbook/animation/page-route-animation), and platform [reduced-motion accessibility preferences](https://api.flutter.dev/flutter/dart-ui/AccessibilityFeatures/reduceMotion.html).

The goal is not to add decoration everywhere. The goal is to create a polished product-management experience where hierarchy is clear, state changes are understandable, interactions feel responsive, and the interface remains performant and accessible.

---

## 2. Executive Design Direction

### Design concept: **Calm Kinetic Productivity**

TaskFlow will evolve from a functional Material app into a refined productivity product with:

- A calm indigo-to-violet identity instead of flat indigo everywhere.
- Soft neutral surfaces with layered depth rather than many identical bordered cards.
- Clear status and priority semantics that use icon + text + color, never color alone.
- More breathing room around page headers and content sections.
- Contextual actions instead of repeated floating buttons and menus.
- Motion that explains navigation, creation, filtering, completion, errors, and connectivity.
- Consistent async-state transitions instead of abrupt spinner-to-content swaps.
- Responsive phone and tablet layouts.
- True light/dark theme consistency through semantic theme tokens.

### Product personality

| Attribute | Expression in UI |
|---|---|
| Focused | Low visual noise, strong content hierarchy, limited accent colors |
| Trustworthy | Clear feedback, visible state, predictable destructive actions |
| Modern | Material 3 surfaces, tonal gradients, adaptive navigation, subtle motion |
| Collaborative | Visible people, assignee identity, comments, project progress |
| Fast | Skeleton loading, optimistic micro-feedback, retained page context |

### What the redesign will avoid

- Excessive gradients on every component.
- Glassmorphism that reduces readability.
- Long or bouncy animations on routine actions.
- GIFs used as persistent decoration.
- Tiny 10 px metadata labels.
- Color-only status communication.
- Full-screen loading indicators for small mutations.
- Animation that blocks interaction.

---

## 3. Current UI → Proposed UI Summary

| Area | Current | Proposed |
|---|---|---|
| Global visual style | Flat white/slate surfaces with thin borders | Tonal layered surfaces, selective soft shadows, subtle gradient identity |
| Typography | Inter, good baseline but some 10–11 px text | Inter with minimum readable metadata sizes and stronger hierarchy |
| Dark mode | Theme exists, but screens use light-only constants | All screens use `ColorScheme` and semantic theme extensions |
| Navigation | Five static destinations, abrupt `NoTransitionPage` swaps | Animated destination indicator, retained tab state, unread badge, adaptive rail on tablets |
| Page headers | Standard AppBars | Large contextual headers, optional summary/action region, scroll-aware collapse |
| Loading | Mostly centered spinners | Skeleton cards/list rows, then a soft content crossfade |
| Empty/error | Shared components, but inconsistently used | Unified illustrated state system with contextual actions and retry |
| Offline | Widget exists but is not mounted globally | Animated global offline/stale-data banner with reconnect feedback |
| Cards | Similar white bordered cards everywhere | Card variants: elevated focus, tonal summary, compact list row |
| Projects | Metadata-focused cards | Progress-focused cards with completion ring/bar, member avatars, next action |
| Tasks | Useful card but crowded and color-heavy | Cleaner hierarchy, assignee identity, semantic badges, swipe/overflow actions |
| Filters | Modal sheet with chips and date range | Search + sort + filter chips, persistent selected-filter summary, validated date range |
| Task detail | Many controls at equal hierarchy | Hero title/card transition, grouped sections, sticky contextual action/status area |
| Task form | Long single column; hidden `proj_1001` fallback | Sectioned form, required visible project selector, sticky save area, dirty-form protection |
| Dashboard | Static statistics and recent tasks | Animated summary, progress focus, upcoming/overdue intelligence, meaningful error/empty state |
| Notifications | Functional list, silent failures | Animated unread state, grouped timeline, unread badge in navigation, explicit errors |
| Settings | Mostly debug controls | Profile + appearance + accessibility + separate developer diagnostics section |
| Accessibility | Mostly inherited Material behavior | Semantics, tooltips, 48 px targets, screen-reader announcements, reduced motion |

---

## 4. Visual Design System

### 4.1 Color system

The existing indigo identity will remain recognizable but become more dimensional.

#### Core palette

| Token | Light | Dark | Use |
|---|---|---|---|
| Primary | `#5B5BD6` | `#A5B4FC` | Main CTA, selected navigation, active controls |
| Primary strong | `#4338CA` | `#818CF8` | Pressed/focused states |
| Secondary | `#0EA5E9` | `#7DD3FC` | Informational accents |
| Tertiary | `#8B5CF6` | `#C4B5FD` | Gradient endpoint and collaboration accents |
| Background | `#F7F8FC` | `#0B1020` | App background |
| Surface | `#FFFFFF` | `#151B2E` | Main cards and sheets |
| Surface tonal | `#EEF0FF` | `#202943` | Summary cards and selected regions |
| Text primary | `#171A2B` | `#F4F6FF` | Primary text |
| Text secondary | `#62677D` | `#AAB2CC` | Supporting text |
| Border | `#E3E6F0` | `#303A56` | Input/card separation |

#### Semantic colors

- To do: neutral slate + circle icon.
- In progress: blue + rotating/progress icon.
- Review: violet + visibility/review icon.
- Done: emerald + check icon.
- Urgent: red + alert icon.
- High: orange + upward priority icon.
- Medium: amber + equal priority icon.
- Low: slate + downward priority icon.

Every semantic badge will include **text and/or an icon**, not color alone.

#### Gradients

Use only in high-value identity areas:

```text
Primary brand gradient: #4F46E5 → #7C3AED
Soft background glow: primary at 12% opacity → transparent
Success accent: #10B981 → #34D399
```

Approved placements:

- Splash background.
- Authentication illustration/logo panel.
- Dashboard welcome/progress hero.
- Primary FAB or high-value CTA only when contrast remains compliant.

Not approved for every card, input, or list item.

### 4.2 Typography

Continue using Inter. Refine the scale:

| Role | Size | Weight | Use |
|---|---:|---:|---|
| Display | 32 | 700 | Splash/auth brand |
| Page title | 26 | 700 | Main page headers |
| Section title | 18 | 650 | Major content sections |
| Card title | 15–16 | 600 | Project/task titles |
| Body | 14–16 | 400 | Main content |
| Metadata | 12–13 | 500 | Dates, counts, helper text |
| Badge | 12 | 600 | Status/priority labels |

Rules:

- No essential text below 12 px.
- Respect system text scaling without clipping.
- Use maximum line counts only where a clear drill-down exists.
- Use tabular figures for counts where supported.

### 4.3 Spacing and sizing

Adopt an 8-point system with 4-point fine adjustments:

```text
4  — icon/text micro-gap
8  — related element gap
12 — compact card internal gap
16 — standard content padding
20 — card padding
24 — section spacing
32 — major section separation
40 — large page breathing room
```

- Minimum interactive target: 48 × 48 logical pixels.
- Phone content padding: 16 px.
- Large phone/tablet content padding: 24–32 px.
- Max content width for forms: 640 px.
- Max content width for standard pages: 1120 px.

### 4.4 Shape and depth

| Component | Radius | Elevation treatment |
|---|---:|---|
| Small chip/badge | 8–10 | None |
| Inputs/buttons | 12–14 | None; tonal/focus border |
| Cards | 16–20 | Border or subtle shadow, not both heavily |
| Bottom sheets/dialogs | 24–28 top/outer radius | Modal elevation |
| FAB | 18 or stadium | Soft colored shadow |

Cards will use three variants:

1. **Tonal summary card** — status/statistics.
2. **Standard content card** — projects/tasks/details.
3. **Interactive list card** — hover/press/selection response.

### 4.5 Iconography and imagery

- Use Material Symbols/Icons consistently.
- Add simple custom vector illustrations only for empty/error states.
- Use generated abstract shapes and icons rather than stock photography.
- User avatars may load mock URLs, but always show deterministic initials fallback.
- Provide a task-check brand mark that can be reused in Splash and authentication Hero motion.

---

## 5. Animation and Motion System

### 5.1 Motion principles

1. **Motion explains change.** It should show where content came from or what changed.
2. **Motion is brief.** Routine transitions stay within 120–300 ms.
3. **Motion is interruptible.** No animation should block taps or navigation.
4. **Motion is consistent.** Similar actions use the same timing and curve.
5. **Motion is accessible.** Reduce/simplify motion when the platform requests it.

Flutter provides suitable native primitives through implicit animations and transition widgets; these are preferable to manually animated GIFs for core interface behavior. The official Flutter animation documentation recommends choosing built-in implicit or explicit transitions based on how much control is required: [Flutter animations overview](https://docs.flutter.dev/ui/animations) and [implicit animations](https://docs.flutter.dev/ui/animations/implicit-animations).

### 5.2 Motion tokens

```dart
instant: 80ms
fast: 140ms
standard: 220ms
emphasized: 320ms
slowBrandOnly: 500ms

standardCurve: Curves.easeOutCubic
emphasizedCurve: Curves.easeInOutCubicEmphasized
exitCurve: Curves.easeInCubic
springLike: Curves.easeOutBack // only for tiny success icons, never page motion
```

### 5.3 Recommended animation map

| Interaction | Animation | Duration | Flutter approach |
|---|---|---:|---|
| Splash logo entry | Fade + 0.92→1 scale + soft glow | 500 ms | `FadeTransition`, `ScaleTransition`, `TweenAnimationBuilder` |
| Splash → Login | Shared logo + content fade | 320 ms | `Hero`, custom page transition |
| Login/Register swap | Fade-through + 12 px vertical slide | 220 ms | `PageRouteBuilder` or custom transition page |
| Bottom navigation change | Animated indicator + content fade | 180–220 ms | `NavigationBar`, `AnimatedSwitcher` |
| Detail page open | Container/shared-element transition | 300 ms | `Hero` for project/task identity; route fade/slide |
| Async state change | Skeleton → content crossfade | 220 ms | `AnimatedSwitcher` |
| Card first appearance | Fade + 8 px upward slide | 180 ms | Shared entrance wrapper; no long stagger |
| Filter apply | Chip width/color transition + list crossfade | 180 ms | `AnimatedContainer`, `AnimatedSwitcher` |
| Status change | Badge color/icon/text morph | 180 ms | `AnimatedContainer`, `AnimatedSwitcher` |
| Task completion | Check draw/scale + row tone change | 240 ms | Animated icon/scale; optional subtle haptic |
| Create success | Button → check state, then navigation | 300 ms | `AnimatedSwitcher`; route pop afterward |
| Delete | Card size collapse + fade | 220 ms | `AnimatedSize`, `FadeTransition` |
| Offline banner | Slide from top + fade | 220 ms | `AnimatedSlide`, `AnimatedOpacity` |
| Notification read | Background tint + dot fade | 180 ms | `AnimatedContainer`, `AnimatedOpacity` |
| Error/empty swap | Crossfade, no bouncing | 180 ms | `AnimatedSwitcher` |
| Refresh completion | Small success/check feedback | 140 ms | Icon switch, optional haptic |

### 5.4 Shared-element transitions

Flutter describes Hero animation as a shared visual moving between routes, which is appropriate when it helps users remain oriented: [Hero animations](https://docs.flutter.dev/ui/animations/hero-animations).

Use Hero transitions for:

- Brand mark: Splash → Login/Register.
- Project folder/icon tile: Project card → Project details.
- Task status marker or compact card identity: Task card → Task details.
- Avatar: Assignee row → assignee picker only if it remains visually stable.

Do not use Hero transitions for every icon or text element; too many shared elements create visual noise and route-transition conflicts.

### 5.5 GIF, Lottie, or Rive decision

#### Recommendation: do **not** use GIFs in the primary UI

GIFs are not recommended for this redesign because they:

- Have fixed playback and poor state control.
- Cannot easily honor reduced-motion settings.
- May consume more memory than vector/native motion.
- Are difficult to recolor for light/dark themes.
- Often look decorative rather than product-focused.

#### Preferred order

1. Native Flutter implicit/explicit animations.
2. Material icons and simple vector assets.
3. Optional Rive/Lottie only for one controlled brand or empty-state illustration if explicitly approved during implementation.

If Rive/Lottie is added, it will be:

- Limited to Splash or one empty state.
- Paused when off-screen.
- Disabled or replaced with a static frame under reduced motion.
- Added as a pinned dependency after checking package compatibility.
- Bundled locally; no runtime network asset download.

### 5.6 Reduced motion

Flutter exposes platform accessibility preferences for reducing or disabling animation. The app will inspect `MediaQuery.disableAnimationsOf(context)` and/or platform reduced-motion features. Flutter documents this platform request through [AccessibilityFeatures.reduceMotion](https://api.flutter.dev/flutter/dart-ui/AccessibilityFeatures/reduceMotion.html).

When reduced motion is active:

- Page slides become short crossfades or instant transitions.
- Hero travel becomes a fade.
- Count-up animation shows the final value immediately.
- Decorative glow/parallax is disabled.
- Continuous shimmer becomes a static skeleton or low-motion pulse.
- Functional state changes remain visible through color, icon, and text changes.

---

## 6. Responsive Layout Strategy

### Breakpoints

| Width | Layout |
|---:|---|
| `< 600` | Compact phone, bottom navigation, one-column content |
| `600–839` | Large phone/small tablet, wider cards, two-column summaries |
| `≥ 840` | Tablet, `NavigationRail`, master-detail where appropriate |

### Adaptive behavior

- Replace the fixed five-item bottom navigation with `NavigationRail` on tablets.
- Constrain forms to 640 px and center them.
- Dashboard uses 2 columns on phone and 4 stat columns on tablet.
- Projects use one column on compact phones, two columns on larger widths.
- Task list/detail can become a master-detail layout on tablets.
- Project status summary wraps or becomes a 2×2 grid under large text scaling.
- Bottom sheets become side sheets/dialogs on wide screens where appropriate.
- Remove unnecessary portrait-only assumptions when tablet support is implemented; orientation behavior will be re-evaluated rather than silently unlocked.

---

## 7. Screen-by-Screen Redesign

## 7.1 Splash / Session Check

### Current

- Flat indigo background.
- White task icon in a square.
- Static title/subtitle and spinner.
- Fixed 500 ms delay.

### Proposed

- Full-screen indigo→violet gradient with a subtle static radial glow.
- Refined TaskFlow mark: rounded check/task symbol inside a softly elevated tonal tile.
- Logo fades/scales into place, title appears 80 ms later.
- Session message changes subtly: “Preparing your workspace” → “Restoring session.”
- Brand mark becomes the Hero source for Login/Register.
- Remove artificial visual delay beyond what is needed for the real session check.
- On unexpected session failure, route normally to Login without alarming users.

### Animation

- Logo: 500 ms fade + scale.
- Text: 220 ms fade-up.
- Exit: 280–320 ms Hero/crossfade.
- Reduced motion: static logo and immediate crossfade.

---

## 7.2 Login

### Current

- Centered icon and form.
- Inline validation, loading button, snackbar errors.
- No credential assistance or persistent server error.

### Proposed

- Mobile: softly tinted/gradient top brand region and elevated form surface below.
- Tablet: two-panel layout—brand/value statement on left, form on right.
- Brand Hero lands above the form.
- Add “Demo accounts” expander with Admin and Member quick-fill chips; passwords are still loaded through the data layer, not hardcoded in the widget.
- Use autofill hints and proper keyboard actions.
- Authentication errors appear in an inline animated error panel above the button, not only a transient snackbar.
- Password visibility button receives tooltip and semantics.
- Sign-in button retains width/context while loading; label crossfades to spinner + “Signing in.”
- Add a small security message: “Your mock session is stored securely on this device.”

### Animation

- Form surface: 220 ms fade-up.
- Field validation: `AnimatedSize` + fade, without shaking.
- Submit: button content switch 140 ms.
- Error panel: size + fade 180 ms.
- Successful login: button check 220 ms, then fade-through to Dashboard.

---

## 7.3 Register

### Current

- Long single-column form identical to Login.

### Proposed

- Same auth shell for consistency.
- Group fields into “Your details” and “Secure your account.”
- Show password requirements in a compact checklist that updates as the user types.
- Confirm password gets a clear match indicator.
- Keep all fields on one screen but use progressive helper content rather than a multi-step wizard, avoiding unnecessary complexity.
- Show registration limitation clearly in demo mode: account creation is local/simulated.

### Animation

- Requirement indicators animate between neutral and complete states.
- Form error/helper rows use `AnimatedSize`.
- Success uses the same button-to-check transition as Login.

---

## 7.4 Main Navigation Shell

### Current

- Five bottom destinations.
- No transition between tabs.
- No unread badge.
- Tab state is not explicitly retained.

### Proposed

- Floating tonal Material 3 navigation surface with safe-area spacing on phones.
- Selected destination receives a softly animated pill indicator.
- Inbox icon displays unread count or dot.
- Use adaptive `NavigationRail` at tablet width.
- Preserve each tab’s navigation/scroll state using stateful shell navigation where feasible.
- Global offline banner sits above page content and below system chrome, not duplicated per screen.
- Tab content uses a restrained 180 ms fade-through; no horizontal carousel effect.

---

## 7.5 Dashboard

### Current

- Greeting, four stat cards, quick actions, recent tasks.
- Failures are silently swallowed and can appear as empty/zero content.

### Proposed

#### Header

- Large personalized greeting with date/context.
- Compact avatar/profile access.
- “Workspace health” hero card with overall completion percentage and progress arc/bar.
- Gradient is used only in this hero card.

#### Statistics

- Four semantic stat tiles: To do, In progress, Done, Overdue.
- Tiles are tappable and open the task list with that filter.
- Counts use subtle number interpolation on first load.

#### Content

- “Focus today” section for overdue and near-due tasks.
- “Recent projects” horizontal cards or responsive grid.
- “Recent tasks” uses the shared compact `TaskCard` variant.
- Quick create button opens a menu for Task or Project rather than three equal static buttons.

#### State quality

- Introduce `DashboardCubit` to support consistent loading/success/empty/error/offline states.
- Replace spinner with dashboard skeleton.
- Explicit retry state on failure.
- True empty workspace state with “Create your first project.”

### Animation

- Skeleton crossfades to content.
- Progress bar/arc animates once from zero to current value.
- Count-up occurs only once and is disabled under reduced motion.
- No cascading animation longer than 300 ms total.

---

## 7.6 Project List

### Current

- Functional list cards with folder icon, count, description, date, status, FAB.

### Proposed

- Large page header with project count and search action.
- Search field expands from an icon or sits below the title.
- Cards emphasize:
  - Project title.
  - Completion progress.
  - Open task count.
  - Up to three assignee/member avatars.
  - Nearest due/overdue task.
- Description remains secondary.
- Grid layout on tablets.
- Create Project FAB becomes an extended FAB on the list, then collapses on scroll.
- Admin-only delete remains both hidden in UI and protected in business logic.
- Mutation progress stays local to the affected card/dialog.

### Animation

- New project card inserts with size + fade.
- Deleted card collapses after confirmed successful deletion.
- Search results crossfade without replaying full list stagger.
- Project folder/icon becomes Hero source for detail.

---

## 7.7 Project Create/Edit

### Current

- Compact alert dialog with name and description.

### Proposed

- Phone: modal bottom sheet with drag handle and keyboard-safe scrolling.
- Tablet: centered dialog.
- Name, description, optional accent/icon selection if scope allows.
- Inline validation and non-blocking submit progress.
- Save button remains stable and changes content to progress/check.
- Close/back asks for confirmation only when content changed.

---

## 7.8 Project Detail

### Current

- Header card, four status cells in one row, progress bar, custom task rows, Add Task FAB.

### Proposed

- Collapsible/sliver header with project identity and Hero continuity.
- Completion progress and open/overdue summary integrated into the header.
- Status summary uses wrap-safe 2×2/4-column adaptive tiles.
- Segmented task views: All, Active, Review, Done.
- Reuse shared TaskCard compact variant.
- Add Task action remains contextual and automatically fixes project context.
- Custom empty state replaced with shared illustrated state.

### Animation

- Hero icon/title transition from Project List.
- Header progress animates once.
- Segment changes use a short fade/size transition.
- Task insert/remove uses animated list behavior.

---

## 7.9 Task List

### Current

- Filter icon, active dot, bottom filter sheet, cards, delete menu, FAB.

### Proposed

#### Discovery controls

- Search bar for task title/description.
- Horizontal filter chips: Status, Priority, Assignee, Due date.
- Sort menu: Due soon, Priority, Recently created, Status.
- Active filters display their selected value and removal icon.
- “Clear all” is a semantic `TextButton`, not a bare gesture.

#### Content

- Optional grouping by status or due period.
- Task card shows actual assignee avatar/name instead of only “Assigned.”
- Due date receives clearer language and overdue icon.
- Status/priority badges use icons + text + color.
- Swipe-to-complete may be considered only after explicit confirmation; default plan keeps overflow actions to avoid accidental mutation.

#### Filter sheet

- Drag handle, safe area, scrollable content.
- Searchable assignee picker.
- Validate From ≤ To.
- Adaptive side sheet/dialog on tablet.
- Apply button shows result count if available.

### Animation

- Filter chips animate selection/tint.
- List results crossfade and reposition smoothly.
- Task completion animates badge and check state.
- Do not animate every scroll item repeatedly.

---

## 7.10 Task Detail

### Current

- Equal-weight editable controls, assignee bottom sheet, description, comments, edit/delete in AppBar.

### Proposed

#### Header

- Hero transition from task card.
- Large title and semantic status badge.
- Context row: project, due date, assignee.
- More menu contains delete; edit remains a labeled action where space allows.

#### Sections

1. Status and priority control card.
2. Details/description.
3. Assignee and collaborators.
4. Activity/comments timeline.

- Status control becomes a segmented or bottom-sheet selection rather than a visually dense dropdown.
- Assignee sheet is searchable and scrollable.
- Show local pending state beside status/assignee while mutation is occurring.
- Delete goes through Cubit and surfaces failures instead of calling repository directly from UI.
- Comments use a timeline layout with avatar, author, timestamp, and body.
- Comment composer is sticky above the keyboard and supports multiline text.

### Animation

- Hero identity transition.
- Status badge morphs on update.
- Assignee avatar crossfades when changed.
- New comment appears with size + fade.
- Failure returns the control to its prior state with an inline message.

---

## 7.11 Task Create/Edit Form

### Current

- Title, description, priority, assignee, date.
- If no project is supplied, task silently uses `proj_1001`.
- Saving replaces the entire form with a loader.

### Proposed

#### Required correctness change

- Add a required **Project** selector whenever the screen is opened outside a project.
- When opened from Project Detail, show the project as a locked contextual field.
- Remove the hard-coded `proj_1001` fallback completely.

#### Form structure

- Section 1: Task essentials — Project, title, description.
- Section 2: Planning — status (edit only), priority, due date.
- Section 3: People — assignee.
- Sticky bottom save region, keyboard-safe.
- Save button disables and displays inline progress while retaining form context.
- Initialization error gets a full retry state instead of an empty editable form.
- Dirty form prompts before leaving.
- Field helper text and server validation appear near relevant fields.

### Animation

- Sections enter with a single short fade, not staggered one by one.
- Validation/helper text uses animated size.
- Date/assignee/project selection updates with animated label/content switch.
- Success changes Save button into check state, then returns.

---

## 7.12 Notifications

### Current

- Unread tint/dot, relative time, mark read/all read, task navigation.
- Errors are silently swallowed.

### Proposed

- Introduce `NotificationCubit` with loading/success/empty/error/offline states.
- Navigation badge shows unread count/dot.
- Group notifications into Today, Earlier, and Older where data supports it.
- Use clearer notification icon tiles.
- Add a small filter: All / Unread.
- Mark-all-read uses local progress and confirmation only if many items; otherwise immediate.
- Failed actions display retry feedback.

### Animation

- Unread background and dot fade when marked read.
- Mark-all-read animates visible dots out together, without long stagger.
- New/returned notifications appear through list insertion animation.

---

## 7.13 Settings

### Current

- Profile, three developer simulation toggles, session info, logout.

### Proposed

#### User settings

- Profile card.
- Appearance: System / Light / Dark segmented setting.
- Motion: Follow system / Reduce motion.
- Notification preference placeholder where appropriate.
- Accessibility information/action.

#### Developer diagnostics

- Move Offline, Force Error, and Force Timeout into a clearly labeled “Developer & Demo” expandable section.
- Show current connectivity state with a status chip.
- Display mock-session details in a secondary information sheet, not as main user content.
- Keep error trigger IDs documented but visually secondary.

#### Account

- Logout remains destructive and confirmed.
- Add clear app version/build information.

### Animation

- Developer section expands with `AnimatedSize`.
- Theme changes crossfade through Flutter theme animation.
- Connectivity toggle immediately triggers the global offline banner.

---

## 8. Shared Components to Create or Refactor

| Component | Responsibility |
|---|---|
| `AppPageScaffold` | Safe area, responsive max width, adaptive padding, optional header/offline region |
| `ResponsiveLayout` | Compact/medium/expanded breakpoints |
| `AnimatedStateSwitcher` | Initial/loading/success/empty/error crossfade with stable layout |
| `SkeletonBox` / `SkeletonList` | Low-cost theme-aware loading placeholders |
| `AppStatusBadge` | Status icon + text + semantic color |
| `AppPriorityBadge` | Priority icon + text + semantic color |
| `UserAvatar` / `AvatarStack` | Network image with deterministic initials fallback |
| `SectionHeader` | Title, optional description and action |
| `TaskCard` variants | Standard, compact, dashboard, selectable |
| `ProjectCard` | Shared responsive project summary |
| `AsyncActionButton` | Idle/loading/success/error content transition |
| `OfflineStatusBanner` | Global offline/stale/reconnected feedback |
| `EmptyStateView` | Consistent illustration, copy, action |
| `ErrorStateView` | Error type, retry, optional details |
| `AppModalSheet` | Drag handle, safe area, responsive constraints |
| `MotionBuilder` | Central reduced-motion-aware durations |

Private duplicate status/priority switches and one-off metadata rows will be consolidated into these components.

---

## 9. State and Architecture Changes Required by the UI

The UI redesign should not place business logic in widgets. Required state improvements:

1. Add `DashboardCubit` for loading/success/empty/error/offline handling.
2. Add `NotificationCubit` for fetch, mark-read, mark-all-read, and failures.
3. Expand TaskForm state to load organization projects and require project selection.
4. Add mutation-specific pending/error information to TaskDetail state.
5. Add search/sort/filter state to TaskList Cubit.
6. Expose connectivity as an app-level reactive stream/Cubit for the global offline banner.
7. Add theme and reduced-motion settings Cubit with local persistence if user-selectable settings are implemented.
8. Keep repository/data-source boundaries unchanged.

---

## 10. Accessibility Requirements

### Semantics

- Add labels for icon-only edit, delete, visibility, filter, send, and overflow actions.
- Mark page headings as semantic headers.
- Announce loading completion, errors, filter result counts, task completion, and offline/reconnected changes.
- Provide meaningful semantics for progress indicators.

### Visual accessibility

- Maintain WCAG-friendly contrast for text and controls.
- Status/priority never rely on color alone.
- Minimum 48 px touch targets.
- Support text scaling without clipped chips or fixed-height rows.
- Do not place important text over gradients without a controlled contrast layer.
- Provide visible focus state for keyboard/tablet navigation.

### Motion accessibility

- Honor reduced-motion settings.
- No rapid flashes.
- No mandatory parallax.
- No continuous decorative animation.
- Functional feedback remains available when motion is disabled.

---

## 11. Performance Rules

- Prefer native Flutter animation widgets over GIF/video.
- Animate transform/opacity where possible; avoid animating expensive layout properties in large lists.
- Do not create an animation controller per scrolling list item unless strictly necessary.
- Pause optional vector animations when off-screen.
- Keep page transitions under 320 ms.
- Use `RepaintBoundary` only after profiling identifies benefit.
- Precache small local illustration assets.
- Avoid heavy blur and oversized shadows.
- Preserve `const` constructors where possible.
- Use lazy lists/grids for project/task content.
- Verify animation performance in Flutter profile mode, not only debug mode.

---

## 12. File-Level Change Map

### Global foundation

- `lib/app/theme/app_colors.dart`
- `lib/app/theme/app_typography.dart`
- `lib/app/theme/app_theme.dart`
- `lib/app/app.dart`
- `lib/app/routes/app_router.dart`
- `lib/app/shell/main_shell.dart`
- `lib/core/network/network_info.dart`

### Shared UI

- Refactor all files in `lib/core/widgets/`.
- Add responsive, semantic badge, avatar, skeleton, async-button, and motion helpers.

### Screens

- `features/auth/presentation/screens/splash_screen.dart`
- `features/auth/presentation/screens/login_screen.dart`
- `features/auth/presentation/screens/register_screen.dart`
- `features/dashboard/presentation/screens/dashboard_screen.dart`
- `features/projects/presentation/screens/project_list_screen.dart`
- `features/projects/presentation/screens/project_detail_screen.dart`
- `features/projects/presentation/widgets/project_form_dialog.dart`
- `features/tasks/presentation/screens/task_list_screen.dart`
- `features/tasks/presentation/screens/task_detail_screen.dart`
- `features/tasks/presentation/screens/task_form_screen.dart`
- `features/tasks/presentation/widgets/task_card.dart`
- `features/tasks/presentation/widgets/task_filter_sheet.dart`
- `features/notifications/presentation/screens/notification_screen.dart`
- `features/settings/presentation/screens/settings_screen.dart`

### State

- Add Dashboard and Notification Cubits.
- Extend existing Task List, Task Detail, and Task Form Cubits/states.
- Add app settings/connectivity presentation state only if needed.

### Assets

Proposed local assets:

```text
assets/branding/taskflow_mark.svg or custom Flutter-painted mark
assets/illustrations/empty_projects.svg
assets/illustrations/empty_tasks.svg
assets/illustrations/no_notifications.svg
assets/illustrations/error_state.svg
```

Use locally owned/generated assets. Do not add third-party artwork without confirming its license and attribution requirements.

---

## 13. Implementation Sequence

### Phase A — Foundation

1. Add semantic color, spacing, radius, elevation, and motion tokens.
2. Fix dark-mode use of light-only constants.
3. Create responsive scaffold/layout primitives.
4. Create reduced-motion-aware motion helper.
5. Create status/priority badges, avatar, skeleton, state switcher, and async button.
6. Theme NavigationBar, NavigationRail, bottom sheets, dialogs, date pickers, menus, and focus states.

### Phase B — App Shell and Authentication

1. Redesign Splash.
2. Redesign Login/Register.
3. Add auth transitions and Hero brand continuity.
4. Refactor navigation shell with adaptive navigation and unread badge.
5. Add global offline banner.

### Phase C — Core Productivity Screens

1. Dashboard with proper Cubit state handling.
2. Project List and Project Detail.
3. Task List, search/sort/filter controls.
4. Task Detail and local mutation feedback.
5. Task Form project selector and dirty-state handling.

### Phase D — Secondary Screens

1. Notifications with Cubit/error handling.
2. Settings with appearance/accessibility and separated demo controls.
3. Empty/error illustrations.

### Phase E — Polish and Validation

1. Reduced-motion verification.
2. Dark-mode and high text-scale checks.
3. Phone/tablet responsive checks.
4. Widget/golden tests for core states if approved.
5. Profile-mode performance review.
6. Full existing test suite and analyzer.

---

## 14. Acceptance Criteria

### Visual

- Every screen follows the same spacing, typography, color, and component system.
- Light and dark themes are visually complete.
- Primary actions are immediately identifiable.
- Cards do not all look identical; hierarchy is purposeful.
- Status and priority are understandable without color perception.

### Motion

- Splash, auth, route, async state, filtering, task update, notification read, delete, and offline transitions are implemented.
- No normal page transition exceeds 320 ms.
- Reduced motion replaces movement with short fades or immediate state changes.
- No continuous decorative GIF/animation remains active in content screens.

### Functional/UI correctness

- All assignment-required loading, empty, error, pull-to-refresh, confirmation, back navigation, auth, role, and offline behaviors remain functional.
- Dashboard and Notifications no longer swallow errors as empty content.
- Offline/stale state is visible globally.
- Task creation requires a valid project and never silently falls back to `proj_1001`.
- Admin-only behavior remains enforced in business logic.

### Responsive/accessibility

- Phone and tablet widths are supported.
- Text scaling does not clip essential controls/content.
- Icon-only actions have semantics/tooltips.
- Touch targets are at least 48 px.
- Screen-reader users receive meaningful state-change announcements.

### Quality

- `flutter analyze` has no errors or warnings.
- Existing tests pass.
- New UI/state behavior receives focused widget tests.
- Animations remain smooth in profile mode on a typical Android emulator/device.

---

## 15. Proposed Final Experience

The redesigned TaskFlow should feel like a real, focused productivity product rather than an assignment assembled from default widgets. It will open with a confident but brief brand moment, guide users through a clean authentication experience, present a useful dashboard immediately, and make project/task state understandable at a glance. Motion will reinforce cause and effect—opening details, applying filters, completing work, receiving notifications, losing connectivity—without becoming distracting.

The recommended implementation uses native Flutter motion for almost all interactions. GIFs are intentionally excluded from the primary design because they reduce control, accessibility, theme integration, and performance. A single local vector animation may be considered later for Splash or an empty state, but the UI will not depend on it.

---

## 16. Research Sources

- [Flutter animation overview](https://docs.flutter.dev/ui/animations)
- [Flutter implicit animations](https://docs.flutter.dev/ui/animations/implicit-animations)
- [Flutter animation tutorial and transition widgets](https://docs.flutter.dev/ui/animations/tutorial)
- [Flutter Hero/shared-element animations](https://docs.flutter.dev/ui/animations/hero-animations)
- [Flutter custom page route transitions](https://docs.flutter.dev/cookbook/animation/page-route-animation)
- [Material motion for Flutter](https://codelabs.developers.google.com/codelabs/material-motion-flutter)
- [Flutter reduced-motion accessibility feature](https://api.flutter.dev/flutter/dart-ui/AccessibilityFeatures/reduceMotion.html)

Content derived from online sources was rephrased for compliance with licensing restrictions.
