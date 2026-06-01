const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();


// =============================
// 1. NOTIF KE ADMIN (ORDER BARU)
// =============================
exports.notifyAdminNewOrder = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snap) => {

    const order = snap.data();

    const admins = await admin.firestore()
      .collection("users")
      .where("role", "==", "admin")
      .get();

    const tokens = admins.docs
      .map(d => d.data().fcmToken)
      .filter(Boolean);

    if (tokens.length === 0) return;

    return admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: "🛒 Order Baru Masuk",
        body: `${order.customerName} melakukan pemesanan`,
      },
      webpush: {
        notification: {
          icon: "https://your-domain.com/logo-ibp.png",
          requireInteraction: true
        }
      }
    });
  });


// =====================================
// 2. NOTIF KE USER (STATUS BERUBAH)
// =====================================
exports.notifyUserStatusUpdate = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change) => {

    const before = change.before.data();
    const after = change.after.data();

    // hanya jika status berubah
    if (before.status === after.status) return;

    const userSnap = await admin.firestore()
      .collection("users")
      .where("email", "==", after.customerEmail)
      .get();

    if (userSnap.empty) return;

    const user = userSnap.docs[0].data();
    const token = user.fcmToken;

    if (!token) return;

    return admin.messaging().send({
      token,
      notification: {
        title: "📦 Status Pesanan Update",
        body: `Status: ${after.status}`,
      },
      webpush: {
        notification: {
          icon: "https://your-domain.com/logo-ibp.png",
          requireInteraction: true
        }
      }
    });
  });