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
//                    Criticality on supplier name, header DataPoint
//                    visualisation #LineChart.
// Demo 3 — Custom action: UI.Identification.actions entry for
//                    MarkReviewed (referenced from manifest).
// Demo 4 — Custom section: FieldGroup #VendorSummary, DataPoint
//                    #SpendTrend — consumed by the SpendAnalytics
//                    fragment.
// Demo 5 — Custom page (Supplier Workbench): SelectionFields, Chart
//                    #SpendByCategory, FieldGroup #SupplierInfo,
//                    LineItem #OpenPOs on Suppliers and related
//                    entities.
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

  // === Demo 2: DataPoint with #LineChart for the Object Page header ===
  // === Demo 4: Same DataPoint reused inside the SpendAnalytics fragment ===
  UI.DataPoint #SpendTrend: {
    Value         : totalAmount,
    Title         : 'Spend Trend',
    Visualization : #LineChart
  },

  // === Demo 2: HeaderFacets — adds the SpendTrend mini-chart to header ===
  UI.HeaderFacets: [
    { $Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#SpendTrend', Label: 'Spend Trend' }
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

  // === Demo 1: Identification (used by the floorplan for header actions) ===
  // === Demo 3: MarkReviewed action is referenced from manifest.json
  //            controlConfiguration. The annotation here exists so the
  //            framework knows the action exists; the press handler is
  //            wired in the manifest.
  UI.Identification: [
    { $Type: 'UI.DataField',      Value: orderNo, Label: 'Order #' },
    { $Type: 'UI.DataFieldForAction',
      Action: 'PurchaseService.markAsReviewed',
      Label:  'Mark as Reviewed',
      Inline: false                                                 }, // DEMO 3
    { $Type: 'UI.DataFieldForIntentBasedNavigation',                  // DEMO 5
      SemanticObject: 'Supplier',
      Action: 'workbench',
      Label: 'Open Supplier Workbench' }
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

  // === Demo 5: filter bar on the Supplier Workbench page ===
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
  UI.Chart #SpendByCategory: {
    Title              : 'Spend by Category',
    ChartType          : #Column,
    Measures           : [ spendByCategory.amount ],
    MeasureAttributes  : [
      { $Type: 'UI.ChartMeasureAttributeType',
        Measure: spendByCategory.amount,
        Role: #Axis1 }
    ],
    Dimensions         : [ spendByCategory.category ],
    DimensionAttributes: [
      { $Type: 'UI.ChartDimensionAttributeType',
        Dimension: spendByCategory.category,
        Role: #Category }
    ]
  },

  // === Demo 5: LineItem for the OpenPOs table on the workbench ===
  UI.LineItem #OpenPOs: [
    { $Type: 'UI.DataField', Value: purchaseOrders.orderNo,     Label: 'Order #' },
    { $Type: 'UI.DataField', Value: purchaseOrders.orderDate,   Label: 'Order Date' },
    { $Type: 'UI.DataField', Value: purchaseOrders.totalAmount, Label: 'Total' },
    { $Type: 'UI.DataField', Value: purchaseOrders.status,      Label: 'Status',
      Criticality: purchaseOrders.statusCriticality                              }
  ]
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

annotate PurchaseService.SupplierSpendByCategory with {
  category @title: 'Category';
  amount   @title: 'Amount';
};

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
