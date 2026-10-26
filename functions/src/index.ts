import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

initializeApp();
const db = getFirestore();

type StaffRole = 'ADMIN' | 'RECEPTION' | 'DOCTOR' | 'ACCOUNTANT' | 'PATIENT';

async function getActor(uid: string): Promise<{ role: StaffRole; clinicId: string }> {
  const snap = await db.collection('users').doc(uid).get();
  if (!snap.exists) throw new HttpsError('failed-precondition', 'Your ClinicFlow profile is not provisioned.');
  const data = snap.data()!;
  const role = String(data.roleId ?? data.role ?? 'PATIENT').toUpperCase() as StaffRole;
  const clinicId = String(data.clinicId ?? '');
  if (!clinicId) throw new HttpsError('failed-precondition', 'Your account is not assigned to a clinic.');
  return { role, clinicId };
}

function requireRole(role: StaffRole, allowed: StaffRole[]) {
  if (!allowed.includes(role)) throw new HttpsError('permission-denied', 'Your role cannot perform this action.');
}

function required(value: unknown, name: string): string {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new HttpsError('invalid-argument', `${name} is required.`);
  }
  return value.trim();
}

/** All bookings go through this transaction; clients cannot self-assign a clinic or patient. */
export const createAppointment = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign-in is required.');
  const actor = await getActor(request.auth.uid);
  const clinicId = required(request.data?.clinicId, 'clinicId');
  const patientId = required(request.data?.patientId, 'patientId');
  const doctorId = required(request.data?.doctorId, 'doctorId');
  const serviceId = required(request.data?.serviceId, 'serviceId');
  const appointmentDate = required(request.data?.appointmentDate, 'appointmentDate');
  const startTime = required(request.data?.startTime, 'startTime');
  const endTime = required(request.data?.endTime, 'endTime');

  if (clinicId !== actor.clinicId) throw new HttpsError('permission-denied', 'Clinic scope mismatch.');
  if (actor.role === 'PATIENT' && patientId !== request.auth.uid) {
    throw new HttpsError('permission-denied', 'Patients can only book for themselves.');
  }
  requireRole(actor.role, ['ADMIN', 'RECEPTION', 'PATIENT']);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(appointmentDate) ||
      !/^([01]\d|2[0-3]):[0-5]\d$/.test(startTime) ||
      !/^([01]\d|2[0-3]):[0-5]\d$/.test(endTime) || endTime <= startTime) {
    throw new HttpsError('invalid-argument', 'Date or appointment time is invalid.');
  }

  const clinic = db.collection('clinics').doc(clinicId);
  const doctorRef = clinic.collection('doctors').doc(doctorId);
  const serviceRef = clinic.collection('services').doc(serviceId);
  const appointments = clinic.collection('appointments');
  const appointmentRef = appointments.doc();
  const slotKey = `${doctorId}_${appointmentDate}_${startTime.replace(':', '')}`;
  const slotRef = clinic.collection('appointment_slots').doc(slotKey);
  const userRef = db.collection('users').doc(patientId);

  await db.runTransaction(async (tx) => {
    const [doctorSnap, serviceSnap, patientSnap, slotSnap] = await Promise.all([
      tx.get(doctorRef), tx.get(serviceRef), tx.get(userRef), tx.get(slotRef),
    ]);
    if (!doctorSnap.exists) throw new HttpsError('not-found', 'Doctor was not found in this clinic.');
    if (!serviceSnap.exists) throw new HttpsError('not-found', 'Service was not found in this clinic.');
    if (!patientSnap.exists) throw new HttpsError('not-found', 'Patient profile was not found.');
    if (slotSnap.exists) {
      const previousId = String(slotSnap.data()?.appointmentId ?? '');
      const previous = previousId ? await tx.get(appointments.doc(previousId)) : null;
      const previousStatus = String(previous?.data()?.status ?? '');
      if (previous?.exists && !['cancelled', 'completed', 'noShow'].includes(previousStatus)) {
        throw new HttpsError('already-exists', 'That appointment time is no longer available.');
      }
    }
    const doctor = doctorSnap.data()!;
    const service = serviceSnap.data()!;
    const date = new Date(`${appointmentDate}T00:00:00.000Z`);
    tx.set(appointmentRef, {
      appointmentId: appointmentRef.id,
      number: `APT-${appointmentDate.replaceAll('-', '')}-${appointmentRef.id.slice(0, 6).toUpperCase()}`,
      clinicId, patientId, doctorId, serviceId, doctor, service,
      date, appointmentDate, startTime, endTime, slotKey,
      status: 'scheduled', source: 'mobile', createdBy: request.auth!.uid,
      createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp(),
    });
    tx.set(slotRef, { appointmentId: appointmentRef.id, appointmentDate, startTime, doctorId, updatedAt: FieldValue.serverTimestamp() });
    tx.set(clinic.collection('audit_logs').doc(), {
      clinicId, entityType: 'appointment', entityId: appointmentRef.id, action: 'created',
      actorId: request.auth!.uid, timestamp: FieldValue.serverTimestamp(),
    });
  });
  return { appointmentId: appointmentRef.id };
});

const TRANSITIONS: Record<string, string[]> = {
  scheduled: ['checkedIn', 'cancelled', 'noShow'],
  checkedIn: ['inConsultation', 'cancelled'],
  inConsultation: ['completed'],
  completed: [], cancelled: [], noShow: [],
};

export const updateAppointmentStatus = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign-in is required.');
  const actor = await getActor(request.auth.uid);
  const clinicId = required(request.data?.clinicId, 'clinicId');
  const appointmentId = required(request.data?.appointmentId, 'appointmentId');
  const nextStatus = required(request.data?.status, 'status');
  if (clinicId !== actor.clinicId) throw new HttpsError('permission-denied', 'Clinic scope mismatch.');
  requireRole(actor.role, ['ADMIN', 'RECEPTION', 'DOCTOR']);
  if (!Object.hasOwn(TRANSITIONS, nextStatus)) throw new HttpsError('invalid-argument', 'Unknown appointment status.');
  if (actor.role === 'RECEPTION' && ['inConsultation', 'completed'].includes(nextStatus)) {
    throw new HttpsError('permission-denied', 'Reception cannot change clinical status.');
  }
  if (actor.role === 'DOCTOR' && !['inConsultation', 'completed'].includes(nextStatus)) {
    throw new HttpsError('permission-denied', 'Doctors can only manage consultation status.');
  }
  const ref = db.collection('clinics').doc(clinicId).collection('appointments').doc(appointmentId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError('not-found', 'Appointment not found.');
    const current = String(snap.data()?.status ?? 'scheduled');
    if (!TRANSITIONS[current]?.includes(nextStatus)) {
      throw new HttpsError('failed-precondition', `Cannot move an appointment from ${current} to ${nextStatus}.`);
    }
    tx.update(ref, { status: nextStatus, updatedAt: FieldValue.serverTimestamp(), updatedBy: request.auth!.uid });
    tx.set(db.collection('clinics').doc(clinicId).collection('audit_logs').doc(), {
      clinicId, entityType: 'appointment', entityId: appointmentId,
      action: `status:${current}->${nextStatus}`, actorId: request.auth!.uid,
      timestamp: FieldValue.serverTimestamp(),
    });
  });
  return { ok: true };
});

export const saveConsultation = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign-in is required.');
  const actor = await getActor(request.auth.uid);
  requireRole(actor.role, ['ADMIN', 'DOCTOR']);
  const clinicId = required(request.data?.clinicId, 'clinicId');
  const appointmentId = required(request.data?.appointmentId, 'appointmentId');
  const notes = required(request.data?.notes, 'notes');
  if (clinicId !== actor.clinicId) throw new HttpsError('permission-denied', 'Clinic scope mismatch.');
  const clinic = db.collection('clinics').doc(clinicId);
  const appointmentRef = clinic.collection('appointments').doc(appointmentId);
  const consultationRef = clinic.collection('consultations').doc(appointmentId);
  await db.runTransaction(async (tx) => {
    const appointment = await tx.get(appointmentRef);
    if (!appointment.exists) throw new HttpsError('not-found', 'Appointment not found.');
    if (!['checkedIn', 'inConsultation'].includes(String(appointment.data()?.status))) {
      throw new HttpsError('failed-precondition', 'The patient must be checked in before a consultation is recorded.');
    }
    tx.set(consultationRef, {
      clinicId, appointmentId, patientId: appointment.data()?.patientId,
      doctorId: request.auth!.uid, notes, diagnosis: String(request.data?.diagnosis ?? ''),
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    tx.set(clinic.collection('audit_logs').doc(), {
      clinicId, entityType: 'consultation', entityId: appointmentId,
      action: 'saved', actorId: request.auth!.uid, timestamp: FieldValue.serverTimestamp(),
    });
  });
  return { ok: true };
});

export const recordPayment = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign-in is required.');
  const actor = await getActor(request.auth.uid);
  requireRole(actor.role, ['ADMIN', 'RECEPTION', 'ACCOUNTANT']);
  const clinicId = required(request.data?.clinicId, 'clinicId');
  const appointmentId = required(request.data?.appointmentId, 'appointmentId');
  const amount = Number(request.data?.amount);
  const method = required(request.data?.method, 'method');
  if (clinicId !== actor.clinicId) throw new HttpsError('permission-denied', 'Clinic scope mismatch.');
  if (!Number.isFinite(amount) || amount <= 0) throw new HttpsError('invalid-argument', 'Payment amount must be positive.');
  if (!['cash', 'card', 'insurance', 'transfer'].includes(method)) throw new HttpsError('invalid-argument', 'Unsupported payment method.');
  const clinic = db.collection('clinics').doc(clinicId);
  const appointmentRef = clinic.collection('appointments').doc(appointmentId);
  const paymentRef = clinic.collection('payments').doc();
  await db.runTransaction(async (tx) => {
    const appointment = await tx.get(appointmentRef);
    if (!appointment.exists) throw new HttpsError('not-found', 'Appointment not found.');
    tx.set(paymentRef, {
      paymentId: paymentRef.id, clinicId, appointmentId,
      patientId: appointment.data()?.patientId, amount, method, status: 'recorded',
      recordedBy: request.auth!.uid, createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(clinic.collection('audit_logs').doc(), {
      clinicId, entityType: 'payment', entityId: paymentRef.id, action: 'recorded',
      actorId: request.auth!.uid, timestamp: FieldValue.serverTimestamp(),
    });
  });
  return { paymentId: paymentRef.id };
});

export const writeAuditLog = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign-in is required.');
  const actor = await getActor(request.auth.uid);
  const clinicId = required(request.data?.clinicId, 'clinicId');
  const entityType = required(request.data?.entityType, 'entityType');
  const entityId = required(request.data?.entityId, 'entityId');
  const action = required(request.data?.action, 'action');
  if (clinicId !== actor.clinicId) throw new HttpsError('permission-denied', 'Clinic scope mismatch.');
  await db.collection('clinics').doc(clinicId).collection('audit_logs').add({
    clinicId, entityType, entityId, action, actorId: request.auth.uid,
    timestamp: FieldValue.serverTimestamp(),
  });
  return { ok: true };
});
