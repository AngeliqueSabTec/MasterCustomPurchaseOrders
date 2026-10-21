// =====================================================================
// SupplierWorkbench — page controller for the Demo 5 custom page
// =====================================================================
// Must extend sap.fe.core.PageController, not the plain
// sap.ui.core.mvc.Controller: PageController is what actually wires in
// the Routing/InternalRouting controller extensions that bind this
// page's view to the route-matched entity instance from the target's
// "contextPath" setting in manifest.json. With the plain Controller
// base class, none of that runs — the view never gets an element
// binding at all, so every building block on the page (Form, Chart,
// Table) is left with no context to inherit: Form shows blank fields,
// Table shows its empty-filter placeholder, and Chart's own internal
// list binding, unable to resolve a parent key, sends a malformed
// request ("/Suppliers/spendByCategory" with no key segment at all),
// which the backend rejects with "Element 'ID' does not contain a
// valid UUID". None of that was a data or annotation problem.
//
// A plain mvc:View (unlike the FE-templated List Report / Object Page)
// also has nothing wired to its Back button by default — a
// controllerName and an explicit navButtonPress handler are required.
// =====================================================================

sap.ui.define([
    "sap/fe/core/PageController"
], function (PageController) {
    "use strict";

    return PageController.extend("zrd.fiori.purchaseorders.ext.controller.SupplierWorkbench", {

        onPageNavButtonPress: function () {
            window.history.back();
        }

    });
});
