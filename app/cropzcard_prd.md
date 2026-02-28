1 — Executive summary
Cropz is a three-part agricultural B2B product: Cropz Card (LinkedIn-style profiles for agri-businesses/people), Cropz Catalog (product master and knowledge base for seeds, pesticides, fertilisers and field recipes), and Cropz Market (B2B marketplace built on the Card + Catalog database). The core value: create a trusted, discoverable master-database of dealers/retailers/products and enable trade + knowledge exchange between agribusiness stakeholders. 
CropzApp
________________________________________
2 — Vision & goals
Vision: Make every agri-business discoverable, trusted and tradeable — enable efficient B2B commerce and knowledge sharing across the agricultural value chain.
Primary goals
•	Build a canonical directory of agri dealers/retailers/nurseries (Cropz Card) that becomes the platform’s single source of truth.
•	Seed a product catalogue & knowledge library (Cropz Catalog) useful for field practitioners.
•	Launch a simple, trust-first marketplace (Cropz Market) leveraging the Card + Catalog.
•	High adoption among small & mid-size agri dealers, wholesalers, and input manufacturers; strong retention through network and transaction utility.
Success metrics (examples)
•	Number of verified Cropz Cards created and active.
•	Product Master entries added / curated.
•	Number of marketplace listings and completed B2B transactions.
•	Monthly active users (MAU) and retention (30/90-day).
•	GMV (gross merchandise value) for the Market and revenue from premium services / data licensing.
________________________________________
3 — Target users & Personas
Below are prioritized personas informed by the brief and target market needs.
Persona A — Ramesh, Agri Retailer (Primary user)
•	Age/location: 40s, small town / peri-urban.
•	Role: Owner of a retail farm inputs shop; sells seeds, fertilisers, pesticides.
•	Goals: Attract wholesalers/brands, get reliable product information & handling tips, streamline supplier contacts and payments.
•	Pain points: No digital identity; manual record-keeping; trust issues with new suppliers; price discovery is hard.
•	Key features they need: Cropz Card, product catalogue search, WhatsApp sharing of profile, quick ordering from marketplace, simple payment links.
Persona B — Sunita, Wholesaler / Distributor
•	Role: Bulk buyer & seller; supplies to retailers and large farms.
•	Goals: Reach verified retailers, reduce fraud, source product SKUs quickly.
•	Pain points: Inefficient lead generation, manual negotiations, inventory mismatch.
•	Needs: Verified Cropz Card database, SKU catalog, quoting & order flow with PO generation.
Persona C — Dr. Arjun, Crop Advisor / Agronomist
•	Role: Extension professional / nursery owner / consultant.
•	Goals: Share crop protection ideas, recipes; build credibility; find customers/suppliers.
•	Pain points: Knowledge not easily discoverable; weak sharing tools.
•	Needs: Content posting in Catalog (recipes), profile with credentials, follower mechanism.
Persona D — Nisha, Manufacturer / Brand Rep
•	Role: Seed or agrochemical company sales rep.
•	Goals: List products, find distributors/retail partners, run promotions, ensure correct product information.
•	Pain points: Listing inconsistencies, counterfeit risk, lack of verified channel partners.
•	Needs: Product master upload, certification badges, analytics on leads and conversions.
________________________________________
4 — Core product (MVP) scope — features (prioritised)
MVP must focus on utility and trust; keep scope narrow. Core modules:
A. Cropz Card (Directory)
•	Create / claim business profiles (fields: firm name, address + geo, GST no., contact, bank/GPay, license info, brief trade summary). 
CropzApp
•	Shareable card (image + deep link) exportable via WhatsApp / messaging. 
CropzApp
•	Basic verification flow (phone + GST document upload) and “verified” badge.
•	Save cards to a user address book / favorites.
Acceptance criteria: Profile created → can be shared → viewable inside app → shows verification status.
B. Cropz Catalog (Product master + knowledge)
•	Product master entries (SKU, category, manufacturer, technical sheet, safe-use recipes). 
CropzApp
•	Search & filter by crop / product type / manufacturer.
•	Ability for agronomists / users to submit short “recipes” / field notes (moderated).
•	Versioned product info and upload via CSV for manufacturers.
Acceptance criteria: Add product → searchable → link to manufacturer's Cropz Card.
C. Cropz Market (Basic B2B trade)
•	Listing creation (seller links listing to their Cropz Card + product SKU). 
CropzApp
•	Enquiry → quote → order flow (initially enquiry/lead generation + message + simple PO).
•	Payment links (GPay/UPI) or offline payment option.
•	Ratings & basic dispute flagging.
Acceptance criteria: Buyer sends enquiry → seller responds → simple order created.
D. Shared system features
•	Geo-search and mapping of dealers (by proximity). 
CropzApp
•	Export / share (WhatsApp image + deep link) of Cards & Catalog entries. 
CropzApp
________________________________________
5 — Functional & non-functional requirements (high level)
Functional
•	Registration & auth (phone OTP, company account).
•	Profile CRUD and document upload (GST, license).
•	Search & browse (products, dealers).
•	Listing / enquiries / messaging.
•	CSV bulk import for product masters and dealer lists.
•	Admin console for verification and content moderation.
Non-functional
•	Mobile-first web + native apps (Android first given market).
•	Offline-friendly reads (basic caching) for rural usage.
•	Secure storage for documents and payment references; GDPR/India data laws compliance (store sensitive PII encrypted).
•	Scalable architecture to support DB of dealers & products; API-first.
________________________________________
6 — UX / key user journeys (short)
1.	Retailer onboard: install app → create Cropz Card → verify via GST + phone → share Card on WhatsApp → saved by peers.
2.	Buyer discovery: search by product or nearby retailers → view Card + product catalog → send enquiry → receive quote → pay/confirm order.
3.	Manufacturer listing: bulk upload SKUs → link listings to authorized dealers → track enquiries & analytics.
________________________________________
7 — Roadmap (phased, milestone-based — no specific time estimates provided)
Note: Plan shows sequence and deliverables — the product team should convert phases into sprint plans and resource allocation.
Phase 0 — Discovery & Partnerships
•	Deliverables: Detailed stakeholder interviews (retailers, distributors, manufacturers), sample data acquisition (dealer lists), pilot partners (1–3 brands/coops), tech stack decision.
•	Success: Pilot partners committed; initial data import sample available.
Phase 1 — Cropz Card (Core directory)
•	Deliverables: Profile creation/verification, shareable card (WhatsApp image + deep link), local geo-search, save/favorite, admin verification console.
•	Success: X verified profiles onboarded in pilot markets; positive field feedback on shareability.
Phase 2 — Cropz Catalog (Knowledge + SKUs)
•	Deliverables: Product master CRUD, CSV bulk import, search/filters, recipe/content posting, link products → Cards.
•	Success: Manufacturers upload product lists; users find product information reliably.
Phase 3 — Cropz Market (Minimal viable trade)
•	Deliverables: Listing creation tied to Cropz Card & Catalog SKU, enquiry → quote flow, basic messaging, payment-link integration, rating & dispute flagging.
•	Success: First transactions completed; measurable GMV & conversion rates.
Phase 4 — Growth & Monetisation
•	Deliverables: In-app payments / escrow, logistics & invoicing integrations, premium features (analytics dashboard, priority placement), API access / data licensing, regional expansion.
•	Success: Revenue from subscriptions/listing fees/data; partnerships with distributors & industry bodies.
Phase 5 — Trust & Scale
•	Deliverables: Full KYC & certification partnerships, fraud detection, wider integrations (ERP for large distributors), multi-lingual support, offline field agent tools.
•	Success: Platform recognized as a reliable dealer master for partners; strong retention.
________________________________________
8 — Go-to-Market (GTM) plan — realistic & achievable
Primary GTM principles
•	Start hyperlocal (1–2 districts) with field pilots, iterate product with on-ground feedback.
•	Focus on trust & ease of sharing (WhatsApp + SMS are critical channels).
•	Leverage existing B2B offline networks (distributors, cooperatives, KVKs, input manufacturers).
GTM phases & tactics
1.	Pilot & validation
o	Partner with 1–2 regional input brands or cooperatives for pilot user lists and co-marketing.
o	Run field onboarding drives via sales agents or local champions to create initial Cropz Cards.
o	Host a 1-day training with dealers (how to create card, use catalog, share card).
2.	Organic growth & virality
o	Make shareable Card images & one-tap WhatsApp invites central — leverage store owners to share with peers.
o	Incentivize referrals (small credit, spotlight on platform).
3.	Channel partnerships
o	Manufacturer partnerships: allow brands to upload product SKUs and offer “verified” badges for authorised dealers.
o	Agricultural extension organizations (Krishi Vigyan Kendras), input associations for credibility.
4.	Field sales + local events
o	Deploy small field sales teams to gather local dealer data and onboard.
o	Attend regional agri trade shows, input fairs for visibility.
5.	Digital marketing & content
o	Short videos on “how to use Cropz Card” for WhatsApp & Facebook.
o	Content from agronomists (recipes) to drive retention.
6.	Monetisation
o	Freemium: basic Card and Catalog access free; paid tiers for analytics, priority listings, bulk uploads and API/data access.
o	Transaction fee or “premium listing” for marketplace sellers once Market is reliable.
Key GTM KPIs
•	Verified cropz cards created / week.
•	Conversion rate from profile view → saved contact → enquiry.
•	Cost per onboarded dealer (by channel).
•	GMV and ARPU (average revenue per user) for paying customers.
________________________________________
9 — Risks & mitigations
•	Low trust / fraud: Mitigate with verification (GST/KYC), manufacturer-backed badges and simple buyer protection (escrow later).
•	Data quality / duplicates: Build dedupe logic, allow claims/merges and human review in admin console.
•	Low digital literacy: Mobile-first UX, simplified flows, field agent onboarding, multi-lingual UI.
•	Market fragmentation: Start local and prove value before scaling; sign key brand partners to seed product data.
•	Payment & logistics complexity: Start with enquiries + payment links; integrate full payments/logistics after traction.
________________________________________
10 — Implementation & resource notes (recommended)
•	Core team: Product manager, 2 full-stack engineers (API + mobile/web), 1 mobile dev (Android), 1 QA, 1 designer, 1 growth lead, 1 field operations person for pilot.
•	Tech stack suggestions: React Native or Android native for field focus; backend API (Node/Python), Postgres, simple object store for docs, map provider (Google/OpenStreetMap).
•	Minimum legal/compliance: document storage policy, privacy policy, T&C for marketplace.
________________________________________
11 — Immediate next steps (actionable)
1.	Validate top 3 pilot partners (a regional input brand, 1-2 distributor groups or a cooperative).
2.	Run 10 field interviews with retailers & wholesalers to confirm pain points and acceptance of shareable Card.
3.	Prepare a prioritized backlog: (1) Cropz Card creation + verification, (2) Catalog search, (3) Listing/enquiry flow.
4.	Build a clickable prototype (Card creation + share) and test in the field in at least 10 shops.


 
Cropz Card — Wireframes & Interaction Specs
Document purpose: Mobile-first wireframes for the Cropz Card (the shareable, verifiable business profile). Includes screen-by-screen layouts, interaction notes, responsive variants, assets and developer handoff checklist.
________________________________________
1. Design principles
•	Mobile-first: Designed for Android devices (360–412dp width) but adaptable to web/tablet.
•	Trust & shareability: Visual verification badge and one-tap WhatsApp/SMS share are primary CTAs.
•	Low-bandwidth friendly: Minimal images, lazy-loading, and offline cache for profile view.
•	Action-oriented: Prominent contact and order CTAs (Call, WhatsApp, Enquiry).
________________________________________
2. Tokens & spacing
•	Grid: 4pt baseline grid.
•	Margins: 16pt horizontal on mobile, 24pt on tablet.
•	Touch target: min 44x44pt for interactive elements.
•	Typography (placeholders):
o	H1 / Business name: 18pt / SemiBold
o	H2 / Location & tagline: 14pt / Regular
o	Body: 13pt / Regular
o	Micro: 11pt / Regular
Color tokens (replace with brand colors later):
•	Primary: #2B7A0B (accent)
•	Surface: #FFFFFF
•	Muted text: #6B6B6B
•	Badge: #FFD700 (verified)
•	Border / divider: #E8E8E8
Icons: phone, whatsapp, map_pin, share, star, download, edit.
________________________________________
3. Screen: Cropz Card — Overview (mobile)
[TOP NAV]
•	Left: Back
•	Center: Business name (short)
•	Right: "More" menu (3-dots)
[HERO]
•	Background: optional cover photo (max 120KB, lazy load)
•	Left overlay: round Profile photo 64px (logo/shopfront)
•	Right overlay: Verified badge (small) + Manufacturer/Authorized badge if applicable
[PRIMARY INFO ROW]
•	Business name (H1)
•	Tagline / trade summary (H2)
•	Rating stars (avg. rating) + reviews count microcopy
[ACTIONS ROW — large buttons side-by-side]
•	Call (phone icon) — opens dialer
•	WhatsApp (whatsapp icon) — opens chat with prefilled message
•	Enquiry / Message (in-app messaging) — opens chat
•	Save (bookmark) — toggles saved state
[KEY DETAILS CARD — 2-column rows]
•	Left column: Address (tap opens maps), Distance from user
•	Right column: Opening hours, Govt IDs (GST masked) + small document icon if uploaded
[TABS]
•	Products | About | Reviews | Map
•	Default tab: Products (first 4 products preview)
[PRODUCT PREVIEW]
•	Horizontal carousel of product cards (thumbnail, title, price range, SKU tag) with "View all" CTA
[FOOTER]
•	Share Card (image + deep link) — primary social share
•	Report / Flag
Micro-interactions & notes:
•	Tapping profile photo opens larger image with download option.
•	Verified badge has tooltip: "GST verified on 20 Sep 2025" (example date) — shows verification source.
________________________________________
4. Screen: Cropz Card — Edit Mode
•	Header: "Edit Cropz Card" + Save CTA disabled until required fields complete.
•	Sections (collapsible): Basic info, Contact & payment, Documents, Products linked, Operating hours, Geo-location.
•	Geo pin: small map widget to drag-pin location + address auto-complete.
•	Documents: upload button (camera/choose file), small thumbnails, file size limits.
•	Save flow: client-side validation, progress indicator during upload.
________________________________________
5. Modal: Verification flow
•	States: Unverified -> Pending -> Verified
•	Unverified state CTA: "Verify now" opens modal with steps:
1.	Phone OTP (one-tap)
2.	GST upload (photo) + auto OCR extract fields
3.	Manual review note: "takes up to 24 hours"
•	Post-verified: show badge + verification metadata (date, verifier name)
Accessibility: allow skip verification but mark as unverified and show friction when interacting with buyers.
________________________________________
6. Share card export (Image + link)
•	Exported image size: 1200 x 630 (suitable for WhatsApp & social). Layout:
o	Left: shop photo or logo
o	Middle: business name, tagline, ratings
o	Right: primary contact icons (phone, WhatsApp), verification badge
o	Bottom bar: "View on Cropz" + short deep link (cropz.app/x/abcd)
•	Also provide copy text that will be auto-copied to clipboard when sharing (prefilled message template).
________________________________________
7. Screen: Product quick-view (from Card)
•	Modal overlay with SKU details: name, manufacturer (link to their Cropz Card), technical sheet (PDF link), recommended dosage/recipe, stock status (if seller supplied), "Enquire" button.
•	CTA: "Add to enquiry" or "Request quote".
________________________________________
8. Screen: Contact & Business actions
•	"Start Enquiry" opens small form: product SKUs (autocomplete), quantity, desired delivery date, notes.
•	After send: show status (Sent) + expected response time (e.g., typical reply within 24 hours).
•	Option to attach photo (field sample) in enquiry.
________________________________________
9. Microcopy examples
•	Prefill WhatsApp message: "Hi, I saw your Cropz Card — I want to enquire about [product]. Please share price & availability. — [Name | Shop]"
•	Empty state for Products tab: "No products listed. Ask this shop to add their product catalog or view their profile." + CTA: Request Product List
________________________________________
10. Responsive: Tablet / Web variations
•	Two-column layout for Web: Left column profile & hero, Right column Products & Map. Keep same visual density but increase image sizes.
•	Desktop: allow CSV upload for products and bulk edit mode in Edit screen.
________________________________________
11. Developer / Handoff notes (APIs & data model)
•	CropzCard JSON model (suggested):
{
  "id": "card_123",
  "name": "Ramesh Agro Store",
  "slug": "ramesh-agro-store-manaparai",
  "phone": "+91989876xxxx",
  "whatsapp": "+91989876xxxx",
  "gst": "33XXXXX...",
  "verified": {
    "status": "verified",
    "date": "2025-09-20",
    "method": "GST-OTP"
  },
  "products": ["sku_1","sku_2"],
  "location": {"lat": 10.90, "lng": 78.12, "address": "..."}
}
•	Endpoints to support: GET /cards/:id, POST /cards, PUT /cards/:id, POST /cards/:id/verify, GET /cards?near=..., POST /cards/:id/share
•	Suggested image assets: profile (square @2x), cover (wide @2x), share-image template (render server-side with brand token).
________________________________________
12. Accessibility & performance
•	Provide alt text for images (shopfront, logo).
•	Support screen readers for CTAs.
•	Server-side render of public profiles for link previews and SEO.
•	Lazy load product images; show skeleton placeholders on slow networks.
________________________________________
13. Handoff & deliverables
•	Provide Export: PNGs of each screen at 1x and 2x.
•	Provide a Figma/Sketch file (if requested) with components: Buttons, Badges, Product card, Share template.
•	Provide annotated specs for engineering (spacing, font sizes, tokens, component props).
________________________________________
14. Next steps (recommendations)
1.	Convert these wireframes into high-fidelity mockups for the hero Card + share flow (2 screens).
2.	Build a clickable prototype (in Figma) for field testing with 10 retailers.
3.	Implement Card creation + share image rendering first — these deliver direct value and virality.
________________________________________
End of wireframes document.

