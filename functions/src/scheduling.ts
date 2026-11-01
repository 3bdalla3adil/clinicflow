export interface ScheduleWindow {
  startTime: string;
  endTime: string;
}

export interface OccupiedInterval {
  start: number;
  end: number;
}

export interface AvailableSlot {
  startTime: string;
  endTime: string;
  durationMinutes: number;
}

export function timeToMinutes(value: string): number {
  const match = /^([01]\d|2[0-3]):([0-5]\d)$/.exec(value);
  if (!match) throw new RangeError('Time must use HH:mm 24-hour format.');
  return Number(match[1]) * 60 + Number(match[2]);
}

export function scheduleForDate(
  doctor: Record<string, any>,
  date: string,
): ScheduleWindow[] {
  const override = doctor.scheduleOverrides?.[date];
  if (Array.isArray(override)) {
    return override.map((entry: Record<string, unknown>) => ({
      startTime: String(entry.startTime ?? ''),
      endTime: String(entry.endTime ?? ''),
    }));
  }
  if (Array.isArray(doctor.leaveDates) && doctor.leaveDates.includes(date)) return [];
  const dayOfWeek = new Date(`${date}T00:00:00.000Z`).getUTCDay();
  if (!Array.isArray(doctor.weeklySchedule)) return [];
  return doctor.weeklySchedule
    .filter((entry: Record<string, unknown>) => Number(entry.dayOfWeek) === dayOfWeek)
    .map((entry: Record<string, unknown>) => ({
      startTime: String(entry.startTime ?? ''),
      endTime: String(entry.endTime ?? ''),
    }));
}

export function isInsideSchedule(
  doctor: Record<string, any>,
  date: string,
  startTime: string,
  endTime: string,
): boolean {
  let start: number;
  let end: number;
  try {
    start = timeToMinutes(startTime);
    end = timeToMinutes(endTime);
  } catch {
    return false;
  }
  const interval = Number(doctor.slotIntervalMinutes ?? 15);
  if (!Number.isInteger(interval) || interval < 5 || interval > 120) return false;
  return scheduleForDate(doctor, date).some((window) => {
    try {
      const windowStart = timeToMinutes(window.startTime);
      const windowEnd = timeToMinutes(window.endTime);
      return windowEnd > windowStart &&
        start >= windowStart &&
        end <= windowEnd &&
        end > start &&
        (start - windowStart) % interval === 0;
    } catch {
      return false;
    }
  });
}

export function buildAvailableSlots(
  doctor: Record<string, any>,
  date: string,
  durationMinutes: number,
  intervalMinutes: number,
  occupied: OccupiedInterval[],
  notBeforeMinute = -1,
): AvailableSlot[] {
  if (!Number.isInteger(durationMinutes) || durationMinutes < 5 || durationMinutes > 480) {
    throw new RangeError('Appointment duration must be between 5 and 480 minutes.');
  }
  if (!Number.isInteger(intervalMinutes) || intervalMinutes < 5 || intervalMinutes > 120) {
    throw new RangeError('Slot interval must be between 5 and 120 minutes.');
  }
  const format = (minutes: number) =>
    `${String(Math.floor(minutes / 60)).padStart(2, '0')}:${String(minutes % 60).padStart(2, '0')}`;
  const slots: AvailableSlot[] = [];
  for (const window of scheduleForDate(doctor, date)) {
    let windowStart: number;
    let windowEnd: number;
    try {
      windowStart = timeToMinutes(window.startTime);
      windowEnd = timeToMinutes(window.endTime);
    } catch {
      continue;
    }
    if (windowEnd <= windowStart) continue;
    for (let start = windowStart; start + durationMinutes <= windowEnd; start += intervalMinutes) {
      const end = start + durationMinutes;
      if (start <= notBeforeMinute) continue;
      if (occupied.some((booking) => start < booking.end && booking.start < end)) continue;
      slots.push({ startTime: format(start), endTime: format(end), durationMinutes });
    }
  }
  return slots;
}
