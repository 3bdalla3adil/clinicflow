import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

initializeApp();
const db = getFirestore();

export const createAppointment = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign-in is required.');
  const { clinicId, patientId, doctorId, serviceId, appointmentDate, startTime, endTime } = request.data ?? {};
  if (![clinicId, patientId, doctorId, serviceId, appointmentDate, startTime, endTime].every(Boolean)) {
    throw new HttpsError('invalid-argument', 'Required appointment fields are missing.');
  }
  if (patientId !== request.auth.uid && !['ADMIN', 'RECEPTION'].includes(String(request.auth.token.roleId))) {
    throw new HttpsError('permission-denied', 'You cannot create an appointment for this patient.');
  }
  const slot = `${doctorId}_${appointmentDate}_${startTime}`;
  const ref = db.collection('appointments').doc();
  await db.runTransaction(async (tx) => {
    const duplicate = await db.collection('appointments').where('slotKey', '==', slot).where('status', 'in', ['scheduled', 'checked_in', 'in_consultation']).limit(1).get();
    if (!duplicate.empty) throw new HttpsError('already-exists', 'That appointment time is no longer available.');
    tx.set(ref, { appointmentId: ref.id, clinicId, patientId, doctorId, serviceId, appointmentDate, startTime, endTime, slotKey: slot, status: 'scheduled', source: 'mobile', createdBy: request.auth.uid, createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
  });
  return { appointmentId: ref.id };
});

export const writeAuditLog = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign-in is required.');
  const { clinicId, entityType, entityId, action } = request.data ?? {};
  if (![clinicId, entityType, entityId, action].every(Boolean)) throw new HttpsError('invalid-argument', 'Audit fields are missing.');
  await db.collection('auditLogs').add({ clinicId, entityType, entityId, action, userId: request.auth.uid, actorType: request.auth.token.roleId ?? 'UNKNOWN', timestamp: FieldValue.serverTimestamp() });
  return { ok: true };
});
