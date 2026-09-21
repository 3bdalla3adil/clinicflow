/* Run only against an emulator or explicitly selected development project. */
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

if (process.env.NODE_ENV === 'production' || !process.env.FIREBASE_PROJECT_ID) {
  throw new Error('Refusing to seed: set a non-production FIREBASE_PROJECT_ID explicitly.');
}
initializeApp({ projectId: process.env.FIREBASE_PROJECT_ID });
const db = getFirestore();
const clinic = { clinicId: 'CLINIC-001', name: 'ClinicFlow Medical Center', code: 'CFMC', currency: 'USD', timezone: 'UTC', active: true, isDemo: true };
const doctors = [
  { doctorId: 'DOC-001', name: 'Dr. Sara Ahmed', specialty: 'General Medicine', appointmentDurationMinutes: 30, active: true, isDemo: true },
  { doctorId: 'DOC-002', name: 'Dr. Mohamed Ali', specialty: 'Dermatology', appointmentDurationMinutes: 30, active: true, isDemo: true },
  { doctorId: 'DOC-003', name: 'Dr. Huda Osman', specialty: 'Dental', appointmentDurationMinutes: 45, active: true, isDemo: true },
];
const services = [
  { serviceId: 'SERVICE-001', name: 'General Consultation', code: 'GEN', durationMinutes: 30, price: 35, active: true, isDemo: true },
  { serviceId: 'SERVICE-002', name: 'Dermatology Consultation', code: 'DERM', durationMinutes: 30, price: 50, active: true, isDemo: true },
  { serviceId: 'SERVICE-003', name: 'Dental Consultation', code: 'DENT', durationMinutes: 45, price: 60, active: true, isDemo: true },
];
(async () => {
  const batch = db.batch();
  batch.set(db.doc('clinics/CLINIC-001'), clinic, { merge: true });
  doctors.forEach(x => batch.set(db.doc(`doctors/${x.doctorId}`), { ...x, clinicId: 'CLINIC-001' }, { merge: true }));
  services.forEach(x => batch.set(db.doc(`services/${x.serviceId}`), { ...x, clinicId: 'CLINIC-001' }, { merge: true }));
  await batch.commit();
  console.log('Seeded demo clinic, doctors, and services only.');
})();
