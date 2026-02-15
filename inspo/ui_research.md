# AiNotes UI Research & Design Inspiration

> Compiled February 2026. Research across 10+ note-taking and knowledge-base apps, plus design community resources (Dribbble, Behance, Figma Community).

---

## Table of Contents

1. [Notion](#1-notion)
2. [Bear Notes](#2-bear-notes)
3. [Obsidian](#3-obsidian)
4. [Google Keep](#4-google-keep)
5. [Mem.ai](#5-memai)
6. [Reflect Notes](#6-reflect-notes)
7. [Apple Notes](#7-apple-notes)
8. [Craft Docs](#8-craft-docs)
9. [Capacities](#9-capacities)
10. [Anytype](#10-anytype)
11. [Design Community Resources](#11-design-community-resources)
12. [AI Chat Interface Patterns](#12-ai-chat-interface-patterns)
13. [Voice Recording UI Patterns](#13-voice-recording-ui-patterns)
14. [Material Design 3 Notes Apps](#14-material-design-3-notes-apps)
15. [Key Takeaways for AiNotes](#15-key-takeaways-for-ainotes)

---

## 1. Notion

**What it does well:** Flexible database views, gallery/card layouts, workspace organization.

### Key UI Patterns
- **Gallery View** -- cards with cover images, configurable card sizes, filterable/sortable. Cards show a preview image + title + metadata properties.
- **Database Views** -- the same data rendered as table, board (kanban), calendar, timeline, or gallery. Users switch views with tabs.
- **Sidebar Navigation** -- collapsible tree of pages and databases. Workspaces at top, favorites section, then full page tree.
- **Slash Commands** -- type `/` to insert any block type. Extremely discoverable.
- **Breadcrumb Navigation** -- always shows where you are in the page hierarchy.
- **Filter Chips** -- inline filter bar above databases for quick filtering by property.

### What Makes It Effective
- One data source, many views. The gallery view is the closest analog to AiNotes' card grid.
- Properties on cards (tags, dates, status) give instant context without opening.
- Clean typography with generous whitespace.

### Reference URLs
- [Notion Gallery View Guide (2026)](https://super.so/blog/notion-gallery-view-a-comprehensive-guide)
- [Notion UI Screens on Figma](https://www.figma.com/community/file/1483380040206366050/notion-ui-screens)
- [Notion UI Kit (Recreated) on Figma](https://www.figma.com/community/file/1279161103014638492/notion-ui-free-ui-kit-recreated)
- [Notion on Refero Design](https://refero.design/apps/64)
- [Notion on UILand](https://uiland.design/screens/notion/screens/0fe2e369-a00c-46ef-b7be-d42a8744ef19)
- [Notion June 2025 UI Update](https://theorganizednotebook.com/blogs/blog/notion-new-ui-design-update-june-2025)

---

## 2. Bear Notes

**What it does well:** Minimalist writing experience, beautiful typography, Apple Design Award winner.

### Key UI Patterns
- **Three-Pane Layout** (desktop) -- sidebar tags | note list | editor. Mobile collapses to single pane with swipe navigation.
- **Tag-Based Organization** -- no folders. Tags are inline in the note body (e.g., `#project/ainotes`). Nested tags create hierarchy automatically.
- **Minimal Toolbar** -- formatting bar only appears contextually at the bottom. No cluttered toolbar.
- **Typography First** -- beautiful default fonts, generous line height, comfortable reading width.
- **Toggle Statistics** -- word count, reading time, etc. shown at bottom, toggled on/off.
- **Dark Mode** -- multiple themes including a signature "Red Graphite" theme.

### What Makes It Effective
- Ruthless simplicity. Nothing competes with the writing/reading experience.
- Tags as first-class citizens instead of folders reduces friction.
- Small, considered animations throughout the UI add polish without distraction.

### Reference URLs
- [Bear Official Site](https://bear.app/)
- [Bear on App Store](https://apps.apple.com/us/app/bear-markdown-notes/id1016366447)
- [Bear for Dark Mode UI Notes](https://www.wendyzhou.se/blog/best-app-for-dark-mode-ui-notes-bear/)
- [Bear 2 Review](https://robertbreen.com/2024/02/23/bear-2-for-writing-and-thinking/)

---

## 3. Obsidian

**What it does well:** Knowledge graph visualization, plugin ecosystem, local-first markdown.

### Key UI Patterns
- **Graph View** -- interactive force-directed graph showing all notes as nodes and links as edges. Color-coded by folder/tag. Zoomable, filterable.
- **Canvas** -- infinite zoomable workspace for placing notes, images, cards, and web embeds freely. Great for spatial organization.
- **Backlinks Panel** -- every note shows what links to it. Unlinked mentions surface implicit connections.
- **Command Palette** -- `Ctrl+P` opens a searchable command palette (similar to VS Code).
- **Split Panes** -- multiple notes open side by side. Linked panes scroll together.
- **Community Themes** -- highly customizable appearance.

### What Makes It Effective
- The graph view makes the "knowledge base" concept tangible and visual.
- Canvas is excellent for brainstorming and spatial thinkers.
- Local-first with plain markdown files -- same philosophy as AiNotes.

### Reference URLs
- [Obsidian Official](https://obsidian.md/)
- [Obsidian on App Store](https://apps.apple.com/us/app/obsidian-connected-notes/id1557175442)
- [Obsidian Graph View Guide](https://www.xda-developers.com/how-to-visualize-your-notes-in-obsidian-with-graph-view/)
- [Obsidian Overview (2025)](https://www.eesel.ai/blog/obsidian-overview)
- [Obsidian Knowledge Graphs](https://www.aitechgirl.com/posts/2025/05/obsidian/)

---

## 4. Google Keep

**What it does well:** Card grid layout, color coding, quick capture.

### Key UI Patterns
- **Masonry Card Grid** -- variable-height cards arranged in a Pinterest-style masonry layout. Cards expand on tap.
- **Color-Coded Cards** -- 12 background colors for visual categorization. Color is the primary visual differentiator.
- **Pin to Top** -- important notes pinned above the main grid with a visual divider.
- **Label Chips** -- small chips on cards show labels. Filter by label from sidebar.
- **Quick Actions on Cards** -- hover/long-press reveals archive, delete, color, label actions without opening the note.
- **FAB (Floating Action Button)** -- bottom-right FAB for new note, with expandable options for list, drawing, photo, voice.
- **Grid/List Toggle** -- switch between masonry grid and compact list view.

### What Makes It Effective
- Instant recognition via color. Users develop personal color systems.
- Cards show just enough content (first few lines + checklist preview) to identify the note without opening.
- The masonry layout feels organic and non-rigid.
- Voice notes show a small audio player inline on the card.

### Reference URLs
- [Smashing Magazine: Card-Based UI Design](https://www.smashingmagazine.com/2016/10/designing-card-based-user-interfaces/)
- [10 Card UI Design Examples (2025)](https://bricxlabs.com/blogs/card-ui-design-examples)
- [Card UI: Best Practices on Mobbin](https://mobbin.com/glossary/card)
- [Card UI Design Fundamentals (Justinmind)](https://www.justinmind.com/ui-design/cards)
- [Cards: NN/g Definition](https://www.nngroup.com/articles/cards-component/)
- [8 Best Practices for Card Design (Prototypr)](https://prototypr.io/post/8-best-practices-for-ui-card-design)

---

## 5. Mem.ai

**What it does well:** AI-first note organization, voice-to-structured-notes, semantic search.

### Key UI Patterns
- **Timeline Feed** -- notes displayed in reverse-chronological order, like a personal feed. No folders required.
- **Smart Search / Deep Search** -- semantic search that understands meaning, not just keywords. "What was our profit in April 2023?" returns relevant notes.
- **Heads Up** -- proactive surfacing of related notes and collections when writing or in meetings. Related content appears automatically.
- **Voice Mode** -- record voice, AI auto-cleans and structures the transcript. Both audio and transcript attached to the note.
- **Collections** -- AI-suggested groupings of related notes. Auto-organized.
- **Chat Interface** -- ask questions about your notes in a conversational UI.
- **Dark Mode** -- full dark theme support.

### What Makes It Effective
- Zero-friction capture: just start typing or talking. AI handles organization.
- Semantic search eliminates the need to remember exact titles or tags.
- "Heads Up" proactive surfacing is the killer feature -- shows you what you forgot you knew.
- Hybrid search architecture: Elasticsearch (keyword) + Pinecone (semantic vectors).

### Reference URLs
- [Mem Official](https://get.mem.ai/)
- [Mem on App Store](https://apps.apple.com/us/app/mem-your-ai-thought-partner/id1578757028)
- [Building Mem with Pinecone (Architecture)](https://get.mem.ai/blog/building-mem-the-ai-notes-app-(feat-pinecone))
- [Mem 2.0 Launch](https://get.mem.ai/blog/introducing-mem-2-0)
- [Mem AI on Zapier](https://zapier.com/blog/mem-ai/)

---

## 6. Reflect Notes

**What it does well:** Daily notes workflow, clean minimal UI, AI-powered search + chat.

### Key UI Patterns
- **Daily Notes Landing** -- opens to today's daily note. Immediate writing surface, no navigation required.
- **Four Main Sections** -- Daily Notes, All Notes, Tasks, and Map (graph view). Extremely focused navigation.
- **Minimal Left Panel** -- no folders, no deep nesting. Just pinned notes and the four sections.
- **Slash Commands** -- `/` for formatting: headers, lists, backlinks, image inserts.
- **Backlinks with @** -- `@` character inserts/links to other notes inline.
- **Graph Map** -- visual overview of notes and connections, similar to Obsidian but cleaner.
- **AI Search + Chat** -- semantic search with conversational follow-up. Filters carry into chat context.
- **Rich Text Editor** -- clean WYSIWYG with no distracting chrome.

### What Makes It Effective
- Opening to daily notes removes the "blank canvas" paralysis.
- Only four navigation items means zero cognitive overhead.
- AI search with filter-aware chat is a natural way to query your knowledge base.
- Fast, intuitive navigation with minimal UI chrome.

### Reference URLs
- [Reflect Official](https://reflect.app/)
- [Reflect on App Store](https://apps.apple.com/us/app/reflect-notes/id1575595407)
- [Reflect: AI Search and Chat](https://reflect.app/blog/ai-search)
- [Reflect Review (Medium)](https://stephenjzeoli.medium.com/reflect-my-perfect-notes-application-af0978de3373)

---

## 7. Apple Notes

**What it does well:** Native iOS feel, instant capture, clean reading experience.

### Key UI Patterns
- **Folder + Smart Folder System** -- traditional folders plus smart folders that auto-collect by criteria.
- **Note List** -- simple list with title, first line preview, and date. Thumbnails for notes with images.
- **Quick Note** -- swipe from corner to capture instantly from anywhere in iOS.
- **Inline Attachments** -- photos, links, scans, drawings all inline in the note body.
- **Scan Documents** -- built-in document scanner with auto-crop and perspective correction.
- **Handwriting + Drawing** -- PencilKit integration for sketches and handwritten notes.
- **Search** -- searches text, handwriting (OCR), and attachment content.

### What Makes It Effective
- Zero friction: always available, syncs instantly, no account setup.
- Native iOS design language feels "at home" on the device.
- Inline scanning and OCR is a model for AiNotes' photo capture feature.

### Reference URLs
- [Apple Notes iOS Figma Kit](https://www.figma.com/community/file/1363324249988272604/apple-notes-ios)
- [Apple Notes UX Redesign Study](https://medium.com/@hopethornt/apple-notes-redesign-cc3c4c5cfb42)
- [iOS Design Resources (Apple)](https://developer.apple.com/design/resources/)
- [iOS Notes App on Dribbble](https://dribbble.com/tags/ios-notes-app)

---

## 8. Craft Docs

**What it does well:** Beautiful document design, native Apple experience, block-based editing.

### Key UI Patterns
- **Block-Based Editor** -- every paragraph, image, or element is a movable block. Drag to reorder.
- **Card Links** -- linked documents appear as styled cards with preview, not just text links.
- **Document Styling** -- custom fonts, cover images, and page-level theming without CSS knowledge.
- **Folder + Space Organization** -- spaces for high-level grouping, folders within.
- **Templates** -- 100+ pre-designed templates for different use cases.
- **Share as Web Page** -- one-click publish to a beautiful web page.
- **Native Performance** -- built natively for Apple platforms, feels fast and responsive.

### What Makes It Effective
- Documents look polished by default. No design effort required from users.
- Card-style document links encourage a wiki-like knowledge structure.
- Native Apple design means smooth animations and platform conventions.

### Reference URLs
- [Craft Official](https://www.craft.do)
- [Craft on App Store](https://apps.apple.com/us/app/craft-write-docs-ai-editing/id1487937127)
- [Craft on Setapp](https://setapp.com/apps/craft)

---

## 9. Capacities

**What it does well:** Object-based note-taking, typed content, clean modern UI.

### Key UI Patterns
- **Object Types** -- every note has a type: Person, Book, Meeting, Idea, Quote, etc. Each type has its own properties and layout.
- **Block-Based Editor** -- rich content blocks within each object. Links can render as small cards, wide cards, link blocks, or embeds.
- **No Folders** -- organization emerges from object types and connections, not hierarchical folders.
- **Daily Notes** -- journal-style daily capture, similar to Reflect.
- **Tags + Properties** -- typed properties (date, rating, URL, etc.) on each object type. Tags for cross-cutting concerns.
- **Clean, Calm Aesthetic** -- generous whitespace, soft colors, modern typography. Described as "a calm place to make sense of the world."

### What Makes It Effective
- Object types impose just enough structure to make notes useful without being rigid.
- "A book is a book, a person is a person" -- intuitive mental model.
- Clean design with excellent spacing and typography.
- Block-based with multiple link display options (card, embed, etc.) adds visual variety.

### Reference URLs
- [Capacities Official](https://capacities.io/)
- [Capacities on App Store](https://apps.apple.com/us/app/capacities-notes-pkm/id1670188548)
- [Object-Based Note-Taking Revolution (Medium)](https://medium.com/@danielasgharian/the-object-based-note-taking-revolution-capacities-at-the-forefront-adb4c081880b)
- [Bottom-Up Note-Taking in Capacities](https://danielwirtz.com/blog/bottom-up-note-taking-in-capacities)
- [Why Object Types Are Better Than Folders](https://capacities.io/tutorials/object-types-vs-folders)

---

## 10. Anytype

**What it does well:** Local-first encrypted PKM, flexible data model, beautiful cross-platform UI.

### Key UI Patterns
- **Custom Types + Relations** -- define your own object types with custom properties (relations). Similar to Capacities but more flexible.
- **Multiple Views** -- list, gallery (card grid), kanban board, calendar views of the same data set.
- **Widget Sidebar** -- left-side widgets provide a high-level dashboard. Jump to any area with one click.
- **Graph View** -- visual knowledge graph showing connections between objects.
- **Composable Blocks** -- text, databases, kanban, calendar, and custom types as inline blocks.
- **Sets and Collections** -- dynamic queries that pull together objects matching criteria.
- **Local-First + Encrypted** -- data stays on device, syncs peer-to-peer with encryption.

### What Makes It Effective
- Beautiful, fast UI despite being a complex PKM tool.
- Gallery view with card grid is directly relevant to AiNotes' home screen.
- Local-first + encrypted aligns with AiNotes' privacy philosophy.
- Widget sidebar gives overview without leaving current context.

### Reference URLs
- [Anytype Official](https://anytype.io/)
- [Anytype on App Store](https://apps.apple.com/gb/app/anytype-secure-notes/id6449487029)
- [Anytype Docs](https://doc.anytype.io/anytype-docs)
- [Anytype Review (ToolFinder)](https://toolfinder.co/tools/anytype)
- [Anytype as Perfect KM App (XDA)](https://www.xda-developers.com/found-perfect-knowledge-management-app/)

---

## 11. Design Community Resources

### Dribbble

| Search Term | Notable Designs | URL |
|---|---|---|
| AI Note Taker | 5 designs; includes AI voice journal app (650 likes) | [dribbble.com/tags/ai-note-taker](https://dribbble.com/tags/ai-note-taker) |
| AI Note Taking | Various AI-powered concepts | [dribbble.com/tags/ai-note-taking](https://dribbble.com/tags/ai-note-taking) |
| Note Taking App | 94 designs | [dribbble.com/tags/note-taking-app](https://dribbble.com/tags/note-taking-app) |
| Notes App | Large collection | [dribbble.com/tags/notes-app](https://dribbble.com/tags/notes-app) |
| Voice Notes | AI voice notes, live transcribe concepts | [dribbble.com/tags/voice-notes](https://dribbble.com/tags/voice-notes) |
| Voice Recording App | 3 designs | [dribbble.com/tags/voice_recording_app](https://dribbble.com/tags/voice_recording_app) |
| Voice Recorder | Waveform UIs, recorder widgets | [dribbble.com/tags/voice-recorder](https://dribbble.com/tags/voice-recorder) |
| Knowledge Base | Various designs | [dribbble.com/tags/knowledge_base](https://dribbble.com/tags/knowledge_base) |

**Standout Dribbble Shot:**
- [UI/UX Mobile App Design for a Notes AI App / Voice Journal App](https://dribbble.com/shots/25578455-UI-UX-Mobile-App-Design-for-a-Notes-AI-App-Voice-Journal-App) by Anna (asol_design) -- directly relevant to AiNotes concept.

### Behance

| Project | Description | URL |
|---|---|---|
| AI Note Taker Mobile App UI/UX | Full mobile app case study (Aug 2025) | [behance.net/gallery/233378667](https://www.behance.net/gallery/233378667/AI-Note-Taker-Mobile-App-UIUX) |
| Notes App Design Projects | Browsable collection | [behance.net/search/projects/notes app design](https://www.behance.net/search/projects/notes%20app%20design) |
| Note Taking App Projects | Browsable collection | [behance.net/search/projects/note taking app](https://www.behance.net/search/projects/note%20taking%20app) |

### Figma Community

| Resource | Description | URL |
|---|---|---|
| Note Taker - AI Note App UI Kit | Full UI kit | [Figma Community](https://www.figma.com/community/file/1428692819814957254/note-taker-ai-note-app-ui-kit) |
| Note Taking App UX-UI Design | Complete app design | [Figma Community](https://www.figma.com/community/file/1272877363595791213/note-taking-app-ux-ui-design) |
| Makarya Notes Design System + UI Kit | Advanced note-taking design system (atoms to organisms) | [Figma Community](https://www.figma.com/community/file/1090245813253623841/free-version-makarya-notes-advanced-note-taking-app-design-system-ui-kit) |
| Notion UI Screens | Notion recreation | [Figma Community](https://www.figma.com/community/file/1483380040206366050/notion-ui-screens) |
| Apple Notes iOS | Apple Notes recreation | [Figma Community](https://www.figma.com/community/file/1363324249988272604/apple-notes-ios) |

### Other Inspiration Platforms

- [Mobbin](https://mobbin.com) -- curated mobile/web UI screenshots with search by app, screen type, or pattern
- [Refero Design](https://refero.design) -- tens of thousands of app screenshots with advanced search
- [UI Garage](https://www.uigarage.net/) -- categorized UI patterns
- [Pttrns](https://www.pttrns.com/) -- mobile design patterns
- [UIPatterns.io](http://uipatterns.io/) -- interactive mobile design patterns

---

## 12. AI Chat Interface Patterns

Relevant for AiNotes' "Ask your notes" RAG-powered Q&A feature.

### Key Patterns

1. **Conversational Thread** -- message bubbles (user right, AI left), typing indicators, timestamps. The standard chat UX.

2. **Inline Assistant** -- AI lives inside the note editor. Small "Generate" button or AI icon appears contextually. Offers multiple options with clear escape hatches (undo, edit manually).

3. **Context Side Panel (Copilot)** -- side panel that "sees" the current screen. Offers contextual actions like "Summarize this note" or "Find related notes." Does not replace the main content.

4. **Guided Form to Prompt** -- instead of freeform prompting, provide structured fields (goal, context, constraints) that the UI converts into a prompt behind the scenes.

5. **Filter-Aware Chat** (Reflect pattern) -- search filters carry into the chat context. If you filter by "meetings" tag, the AI chat only considers meeting notes.

### Design Best Practices
- Clean layout with readable fonts and clear message bubbles
- Obvious input area with send button
- Typing indicators and read receipts
- Source citations: show which notes the AI used to form its answer
- Always provide an escape hatch (edit, undo, dismiss)

### Reference URLs
- [31 Chatbot UI Examples (Eleken)](https://www.eleken.co/blog-posts/chatbot-ui-examples)
- [60+ Chat UI Design Ideas 2026 (Muzli)](https://muz.li/inspiration/chat-ui/)
- [15 Chatbot UI Examples (Sendbird)](https://sendbird.com/blog/chatbot-ui)
- [16 Chat UI Design Patterns (2025)](https://bricxlabs.com/blogs/message-screen-ui-deisgn)
- [AI UI Patterns (patterns.dev)](https://www.patterns.dev/react/ai-ui-patterns/)
- [Beyond Chat: AI Transforming UI Patterns](https://artium.ai/insights/beyond-chat-how-ai-is-transforming-ui-design-patterns)

---

## 13. Voice Recording UI Patterns

Relevant for AiNotes' voice-first recording feature.

### Key Patterns

1. **Waveform Visualization** -- real-time audio waveform during recording. Provides visual feedback that recording is active. Can be a simple bar graph, oscilloscope line, or circular visualization.

2. **Large Record Button** -- prominent circular button, often red or accent-colored. Pulsing animation during active recording.

3. **Timer Display** -- elapsed recording time prominently displayed. Sometimes with file size estimate.

4. **Live Transcription Overlay** -- text appears in real-time as the user speaks. Words highlight as they are recognized. (Mem.ai pattern)

5. **Pause/Resume** -- distinct from stop. Allows interruptions without creating multiple recordings.

6. **Post-Recording Actions** -- after stopping: play back, re-record, add to note, discard. Transcript appears below the audio player.

7. **Inline Audio Card** -- on the note card in the grid, show a small audio player with waveform thumbnail and duration.

### Reference URLs
- [Voice Recorder on Dribbble](https://dribbble.com/tags/voice-recorder)
- [Voice Recording App on Dribbble](https://dribbble.com/tags/voice_recording_app)
- [Voice Recording UI on Dribbble](https://dribbble.com/tags/voice-recording-ui)
- [Voice Notes on Dribbble](https://dribbble.com/tags/voice-notes)
- [Voice Recorder App UI Design (CMARIX)](https://dribbble.com/shots/19061049-Voice-Recorder-App-UI-Design)

---

## 14. Material Design 3 Notes Apps

Relevant for AiNotes' Flutter implementation with Material 3.

### Key M3 Features for Notes Apps
- **Dynamic Color** -- extract color scheme from user's wallpaper or a note's cover image. Personalized feel.
- **Tonal Elevation** -- surfaces use tonal color shifts instead of drop shadows. Softer, more modern look.
- **Large Top App Bar** -- collapsible top bar with title that shrinks on scroll.
- **FAB Variants** -- small, regular, large, and extended FABs. Extended FAB can show label + icon ("New Note").
- **Filter Chips** -- M3 filter chips for category filtering on the home grid.
- **Navigation Bar** (bottom) -- 3-5 destinations. M3 uses a pill-shaped active indicator.
- **Cards** -- elevated, filled, and outlined card variants. Filled cards with tonal surface colors work well for note grids.
- **Search Bar** -- M3 search bar expands from a pill shape into full-screen search with suggestions.

### Reference URLs
- [Material Design 3 in Compose](https://developer.android.com/develop/ui/compose/designsystems/material3)
- [Makarya Notes M3 Design System (Figma)](https://www.figma.com/community/file/1090245813253623841/free-version-makarya-notes-advanced-note-taking-app-design-system-ui-kit)
- [M3 Reminder App (Coursera)](https://www.coursera.org/projects/ui-design-using-material-design-3-designing-a-reminder-app)
- [Exploring M3 Visuals (Medium)](https://medium.com/@binayshaw7777/exploring-material-design-3-creating-stunning-visuals-for-your-app-d3f10a72d1ac)

---

## 15. Key Takeaways for AiNotes

### Home Screen / Card Grid
- **Use a masonry-style card grid** (Google Keep) with variable card heights based on content length.
- **Color-code by category** -- each NoteCategory gets a distinct tonal surface color (M3 tonal elevation).
- **Show preview content on cards** -- first 2-3 lines of rewritten text, source icon (mic/camera/text/doc), category chip, timestamp.
- **Pin important notes** above the grid (Google Keep).
- **Filter chips** at top for categories: All, Shopping, Todos, Ideas, General (M3 filter chips).
- **Grid/list toggle** for user preference.

### Navigation
- **Bottom navigation bar** with 3-4 tabs: Home, Search, Ask (AI chat), Settings. Keep it minimal like Reflect's four sections.
- **FAB** for new capture -- expandable to show Voice, Text, Photo, Document options (Google Keep pattern).

### Search
- **Semantic search bar** that expands from pill to full-screen (M3 pattern).
- **Show results as cards** matching the home grid style.
- **Recent searches** and **suggested queries** in the expanded search view.
- **Hybrid results** -- keyword matches + semantic matches, clearly differentiated.

### Recording / Voice Capture
- **Full-screen recording mode** with large waveform visualization.
- **Prominent red/accent record button** with pulse animation.
- **Live transcription** appearing below the waveform as the user speaks.
- **Timer** prominently displayed.
- **Post-recording flow**: show transcript, allow editing, then "Process with AI" button triggers the pipeline.

### AI Chat (Ask Feature)
- **Conversational thread UI** with message bubbles.
- **Source citations** -- each AI answer shows which notes it drew from, tappable to open.
- **Suggested questions** as chips above the input field.
- **Filter-aware** -- if user navigated from a category, chat defaults to that context.

### Note Detail
- **Clean reading view** with generous typography (Bear pattern).
- **Collapsible sections**: Original transcript, AI-rewritten version, metadata.
- **Inline audio player** if source was voice.
- **Related notes** section at bottom (Mem.ai "Heads Up" pattern).
- **Category + tags** shown as chips at top.

### Design Principles
1. **Voice-first, but not voice-only** -- the recording UI should be the most polished screen.
2. **AI is invisible** -- AI enhances content silently (rewriting, classifying, connecting). Don't make users "use" AI.
3. **Zero-friction capture** -- from app launch to recording in one tap.
4. **Cards are the atomic unit** -- every note is a card. Cards are scannable, colorful, and information-dense.
5. **Local-first confidence** -- subtle indicators that data is on-device and private (Anytype pattern).
6. **M3 tonal surfaces** -- use filled cards with tonal elevation, dynamic color, and the M3 component library for a modern Android/Flutter feel.
