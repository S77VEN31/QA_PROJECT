;
// Icons
import { IconCurrencyCent } from '@tabler/icons-react';

// Mantine
import { NumberInput } from '@mantine/core';

// Interfaces
interface NumInputProps {
  value: number;
  onChange: (value: number) => void;
  placeholder?: string;
  label?: string;
}

export function NumInput({ value, onChange, placeholder, label }: NumInputProps) {
  return (
    <NumberInput
      value={value}
      label={label}
      placeholder={placeholder || 'Ingrese un número...'}
      leftSection={<IconCurrencyCent size={16} />}
      allowDecimal={false}
      allowNegative={false}
      onChange={(value) => {
        if (typeof value === 'number') {
          onChange(value);
        }
      }}
    />
  );
}