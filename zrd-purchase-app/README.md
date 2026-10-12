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

All entity IDs use a `ZRD_` discipline at the conceptual level; physical IDs
are GUIDs.

---

## Prerequisites

- Node.js 18 LTS or 20 LTS
- npm 9+
- A modern browser (Chrome / Edge / Firefox)
- Optional: `@sap/cds-dk` installed globally for the `cds` CLI

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
            │   └── ObjectPageExt.js     (Demos 3 & 5)
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
- **Spend trend mini-chart in header** — `UI.DataPoint #SpendTrend` with
  `Visualization: #LineChart`, referenced from `UI.HeaderFacets`

No JavaScript. No manifest changes. Zero upgrade risk.

### Demo 3 — Custom Action with Controller Extension

The **Mark as Reviewed** button on the Object Page. Look at:

- **`app/purchaseorders/webapp/ext/controller/ObjectPageExt.js`** —
  `onMarkAsReviewed` handler. Confirms with the user, invokes the bound
  CAP action through `extensionAPI.invokeAction`, refreshes, toasts.
- **`app/purchaseorders/webapp/manifest.json`** —
  `routing.targets.PurchaseOrdersObjectPage.options.settings.
  controlConfiguration["@com.sap.vocabularies.UI.v1.Identification"]
  .actions.MarkReviewed`
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
"enabled": "{= ${Status} !== 'Reviewed' && ${Status} !== 'Draft' }"
```
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
  `UI.DataPoint #SpendTrend`, both tagged `// === Demo 4 ===`

Resize the browser — the building blocks adapt without any custom
responsive code.

### Demo 5 — Custom Page with Building Blocks

A **Supplier Workbench** page composed from filter bar, form, chart, and
table — none of which we wrote ourselves. Look at:

- **`app/purchaseorders/webapp/ext/view/SupplierWorkbench.view.xml`** —
  the custom page, composed entirely from `macros:FilterBar`,
  `macros:Form`, `macros:Chart`, `macros:Table`
- **`app/purchaseorders/webapp/manifest.json`** —
  `routing.routes` entry with pattern `supplier-workbench/{supplierId}`,
  and `routing.targets.SupplierWorkbench` with `name: sap.fe.core.fpm`
  (the FPM custom-page host)
- **`app/purchaseorders/webapp/ext/controller/ObjectPageExt.js`** —
  `onOpenSupplierWorkbench` handler navigating via
  `extensionAPI.getRouting().navigateToRoute(...)`
- **`srv/annotations.cds`** — `UI.SelectionFields`, `UI.FieldGroup
  #SupplierInfo`, `UI.Chart #SpendByCategory`, `UI.LineItem #OpenPOs`,
  all on `Suppliers`, all tagged `// === Demo 5 ===`

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
- Status values: `Draft`, `Submitted`, `Approved`, `Reviewed`, `Closed`.
  Only `Submitted` and `Approved` can be moved to `Reviewed` (see
  `srv/purchase-service.js`). `Draft` will return a 400; `Reviewed`
  will return a 409 — useful for showing both happy and error paths in
  Demo 3.
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

**`Mark as Reviewed` button is disabled on the PO I picked.** That PO is
either `Draft` (cannot be reviewed without submission) or already
`Reviewed`. Try a different PO — PO-2026-0001 (Approved) and PO-2026-0007
(Approved) are good demo targets.

**Browser shows old UI / annotations.** Hard-refresh with
`Ctrl+Shift+R` (or `Cmd+Shift+R`). The framework caches metadata
aggressively in development.

---

## Reference

Generated for the SAP Live Session transcript bundle. See
`Mastering_Custom_SAP_Fiori_Elements_Session_Transcript.docx` for the
narrative material and the corresponding slide guide for the slide deck.
