// =====================================================================
// ObjectPageExt — Controller extension for the Purchase Order Object Page
// =====================================================================
// Two custom handlers live here:
//
//   onMarkAsReviewed       — DEMO 3 — invoked by the "Mark as Reviewed"
//                            custom action defined in manifest.json.
//                            Confirms with the user, calls the bound
//                            CAP action, refreshes, shows feedback.
//
//   onOpenSupplierWorkbench — DEMO 5 — invoked by the "Open Supplier
//                            Workbench" custom action. Reads the
//                            supplier ID from the current binding
//                            context and navigates to the FPM custom
//                            page.
//
// Notes for trainees:
//   - this.base.getExtensionAPI() reads floorplan state (binding
//     context, etc). this.base.editFlow and this.base.routing are
//     separate built-in controller extensions FE mixes into every page
//     controller — that's where invokeAction/navigateToRoute live.
//     extensionAPI itself has neither method.
//   - We never reach into the DOM. The framework owns rendering.
//   - Business logic stays on the server (the CAP markAsReviewed
//     action). The controller's job is UX — confirmation, feedback.
// =====================================================================

sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension",
    "sap/m/MessageBox",
    "sap/m/MessageToast"
], function (ControllerExtension, MessageBox, MessageToast) {
    "use strict";

    return ControllerExtension.extend("zrd.fiori.purchaseorders.ext.controller.ObjectPageExt", {

        // -------------------------------------------------------------
        // DEMO 3 — custom action handler
        // -------------------------------------------------------------
        onMarkAsReviewed: function () {
            const oExtAPI  = this.base.getExtensionAPI();
            const oContext = oExtAPI.getBindingContext();
            const that     = this;

            if (!oContext) {
                MessageBox.error("No purchase order context available.");
                return;
            }

            const sOrderNo = oContext.getProperty("orderNo");

            MessageBox.confirm(
                "Mark PO " + sOrderNo + " as Reviewed?",
                {
                    title: "Confirm Review",
                    onClose: function (sAction) {
                        if (sAction !== MessageBox.Action.OK) {
                            return;
                        }

                        // extensionAPI has no invokeAction method — bound/unbound
                        // actions are invoked through the editFlow controller
                        // extension, which FE mixes into every page controller
                        // as this.base.editFlow.
                        that.base.editFlow.invokeAction(
                            "PurchaseService.markAsReviewed",
                            { contexts: oContext }
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
        onOpenSupplierWorkbench: function () {
            const oExtAPI  = this.base.getExtensionAPI();
            const oContext = oExtAPI.getBindingContext();

            if (!oContext) {
                MessageBox.error("No purchase order context available.");
                return;
            }

            const sSupplierId = oContext.getProperty("supplier_ID");
            if (!sSupplierId) {
                MessageBox.warning("This purchase order has no supplier assigned.");
                return;
            }

            // Navigate to the FPM custom page registered in manifest.json
            // under routing.targets.SupplierWorkbench. The route pattern
            // is "Suppliers({key})" so FE can bind the page's context
            // straight from the URL. extensionAPI has no getRouting()
            // method — routing is its own built-in controller extension,
            // mixed into the page controller as this.base.routing, same
            // pattern as this.base.editFlow.
            this.base.routing.navigateToRoute("SupplierWorkbench", {
                key: sSupplierId
            });
        }

    });
});
