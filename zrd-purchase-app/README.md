# Mastering Custom SAP Fiori Elements — Demo Bundle

A complete CAP + Fiori Elements V4 demo project for the SAP Live Session
**Mastering Custom SAP Fiori Elements: From Standard Templates to Advanced
Extensions & Custom Pages**.

This project represents the *final state* of all six demos applied on top of
a baseline List Report / Object Page. Inline comments in every file mark
which demo introduced which piece, so the instructor can either:

1. Use it as a finished reference (run it once, walk attendees through the
   structure), or
2. Use it as a backup solution while building the same app live in front of
   attendees, scaffolding from blank during Demo 1 and layering on the
   pieces demo by demo.

---

## Domain

A simplified Purchasing model:

- **Suppliers** — vendor master with risk rating, payment terms, on-time
  delivery, and total spend
- **Materials** — material master across five categories (Raw Materials,
  Electronics, Components, Tools, Packaging)
- **PurchaseOrders** — header table with status, delivery date, and a
  composition of items
- **Items** — line items referencing a material
- **SupplierSpendByCategory** — pre-aggregated table for the chart on the
  Supplier Workbench page
- **SupplierSpendHistory** — monthly spend per supplier, feeding the
  Spend Trend mini-chart (header facet and Demo 4 section)

All entity IDs use a `ZRD_` discipline at the conceptual level; physical IDs
are GUIDs.

---

## Prerequisites

- Node.js 18 LTS or 20 LTS
- npm 9+
- A modern browser (Chrome / Edge / Firefox)
- Optional: `@sap/cds-dk` installed globally for the `cds` CLI
- **If this folder lives on a deeply nested path** (e.g. under a long
  OneDrive path), `npm install` can fail compiling `better-sqlite3`
  because the build's intermediate paths exceed Windows' 260-character
  limit. Easiest fix: run `npm install` from a short path — e.g. map a
  drive letter with `subst Z: "<repo root>"` and `cd` there first — but
  then run `cds watch`/`cds serve` from the **real, non-substituted**
  path afterwards. Running the server itself from a `subst`'d drive
  makes `cds` see the project's `db/data` folder under two different
  path strings (the substituted one from `cwd`, the real one from
  resolved module paths) and deploy every seed CSV twice, which fails
  with `ENTITY_ALREADY_EXISTS`. `node_modules` built via the short path
  still work fine once you `cd` back to the real path to run the
  server — only `npm install`'s native build needs the short path.

```bash
npm install -g @sap/cds-dk
```

---

## Running the project

```bash
# 1. Install root dependencies (CAP + SQLite)
npm install

# 2. Install the UI app dependencies
cd app/purchaseorders
npm install
cd ../..

# 3. Run everything with one command (CAP + watch + auto-open UI)
cds watch
```

The CAP server starts on `http://localhost:4004`. The Fiori Elements app is
served from `http://localhost:4004/purchaseorders/webapp/index.html`. The
service metadata is available at `http://localhost:4004/purchase/$metadata`.

> **Note:** the project uses an in-memory SQLite database by default, so
> data resets on every restart. CSVs under `db/data/` are loaded
> automatically on startup.

---

## Project layout

```
zrd-purchase-app/
├── package.json                 CAP project + dependencies
├── .cdsrc.json                  CAP runtime config
├── db/
│   ├── schema.cds               Data model
│   └── data/                    Seed CSVs (Suppliers, Materials, POs, Items, Spend)
├── srv/
│   ├── purchase-service.cds     Service definition with markAsReviewed action
│   ├── purchase-service.js      Handler for markAsReviewed
│   └── annotations.cds          ALL UI annotations (commented per demo)
└── app/purchaseorders/
    ├── package.json
    ├── ui5.yaml
    └── webapp/
        ├── manifest.json        Manifest with FE configuration & extensions
        ├── Component.js
        ├── index.html
        ├── i18n/i18n.properties
        └── ext/
            ├── controller/
            │   ├── ObjectPageExt.controller.js     (Demos 3 & 5)
            │   └── SupplierWorkbench.controller.js (Demo 5 — back nav)
            └── view/
                ├── SpendAnalytics.fragment.xml   (Demo 4)
                └── SupplierWorkbench.view.xml    (Demo 5)
```

---

## Demo-by-demo: where to look

### Demo 1 — Baseline List Report / Object Page

A vanilla LR / OP generated from annotations. Look at:

- **`db/schema.cds`** — the data model
- **`srv/purchase-service.cds`** — the OData V4 service
- **`srv/annotations.cds`** — the `UI.HeaderInfo`, `UI.LineItem`,
  `UI.FieldGroup #GeneralInformation`, `UI.SelectionFields`,
  `UI.Identification`, `UI.Facets` blocks marked `=== Demo 1 ===`
- **`app/purchaseorders/webapp/manifest.json`** — the `routing.targets`
  for `PurchaseOrdersList` and `PurchaseOrdersObjectPage`

Run `cds watch`, open the app, filter, sort, navigate to an Object Page.
Everything you see is annotation-driven.

### Demo 2 — Annotation-Only Customization

Three pure annotation changes. Look at the blocks tagged `// DEMO 2`:

- **DeliveryDate column** — extra `UI.DataField` inside `UI.LineItem` on
  `PurchaseOrders`
- **Risk-indicator criticality** — `Criticality: supplier.riskCriticality`
  on the supplier name `UI.DataField`
- **Spend trend mini-chart in header** — `UI.Chart #SpendTrend`
  (`ChartType: #Line`) over the `supplierHistory` association,
  referenced from `UI.HeaderFacets`. (A `UI.DataPoint` cannot use
  `Visualization: #LineChart` — that value doesn't exist.)

No JavaScript. No manifest changes. Zero upgrade risk.

### Demo 3 — Custom Action with Controller Extension

The **Mark as Reviewed** button on the Object Page. Look at:

- **`app/purchaseorders/webapp/ext/controller/ObjectPageExt.controller.js`**
  — `onMarkAsReviewed` handler. Confirms with the user, invokes the bound
  CAP action through `this.base.editFlow.invokeAction` (`extensionAPI`
  has no `invokeAction` method), toasts. `editFlow` refreshes the bound
  context itself.
- **`app/purchaseorders/webapp/manifest.json`** —
  `routing.targets.PurchaseOrdersObjectPage.options.settings.
  content.header.actions.MarkReviewed` (header actions are registered
  under `content.header.actions`, not `controlConfiguration`)
- **`app/purchaseorders/webapp/manifest.json`** —
  `sap.ui5.extends.extensions.sap.ui.controllerExtensions.
  "sap.fe.templates.ObjectPage.ObjectPageController"`
  registers the extension
- **`srv/purchase-service.cds`** — the `action markAsReviewed() returns
  PurchaseOrders;` declaration
- **`srv/purchase-service.js`** — the action handler (server-side logic;
  see anti-pattern 10.5 in the transcript)

The action's `enabled` expression in the manifest:
```
"enabled": "{= %{status} === 'Submitted' }"
```
Expression bindings for manifest-configured actions read the metadata
model via `%{...}`, not the regular `${...}` instance-model syntax, and
the property name is lower-case (`status`), matching the CDS element.
Declarative UI state — no imperative code needed to keep the button in
sync with the entity.

### Demo 4 — Custom Section with Building Blocks

A **Spend Analytics** section on the Object Page using `macros:MicroChart`
and `macros:Form`. Look at:

- **`app/purchaseorders/webapp/ext/view/SpendAnalytics.fragment.xml`** —
  the fragment, under fifteen lines of meaningful content
- **`app/purchaseorders/webapp/manifest.json`** —
  `content.body.sections.SpendAnalytics` registers the fragment with
  `placement: After, anchor: GeneralInformationFacet`
- **`srv/annotations.cds`** — `UI.FieldGroup #VendorSummary` and
  `UI.Chart #SpendTrendDetail`, both tagged `// === Demo 4 ===`. A
  separate qualifier from the header facet's `#SpendTrend` — reusing one
  chart's metaPath in two controls on the same page renders a duplicate
  control ID.

Resize the browser — the building blocks adapt without any custom
responsive code.

### Demo 5 — Custom Page with Building Blocks

A **Supplier Workbench** page composed from form, chart, and table —
none of which we wrote ourselves. Look at:

- **`app/purchaseorders/webapp/ext/view/SupplierWorkbench.view.xml`** —
  the custom page, composed from `macros:Form`, `macros:Chart`,
  `macros:Table`. No `macros:FilterBar`: the page is already scoped to
  one supplier via navigation, and a FilterBar-connected table queries
  its whole entity set rather than following that navigation. The view
  also needs its own `controllerName` + `navButtonPress` handler for
  the Back button — a plain `mvc:View` has nothing wired to it by
  default, unlike the FE-templated List Report / Object Page.
- **`app/purchaseorders/webapp/ext/controller/SupplierWorkbench.controller.js`**
  — `onNavBack` for that Back button.
- **`app/purchaseorders/webapp/manifest.json`** —
  `routing.routes` entry with pattern `Suppliers({key})`, and
  `routing.targets.SupplierWorkbench` with `name: sap.fe.core.fpm`
  (the FPM custom-page host). The route must resolve to an actual
  entity-key pattern so FE can bind the page's context from the URL.
- **`app/purchaseorders/webapp/ext/controller/ObjectPageExt.controller.js`**
  — `onOpenSupplierWorkbench` handler navigating via
  `this.base.routing.navigateToRoute("SupplierWorkbench", { key: ... })`
  (`extensionAPI` has no `getRouting` method — `routing`, like
  `editFlow`, is its own built-in controller extension).
- **`srv/annotations.cds`** — `UI.SelectionFields`, `UI.FieldGroup
  #SupplierInfo`, `UI.Chart #SpendByCategory` on `Suppliers`, and
  `UI.LineItem #OpenPOs` on `PurchaseOrders` (a table row template
  needs plain properties of its own entity, not a to-many association's
  fields inlined as scalars — the table instead binds through the
  association itself via `metaPath="purchaseOrders/@UI.LineItem#OpenPOs"`).
  All tagged `// === Demo 5 ===`.

Navigate: List Report → PO Object Page → click **Open Supplier
Workbench** → custom page renders. Same app, same model, no glue code.

### Demo 6 — Adaptation Project Pattern

Conceptual / structural — this bundle does not include a separate
Adaptation Project (that is a session of its own). In the live demo,
scaffold an Adaptation Project from the SAP Build Code template, open
the `manifest.appdescr_variant`, walk the `changes` array, and point at
where a fragment / controller extension would live in
`webapp/changes/`. The same FPM concepts apply; only the wrapper
differs.

---

## Notes for the instructor

- The CSV data set is deliberately small and varied so that filtering,
  criticality, and the chart all show meaningful colour even with only
  five suppliers and twenty purchase orders.
- Status values: `New`, `Submitted`, `Approved`, `Reviewed`, `Closed`.
  (Named `New` rather than `Draft` — this entity is also
  `@odata.draft.enabled`, and a business status literally called
  "Draft" next to OData draft documents invites confusion.) Only
  `Submitted` can be moved to `Reviewed` (see `srv/purchase-service.js`
  and the manifest's `enabled` expression). Anything else returns 400;
  an already-`Reviewed` PO returns 409 — useful for showing both happy
  and error paths in Demo 3.
- The `riskCriticality` field is pre-set in the CSV (1/2/3) rather than
  computed. This is intentional — the demo is about UI customization,
  not about CDS computed properties. In a real project this would be a
  CDS `virtual` field or a function in the service handler.
- All extension code lives under `webapp/ext/`. No code anywhere else
  in the app. This is the discipline that makes upgrades trivial.

---

## Troubleshooting

**`cds watch` fails with a database error.** Make sure root `npm install`
completed; `@cap-js/sqlite` is the dev-dependency that provides the
in-memory SQLite engine.

**The Fiori Elements app loads but shows no data.** Visit the service
metadata at `http://localhost:4004/purchase/$metadata` and confirm the
service is up. Then visit `http://localhost:4004/purchase/PurchaseOrders`
to confirm the seed data loaded.

**`Mark as Reviewed` button is disabled on the PO I picked.** The button
only enables when status is `Submitted`. Try a different PO —
PO-2026-0003 and PO-2026-0009 (both `Submitted`) are good demo targets.

**`$apply` aggregation (the macros:Chart building blocks in Demos 4/5)
returns a parse error.** `@sap/cds ^7` (this project's original pin)
has broken `aggregate(...)` support in its SQLite service — `groupby`
alone works, any `aggregate(...)` form doesn't, regardless of syntax.
`package.json` now pins `@sap/cds ^9` / `@sap/cds-dk ^9` /
`@cap-js/sqlite ^2` (matching the `cds 9.9.3` baseline this bundle was
actually tested against) — verified working via a direct `$apply=
groupby((category),aggregate(amount with sum as total))` call.

**Browser shows old UI / annotations.** Hard-refresh with
`Ctrl+Shift+R` (or `Cmd+Shift+R`). The framework caches metadata
aggressively in development.

---

## Reference

Generated for the SAP Live Session transcript bundle. See
`Mastering_Custom_SAP_Fiori_Elements_Session_Transcript.docx` for the
narrative material and the corresponding slide guide for the slide deck.
