// React
import { useEffect, useState } from 'react';
// Mantine
import { DatePickerInput } from '@mantine/dates';
// Classes
import classes from './DateRangePicker.module.css';
// Styles
import '@mantine/dates/styles.css';

// Interfaces
interface DateRangePickerProps {
  placeholder: string;
  minDate?: Date;
  initialRange?: [Date | null, Date | null];
  onRangeChange?: (range: [Date | null, Date | null]) => void;
  startDateLabel?: string;
  endDateLabel?: string;
  startDatePlaceholder?: string;
  endDatePlaceholder?: string;
}

export function DateRangePicker({
  minDate,
  initialRange = [null, null],
  onRangeChange,
  startDateLabel = 'Start date',
  endDateLabel = 'End date',
  startDatePlaceholder = 'Start date',
  endDatePlaceholder = 'End date',
}: DateRangePickerProps) {
  const [startDate, setStartDate] = useState<Date | null>(initialRange[0]);
  const [endDate, setEndDate] = useState<Date | null>(initialRange[1]);

  useEffect(() => {
    if (onRangeChange) {
      onRangeChange([startDate, endDate]);
    }
  }, [startDate, endDate, onRangeChange]);

  const handleStartDateChange = (date: Date | null) => {
    setStartDate(date);
    // Make sure end date is not before start date
    if (endDate && date && date > endDate) {
      setEndDate(date);
    }
  };

  const handleEndDateChange = (date: Date | null) => {
    // If start date is set and end date is before start date, set end date to start date
    if (startDate && date && date < startDate) {
      setEndDate(startDate);
    } else {
      setEndDate(date);
    }
  };

  return (
    <div className={classes.container}>
      <DatePickerInput
        className={classes.input}
        label={startDateLabel}
        placeholder={startDatePlaceholder}
        value={startDate}
        onChange={handleStartDateChange}
        minDate={minDate}
        clearable
      />
      <DatePickerInput
        className={classes.input}
        label={endDateLabel}
        placeholder={endDatePlaceholder}
        value={endDate}
        onChange={handleEndDateChange}
        minDate={startDate || minDate}
        clearable
      />
    </div>
  );
}
