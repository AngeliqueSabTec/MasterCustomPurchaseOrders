// =====================================================================
// UI Annotations for the Purchasing Fiori Elements demo
// =====================================================================
// This file is the "final state" version of the annotations after all
// demos have been applied. Inline comments mark which demo introduced
// each block.
//
// Demo 1 — Baseline: HeaderInfo, basic LineItem, FieldGroup,
//                    SelectionFields, Identification, Facets.
// Demo 2 — Annotation-only customization: DeliveryDate column,
//                    Criticality on supplier name, header UI.Chart
//                    (#Line) trend mini-chart.
// Demo 3 — Custom action: MarkReviewed is a header action registered
//                    in manifest.json's content.header.actions.
// Demo 4 — Custom section: FieldGroup #VendorSummary, DataPoint
//                    #SpendTrend — consumed by the SpendAnalytics
//                    fragment.
// Demo 5 — Custom page (Supplier Workbench): SelectionFields, Chart
//                    #SpendByCategory, FieldGroup #SupplierInfo on
//                    Suppliers; LineItem #OpenPOs on PurchaseOrders,
//                    reached through the purchaseOrders association.
// =====================================================================

using PurchaseService from './purchase-service';

// ---------------------------------------------------------------------
// PurchaseOrders — header, list, object page
// ---------------------------------------------------------------------
annotate PurchaseService.PurchaseOrders with @(

  // === Demo 1: Header ===
  UI.HeaderInfo: {
    TypeName       : 'Purchase Order',
    TypeNamePlural : 'Purchase Orders',
    Title          : { Value: orderNo },
    Description    : { Value: supplier.name }
  },

  // === Demo 1: LineItem (List Report table) ===
  // === Demo 2: Added DeliveryDate; added Criticality on Supplier ===
  UI.LineItem: [
    { $Type: 'UI.DataField', Value: orderNo,           Label: 'Order #' },
    { $Type: 'UI.DataField', Value: supplier.name,     Label: 'Supplier',
      Criticality: supplier.riskCriticality                              }, // DEMO 2
    { $Type: 'UI.DataField', Value: orderDate,         Label: 'Order Date' },
    { $Type: 'UI.DataField', Value: deliveryDate,      Label: 'Delivery Date' }, // DEMO 2
    { $Type: 'UI.DataField', Value: totalAmount,       Label: 'Total' },
    { $Type: 'UI.DataField', Value: status,            Label: 'Status',
      Criticality: statusCriticality                                     }
  ],

  // === Demo 1: SelectionFields (filter bar) ===
  UI.SelectionFields: [ supplier_ID, status, orderDate ],

  // === Demo 1: FieldGroup for general information ===
  UI.FieldGroup #GeneralInformation: {
    Data: [
      { $Type: 'UI.DataField', Value: orderNo,      Label: 'Order #' },
      { $Type: 'UI.DataField', Value: orderDate,    Label: 'Order Date' },
      { $Type: 'UI.DataField', Value: deliveryDate, Label: 'Delivery Date' },
      { $Type: 'UI.DataField', Value: status,       Label: 'Status',
        Criticality: statusCriticality                                   },
      { $Type: 'UI.DataField', Value: totalAmount,  Label: 'Total' },
      { $Type: 'UI.DataField', Value: notes,        Label: 'Notes' }
    ]
  },

  // === Demo 4: FieldGroup for vendor summary, consumed by SpendAnalytics fragment ===
  UI.FieldGroup #VendorSummary: {
    Data: [
      { $Type: 'UI.DataField', Value: supplier.name,              Label: 'Supplier' },
      { $Type: 'UI.DataField', Value: supplier.country,           Label: 'Country' },
      { $Type: 'UI.DataField', Value: supplier.industry,          Label: 'Industry' },
      { $Type: 'UI.DataField', Value: supplier.onTimeDeliveryPct, Label: 'On-Time Delivery %' },
      { $Type: 'UI.DataField', Value: supplier.paymentTerms,      Label: 'Payment Terms' }
    ]
  },

  // === Demo 2: UI.Chart (#Line) for the Object Page header mini-chart,
  // and Demo 4's #SpendTrendDetail for the SpendAnalytics section ===
  // A UI.DataPoint cannot use Visualization: #LineChart (not a valid
  // value) — a trend line needs a UI.Chart over a to-many time series.
  //
  // Both qualifiers are declared below on SupplierSpendHistory itself
  // (the supplierHistory association's target), not here on
  // PurchaseOrders with dotted Measures/Dimensions. The macros:Chart
  // building block (used by SupplierWorkbench's #SpendByCategory)
  // tolerates navigation-qualified Measures from the root entity, but
  // macros:MicroChart does not: it resolves Measures/Dimensions against
  // whatever entity type contextPath/metaPath currently points at, so a
  // dotted path like `supplierHistory.amount` doesn't resolve to a
  // property and the building block silently renders an invisible
  // placeholder (no console error) instead of a chart. Same restriction
  // applies to a UI.Chart consumed via UI.HeaderFacets — its Target
  // must include the navigation segment for the same reason. See
  // `annotate PurchaseService.SupplierSpendHistory` below.

  // === Demo 2: HeaderFacets — adds the SpendTrend mini-chart to header ===
  UI.HeaderFacets: [
    { $Type: 'UI.ReferenceFacet', Target: 'supplierHistory/@UI.Chart#SpendTrend', Label: 'Spend Trend' }
  ],

  // === Demo 1: Object Page body facets ===
  // === Demo 4: SpendAnalytics section is registered in manifest.json,
  //            not here — sections added via custom fragments live in
  //            the manifest's content.body.sections structure.
  UI.Facets: [
    { $Type: 'UI.ReferenceFacet',
      ID:     'GeneralInformationFacet',
      Label:  'General Information',
      Target: '@UI.FieldGroup#GeneralInformation' },
    { $Type: 'UI.ReferenceFacet',
      ID:     'ItemsFacet',
      Label:  'Items',
      Target: 'items/@UI.LineItem' }
  ],

  // === Demo 1: Identification ===
  // === Demo 3 & 5: Mark as Reviewed / Open Supplier Workbench are
  //            registered as header actions in manifest.json's
  //            content.header.actions, not here — an action defined in
  //            both places renders twice.
  UI.Identification: [
    { $Type: 'UI.DataField', Value: orderNo, Label: 'Order #' }
  ],

  // === Demo 5: LineItem for the Supplier Workbench's "Open Purchase
  // Orders" table. A table row template needs plain properties of its
  // own entity — not a to-many association's fields inlined as if they
  // were scalars (that was the original, invalid version of this
  // annotation, defined on Suppliers using purchaseOrders.orderNo etc).
  // The table instead binds through the to-many path itself via
  // metaPath="purchaseOrders/@UI.LineItem#OpenPOs" in the view. ===
  UI.LineItem #OpenPOs: [
    { $Type: 'UI.DataField', Value: orderNo,     Label: 'Order #' },
    { $Type: 'UI.DataField', Value: orderDate,   Label: 'Order Date' },
    { $Type: 'UI.DataField', Value: totalAmount, Label: 'Total' },
    { $Type: 'UI.DataField', Value: status,      Label: 'Status',
      Criticality: statusCriticality                              }
  ]
);

// ---------------------------------------------------------------------
// Items — LineItem for the Object Page items facet (Demo 1)
// ---------------------------------------------------------------------
annotate PurchaseService.Items with @(
  UI.LineItem: [
    { $Type: 'UI.DataField', Value: itemNo,             Label: 'Item #' },
    { $Type: 'UI.DataField', Value: material.materialNo, Label: 'Material #' },
    { $Type: 'UI.DataField', Value: material.description, Label: 'Description' },
    { $Type: 'UI.DataField', Value: quantity,           Label: 'Quantity' },
    { $Type: 'UI.DataField', Value: unitPrice,          Label: 'Unit Price' },
    { $Type: 'UI.DataField', Value: lineTotal,          Label: 'Line Total' }
  ]
);

annotate PurchaseService.Items with {
  parent   @title: 'Purchase Order';
  material @title: 'Material';
};

// ---------------------------------------------------------------------
// Suppliers — annotations to drive Demo 5 (Supplier Workbench page)
// ---------------------------------------------------------------------
annotate PurchaseService.Suppliers with @(

  UI.HeaderInfo: {
    TypeName       : 'Supplier',
    TypeNamePlural : 'Suppliers',
    Title          : { Value: name },
    Description    : { Value: industry }
  },

  // === Demo 5: kept for Suppliers metadata completeness. Not consumed
  // by a FilterBar on the Workbench page — see SupplierWorkbench.view.xml. ===
  UI.SelectionFields: [ country, industry, riskRating ],

  // === Demo 5: FieldGroup for the Supplier info form ===
  UI.FieldGroup #SupplierInfo: {
    Data: [
      { $Type: 'UI.DataField', Value: name,              Label: 'Name' },
      { $Type: 'UI.DataField', Value: country,           Label: 'Country' },
      { $Type: 'UI.DataField', Value: industry,          Label: 'Industry' },
      { $Type: 'UI.DataField', Value: riskRating,        Label: 'Risk Rating',
        Criticality: riskCriticality                                      },
      { $Type: 'UI.DataField', Value: paymentTerms,      Label: 'Payment Terms' },
      { $Type: 'UI.DataField', Value: onTimeDeliveryPct, Label: 'On-Time Delivery %' },
      { $Type: 'UI.DataField', Value: spendAmount,       Label: 'Total Spend' }
    ]
  },

  // === Demo 5: Chart annotation for the SpendByCategory chart ===
  // Was declared here with dotted Measures/Dimensions through the
  // spendByCategory association (Measures: [spendByCategory.amount]) —
  // compiled and rendered fine, but CAP's SQLite $apply engine rejects
  // the resulting query at runtime: "$expand is not yet supported.
  // Dimension: spendByCategory/category from an association cannot be
  // used" — a hard error that took the whole Supplier Workbench page
  // down with it (Supplier Details form and Open POs table too, not
  // just the chart). Moved to PurchaseService.SupplierSpendByCategory
  // below with plain properties, same fix as UI.Chart #SpendTrend /
  // #SpendTrendDetail on SupplierSpendHistory.
);

annotate PurchaseService.Suppliers with {
  name              @title: 'Name';
  country           @title: 'Country';
  industry          @title: 'Industry';
  riskRating        @title: 'Risk Rating';
  paymentTerms      @title: 'Payment Terms';
  onTimeDeliveryPct @title: 'On-Time Delivery %';
  spendAmount       @title: 'Total Spend';
};

// macros:Chart aggregates its measure via OData $apply — the measure
// property needs to be flagged as an analytical measure, or the chart
// building block has nothing to group/sum.
annotate PurchaseService.SupplierSpendByCategory with {
  category @title: 'Category';
  amount   @title: 'Amount' @Analytics.Measure: true @Aggregation.default: #SUM;
};

// Same requirement as SupplierSpendHistory below: macros:Chart (used by
// SupplierWorkbench.view.xml's #SpendByCategory) hard-errors the whole
// page without this — "ApplySupported is not added to the annotations".
// Also publishes Org.OData.Aggregation.V1.CustomAggregate for amount
// (@Aggregation.default alone doesn't), and the UI.Chart itself — moved
// here from Suppliers with plain Measures/Dimensions; see the comment
// on Suppliers.UI.Chart's old location for why.
annotate PurchaseService.SupplierSpendByCategory with @(
  Aggregation.CustomAggregate #amount: 'Edm.Decimal',
  Aggregation.ApplySupported: {
    Transformations        : [ 'aggregate', 'groupby', 'filter' ],
    Rollup                 : #None,
    PropertyRestrictions   : true,
    GroupableProperties    : [ category ],
    AggregatableProperties : [ { Property: amount } ]
  },
  UI.Chart #SpendByCategory: {
    Title              : 'Spend by Category',
    ChartType          : #Column,
    Measures           : [ amount ],
    MeasureAttributes  : [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: amount, Role: #Axis1 }
    ],
    Dimensions         : [ category ],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: category, Role: #Category }
    ]
  }
);

annotate PurchaseService.SupplierSpendHistory with {
  period @title: 'Period';
  amount @title: 'Amount' @Analytics.Measure: true @Aggregation.default: #SUM;
};

// CAP doesn't publish Org.OData.Aggregation.V1.CustomAggregate from
// @Aggregation.default alone — without it, a client's bare
// `aggregate(amount)` (no explicit "with sum as") 400s with "Result type
// for custom aggregation of property not found". Declared explicitly so
// that shorthand resolves instead of silently failing.
annotate PurchaseService.SupplierSpendHistory with @(
  Aggregation.CustomAggregate #amount: 'Edm.Decimal'
);

// macros:Chart (used below for #SpendTrendDetail) refuses to render at
// all — a hard error, not a silent fallback like MicroChart — unless
// the entity set declares Aggregation.ApplySupported. Without this, the
// whole Object Page fails to load: "Error creating content for building
// block sap.fe.macros.Chart ... ApplySupported is not added to the
// annotations".
annotate PurchaseService.SupplierSpendHistory with @(
  Aggregation.ApplySupported: {
    Transformations        : [ 'aggregate', 'groupby', 'filter' ],
    Rollup                 : #None,
    PropertyRestrictions   : true,
    GroupableProperties    : [ period ],
    AggregatableProperties : [ { Property: amount } ]
  }
);

// Demo 2 header mini-chart (#SpendTrend) and Demo 4 section chart
// (#SpendTrendDetail, distinct qualifier — reusing one qualifier across
// both controls on the same page renders duplicate control IDs).
// Declared here, on the association target, with plain Measures/
// Dimensions — see the comment on PurchaseOrders.UI.HeaderFacets for why.
annotate PurchaseService.SupplierSpendHistory with @(
  // macros:MicroChart (unlike macros:Chart) resolves each measure's
  // DataPoint to decide how/whether to render it — a MeasureAttributes
  // entry with only a Role and no DataPoint reference leaves the
  // building block nothing to bind the value to, and it renders an
  // invisible placeholder instead of the chart, with no console error.
  UI.DataPoint #SpendTrendAmount: {
    Value: amount
  },
  UI.Chart #SpendTrend: {
    ChartType : #Line,
    Title     : 'Spend Trend',
    Measures  : [ amount ],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: amount, Role: #Axis1,
        DataPoint: '@UI.DataPoint#SpendTrendAmount' }
    ],
    Dimensions: [ period ],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: period, Role: #Category }
    ]
  },
  UI.Chart #SpendTrendDetail: {
    ChartType : #Line,
    Title     : 'Spend Trend',
    Measures  : [ amount ],
    MeasureAttributes: [
      { $Type: 'UI.ChartMeasureAttributeType', Measure: amount, Role: #Axis1,
        DataPoint: '@UI.DataPoint#SpendTrendAmount' }
    ],
    Dimensions: [ period ],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType', Dimension: period, Role: #Category }
    ]
  }
);

annotate PurchaseService.PurchaseOrders with {
  orderNo      @title: 'Order #';
  orderDate    @title: 'Order Date';
  deliveryDate @title: 'Delivery Date';
  supplier     @title: 'Supplier';
  status       @title: 'Status';
  totalAmount  @title: 'Total';
  currency     @title: 'Currency';
  notes        @title: 'Notes';
};
