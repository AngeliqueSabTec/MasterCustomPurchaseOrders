// =====================================================================
// ObjectPageExt — custom action handlers for the Purchase Order Object Page
// =====================================================================
// Referenced by manifest.json's content.header.actions[...].press as
// "zrd.fiori.purchaseorders.ext.controller.ObjectPageExt.<method>".
//
// This is a PLAIN module, not a ControllerExtension. sap.fe.core's
// FPMHelper is what actually dispatches a "press" string like this one:
// it loads the module with a bare sap.ui.require (dotted path -> slashes
// -> ".js", no ".controller" suffix — different from how a real
// sap.ui.core.mvc.Controller/ControllerExtension module is resolved),
// then calls `loadedModule[method].bind(extensionAPI)(oBindingContext,
// aSelectedContexts, listBinding)`. So:
//   - `this` is the page's ExtensionAPI, not a ControllerExtension — there
//     is no `this.base`. editFlow/routing come from
//     this.getEditFlow()/this.getRouting() instead.
//   - the current binding context arrives as the first parameter; no
//     need to look it up via extensionAPI.
//
//   onMarkAsReviewed       — DEMO 3 — invoked by the "Mark as Reviewed"
//                            custom action. Confirms with the user,
//                            calls the bound CAP action, shows feedback.
//
//   onOpenSupplierWorkbench — DEMO 5 — invoked by the "Open Supplier
//                            Workbench" custom action. Reads the
//                            supplier ID from the current binding
//                            context and navigates to the FPM custom
//                            page.
//
// Business logic stays on the server (the CAP markAsReviewed action).
// This module's job is UX — confirmation, feedback, navigation.
// =====================================================================

sap.ui.define([
    "sap/m/MessageBox",
    "sap/m/MessageToast"
], function (MessageBox, MessageToast) {
    "use strict";

    return {

        // -------------------------------------------------------------
        // DEMO 3 — custom action handler
        // -------------------------------------------------------------
        onMarkAsReviewed: function (oBindingContext) {
            const oExtensionAPI = this;

            if (!oBindingContext) {
                MessageBox.error("No purchase order context available.");
                return;
            }

            const sOrderNo = oBindingContext.getProperty("orderNo");

            MessageBox.confirm(
                "Mark PO " + sOrderNo + " as Reviewed?",
                {
                    title: "Confirm Review",
                    onClose: function (sAction) {
                        if (sAction !== MessageBox.Action.OK) {
                            return;
                        }

                        oExtensionAPI.getEditFlow().invokeAction(
                            "PurchaseService.markAsReviewed",
                            { contexts: oBindingContext }
                        ).then(function () {
                            MessageToast.show("PO " + sOrderNo + " marked as Reviewed");
                        }).catch(function (oErr) {
                            const sMsg = (oErr && oErr.message) || "Action failed.";
                            MessageBox.error(sMsg);
                        });
                    }
                }
            );
        },

        // -------------------------------------------------------------
        // DEMO 5 — navigate to the Supplier Workbench custom page
        // -------------------------------------------------------------
        onOpenSupplierWorkbench: function (oBindingContext) {
            if (!oBindingContext) {
                MessageBox.error("No purchase order context available.");
                return;
            }

            // Read through the "supplier" navigation property, not the raw
            // supplier_ID scalar: the object page never displays supplier_ID
            // directly (only supplier.name/.country/... via the expanded
            // navigation), so OData V4's autoExpandSelect never fetches
            // that scalar and getProperty("supplier_ID") comes back
            // undefined even though every order genuinely has a supplier.
            // An expanded navigation entity's key is always included,
            // regardless of $select, so supplier/ID is reliably present.
            const sSupplierId = oBindingContext.getProperty("supplier/ID");
            if (!sSupplierId) {
                MessageBox.warning("This purchase order has no supplier assigned.");
                return;
            }

            // Navigate to the FPM custom page registered in manifest.json
            // under routing.targets.SupplierWorkbench. The route pattern
            // is "Suppliers({key})" so FE can bind the page's context
            // straight from the URL.
            this.getRouting().navigateToRoute("SupplierWorkbench", {
                key: sSupplierId
            });
        }

    };
});
