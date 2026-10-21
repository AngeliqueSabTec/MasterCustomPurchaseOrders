// =====================================================================
// PurchaseService implementation
// =====================================================================
// Most of this service is CRUD that CAP serves automatically from the
// projections in purchase-service.cds. The only custom logic is the
// bound action used by Demo 3 (the "Mark as Reviewed" custom action on
// the Object Page).
// =====================================================================

const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

  const { PurchaseOrders } = this.entities;

  // -------------------------------------------------------------------
  // DEMO 3 — bound action: markAsReviewed
  // -------------------------------------------------------------------
  // Flips status to 'Reviewed' and updates criticality to 3 (green).
  // Returns the updated PurchaseOrder so the UI can rebind without an
  // extra round-trip. The same effect could be achieved client-side
  // by setting status/statusCriticality from the controller extension,
  // but routing through a service action is preferred — see Anti-
  // Pattern 10.5 in the session transcript ("business logic in the
  // controller extension").
  // -------------------------------------------------------------------
  this.on('markAsReviewed', PurchaseOrders, async (req) => {
    const { ID } = req.params[req.params.length - 1];
    const po = await SELECT.one.from(PurchaseOrders).where({ ID });

    if (!po) {
      return req.error(404, `Purchase order ${ID} not found.`);
    }
    if (po.status === 'Reviewed') {
      return req.error(409, `Purchase order ${po.orderNo} is already Reviewed.`);
    }
    if (po.status !== 'Submitted') {
      return req.error(400, `Purchase order ${po.orderNo} must be Submitted before it can be reviewed.`);
    }

    await UPDATE(PurchaseOrders, ID).with({
      status: 'Reviewed',
      statusCriticality: 3
    });

    return await SELECT.one.from(PurchaseOrders).where({ ID });
  });

});
