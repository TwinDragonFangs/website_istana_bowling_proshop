const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// ==========================
// 1. ORDER CREATED → NOTIF ADMIN
// ==========================
exports.onOrderCreate = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snap, context) => {
    const order = snap.data();

    const adminUsers = await admin.firestore()
      .collection("users")
      .where("role", "==", "admin")
      .get();

    const tokens = [];

    adminUsers.forEach(doc => {
      const data = doc.data();
      if (data.fcmToken) {
        tokens.push(data.fcmToken);
      }
    });

    if (tokens.length === 0) return;

    const message = {
      notification: {
        title: "Pesanan Baru",
        body: `${order.customerName} membuat pesanan baru`,
      },
      data: {
        type: "order",
        orderId: context.params.orderId,
      },
      tokens: tokens,
    };

    await admin.messaging().sendMulticast(message);
  });


// ==========================
// 2. ORDER STATUS UPDATE → NOTIF USER
// ==========================
exports.onOrderUpdate = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {

    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status) return;

    const userSnap = await admin.firestore()
      .collection("users")
      .where("email", "==", after.customerEmail)
      .limit(1)
      .get();

    if (userSnap.empty) return;

    const user = userSnap.docs[0].data();

    if (!user.fcmToken) return;

    const message = {
      notification: {
        title: "Update Pesanan",
        body: `Status pesanan Anda: ${after.status}`,
      },
      data: {
        type: "order",
        orderId: context.params.orderId,
      },
      token: user.fcmToken,
    };

    await admin.messaging().send(message);
  });