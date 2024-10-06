// Mantine
import { Checkbox, Text, UnstyledButton } from '@mantine/core';
// Classes
import classes from './CheckboxCard.module.css';

// Interfaces
interface CheckboxCardProps {
  label: string;
  description: string;
  checked: boolean;
  onChange: (checked: boolean) => void;
}

export function CheckboxCard({ label, description, checked, onChange }: CheckboxCardProps) {
  return (
    <UnstyledButton onClick={() => onChange(!checked)} className={classes.button}>
      <Checkbox
        checked={checked}
        onChange={() => {}}
        tabIndex={-1}
        size="md"
        mr="xl"
        styles={{ input: { cursor: 'pointer' } }}
        aria-hidden
      />
      <div>
        <Text fw={500} mb={7} lh={1}>
          {label}
        </Text>
        <Text fz="sm" c="dimmed">
          {description}
        </Text>
      </div>
    </UnstyledButton>
  );
}
