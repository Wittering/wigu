# “What Do I Want To Be When I Grow Up?”  
### A Self + Mirror Insight Engine (Spec for Dev Team)

> **Purpose:** Help a user uncover the work they *should* be doing now—by combining their own narrative (joy, strengths, values, constraints) with mirrored input from trusted advisors, then synthesising both into clear insights, role hypotheses, and next steps.

---

## 0. TL;DR for the Build Team

- **Two-pass model:**  
  1. **Self Pass** – user answers 5 top-line questions → AI probes 1-at-a-time (max 3–4) → distilled “ingredients”.  
  2. **Advisor Pass** – 3–4 invited people answer a streamlined mirror version → AI distils.  
- **Synthesis Engine:** merges self + others → finds alignment, gaps, surprises → outputs visuals + text summary.  
- **Deliverables:** A user-facing report (narrative + visuals), optional archetype mapping, and a micro-experiment list to “test” suggested roles.  
- **Key constraints:** one-question-at-a-time probing, anonymity option for advisors, user always has final editorial control.

---

## 1. Problem Statement & Goals

### Problem
People struggle to translate “what I like / I’m good at” into a role that fits their skills, values, and life constraints. Self-perception is biased; external feedback is scattered.

### Product Goals
- Elicit deep, story-based self-insight (not just checkboxes).
- Capture mirrored perceptions from a diverse panel.
- Highlight convergences, blind spots, and overused strengths.
- Generate practical role directions and experiments.
- Make the process emotionally safe and intellectually rigorous.

**Success Criteria (examples):**
- ≥80% of users say it clarified direction.  
- ≥70% implement at least one recommended experiment within 30 days.  
- Advisors complete rate ≥75%.

---

## 2. Core Concepts & Glossary

| Term | Definition |
|------|------------|
| **Top-line Question** | One of five master questions that start each domain funnel. |
| **Probe** | Follow-up question asked one-at-a-time by the AI to clarify, deepen, or abstract. |
| **Ingredient** | Distilled element (verb, noun, value word) extracted from responses. |
| **Mirror** | Input from advisors reflecting what they see as the user’s strengths/energy/impact. |
| **Synthesis** | AI-generated comparison of self vs. mirror data, categorised into insight types. |
| **Insight Types** | Energising Strengths, Hidden Strengths, Overused Talents, Aspirational Areas, Misaligned Energy. |
| **Johari Mapping** | Known to self/others vs. unknown, used to visualise blind spots and hidden gems. |
| **Micro-Experiment** | Small, low-risk test to validate a potential role or direction. |

---

## 3. User Roles & Permissions

- **User (Primary Subject):** Creates account, completes self pass, selects advisors, receives final report, controls sharing.  
- **Advisor:** Completes short survey (optionally anonymous). No visibility into others’ responses unless allowed.  
- **Admin/Coach (optional feature):** Can view aggregated data for a user if permission granted.  
- **System/AI Agent:** Probes, distils, synthesises, and generates outputs.

---

## 4. High-Level Flow

[User Registers/Logs In]
|
V
[Self Pass: 5 Top-line Qs]
|–(Q1 Answer)–> [AI Probe 1] -> Answer -> [AI Probe 2] -> … -> Summarise Domain
|  (repeat for Q2-Q5)
V
[User Invites Advisors] -> Unique Links Sent
|
V
[Advisor Pass (parallel)]
|– Responses stored & parsed
V
[AI Synthesis]
|– Self vs Others Compare
|– Identify Insight Types
|– Generate Visuals & Narrative
V
[Draft Report Generated]
|– User edits/accepts
V
[Role Hypotheses + Micro-Experiments]
|– Optional archetype mapping
V
[Export/Share/Iterate]

---

## 5. The Five Top-Line Questions (Self Pass)

### 1. **“When do you feel most alive and lose track of time?”**  
*Domain: Joy/Energy/Flow*

**Probe Bank (use 1-at-a-time, max 3–4):**  
- “Tell me about the last time that happened—what were you doing and with whom?”  
- “What part gave you the buzz: the challenge, the people, the outcome, the craft?”  
- “What ‘ingredients’ show up across those moments?”  
- “When it doesn’t happen, what’s usually missing?”

**Example (Self answer):**  
> “I was designing a workshop with a friend; 4 hours flew by. We mapped customer journeys, argued about personas, and built activities. I forgot to eat.”  
**Agent Extracted Ingredients:** `["designing workshops", "collaboration", "creative problem solving", "teaching through activities", "time blindness = good sign"]`

---

### 2. **“What do you consistently do better than most—and how do you know?”**  
*Domain: Strengths (Self-Evidence)*

**Probes:**  
- “Share a story where that strength changed the outcome—what did *you* uniquely add?”  
- “Who’s told you this and what exact words did they use?”  
- “How did you build that capability?”  
- “Where might you be overrating yourself?”

**Example:**  
> “I can simplify complex ideas. A client once said I ‘translate tech into human’. In a crisis rollout, I rewrote the comms and got buy-in in 24 hours.”  
**Ingredients:** `["simplification", "translation", "crisis comms", "buy-in", "storytelling"]`

---

### 3. **“What do people seek you out for—and which of those asks actually light you up?”**  
*Domain: Reflected Strengths vs Energy Filter*

**Probes:**  
- “List three types of problems people bring you. Which one excites you most?”  
- “What do you wish they’d ask you for instead?”  
- “Have you started saying ‘no’ to some requests? Why?”  
- “What feedback keeps repeating?”

**Example:**  
> “People come to me to check their decks, solve team tension, or brainstorm product names. I love the brainstorming; decks drain me.”  
**Ingredients:** `["brainstorming", "naming/brand ideation", "conflict mediation (drain)", "slide-polishing (drain)"]`

---

### 4. **“If you could help fix or improve one thing over the next few years, what would it be and why?”**  
*Domain: Values/Impact*

**Probes:**  
- “Who benefits and how do their lives change?”  
- “Why *this* problem—what’s the personal hook?”  
- “Would you still care if nobody knew you did it?”  
- “What scale feels right—one person, a team, an industry, the planet?”

**Example:**  
> “I want to make data literacy accessible to non-tech staff. My parents struggled at work because they feared spreadsheets. I’d love to run community classes.”  
**Ingredients:** `["data literacy", "non-tech audience", "teaching", "equity", "community scale"]`

---

### 5. **“What does ‘a great work life’ look like for you—non-negotiables, nice-to-haves, and deal-breakers?”**  
*Domain: Life Design & Constraints*

**Probes:**  
- “Rank these: pay, autonomy, stability, flexibility, status, learning, impact.”  
- “Which trade-offs are you willing to make?”  
- “Describe your ideal week (hours, rhythms, people contact).”  
- “What would success vs disappointment look like in 12 months?”

**Example:**  
> “Non-negotiables: autonomy and learning. Nice-to-haves: remote work, collaborative team. Deal-breaker: 60+ hour weeks. Success in 12 months: I’m known for a signature workshop.”  
**Ingredients:** `["autonomy", "learning", "remote-friendly", "team collaboration", "ideal hours ≤45", "signature workshop goal"]`

---

## 6. Advisor Pass: Question Set

**Tone:** Friendly, story-driven, 5 core areas. Enable anonymity toggle.

### A. Energy & Joy  
> “When have you seen **<Name>** at their best—totally absorbed or ‘in the zone’? What were they doing?”

### B. Distinctive Strengths  
> “What does **<Name>** do better than most? Share a moment where it really mattered.”

### C. What People Seek Them Out For  
> “What do people (including you) usually ask **<Name>** to help with? Which of those requests seem to light them up?”

### D. Impact & Values  
> “If **<Name>** decided to ‘make a dent’ somewhere, where do you think they’d have the greatest positive impact—and why?”

### E. Environment Fit  
> “What kind of environment, team, or setup brings out **<Name>**’s best work? What shuts them down?”

**Optional Quick Ratings (1–5):**  
- Consistency of delivery  
- Coachability / growth mindset  
- Energy contagion (lifts others?)  
- Values clarity (guided by a ‘why’?)  

**Example Advisor Response (Energy & Joy):**  
> “When she’s sketching ideas on a whiteboard with a team under pressure. She’s fast, funny, and gets everyone contributing.”

**AI Ingredients:** `["facilitating under pressure", "visual thinking", "inclusive brainstorming", "team energy catalyst"]`

---

## 7. Synthesis Logic

### 7.1 Insight Categorisation

| Insight Type | Self Says | Others Say | Action |
|--------------|-----------|------------|--------|
| **Energising Strength** | High energy | High recognition | Core sweet spot – design role around it |
| **Hidden/Underrated** | Low/neutral | High recognition | Market it more, build confidence |
| **Overused Talent** | High pride/usage | High recognition but caveats | Set guardrails, context triggers |
| **Aspirational** | High desire | Low recognition | Skill build / experiment |
| **Misaligned Energy** | High energy | Low external value | Hobby? Reframe context or audience |

### 7.2 Visual Outputs (Examples)
- **Radar Chart**: 5 domains, Self vs Avg Others.  
- **Johari Window**: 2x2 grid (Known/Unknown to Self vs Others).  
- **Word Cloud**: Weighted by frequency in advisor comments.  
- **Top 5 Verbatim Phrases**: Anonymised quotes.  
- **Keep/Grow/Experiment Table**.

### 7.3 Narrative Output
- “**Three Truths**” (high alignment items)  
- “**Two Tensions**” (conflicts or gaps)  
- “**One Experiment**” (first action to test direction)

**Example Tension Statement:**  
> “You LOVE brainstorming, but others mostly come to you for slide-polishing. Consider publicly repositioning your availability for ideation sessions.”

---

## 8. Data Model (Draft JSON Schemas)

### 8.1 Question Schema
```json
{
  "id": "flow",
  "top_line": "When do you feel most alive and lose track of time?",
  "probes": [
    "Tell me about the last time that happened—what exactly were you doing and with whom?",
    "Which part gave you the buzz: the challenge, the people, the outcome, the craft?",
    "What ingredients show up every time you feel this way?",
    "When it doesn’t happen, what’s usually missing?"
  ],
  "tags": ["joy", "energy", "flow"]
}

8.2 User Response Object

{
  "user_id": "123",
  "question_id": "flow",
  "answers": [
    {
      "type": "top_line",
      "text": "I was designing a workshop...",
      "timestamp": "2025-07-25T03:15:00Z"
    },
    {
      "type": "probe",
      "probe_id": 1,
      "text": "The challenge and collaboration...",
      "timestamp": "2025-07-25T03:17:00Z"
    }
  ],
  "ingredients": ["designing workshops", "collaboration", "creative problem solving"]
}

8.3 Advisor Response Object
{
  "advisor_id": "a456",
  "user_id": "123",
  "domain": "energy",
  "response": "When she’s sketching ideas on a whiteboard...",
  "ratings": {
    "consistency": 4,
    "coachability": 5
  },
  "ingredients": ["facilitating under pressure", "visual thinking", "inclusive brainstorming"]
}


8.4 Synthesis Output

{
  "user_id": "123",
  "insights": [
    {
      "type": "energising_strength",
      "label": "Creative Facilitation",
      "self_signal": "high",
      "others_signal": "high",
      "evidence": ["Self story #1", "Advisor quote #2"],
      "action": "Design role around workshop creation and facilitation"
    },
    {
      "type": "misaligned_energy",
      "label": "Slide-Polishing",
      "self_energy": "low",
      "others_requests": "high",
      "action": "Set boundaries, redirect to peer resources"
    }
  ],
  "visuals": {
    "radar_chart": "/assets/radar123.png",
    "word_cloud": "/assets/wordcloud123.png"
  },
  "next_steps": [
    "Run 3 micro-workshops in the next 2 months",
    "Publish a ‘what I offer’ page clarifying my sweet spots"
  ]
}


9. AI Agent Behaviour Spec

9.1 Self Pass Flow Rules
	1.	Receive top-line answer.
	2.	Reflect back a short paraphrase for confirmation.
	3.	Ask ONE probe. Wait.
	4.	Repeat until clarity achieved or max probes reached (~3–4).
	5.	Extract ingredients (verbs, nouns, values).
	6.	Summarise domain in 1–2 sentences. Move on.

9.2 Advisor Pass Flow Rules
	•	No probing unless configured (default: static form).
	•	Optional: If using AI as concierge, ask one gentle clarifier if answer is < X chars or too vague.

9.3 Synthesis Rules
	•	Cluster ingredients by semantic similarity (embedding similarity > threshold).
	•	Determine insight type via logic (see 7.1).
	•	Construct narrative with: “truths/tensions/experiments” scaffold.
	•	Offer user chance to edit or reject statements.

9.4 Safety & Tone
	•	Validate for emotionally sensitive content; avoid diagnosing or therapy language.
	•	Always give user agency: “Does this resonate?” vs. “You are X”.

⸻

10. UI/UX Notes (MVP)

Self Pass Screen
	•	One question per screen, minimal UI, progress indicator (1/5).
	•	After user answers, chat-like AI response with paraphrase + next probe.
	•	Ingredient chips appear as they’re extracted (“We heard: ‘creative problem solving’—keep?”).

Advisor Invite
	•	Simple selector for contacts + role hints (“manager/peer/client/friend”).
	•	Message template editable.
	•	Option to toggle anonymity per advisor.

Advisor Form
	•	Mobile-friendly, 5 open questions + optional ratings.
	•	“You can leave anything blank” clarity.

Report View
	•	Tabs: Summary | Deep Dive | Quotes | Experiments.
	•	Toggle show/hide raw advisor quotes (anonymised).
	•	Export to PDF/Docx/Notion.

⸻

11. Edge Cases & Error Handling
	•	User skips a domain → prompt gently; allow skip with acknowledgement.
	•	Advisor non-response → auto-reminder at 3 & 7 days. Allow user to replace advisor.
	•	Conflicting input (self hates X, advisors love X) → flag as “tension” not “error”.
	•	Toxic feedback → content moderation, let user choose to hide.
	•	User fatigue → allow save & resume, show estimated time remaining.
	•	Probe loop → hard cap on probes; allow user to type “I’m done on this one”.

⸻

12. Privacy & Consent
	•	Advisors informed responses go to the user and are analysed by AI.
	•	Option for anonymity; system stores but masks identity in user view.
	•	Data retention policy configurable (e.g., auto-delete after 12 months).
	•	User can export and delete all data (GDPR-style).

⸻

13. Roadmap Suggestions (Post-MVP)
	•	Archetype/Role Library: Map ingredient clusters to role archetypes (e.g., “Advisor”, “Builder”, “Storyteller”).
	•	Job Market Fit Layer: Plug into job APIs to show live roles matching ingredients.
	•	Coach Portal: Licensed coaches access dashboards to guide clients.
	•	Annual Refresh: Nudge user to re-run or update after major life events.
	•	Teams Version: Aggregate across a team to build capability/energy maps.

⸻

14. Example End-to-End Snippet

Self Q1 Answer (User):

“When I’m mentoring juniors on data storytelling, I lose time. Helping them nail their narrative is addictive.”

AI Probe:

“What part—explaining concepts, seeing their growth, or crafting the story—gives you the biggest buzz?”

User:

“Seeing their growth. Watching confidence click.”

AI Extracts: ["mentoring", "data storytelling", "growth coaching", "confidence building"]
AI Summary:

“You light up mentoring others in data storytelling, especially when you witness their confidence grow.”

Advisor Response:

“He’s best when improvising solutions in high-pressure client meetings. He turns chaos into clarity.”

AI Extracts: ["improvising", "client pressure", "turning chaos to clarity"]

Synthesis Insight:
	•	Truth: Both you and others see you as a clarity-creator in messy contexts.
	•	Tension: You emphasise mentoring; others emphasise firefighting—different contexts, same skill?
	•	Experiment: Offer a “Data Story Rescue” clinic for juniors AND a rapid-response comms service for teams. Track which energises you more.

⸻

15. Acceptance Criteria (Sample)
	•	Functional:
	•	User can complete self pass with adaptive probing.
	•	Advisors can submit through unique links without logging in.
	•	Synthesis engine outputs at least: 3 truths, 2 tensions, 1 experiment.
	•	User can export report.
	•	Non-Functional:
	•	All prompts/responses stored securely, encrypted at rest.
	•	Average advisor form completion < 10 minutes.
	•	System handles up to 10 advisors (future-proof) without perf degradation.