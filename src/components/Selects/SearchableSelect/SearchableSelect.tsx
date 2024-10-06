// React
import { useEffect, useState } from 'react';
// Mantine
import { Combobox, Input, InputBase, useCombobox } from '@mantine/core';
// Classes
import classes from './SearchableSelect.module.css';

// Interfaces
interface SearchableSelectProps {
  items: { label: string; value: number }[];
  selectedItem: { label: string; value: number } | null;
  setSelectedItem: (item: { label: string; value: number } | null) => void;
  placeholder?: string;
  label?: string;
}

export function SearchableSelect({
  items,
  selectedItem,
  setSelectedItem,
  placeholder,
  label,
}: SearchableSelectProps) {
  const combobox = useCombobox({
    onDropdownClose: () => combobox.resetSelectedOption(),
  });

  const [search, setSearch] = useState('');

  useEffect(() => {
    if (search === '') {
      setSelectedItem(null);
    }
  }, [search, setSelectedItem]);

  const shouldFilterOptions = items.every((item) => item.label !== search);
  const filteredOptions = shouldFilterOptions
    ? items.filter((item) => item.label.toLowerCase().includes(search.toLowerCase().trim()))
    : items;

  const options = filteredOptions.map((item) => (
    <Combobox.Option value={item.label} key={item.value}>
      {item.label}
    </Combobox.Option>
  ));

  return (
    <Input.Wrapper label={label} className={classes.wrapper}>
      <Combobox
        store={combobox}
        withinPortal={false}
        onOptionSubmit={(val) => {
          const selected = items.find((item) => item.label === val);
          if (selected) {
            setSelectedItem(selected);
            setSearch(selected.label);
            combobox.closeDropdown();
          }
        }}
      >
        <Combobox.Target>
          <InputBase
            classNames={{ input: classes.input }}
            rightSection={<Combobox.Chevron />}
            value={search}
            onChange={(event) => {
              combobox.openDropdown();
              combobox.updateSelectedOptionIndex();
              setSearch(event.currentTarget.value);
            }}
            onClick={() => combobox.openDropdown()}
            onFocus={() => combobox.openDropdown()}
            onBlur={() => {
              combobox.closeDropdown();
              setSearch(selectedItem?.label || '');
            }}
            placeholder={placeholder || 'Search an item...'}
            rightSectionPointerEvents="none"
          />
        </Combobox.Target>
        <Combobox.Dropdown>
          <Combobox.Options className={classes.options}>
            {options.length > 0 ? options : <Combobox.Empty>Nothing found</Combobox.Empty>}
          </Combobox.Options>
        </Combobox.Dropdown>
      </Combobox>
    </Input.Wrapper>
  );
}
