const test = require('node:test');
const assert = require('node:assert/strict');
const {
  buildAvailableSlots,
  isInsideSchedule,
  scheduleForDate,
} = require('../lib/scheduling.js');

const doctor = {
  durationMinutes: 30,
  slotIntervalMinutes: 15,
  weeklySchedule: [
    { dayOfWeek: 0, startTime: '09:00', endTime: '10:30' },
    { dayOfWeek: 1, startTime: '13:00', endTime: '15:00' },
  ],
};

test('uses Sunday-based weekday numbering for weekly schedules', () => {
  assert.deepEqual(scheduleForDate(doctor, '2026-11-01'), [
    { startTime: '09:00', endTime: '10:30' },
  ]);
});

test('date overrides replace weekly hours and empty overrides close the day', () => {
  const custom = {
    ...doctor,
    scheduleOverrides: {
      '2026-11-01': [{ startTime: '11:00', endTime: '12:00' }],
      '2026-11-08': [],
    },
  };
  assert.deepEqual(scheduleForDate(custom, '2026-11-01'), [
    { startTime: '11:00', endTime: '12:00' },
  ]);
  assert.deepEqual(scheduleForDate(custom, '2026-11-08'), []);
});

test('doctor leave overrides the weekly schedule', () => {
  assert.deepEqual(scheduleForDate({
    ...doctor,
    leaveDates: ['2026-11-01'],
  }, '2026-11-01'), []);
});

test('availability respects appointment duration and slot interval', () => {
  assert.deepEqual(
    buildAvailableSlots(doctor, '2026-11-01', 30, 15, []),
    [
      { startTime: '09:00', endTime: '09:30', durationMinutes: 30 },
      { startTime: '09:15', endTime: '09:45', durationMinutes: 30 },
      { startTime: '09:30', endTime: '10:00', durationMinutes: 30 },
      { startTime: '09:45', endTime: '10:15', durationMinutes: 30 },
      { startTime: '10:00', endTime: '10:30', durationMinutes: 30 },
    ],
  );
});

test('availability excludes overlapping bookings and elapsed times', () => {
  const slots = buildAvailableSlots(
    doctor,
    '2026-11-01',
    30,
    15,
    [{ start: 9 * 60 + 30, end: 10 * 60 }],
    9 * 60,
  );
  assert.deepEqual(slots.map((slot) => slot.startTime), ['10:00']);
});

test('booking validation rejects times outside published hours or interval boundaries', () => {
  assert.equal(isInsideSchedule(doctor, '2026-11-01', '09:15', '09:45'), true);
  assert.equal(isInsideSchedule(doctor, '2026-11-01', '09:10', '09:40'), false);
  assert.equal(isInsideSchedule(doctor, '2026-11-01', '10:15', '10:45'), false);
});
