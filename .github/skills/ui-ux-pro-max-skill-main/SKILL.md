---
name: ui-ux-pro-max-skill-main
description: "Use when improving app UI/UX quality, visual polish, design consistency, accessibility, responsive behavior, and product professionalism in Flutter projects. Triggers: redesign screen, modern UI, better UX, professional app, تحسين الواجهة, تحسين تجربة المستخدم."
argument-hint: "[target: full-app|screen|component] [platform: android|ios|web|all]"
user-invocable: true
disable-model-invocation: false
---

# UI/UX Pro Max Skill (Main)

Use this skill to upgrade the app into a more professional and polished product experience.

## When to Use

- The user asks for a modern, premium, or professional UI.
- UX feels inconsistent, cluttered, or unclear.
- App needs better hierarchy, spacing, typography, or colors.
- Flows need better usability, error states, and user guidance.
- Responsive behavior or accessibility quality is weak.

## Outcomes

- Consistent visual system (colors, spacing, typography, components).
- Cleaner, clearer user flows with fewer friction points.
- Stronger accessibility and responsive behavior.
- Production-ready polish (loading, empty, error, and success states).

## Procedure

1. Map current UX and identify pain points screen by screen.
2. Define a compact design system:
   - color roles (primary, surface, semantic)
   - typography scale
   - spacing and radius tokens
   - elevation and interaction states
3. Standardize shared UI primitives before screen-by-screen redesign.
4. Upgrade information hierarchy on each screen:
   - clear headline/action priority
   - reduce cognitive load
   - improve labels, hints, and microcopy
5. Improve interaction quality:
   - visible focus/pressed/disabled states
   - better form validation and inline feedback
   - consistent navigation and back behavior
6. Add robust UI states everywhere:
   - loading/skeleton
   - empty state with clear next action
   - error state with recovery action
   - success confirmation feedback
7. Enforce accessibility and responsiveness:
   - color contrast and touch target size
   - text scaling resilience
   - adaptive layouts for narrow/wide screens
8. Finish with polish pass:
   - animation restraint and consistency
   - icon/style alignment
   - copy quality and tone consistency

## Guardrails

- Prioritize clarity and task completion over decorative visuals.
- Keep patterns reusable; avoid one-off widgets when a shared component is possible.
- Preserve existing business logic; focus changes on UX quality unless functional fixes are required.
- Prefer incremental, testable improvements over risky all-at-once rewrites.

## Definition of Done

- Visual language is consistent across main flows.
- Key user tasks are easier, faster, and clearer.
- Accessibility basics pass for contrast, sizing, and readable hierarchy.
- Critical screens look and feel production-grade.
