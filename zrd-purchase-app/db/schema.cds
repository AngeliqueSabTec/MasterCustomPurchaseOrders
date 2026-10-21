namespace zrd.purchasing;

aspect cuid {
  key ID : UUID;
}

aspect managed {
  createdAt  : Timestamp @cds.on.insert: $now;
  createdBy  : String(255) @cds.on.insert: $user;
  modifiedAt : Timestamp @cds.on.insert: $now @cds.on.update: $now;
  modifiedBy : String(255) @cds.on.insert: $user @cds.on.update: $user;
}



/**
 * Suppliers — the vendor master for the demo. Includes risk rating which
 * is used by Demo 2 to drive criticality on the supplier name in the
 * List Report table.
 */
entity Suppliers : cuid, managed {
  name              : String(100);
  country           : String(2);                  // ISO-2 country code
  industry          : String(50);
  riskRating        : Integer;                    // 1 (low) .. 5 (high)
  riskCriticality   : Integer;                    // 1=neg(red), 2=warn(amber), 3=ok(green), 0=neutral
  paymentTerms      : String(20);
  onTimeDeliveryPct : Decimal(5,2);
  spendAmount       : Decimal(15,2);
  spendCurrency     : String(3);
  purchaseOrders    : Association to many PurchaseOrders on purchaseOrders.supplier = $self;
  spendByCategory   : Association to many SupplierSpendByCategory on spendByCategory.supplier = $self;
}

entity Materials : cuid, managed {
  materialNo  : String(20);
  description : String(200);
  category    : String(50);
  unitPrice   : Decimal(13,2);
  currency    : String(3);
  uom         : String(3);
}

/**
 * PurchaseOrders — the central transactional entity. Status field is the
 * one Demo 3 flips to 'Reviewed' via the custom action (only from
 * 'Submitted' — see srv/purchase-service.js); statusCriticality drives
 * the colour of the status field on the List Report (Demo 2). The value
 * 'New' (not 'Draft') is used deliberately — this entity is also
 * @odata.draft.enabled, and a business status literally called "Draft"
 * would be confusing next to OData draft documents.
 */
entity PurchaseOrders : cuid, managed {
  orderNo            : String(20);
  orderDate          : Date;
  deliveryDate       : Date;
  supplier           : Association to Suppliers;
  // Direct association to the same supplier's spend history, correlated
  // through `supplier` rather than navigated as supplier.spendHistory.
  // The chart annotations need a single-hop to-many path — a two-hop
  // path (to-one then to-many) makes CDS auto-expose a second, redundant
  // projection of the target entity, which then gets its CSV seed data
  // deployed twice and fails with ENTITY_ALREADY_EXISTS.
  supplierHistory    : Association to many SupplierSpendHistory on supplierHistory.supplier = supplier;
  status             : String(20) default 'New'; // New | Submitted | Approved | Reviewed | Closed
  statusCriticality  : Integer;                    // 1=neg, 2=warn, 3=ok, 0=neutral
  totalAmount        : Decimal(15,2);
  currency           : String(3);
  notes              : String(500);
  items              : Composition of many Items on items.parent = $self;
}

entity Items : cuid {
  parent     : Association to PurchaseOrders;
  itemNo     : Integer;
  material   : Association to Materials;
  quantity   : Decimal(13,3);
  unitPrice  : Decimal(13,2);
  lineTotal  : Decimal(15,2);
  currency   : String(3);
}

/**
 * SupplierSpendByCategory — pre-aggregated table used by the chart on the
 * Supplier Workbench custom page (Demo 5). Materialised this way to keep
 * the demo simple and avoid runtime aggregation magic.
 */
entity SupplierSpendByCategory : cuid {
  supplier : Association to Suppliers;
  category : String(50);
  amount   : Decimal(15,2);
  currency : String(3);
}

/**
 * SupplierSpendHistory — monthly spend per supplier, feeding the
 * UI.Chart #SpendTrend / #SpendTrendDetail line charts (Demo 2 header
 * mini-chart and Demo 4 section chart). A UI.DataPoint cannot use
 * Visualization: #LineChart (not a valid value) — a trend line needs a
 * UI.Chart over a to-many time series instead.
 */
entity SupplierSpendHistory : cuid {
  supplier : Association to Suppliers;
  period   : String(7);   // 'YYYY-MM'
  amount   : Decimal(15,2);
  currency : String(3);
}
