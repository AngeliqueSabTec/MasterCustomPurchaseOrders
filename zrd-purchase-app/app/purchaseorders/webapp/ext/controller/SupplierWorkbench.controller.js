// =====================================================================
// SupplierWorkbench — page controller for the Demo 5 custom page
// =====================================================================
// A plain mvc:View (unlike the FE-templated List Report / Object Page)
// has nothing wired to its Back button by default — a controllerName
// and an explicit navButtonPress handler are required.
// =====================================================================

sap.ui.define([
    "sap/ui/core/mvc/Controller"
], function (Controller) {
    "use strict";

    return Controller.extend("zrd.fiori.purchaseorders.ext.controller.SupplierWorkbench", {

        onNavBack: function () {
            window.history.back();
        }

    });
});
