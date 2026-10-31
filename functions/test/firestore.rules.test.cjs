const fs = require('node:fs');
const path = require('node:path');
const { after, before, beforeEach, test } = require('node:test');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const { doc, getDoc, setDoc, updateDoc } = require('firebase/firestore');

const projectId = 'clinicflow-rules-test';
let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '../../firestore/firestore.rules'), 'utf8'),
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const seed = [
      ['users/admin-1', { roleId: 'ADMIN', clinicId: 'clinic-a' }],
      ['users/doctor-1', { roleId: 'DOCTOR', clinicId: 'clinic-a' }],
      ['users/doctor-2', { roleId: 'DOCTOR', clinicId: 'clinic-a' }],
      ['users/reception-1', { roleId: 'RECEPTION', clinicId: 'clinic-a' }],
      ['users/patient-1', { roleId: 'PATIENT', clinicId: 'clinic-a' }],
      ['users/patient-2', { roleId: 'PATIENT', clinicId: 'clinic-a' }],
      ['clinics/clinic-a/doctors/doc-1', { userId: 'doctor-1' }],
      ['clinics/clinic-a/doctors/doc-2', { uid: 'doctor-2' }],
      ['clinics/clinic-a/appointments/assigned-1', { doctorId: 'doc-1', patientId: 'patient-1', status: 'scheduled' }],
      ['clinics/clinic-a/appointments/assigned-2', { doctorId: 'doc-2', patientId: 'patient-2', status: 'scheduled' }],
      ['clinics/clinic-a/patients/patient-1', { name: 'Patient One' }],
      ['clinics/clinic-a/consultations/consult-1', { doctorId: 'doctor-1', patientId: 'patient-1' }],
      ['clinics/clinic-a/audit_logs/audit-1', { action: 'created' }],
      ['clinics/clinic-a/payments/payment-1', { amount: 50 }],
    ];
    for (const [documentPath, data] of seed) {
      await setDoc(doc(db, documentPath), data);
    }
  });
});

const signedIn = (uid) => testEnv.authenticatedContext(uid).firestore();
const read = (db, documentPath) => getDoc(doc(db, documentPath));

test('a doctor can read an appointment assigned to their doctor record', async () => {
  await assertSucceeds(read(signedIn('doctor-1'), 'clinics/clinic-a/appointments/assigned-1'));
});

test('a doctor cannot read another doctor appointment', async () => {
  await assertFails(read(signedIn('doctor-1'), 'clinics/clinic-a/appointments/assigned-2'));
});

test('a patient can read only their own appointment', async () => {
  await assertSucceeds(read(signedIn('patient-1'), 'clinics/clinic-a/appointments/assigned-1'));
  await assertFails(read(signedIn('patient-1'), 'clinics/clinic-a/appointments/assigned-2'));
});

test('a doctor cannot read the clinic-wide patient directory', async () => {
  await assertFails(read(signedIn('doctor-1'), 'clinics/clinic-a/patients/patient-1'));
});

test('a doctor can read only consultations authored by their authenticated UID', async () => {
  await assertSucceeds(read(signedIn('doctor-1'), 'clinics/clinic-a/consultations/consult-1'));
  await assertFails(read(signedIn('doctor-2'), 'clinics/clinic-a/consultations/consult-1'));
});

test('clients cannot create or modify appointments directly', async () => {
  const db = signedIn('reception-1');
  await assertFails(setDoc(doc(db, 'clinics/clinic-a/appointments/fake'), {
    doctorId: 'doc-1', patientId: 'patient-1', status: 'scheduled',
  }));
  await assertFails(updateDoc(doc(db, 'clinics/clinic-a/appointments/assigned-1'), { status: 'checkedIn' }));
});

test('clients cannot write audit logs, payments, consultations, or slot locks', async () => {
  const db = signedIn('admin-1');
  await assertFails(setDoc(doc(db, 'clinics/clinic-a/audit_logs/fake'), { action: 'forged' }));
  await assertFails(setDoc(doc(db, 'clinics/clinic-a/payments/fake'), { amount: 999 }));
  await assertFails(setDoc(doc(db, 'clinics/clinic-a/consultations/fake'), { notes: 'forged' }));
  await assertFails(setDoc(doc(db, 'clinics/clinic-a/appointment_slots/fake'), { appointmentId: 'fake' }));
});

test('users cannot change their own role or clinic assignment', async () => {
  const db = signedIn('patient-1');
  await assertFails(updateDoc(doc(db, 'users/patient-1'), { roleId: 'ADMIN' }));
  await assertFails(updateDoc(doc(db, 'users/patient-1'), { clinicId: 'clinic-b' }));
});

test('users cannot access another clinic records', async () => {
  await assertFails(read(signedIn('doctor-1'), 'clinics/clinic-b/appointments/any'));
});

test('reception can read clinic appointments but cannot write audit records', async () => {
  const db = signedIn('reception-1');
  await assertSucceeds(read(db, 'clinics/clinic-a/appointments/assigned-1'));
  await assertFails(setDoc(doc(db, 'clinics/clinic-a/audit_logs/forged-by-reception'), { action: 'fake' }));
});


test('even clinic admins cannot bypass audited catalog callables', async () => {
  const db = signedIn('admin-1');
  await assertFails(setDoc(doc(db, 'clinics/clinic-a/doctors/new-doctor'), {
    name: 'New Doctor', specialty: 'General', durationMinutes: 30,
  }));
  await assertFails(setDoc(doc(db, 'clinics/clinic-a/services/new-service'), {
    name: 'Consultation', price: 100,
  }));
  await assertFails(updateDoc(doc(db, 'clinics/clinic-a/doctors/doc-1'), {
    specialty: 'Cardiology',
  }));
});
