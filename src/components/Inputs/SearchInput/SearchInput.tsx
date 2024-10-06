// Icons
import { IconSearch } from '@tabler/icons-react';
// Mantine
import { CloseButton, Input } from '@mantine/core';
// Classes
import classes from './SearchInput.module.css';

// Interfaces
interface SearchInputProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  label?: string;
}

export function SearchInput({ value, onChange, placeholder, label }: SearchInputProps) {
  return (
    <Input.Wrapper label={label} className={classes.wrapper}>
      <Input
        className={classes.input}
        placeholder={placeholder || 'Search...'}
        value={value}
        onChange={(event) => onChange(event.currentTarget.value)}
        leftSection={<IconSearch size={16} />}
        rightSectionPointerEvents="all"
        rightSection={
          <CloseButton
            aria-label="Clear input"
            onClick={() => onChange('')}
            style={{ display: value ? undefined : 'none' }}
          />
        }
      />
    </Input.Wrapper>
  );
}
