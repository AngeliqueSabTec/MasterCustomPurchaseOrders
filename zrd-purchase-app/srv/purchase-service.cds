using { zrd.purchasing as my } from '../db/schema';

service PurchaseService @(path: '/purchase') {

  @odata.draft.enabled
  entity PurchaseOrders as projection on my.PurchaseOrders actions {
    // DEMO 3 — bound action invoked from the custom "Mark as Reviewed" button.
    // Same action could be wired straight into UI.Identification.actions and
    // rendered automatically without any manifest entry. We expose it here so
    // the controller extension can also invoke it programmatically.
    action markAsReviewed() returns PurchaseOrders;
  };

  entity Items     as projection on my.Items;
  entity Suppliers as projection on my.Suppliers;
  entity Materials as projection on my.Materials;
  entity SupplierSpendByCategory as projection on my.SupplierSpendByCategory;
  entity SupplierSpendHistory as projection on my.SupplierSpendHistory;
}
